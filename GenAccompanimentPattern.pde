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

  //public GenAccompanimentPattern() {
  //  super();
  //}

  @Override
    NoteEvent[] generateFromSeed(NoteEvent[] seed) {
    println("Generating accompaniment pattern.");

    int shortestNoteDuration = int(map(
      pieceState.speed.getValue(), 
      StateProperty.MAX_VAL, 
      StateProperty.MIN_VAL, 
      MIN_SHORTEST_NOTE_DURATION, 
      MAX_SHORTEST_NOTE_DURATION));
    println("shortestNoteDuration: " + shortestNoteDuration);

    int patternLength = int(random(MIN_PATTERN_LENGTH, MAX_PATTERN_LENGTH));
    PatternEntity[] pattern = calculatePattern(patternLength);

    int curTime = 0;
    int patternIndex = 0;
    int seedTime = getEndTime(seed);
    
    int defaultVelocity = int(map(
      pieceState.loudness.getValue(), 
      pieceState.loudness.MIN_VAL, 
      pieceState.loudness.MAX_VAL,
      NoteEvent.VELOCITY_MIN,
      NoteEvent.VELOCITY_MAX));
    int patternBeginningVelocity = defaultVelocity + 5;
    
    NoteEvent curNote = new NoteEvent(
      Key.A, 
      int(random(MIN_STARTING_OCTAVE, MAX_STARTING_OCTAVE)),
      0,
      0,
      0);
      
    ArrayList<NoteEvent> gen = new ArrayList<NoteEvent>();
    while (curTime < seedTime) {
      int thisVelocity = defaultVelocity;
      if (patternIndex == 0) {
        thisVelocity = patternBeginningVelocity;
      }
      // Create the new note with a potentially temporary pitch.
      NoteEvent newNote = new NoteEvent(
        calculatePitchInRange(curNote.getPitch(), pattern[patternIndex].pitchDifferenceFromPrev),
        thisVelocity,
        curTime,
        pattern[patternIndex].length * shortestNoteDuration);
        
      // Move the new note's pitch to a pitch from the current harmony.
      // Pick from harmony the closest possible pitch.
      NoteEvent[] curHarmony = harmonyController.getHarmonyAtTime(curTime);
      int closestPitchIndex = -1;
      int closestPitchDiff = 200; // Just a high number
      for (int i = 0; i < curHarmony.length; ++i) {
        int thisPitchDiff = 
          getClosestPitch(calculateKey(curHarmony[i]), newNote) - newNote.getPitch();
        if (abs(thisPitchDiff) < abs(closestPitchDiff)) {
          closestPitchIndex = i;
          closestPitchDiff = thisPitchDiff;
        }
      }
      newNote.setPitch(newNote.getPitch() + closestPitchDiff);
      //printNoteEvent(newNote);
      
      
      gen.add(newNote);
      curNote = newNote;
      curTime += newNote.getDuration();
      patternIndex = (patternIndex + 1) % pattern.length;
    }

    NoteEvent[] genArr = new NoteEvent[gen.size()];
    return gen.toArray(genArr);
  }

  private static final float NOTE_LENGTH_BASE_STANDARD_DEVIATION = 0.5f;
  private static final float PITCH_VARIATION_STANDARD_DEVIATION = 6f;
  private static final float PITCH_VARIATION_MEAN = 0f;
  private PatternEntity[] calculatePattern(int patternLength) {
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
        
      pattern.add(new PatternEntity(pitchVariance, noteLength));
      curLength += noteLength;
    }
    
    println("Generated pattern length: " + pattern.size());
    print("Generated pattern: ");
    for (PatternEntity ent : pattern) {
      ent.print();
    }
    
    PatternEntity[] patternArr = new PatternEntity[pattern.size()];
    return pattern.toArray(patternArr);
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

  private class PatternEntity {
    public PatternEntity(int pitchIn, int lengthIn) {
      pitchDifferenceFromPrev = pitchIn;
      length = lengthIn;
    }
    
    public void print() {
      println("Pattern entity with pitch difference: " + pitchDifferenceFromPrev + ", with length: " + length);
    }
    
    // Set to 0 for the first note.
    public int pitchDifferenceFromPrev;
    public int length; // in terms of unit note.
  }
}
