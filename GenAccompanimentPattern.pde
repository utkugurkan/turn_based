class GenAccompanimentPattern extends GenerationMethod {

  // in ms.
  private static final int MIN_SHORTEST_NOTE_DURATION = 85;
  private static final int MAX_SHORTEST_NOTE_DURATION = 500;

  private static final int MIN_PATTERN_LENGTH = 3;
  private static final int MAX_PATTERN_LENGTH = 10;

  private static final int MIN_PATTERN_ELEMENT_LENGTH = 1;
  private static final int MAX_PATTERN_ELEMENT_LENGTH = 3;

  private static final int MIN_PITCH_VARIATION_BETWEEN_NOTES = -12;
  private static final int MAX_PITCH_VARIATION_BETWEEN_NOTES = +12;
  
  private static final int MIN_STARTING_OCTAVE = 2;
  private static final int MAX_STARTING_OCTAVE = 4;
  
  // The chance of calculating a new pattern even when there
  // is a passed in state.
  private static final float PATTERN_CHANGE_PROBABILITY = 0.05;
  private static final float CONSECUTIVE_SAME_NOTE_PROBABILITY = 0.2;
  
  private static final int MIN_RECOMMENDED_NUMBER_OF_GENERATIONS = 6;
  private static final int MAX_RECOMMENDED_NUMBER_OF_GENERATIONS = 24;

  public GenAccompanimentPattern() {
    super();
    
    _minRecommendedNumberOfGenerations = MIN_RECOMMENDED_NUMBER_OF_GENERATIONS;
    _maxRecommendedNumberOfGenerations = MAX_RECOMMENDED_NUMBER_OF_GENERATIONS;
  }

  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seed, DataPacketSet dataSet) {
    println("Generating accompaniment pattern.");

    int shortestNoteDuration = int(map(
      pieceState.speed.getValue(), 
      StateProperty.MAX_VAL, 
      StateProperty.MIN_VAL, 
      MIN_SHORTEST_NOTE_DURATION, 
      MAX_SHORTEST_NOTE_DURATION));
    //println("shortestNoteDuration: " + shortestNoteDuration);

    //int patternLength = int(random(MIN_PATTERN_LENGTH, MAX_PATTERN_LENGTH));
    TemplateState templateState = calculatePattern(dataSet);
    
    if (templateState == null) {
      return new NoteEvent[0];
    }
    PatternEntity[] pattern = templateState.template;
    int curIndex = templateState.curIndex;
    if (curIndex >= pattern.length) {
      curIndex = 0;
    }
    NoteEvent curNote = templateState.prevNote;

    int curTime = 0;
    int seedTime = getEndTime(seed);
    
    int defaultVelocity = int(map(
      pieceState.loudness.getValue(), 
      StateProperty.MIN_VAL, 
      StateProperty.MAX_VAL,
      NoteEvent.VELOCITY_MIN,
      NoteEvent.VELOCITY_MAX));
    int patternBeginningVelocity = defaultVelocity + 5;
      
    ArrayList<NoteEvent> gen = new ArrayList<NoteEvent>();
    while (curTime < seedTime) {
      int noteDuration = pattern[curIndex].length * shortestNoteDuration;
      
      if (!pattern[curIndex].isRest) {
        int thisVelocity = defaultVelocity;
        if (curIndex == 0) {
          thisVelocity = patternBeginningVelocity;
          curNote = getNewStartingNote();
        }
        // Create the new note with a potentially temporary pitch.
        NoteEvent newNote = new NoteEvent(
          calculatePitchInRange(curNote.getPitch(), pattern[curIndex].pitchDiff),
          thisVelocity,
          curTime,
          noteDuration);
          
        // Move the new note's pitch to a pitch from the current harmony.
        // Pick from harmony the closest possible pitch.
        NoteEvent[] curHarmony = harmonyController.getHarmonyAtTime(curTime);
        
        int closestPitchIndex = -1;
        int closestPitchDiff = 200; // Just a high number
        for (int i = 0; i < curHarmony.length; ++i) {
          int thisPitchDiff = 
            getClosestPitch(calculateKey(curHarmony[i]), newNote) - newNote.getPitch();
          if (abs(thisPitchDiff) < abs(closestPitchDiff)) {
            // If this would have been the same note as the previous,
            // Only do it if there are no other options or based on the dice roll.
            if (gen.size() > 0 && gen.get(gen.size() - 1).getPitch() == newNote.getPitch() + thisPitchDiff &&
              (!(closestPitchIndex == -1 && i == curHarmony.length - 1) || random(1.0f) > CONSECUTIVE_SAME_NOTE_PROBABILITY)) {
              continue;
            }
            closestPitchIndex = i;
            closestPitchDiff = thisPitchDiff;
          }
        }
        int newPitch = fitPitchInLimits(newNote.getPitch() + closestPitchDiff);
        newNote.setPitch(newPitch);
        
        gen.add(newNote);
        curNote = newNote;
      }
      else {
        //println("Adding rest");
      }
      
      // Do the increment regardless of whether the note is a rest or not.
      curTime += noteDuration;
      curIndex = (curIndex + 1) % pattern.length;
    }

    TemplateState newTemplateState = new TemplateState(pattern, curIndex, 0, curNote);
    saveData(dataSet, newTemplateState);
    
    NoteEvent[] genArr = new NoteEvent[gen.size()];
    return gen.toArray(genArr);
  }
  
  private TemplateState calculatePattern(DataPacketSet dataSet) {
    if (random(1f) < PATTERN_CHANGE_PROBABILITY) {
      return genNewPattern();
    }
    
    TemplateState template = unpackData(dataSet);
    if (template != null) {
      return template;
    }
    return genNewPattern();
      
  }
  
  private static final float NOTE_LENGTH_BASE_STANDARD_DEVIATION = 0.5f;
  private static final float PITCH_VARIATION_STANDARD_DEVIATION = 6f;
  private static final float PITCH_VARIATION_MEAN = 0f;
  private TemplateState genNewPattern() {
    int patternLength = int(random(MIN_PATTERN_LENGTH, MAX_PATTERN_LENGTH));
    
    ArrayList<PatternEntity> pattern = new ArrayList<PatternEntity>();
    int curLength = 0;
    while (curLength < patternLength) {
      float minVal = MIN_PATTERN_ELEMENT_LENGTH;
      float maxVal = min(patternLength - curLength, MAX_PATTERN_ELEMENT_LENGTH) + 0.5;
      
      float noteLengthMean = map(
        pieceState.speed.getValue(), 
        pieceState.speed.MIN_VAL,
        pieceState.speed.MAX_VAL,
        maxVal,
        minVal);
        
      //println("Note length mean: " + noteLengthMean);
      
      // The farther the speed is from the average speed, the smaller the standard deviation is.
      float speedPropMean = (pieceState.speed.MAX_VAL - pieceState.speed.MIN_VAL) / 2f;
      float speedDiffFromMeanSpeed = abs(speedPropMean - pieceState.speed.getValue());
      float noteLengthStdDev = map(
        speedDiffFromMeanSpeed,
        speedPropMean,
        0f,
        0f,
        NOTE_LENGTH_BASE_STANDARD_DEVIATION);
      //println("Standard dev: " + noteLengthStdDev);
      
      int noteLength = int(randomTruncatedGaussian(minVal, maxVal, noteLengthMean, noteLengthStdDev));
      //int noteLength = 1;
      //println("Note length: " + noteLength);
      
      int pitchVariance = int(randomTruncatedGaussian(
        MIN_PITCH_VARIATION_BETWEEN_NOTES,
        MAX_PITCH_VARIATION_BETWEEN_NOTES, 
        PITCH_VARIATION_MEAN, 
        PITCH_VARIATION_STANDARD_DEVIATION));
      
      boolean isRest = patternElementShouldBeRest();
      
      pattern.add(new PatternEntity(pitchVariance, noteLength, isRest));
      curLength += noteLength;
    }
    
    //println("Generated pattern length: " + pattern.size());
    //print("Generated pattern: ");
    //for (PatternEntity ent : pattern) {
    //  ent.print();
    //}
    
    // TODO: Remove this when done testing.
    //int restCount = 0;
    //for (PatternEntity ent : pattern) {
    //  if (ent.isRest) {
    //    ++restCount;
    //  }
    //}
    //println("ATTN! Out of " + pattern.size() + " notes, " + restCount + " of them were rests.");
    
    NoteEvent startingNote = getNewStartingNote();
    PatternEntity[] patternArr = new PatternEntity[pattern.size()];
    return new TemplateState(pattern.toArray(patternArr), 0, 0, startingNote);
  }
  
  // Use this function to get the pitch to use, given the pitch of the previous note
  // as well as the pitch difference as determined by the pattern.
  // This function will consider the minimum and maximum pitches to adjust
  // if necessary.
  // The pitch will be adjusted by rates of this much until it is in range.
  private static final int PITCH_RANGE_FIT_FACTOR = 12;
  private int calculatePitchInRange(int prevNotePitch, int pitchDiff) {
    int suggestedPitch = prevNotePitch + pitchDiff;
    while (suggestedPitch > NoteEvent.PITCH_MAX) {
      suggestedPitch -= PITCH_RANGE_FIT_FACTOR;
    }
    while (suggestedPitch < NoteEvent.PITCH_MIN) {
      suggestedPitch += PITCH_RANGE_FIT_FACTOR;
    }
    return suggestedPitch;
  }
  
  private TemplateState unpackData(DataPacketSet dataSet) {
    DataPacket[] data = dataSet.data;
    if (data != null && data.length >= 3 && data[0].type == PatternEntity[].class &&
      data[1].type == Integer.class && data[2].type == NoteEvent.class) {
        
      //println("Using the same pattern.");
      PatternEntity[] template = (PatternEntity[])data[0].value;
      int curIndex = (int)data[1].value;
      NoteEvent prevNote = (NoteEvent)data[2].value;
      
      // We don't use the third parameter here, which is the unit note length,
      // since it's calculated each time.
      return new TemplateState(template, curIndex, 0, prevNote);
    }
    else {
      //println("Not using the same pattern.");
      return null;
    }
  }
  
  // Sets the state data that was passed in
  // to the generation method.
  private void saveData(DataPacketSet dataSet, TemplateState templateState) {
    dataSet.data = new DataPacket[3];
    dataSet.data[0] = new DataPacket(templateState.template);
    dataSet.data[1] = new DataPacket(templateState.curIndex);
    dataSet.data[2] = new DataPacket(templateState.prevNote);
  }
  
  private NoteEvent getNewStartingNote() {
    return new NoteEvent(calculatePitch(getRandomKey(), int(random(MIN_STARTING_OCTAVE, MAX_STARTING_OCTAVE + 0.5))), 40, 0, 0);
  }
  
  private static final float MIN_REST_PROBABILITY = 0.05f;
  private static final float MAX_REST_PROBABILITY = 0.20f;
  // This is the speed at which the most rests will occur.
  private static final float MAX_REST_POINT_IN_SPEED_PROP = 0.6f;
  private static final float REST_STD_DEV = 0.02f;
  private boolean patternElementShouldBeRest() {
    
    float speedOffset = abs(MAX_REST_POINT_IN_SPEED_PROP - pieceState.speed.getValue());
    // Mean of the gaussian depends on how far the current speed is from the point
    // that would have the highest rest probability.
    float mean = map(
      speedOffset,
      0.0f,
      MAX_REST_POINT_IN_SPEED_PROP,
      MAX_REST_PROBABILITY,
      MIN_REST_PROBABILITY);
      
    float restProb = randomTruncatedGaussian(
      MIN_REST_PROBABILITY, 
      MAX_REST_PROBABILITY,
      mean,
      REST_STD_DEV);
      
    //println("Rest probability is : " + restProb);
    //map(
    //  pieceState.speed.getValue(),
    //  StateProperty.MIN_VAL,
    //  StateProperty.MAX_VAL,
    //  MIN_REST_PROBABILITY,
    //  MAX_REST_PROBABILITY);
      
    return random(1.0f) <= restProb;
  }
}
