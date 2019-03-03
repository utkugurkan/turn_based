import java.util.ArrayList;

class GenFillBetweenNotes extends GenerationMethod {
  
  static final int MAX_FILL_COUNT = 6;
  // We don't want to produce notes that are quicker than this (in milliseconds).
  static final int MIN_NOTE_DURATION = 50;
  
  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seedIn) {
    println("Filling between notes.");
    NoteEvent[] seed = deepClone(seedIn);
    
    ArrayList<NoteEvent> gen = new ArrayList<NoteEvent>();
    
    if (seed.length == 0) {
      return seed;
    }
    
    // Fill in more notes after each note based on that note's length and what comes after.
    // For the last note, "what comes after" becomes the first note".
    // (Keep this in mind for the potentiall awkward result of a single note seed.)
    for (int i = 0; i < seed.length; ++i) {
      NoteEvent curNote = seed[i];
      int maxNoteCount = curNote.getDuration() / MIN_NOTE_DURATION;
      // This includes the original note.
      int notesToAddCount = int(random(1, min(MAX_FILL_COUNT, maxNoteCount)));
      
      int pitchesToAdd[] = new int[notesToAddCount];
      int velocitiesToAdd[] = new int[notesToAddCount];
      
      // Ensure that the last note's next wraps back to the beginning.
      int nextNoteIndex = (i + 1) % seed.length;
      NoteEvent nextNote = seed[nextNoteIndex];
      
      int curPitch = curNote.getPitch();
      int curVelocity = curNote.getVelocity();
      
      int nextPitch = nextNote.getPitch();
      int nextVelocity = nextNote.getVelocity();
      
      pitchesToAdd[0] = curPitch;
      velocitiesToAdd[0] = curVelocity;
      for (int noteCount = 1; noteCount < notesToAddCount; ++noteCount) {
        int minPitch = min(curPitch, nextPitch);
        int maxPitch = max(curPitch, nextPitch);
        int minVelocity = min(curVelocity, nextVelocity);
        int maxVelocity = min(curVelocity, nextVelocity);
        
        pitchesToAdd[noteCount] = int(random(minPitch, maxPitch));
        velocitiesToAdd[noteCount] = int(random(minVelocity, maxVelocity));
      }
      
      int baseTime = curNote.getStartTime();
      int duration = curNote.getDuration() / notesToAddCount;
      for (int noteCount = 0; noteCount < notesToAddCount; ++noteCount) {
        gen.add(new NoteEvent(pitchesToAdd[noteCount], velocitiesToAdd[noteCount], baseTime + noteCount * duration, duration));
      }
      
      
    }
    
    
    ////
    
    //gen.add(seed[0]); // TODO: Figure out how to shorten this down according to the fill count. 
    
    //for (int i = 1; i < seed.length; ++i) {
    //  println("Loooopiiiing.");
    //  int numberOfNotesToAdd = int(random(1, MAX_FILL_COUNT));
    //  int baseTime = gen.get(i - 1).getStartTime();
    //  int duration = gen.get(i - 1).getDuration() / numberOfNotesToAdd;
    //  int prevPitch = gen.get(i - 1).getPitch();
      
    //  NoteEvent curNote = seed[i];
    //  int curPitch = curNote.getPitch();
      
    //  for (int noteCount = 0; noteCount < numberOfNotesToAdd; ++i) {
    //    int pitch = int(random(prevPitch, curPitch));
    //    gen.add(new NoteEvent(pitch, curNote.getVelocity(), baseTime + noteCount * duration, duration));
    //  }
      
    //  // Will also need to adjust this duration based on the next. So maybe we should be doing this at the top of the loop,
    //  // including the very first time.
    //  gen.add(new NoteEvent(curPitch, curNote.getVelocity(), curNote.getStartTime(), curNote.getDuration()));
    //}
    
    NoteEvent[] genResultArr = new NoteEvent[gen.size()];
    return gen.toArray(genResultArr);
  }
}
