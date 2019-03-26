final int MIN_GENERATOR_COUNT = 2;
final int MAX_GENERATOR_COUNT = 4;

class Model {  
  public Model() {
    _turnEndTime = 0;
    
    _generators = new Generator[MAX_GENERATOR_COUNT];
    _oldDataPackets = new ArrayList<ArrayList<GeneratorState>>();
    for (int i = 0; i < _generators.length; ++i) {
      _generators[i] = new Generator();
      _oldDataPackets.add(new ArrayList<GeneratorState>());
    }
    
    pieceState.genState();
    
  }
  
  public NoteEvent[] update(NoteEvent[] seed) {
    // Updates related systems that rely on these updates.
    updateSystemsPerUpdateFrequency();
    
    NoteEvent[] newSeed = null;
    
    ArrayList<NoteEvent[]> allGenResults;
    if (canExecuteNextTurn()) {
      updateSystemsPerTurnFrequency(seed);
      
      if (rhythmController.isEnabled()) {
        //println("Using RhythmController to quantize notes.");
        NoteEvent[] quantizedSeed = rhythmController.quantizeSeed(seed);
        allGenResults = genNextTurnMaterial(quantizedSeed);
      }
      else {
        allGenResults = genNextTurnMaterial(seed);
      }
      
      // Generate pedaling.
      PedalEvent[] sustainPedaling = sustainPedalController.genPedaling(allGenResults, _turnLength);
      PedalEvent[] unaCordaPedaling = unaCordaPedalController.genPedaling();
      
      // Generate new seed
      newSeed = calculateNewSeed(seed, allGenResults);
    
      // Register the genResults to be played.
      int baseTime = millis();
      for (NoteEvent[] singleGenResult : allGenResults) {
        adjustNoteEventsForBaseTime(singleGenResult, baseTime);
        player.addNotes(singleGenResult);
      }
      
      adjustPedalEventsForBaseTime(sustainPedaling, baseTime);
      adjustPedalEventsForBaseTime(unaCordaPedaling, baseTime);
      player.addSustainPedaling(sustainPedaling);
      player.addUnaCordaPedaling(unaCordaPedaling);
    }
    
    // Update player.
    player.update();

    if (newSeed != null) {
      return newSeed;
    }
    
    return seed;
  }
  
  public boolean canExecuteNextTurn() {
    return millis() >= _turnEndTime;
  }
  
  // Some systems need updating in each Model update,
  // while the others need it at the end of each turn.
  // Use these functions to register the systems for updates.
  private void updateSystemsPerUpdateFrequency() {
    // Update Generators.
    for (Generator gen : _generators) {
      gen.update();
    }
    
    rhythmController.update();
  }
  
  private void updateSystemsPerTurnFrequency(NoteEvent[] seed) {
    // Update the piece state.
    pieceState.update();
    // Calculate harmonies.
    harmonyController.update(seed);
  }
  
  private ArrayList<NoteEvent[]> genNextTurnMaterial(NoteEvent[] seed) {
    println();
    println("Generating next turn.");
    
    int seedEndTime = getEndTime(seed); // This will be used as the turn length.
    // Set the turn end. After this we can generate a new turn.
    _turnLength = seedEndTime;
    _turnEndTime = millis() + seedEndTime;
    println("Turn length: " + seedEndTime);
    
    ArrayList<NoteEvent[]> allGenResults = new ArrayList<NoteEvent[]>();
    
    // Determine number of generators to use for the turn.
    int numGen = min(
      int(map(
        pieceState.noteDensity.getValue(),
        StateProperty.MIN_VAL, 
        StateProperty.MAX_VAL,
        float(MIN_GENERATOR_COUNT),
        float(MAX_GENERATOR_COUNT) + 0.5f)),
      _generators.length);
    println("Using " + numGen + " generators.");
    
    boolean needToSaveState = false;
    if (_turnCountSinceSeedReset == 0) {
      if (_oldDataPackets.get(0).size() > 0 && random(1f) < USE_OLD_GEN_STATE_PROBABILITY) {
        loadRandomGeneratorState();
      }
      else {
        needToSaveState = true;
      }
    }
    
    // Pass on to generators and apply effects.
    for (int i = 0; i < numGen; ++i) {
      Generator gen = _generators[i];
      if (gen.isAvailable()) {
        NoteEvent[] genResult = gen.generate(seed);
        // Quantize into rhythm if necessary.
        if (rhythmController.isEnabled()) {
          genResult = rhythmController.quantize(genResult, i);
        }
        // Apply enforced effects.
        applyAllEnforcedEffects(genResult);
        // Apply individual effect.
        applyRandomEffect(genResult);
        
        // Update the generator's job finish time.
        gen.setJobFinishTime(getEndTime(genResult));
        
        // Store the result.
        allGenResults.add(genResult);
      }
    }
    
    if (metronome_on) {
      allGenResults.add(rhythmController.getMetronomeNotesForSeed(seed));
    }
    
    // If just generated with this seed for the first time,
    // store the data.
    if (needToSaveState) {
      storeGeneratorStates();
    }
    
    return allGenResults;
  }
  
  private NoteEvent[] calculateNewSeed(NoteEvent[] seed, ArrayList<NoteEvent[]> allGenResults) {
    //println();
    //println("Current seed: ");
    //printNoteEvents(seed);
    
    if (needNewSeed(seed)) {
      println("Resetting seed!!");
      ++_totalSeedResetCount;
      for (Generator gen : _generators) {
        gen.dropStateData();
      }
      maybeMoveToStatePreset();
      
      _turnCountSinceSeedReset = 0;
      return generateNewSeed();
    }
    
    NoteEvent[] tempResultArr = deepClone(seed);
    List<NoteEvent> resultList = new LinkedList<NoteEvent>(Arrays.asList(tempResultArr));
    
    // Remove from seed.
    if (resultList.size() > 1 && checkOdds(REMOVAL_FROM_SEED_ODDS)) {
      int index = int(random(resultList.size()));
      resultList.remove(index);
      println("Removing from seed.");
    }
    
    // Add to seed.
    if (!allGenResults.isEmpty() && checkOdds(ADDITION_TO_SEED_ODDS)) {
      println("Adding to seed.");
      int genResultIndex = int(random(allGenResults.size()));
      NoteEvent[] genResult = allGenResults.get(genResultIndex);
      if (genResult.length > 0) {
        int noteIndex = int(random(genResult.length));
        NoteEvent note = genResult[noteIndex];
        //print("Adding note: ");
        //printNoteEvent(note);
        
        resultList.add(new NoteEvent(note));
      }
    }
    
    Collections.sort(resultList, new SortNoteEventByStartTime());
    
    NoteEvent[] seedResultArr = new NoteEvent[resultList.size()];
    resultList.toArray(seedResultArr);
    
    // Increment the number of turns
    ++_turnCountSinceSeedReset;
    
    //println();
    println("Turn count since last seed reset: " + _turnCountSinceSeedReset);
    println("Total seed reset count: " + _totalSeedResetCount);
    //println("New seed: (turns since last reset is " + _turnCountSinceSeedReset + ") ");
    //printNoteEvents(seedResultArr);
    
    return seedResultArr;
  }
  
  // in number of notes
  final int NEW_SEED_MIN_NOTE_COUNT = 4;
  final int NEW_SEED_MAX_NOTE_COUNT = 14;
  final int NEW_SEED_LATEST_NOTE_START_TIMESTAMP = 5000; // in ms
  final int NEW_SEED_MIN_NOTE_DURATION = 60; // in ms;
  final int NEW_SEED_MAX_NOTE_DURATION = 1200; // in ms;
  final int NEW_SEED_MIN_PITCH = 50;
  final int NEW_SEED_MAX_PITCH = 65;
  final int NEW_SEED_NOTE_VELOCITY = 80;
  
  public NoteEvent[] generateNewSeed() {
    int noteCount = int(random(NEW_SEED_MIN_NOTE_COUNT, NEW_SEED_MAX_NOTE_COUNT));
    NoteEvent[] seed = new NoteEvent[noteCount];
    
    for (int i = 0; i < noteCount; ++i) {
      seed[i] = new NoteEvent(
        int(random(NEW_SEED_MIN_PITCH, NEW_SEED_MAX_PITCH)),
        NEW_SEED_NOTE_VELOCITY,
        int(random(NEW_SEED_LATEST_NOTE_START_TIMESTAMP)),
        int(random(NEW_SEED_MIN_NOTE_DURATION, NEW_SEED_MAX_NOTE_DURATION)));
    }
     
    return seed;
  }
  
  private static final int TURN_COUNT_BEFORE_SEED_RECONSIDERATION = 15; // 15
  // The probability of resetting the seed after the above threshold count will increase
  // by this much each turn.
  private static final float RECONSIDERATION_SEED_RESET_PROBABILITY_INCREASE_RATE = 0.05f; // 0.05f
  private boolean needNewSeed(NoteEvent[] seed) {
    return seedHasExtremeLocalization(seed) || 
      (_turnCountSinceSeedReset > TURN_COUNT_BEFORE_SEED_RECONSIDERATION && 
      (_turnCountSinceSeedReset - TURN_COUNT_BEFORE_SEED_RECONSIDERATION) * 
      RECONSIDERATION_SEED_RESET_PROBABILITY_INCREASE_RATE > random(1.0f));
  }
  
  // If too many notes are too close to one another, return true.
  final int EXTREME_LOCALIZATION_THRESHOLD = 5; // in note count
  final int EXTREME_LOCALIZATION_RANGE = 35 ; // in ms (below and above range)
  private boolean seedHasExtremeLocalization(NoteEvent[] seed) {
    for (int i = 0; i < seed.length; ++i) {
      int centerNoteStartTime = seed[i].getStartTime();
      int localNoteCount = 1;
      for (int j = 0; j < seed.length; ++j) {
        if (j == i) {
          continue;
        }
        int surroundingNoteStartTime = seed[j].getStartTime();
        if (abs(centerNoteStartTime - surroundingNoteStartTime) <= EXTREME_LOCALIZATION_RANGE) {
          ++localNoteCount;
          if (localNoteCount >= EXTREME_LOCALIZATION_THRESHOLD) {
            return true;
          }
        }
      }
    }
    return false;
  }
  
  // Given a rate between 0-1, "rolls a dice" with those rates and returns the result.
  private boolean checkOdds(float rate) {
    float val = random(1);
    return val <= rate;
  }
  
  // Adds the baseTime to the startTime of all the notes in a seed.
  private void adjustNoteEventsForBaseTime(NoteEvent[] notes, int baseTime) {
    for (NoteEvent note : notes) {
       note.setStartTime(note.getStartTime() + baseTime); 
    }
  }
  
  private void adjustPedalEventsForBaseTime(PedalEvent[] pedals, int baseTime) {
    for (PedalEvent pedal : pedals) {
       pedal.setStartTime(pedal.getStartTime() + baseTime); 
    }
  }
  
  private void storeGeneratorStates() {
    // if this would make the stored state list too long
    if (_oldDataPackets.get(0).size() + 1 >= OLD_GEN_STATE_COUNT_TO_STORE) {
      int size = _oldDataPackets.get(0).size();
      int idxToRemove = int(random(size));
      println("Removing index " + idxToRemove + " from old generator states.");
      for (int i = 0; i < size; ++i) {
        _oldDataPackets.get(i).remove(idxToRemove);
      }
    }
    
    // Add state.
    for (int i = 0; i < _generators.length; ++i) {
      _oldDataPackets.get(i).add(_generators[i].getState());
    }   
  }
  
  private void loadRandomGeneratorState() {
    if (_oldDataPackets.get(0).size() <= 0) {
      return;
    }
    
    int idxToLoad = int(random(_oldDataPackets.get(0).size()));
    println("Loading random generator state at index " + idxToLoad);
    for (int i = 0; i < _generators.length; ++i) {
      _generators[i].setState(_oldDataPackets.get(i).get(idxToLoad));
    }
  }
  
  private static final float STATE_PRESET_USE_PROBABILITY = 0.05f;
  private void maybeMoveToStatePreset() {
    if (random(1.0f) > STATE_PRESET_USE_PROBABILITY) {
      return;
    }
    //println("Applying state preset.");
    int idx = int(random(statePresets.length));
    statePresets[idx].applyPreset(pieceState, _generators);
  }
  
  private static final float REMOVAL_FROM_SEED_ODDS = 0.2f;
  private static final float ADDITION_TO_SEED_ODDS = 0.4f;
  private static final float USE_OLD_GEN_STATE_PROBABILITY = 0.1f;
  private static final int OLD_GEN_STATE_COUNT_TO_STORE = 5;
  
  private int _turnLength;
  private int _turnEndTime;
  private int _turnCountSinceSeedReset = 0;
  private int _totalSeedResetCount = 0;
  private Generator[] _generators;
  private ArrayList<ArrayList<GeneratorState>> _oldDataPackets;
}
