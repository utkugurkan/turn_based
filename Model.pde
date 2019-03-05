final int GENERATOR_COUNT = 2;

class Model {  
  public Model() {
    _turnEndTime = 0;
    
    _generators = new Generator[GENERATOR_COUNT];
    for (int i = 0; i < _generators.length; ++i) {
      _generators[i] = new Generator();
    }
    
    pieceState.genState();
  }
  
  public NoteEvent[] update(NoteEvent[] seed) {
    // Updates related systems that rely on these updates.
    updateSystemsPerUpdateFrequency();
    
    NoteEvent[] newSeed = null;
    
    ArrayList<NoteEvent[]> allGenResults;
    if (canExecuteNextTurn()) {
      // Calculate harmonies.
      harmonyController.update(seed);
      
      if (rhythmController.isEnabled()) {
        NoteEvent[] quantizedSeed = rhythmController.quantizeSeed(seed);
        allGenResults = genNextTurnMaterial(quantizedSeed);
      }
      else {
        allGenResults = genNextTurnMaterial(seed);
      }
      
      // Generate new seed
      newSeed = calculateNewSeed(seed, allGenResults);
    
      // Register the genResults to be played.
      int baseTime = millis();
      for (NoteEvent[] singleGenResult : allGenResults) {
        adjustSeedForBaseTime(singleGenResult, baseTime);
        player.addNotes(singleGenResult);
      }
      
      updateSystemsPerTurnFrequency();
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
  
  private void updateSystemsPerTurnFrequency() {
    // Update the piece state.
    pieceState.update();
  }
  
  private ArrayList<NoteEvent[]> genNextTurnMaterial(NoteEvent[] seed) {
    println();
    println("Generating next turn.");
    
    int seedEndTime = getEndTime(seed); // This will be used as the turn length.
    // Set the turn end. After this we can generate a new turn.
    _turnEndTime = millis() + seedEndTime;
    println("Turn length: " + seedEndTime);
    
    ArrayList<NoteEvent[]> allGenResults = new ArrayList<NoteEvent[]>();
    
    // Pass on to generators and apply effects.
    for (Generator gen : _generators) {
      if (gen.isAvailable()) {
        NoteEvent[] genResult = gen.generate(seed);
        // Quantize into rhythm if necessary.
        if (rhythmController.isEnabled()) {
          genResult = rhythmController.quantize(genResult);
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
    
    return allGenResults;
  }
  
  private NoteEvent[] calculateNewSeed(NoteEvent[] seed, ArrayList<NoteEvent[]> allGenResults) {
    //println();
    //println("Current seed: ");
    //printNoteEvents(seed);
    
    if (needNewSeed(seed)) {
      println("Resetting seed!!");
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
        print("Adding note: ");
        printNoteEvent(note);
        
        resultList.add(new NoteEvent(note));
      }
    }
    
    Collections.sort(resultList, new SortNoteEventByStartTime());
    
    NoteEvent[] seedResultArr = new NoteEvent[resultList.size()];
    resultList.toArray(seedResultArr);
    
    println();
    println("New seed: ");
    printNoteEvents(seedResultArr);
    
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
  
  private NoteEvent[] generateNewSeed() {
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
  
  private boolean needNewSeed(NoteEvent[] seed) {
    return seedHasExtremeLocalization(seed);
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
  private void adjustSeedForBaseTime(NoteEvent[] seed, int baseTime) {
    for (NoteEvent note : seed) {
       note.setStartTime(note.getStartTime() + baseTime); 
    }
  }
  
  private static final float REMOVAL_FROM_SEED_ODDS = 0.2f;
  private static final float ADDITION_TO_SEED_ODDS = 0.4f;
  
  private int _turnEndTime;
  private Generator[] _generators;
}
