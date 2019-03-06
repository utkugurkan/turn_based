// Creates a melody based on the determined harmonies.
class GenMelody extends GenerationMethod {
  // in ms
  private static final int MIN_NOTE_DURATION = 50;
  private static final int MAX_NOTE_DURATION = 4000;
  
  private static final int MIN_UNIT_NOTE_DURATION = 200;
  private static final int MAX_UNIT_NOTE_DURATION = 1500;
  
  private static final int MIN_OCTAVE = 3;
  private static final int MAX_OCTAVE = 5;
  
  private final float[] ALLOWABLE_FRACTIONS = {
    //4f,
    //3f,
    //2f,
    1f,
    0.75f,
    0.5f,
    0.33f,
    0.25f,
    0.166f,
    0.125f
  };
  
  private static final int MIN_RECOMMENDED_NUMBER_OF_GENERATIONS = 8;
  private static final int MAX_RECOMMENDED_NUMBER_OF_GENERATIONS = 16;
  public GenMelody() {
    super();
    
    _minRecommendedNumberOfGenerations = MIN_RECOMMENDED_NUMBER_OF_GENERATIONS;
    _maxRecommendedNumberOfGenerations = MAX_RECOMMENDED_NUMBER_OF_GENERATIONS;
  }
  
  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seed, DataPacketSet dataSet) {
    println("Generating melody.");
    
    //TreeMap<Integer, NoteEvent[]> harmonizedSeed = harmonyController.getHarmonizedSeed();
    //if (harmonizedSeed.isEmpty()) {
    //  return new NoteEvent[0];
    //}
    
    int endTime = getEndTime(seed);
    TemplateState templateState = genMelodyTemplate(endTime, dataSet);
    if (templateState == null) {
      return new NoteEvent[0];
    }
    PatternEntity[] template = templateState.template;
    int curIndex = templateState.curIndex;
    int unitNoteLength = templateState.unitNoteLength;
    NoteEvent lastNote = templateState.prevNote;
   
    ArrayList<NoteEvent> gen = new ArrayList<NoteEvent>();
    // We keep track of both the time that we have filled until
    // as well as where we are in the harmonized seed.
    int curTime = 0;
    
    while (curTime < endTime) {
      // Set to a random reference point to start a new melodic line.
      if (curIndex == 0) {
        lastNote = new NoteEvent(calculatePitch(getRandomKey(), int(random(MIN_OCTAVE, MAX_OCTAVE + 0.5))), 40, 0, 0);
      }
      int fractionIndex = template[curIndex].length;
      
      //NoteEvent[] harmNotes = harmonyController.getHarmonyAtTime(curTime);
      //int harmIndex = int(random(harmNotes.length));
      //int newPitch = getClosestPitch(calculateKey(harmNotes[harmIndex]), lastNote);
      
      int newPitch = lastNote.getPitch() + template[curIndex].pitchDiff;
      
      
      int duration = int(ALLOWABLE_FRACTIONS[fractionIndex] * unitNoteLength);
      lastNote = new NoteEvent(newPitch, int(random(NoteEvent.VELOCITY_MIN, NoteEvent.VELOCITY_MAX)), curTime, duration);
      gen.add(lastNote);
      curTime += duration;
      curIndex = (curIndex + 1) % template.length;
    }
    
    TemplateState newTemplateState = new TemplateState(template, curIndex, unitNoteLength, lastNote);
    saveData(dataSet, newTemplateState);
    
    NoteEvent[] genResultArr = new NoteEvent[gen.size()];
    return gen.toArray(genResultArr);
  }
  
  //@Override
  //NoteEvent[] generateFromSeed(NoteEvent[] seed, DataPacketSet dataSet) {
  //  println("Generating melody.");
    
  //  TreeMap<Integer, NoteEvent[]> harmonizedSeed = harmonyController.getHarmonizedSeed();
  //  if (harmonizedSeed.isEmpty()) {
  //    return new NoteEvent[0];
  //  }
    
  //  int unitNoteLength = int(map(
  //      pieceState.speed.getValue(),
  //      StateProperty.MAX_VAL,
  //      StateProperty.MIN_VAL, 
  //      MIN_UNIT_NOTE_DURATION, 
  //      MAX_UNIT_NOTE_DURATION));
        
    
  //  int endTime = getEndTime(seed);
   
  //  ArrayList<NoteEvent> gen = new ArrayList<NoteEvent>();
  //  // We keep track of both the time that we have filled until
  //  // as well as where we are in the harmonized seed.
  //  int curTime = 0;
    
  //  // Set to a random reference point note at first, this will be updated in each iteration.
  //  NoteEvent lastNote = new NoteEvent(calculatePitch(Key.A, int(random(MIN_OCTAVE, MAX_OCTAVE + 0.5))), 0, 0, 0);
    
  //  while (curTime < endTime) {
  //    //int fractionIndex = int(random(ALLOWABLE_FRACTIONS.length));
  //    int remainingTime = endTime - curTime;
      
  //    // Calculate the acceptable bounds for fractions.
  //    int minFractionIndex = -1; // Min index has the greatest fractions.
  //    int maxFractionIndex = -1; // Max index has the smallest fractions.
  //    for (int i = 0; i < ALLOWABLE_FRACTIONS.length; ++i) {
  //      if (ALLOWABLE_FRACTIONS[i] * unitNoteLength < remainingTime) {
  //        minFractionIndex = i;
  //        break;
  //      }
  //    }
      
  //    for (int i = ALLOWABLE_FRACTIONS.length - 1; i >= 0; --i) {
  //      if (ALLOWABLE_FRACTIONS[i] * unitNoteLength > MIN_NOTE_DURATION) {
  //        maxFractionIndex = i;
  //        break;
  //      }
  //    }
      
  //    if (minFractionIndex == -1 || maxFractionIndex == -1) {
  //      break;
  //    }
  //    int fractionIndex = int(random(minFractionIndex, maxFractionIndex));
      
  //    NoteEvent[] harmNotes = harmonyController.getHarmonyAtTime(curTime);
  //    int harmIndex = int(random(harmNotes.length));
  //    int newPitch = getClosestPitch(calculateKey(harmNotes[harmIndex]), lastNote);
      
  //    int duration = int(ALLOWABLE_FRACTIONS[fractionIndex] * unitNoteLength);
  //    lastNote = new NoteEvent(newPitch, int(random(NoteEvent.VELOCITY_MIN, NoteEvent.VELOCITY_MAX)), curTime, duration);
  //    gen.add(lastNote);
  //    curTime += duration;
  //  }
    
  //  NoteEvent[] genResultArr = new NoteEvent[gen.size()];
  //  return gen.toArray(genResultArr);
  //}
  
  // TODO: Incorporate directions.
  private static final int DIRECTIONAL_CONFIDENCE_INITIAL_MIN = 3;
  private static final int DIRECTIONAL_CONFIDENCE_INITIAL_MAX = 12;
  
  //private static final float PREVIOUS_INTERVAL_SELECTION_CHANCE;
  //private static final int MAX_REPEATABLE_INTERVAL;
  
  private static final float NOTE_LENGTH_INDEX_STANDARD_DEV = 3f;
  //private static 
  private static final int MIN_DOMINANT_FRACTION_LENGTH = 1;
  private static final int MAX_DOMINANT_FRACTION_LENGTH = 8;
  
  private static final int MIN_PITCH_VARIATION_BETWEEN_NOTES = -12;
  private static final int MAX_PITCH_VARIATION_BETWEEN_NOTES = +12;
  private static final float PITCH_VARIATION_STANDARD_DEVIATION = 4f;
  private static final float PITCH_VARIATION_MEAN = 0f;
  
  // Current thoughts and methodology:
  // Determine a "dominant" note length (or fraction) to be used for a certain amount of time.
  private TemplateState genMelodyTemplate(int seedLength, DataPacketSet dataSet) {
    TemplateState template = unpackData(dataSet);
    if (template != null) {
      return template;
    }
    println("ATTN!! Generating new melody template");
    
    int templateLength = calculateTemplateLength(seedLength);
    
    int unitNoteLength = int(map(
      pieceState.speed.getValue(),
      StateProperty.MAX_VAL,
      StateProperty.MIN_VAL, 
      MIN_UNIT_NOTE_DURATION, 
      MAX_UNIT_NOTE_DURATION));
    
    ArrayList<PatternEntity> pattern = new ArrayList<PatternEntity>();
    int curLength = 0;
    int dominantFractionIndex = 0;
    int dominantFractionDurationLeft = 0;
    
    // Calculate acceptable fraction bounds. 
    int minFractionIndex = -1;
    int maxFractionIndex = -1;
    for (int i = ALLOWABLE_FRACTIONS.length - 1; i >= 0; --i) {
      if (ALLOWABLE_FRACTIONS[i] * unitNoteLength > MIN_NOTE_DURATION) {
        minFractionIndex = i;
        break;
      }
    }
    for (int i = 0; i < ALLOWABLE_FRACTIONS.length; ++i) {
      if (ALLOWABLE_FRACTIONS[i] * unitNoteLength < MAX_NOTE_DURATION) {
        maxFractionIndex = i;
        break;
      }
    }
    
    if (minFractionIndex == -1 || maxFractionIndex == -1) {
      println("CRITICAL ERROR: No acceptable fractions for melody.");
      return null;
    }
    
    // True: going up. False: going down.
    boolean direction;
    if (random(1.0f) < 0.5) {
      direction = true;
    }
    else {
      direction = false;
    }
    int curDirectionalConfidence = 0;
    while (curLength < templateLength) {
      if (dominantFractionDurationLeft <= 0) {
        int noteLengthIndexMean = int(map(
          pieceState.speed.getValue(), 
          pieceState.speed.MIN_VAL,
          pieceState.speed.MAX_VAL,
          0,
          ALLOWABLE_FRACTIONS.length));
        
        dominantFractionIndex = int(randomTruncatedGaussian(
          0,
          ALLOWABLE_FRACTIONS.length,
          noteLengthIndexMean,
          NOTE_LENGTH_INDEX_STANDARD_DEV));
          
        dominantFractionDurationLeft = int(random(MIN_DOMINANT_FRACTION_LENGTH, MAX_DOMINANT_FRACTION_LENGTH + 0.5));
      }
      
      if (curDirectionalConfidence <= 0) {
        direction = !direction;
        curDirectionalConfidence = int(random(DIRECTIONAL_CONFIDENCE_INITIAL_MIN, DIRECTIONAL_CONFIDENCE_INITIAL_MAX + 0.5));
      }
      
      int pitchVariance = int(randomTruncatedGaussian(
        MIN_PITCH_VARIATION_BETWEEN_NOTES,
        MAX_PITCH_VARIATION_BETWEEN_NOTES, 
        PITCH_VARIATION_MEAN, 
        PITCH_VARIATION_STANDARD_DEVIATION));
      if ( (direction && pitchVariance < 0) || (!direction && pitchVariance > 0) ) {
        pitchVariance *= -1;
      }
      curDirectionalConfidence -= abs(pitchVariance);
        
      pattern.add(new PatternEntity(pitchVariance, dominantFractionIndex));
      curLength += unitNoteLength * ALLOWABLE_FRACTIONS[dominantFractionIndex];
      --dominantFractionDurationLeft;
    }
    
    //println("Generated pattern length: " + pattern.size());
    //print("Generated pattern: ");
    //for (PatternEntity ent : pattern) {
    //  ent.print();
    //}
    
    NoteEvent startingNote = new NoteEvent(calculatePitch(Key.A, int(random(MIN_OCTAVE, MAX_OCTAVE + 0.5))), 40, 0, 0);
    PatternEntity[] patternArr = new PatternEntity[pattern.size()];
    return new TemplateState(pattern.toArray(patternArr), 0, unitNoteLength, startingNote);
  }
  
  
  private TemplateState unpackData(DataPacketSet dataSet) {
    DataPacket[] data = dataSet.data;
    if (data != null && data.length >= 4 && data[0].type == PatternEntity[].class &&
      data[1].type == Integer.class && data[2].type == Integer.class && data[3].type == NoteEvent.class) {
      //println("Using the same pattern.");
      PatternEntity[] template = (PatternEntity[])data[0].value;
      int curIndex = (int)data[1].value;
      int unitNoteLength = (int)data[2].value;
      NoteEvent prevNote = (NoteEvent)data[3].value;
      return new TemplateState(template, curIndex, unitNoteLength, prevNote);
    } else {
      return null;
    }
  }
  
  private void saveData(DataPacketSet dataSet, TemplateState templateState) {
    dataSet.data = new DataPacket[4];
    dataSet.data[0] = new DataPacket(templateState.template);
    dataSet.data[1] = new DataPacket(templateState.curIndex);
    dataSet.data[2] = new DataPacket(templateState.unitNoteLength);
    dataSet.data[3] = new DataPacket(templateState.prevNote);
  }
  
  private static final int MIN_SEED_LENGTH_MULTIPLIER = 2;
  private static final int MAX_SEED_LENGTH_MULTIPLIER = 12;
  private int calculateTemplateLength(int seedLength) {
    return seedLength * int(random(MIN_SEED_LENGTH_MULTIPLIER, MAX_SEED_LENGTH_MULTIPLIER + 0.5)); 
  }
  
  private class TemplateState {
    public TemplateState(PatternEntity[] templateIn, int curIndexIn, int unitNoteLengthIn, NoteEvent prevNoteIn) {
      template = templateIn;
      curIndex = curIndexIn;
      unitNoteLength = unitNoteLengthIn;
      prevNote = prevNoteIn;
    }
    public PatternEntity[] template;
    public int curIndex;
    public int unitNoteLength;
    public NoteEvent prevNote;
  }
}
