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
    //1f,
    //0.75f,
    0.5f,
    0.33f,
    0.25f,
    0.166f,
    0.125f
  };
  
  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seed, DataPacketSet dataSet) {
    println("Generating melody.");
    
    TreeMap<Integer, NoteEvent[]> harmonizedSeed = harmonyController.getHarmonizedSeed();
    if (harmonizedSeed.isEmpty()) {
      return new NoteEvent[0];
    }
    
    int unitNoteLength = int(map(
        pieceState.speed.getValue(),
        StateProperty.MAX_VAL,
        StateProperty.MIN_VAL, 
        MIN_UNIT_NOTE_DURATION, 
        MAX_UNIT_NOTE_DURATION));
        
    
    int endTime = getEndTime(seed);
   
    ArrayList<NoteEvent> gen = new ArrayList<NoteEvent>();
    // We keep track of both the time that we have filled until
    // as well as where we are in the harmonized seed.
    int curTime = 0;
    
    // Set to a random reference point note at first, this will be updated in each iteration.
    NoteEvent lastNote = new NoteEvent(calculatePitch(Key.A, int(random(MIN_OCTAVE, MAX_OCTAVE + 0.5))), 0, 0, 0);
    
    while (curTime < endTime) {
      //int fractionIndex = int(random(ALLOWABLE_FRACTIONS.length));
      int remainingTime = endTime - curTime;
      
      // Calculate the acceptable bounds for fractions.
      int minFractionIndex = -1; // Min index has the greatest fractions.
      int maxFractionIndex = -1; // Max index has the smallest fractions.
      for (int i = 0; i < ALLOWABLE_FRACTIONS.length; ++i) {
        if (ALLOWABLE_FRACTIONS[i] * unitNoteLength < remainingTime) {
          minFractionIndex = i;
          break;
        }
      }
      
      for (int i = ALLOWABLE_FRACTIONS.length - 1; i >= 0; --i) {
        if (ALLOWABLE_FRACTIONS[i] * unitNoteLength > MIN_NOTE_DURATION) {
          maxFractionIndex = i;
          break;
        }
      }
      
      if (minFractionIndex == -1 || maxFractionIndex == -1) {
        break;
      }
      int fractionIndex = int(random(minFractionIndex, maxFractionIndex));
      
      //boolean finishAdding = false;
      //while (ALLOWABLE_FRACTIONS[fractionIndex] * unitNoteLength > remainingTime) {
      //  if (fractionIndex > 0) {
      //    --fractionIndex;
      //  }
      //  else {
      //    finishAdding = true;
      //    break;
      //  }
      //}
      
      //// We can't fit anything else.
      //// TODO: Consider extending the length of the previous note?
      //if (ALLOWABLE_FRACTIONS[fractionIndex] * unitNoteLength < MIN_NOTE_DURATION) {
      //  finishAdding = true;
      //}
      
      //if (finishAdding) {
      //  break;
      //}
      
      NoteEvent[] harmNotes = harmonyController.getHarmonyAtTime(curTime);
      int harmIndex = int(random(harmNotes.length));
      int newPitch = getClosestPitch(calculateKey(harmNotes[harmIndex]), lastNote);
      
      int duration = int(ALLOWABLE_FRACTIONS[fractionIndex] * unitNoteLength);
      lastNote = new NoteEvent(newPitch, int(random(NoteEvent.VELOCITY_MIN, NoteEvent.VELOCITY_MAX)), curTime, duration);
      gen.add(lastNote);
      curTime += duration;
    }
    
    NoteEvent[] genResultArr = new NoteEvent[gen.size()];
    return gen.toArray(genResultArr);
  }
}
