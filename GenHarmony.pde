//import java.util.ArrayList;

class GenHarmony extends GenerationMethod {
  
  //// The max interval between each harm note.
  //static final int MAX_HARM_INTERVAL = 7;
  //static final int MIN_HARM_COUNT = 2;
  //static final int MAX_HARM_COUNT = 5;
  
  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seedIn, DataPacketSet dataSet) {
    println("Generating harmony.");
    
    TreeMap<Integer, NoteEvent[]> harms = harmonyController.getHarmonizedSeed();
    ArrayList<NoteEvent> gen = new ArrayList<NoteEvent>();
    
    int defaultVelocity = int(map(
      pieceState.loudness.getValue(), 
      StateProperty.MIN_VAL, 
      StateProperty.MAX_VAL,
      NoteEvent.VELOCITY_MIN,
      NoteEvent.VELOCITY_MAX));
    
    for(Map.Entry<Integer, NoteEvent[]> entry : harms.entrySet()) {
      Integer startTime = entry.getKey();
      NoteEvent[] notes = entry.getValue();

      for (NoteEvent note : notes) {
        NoteEvent newNote = new NoteEvent(note);
        newNote.setStartTime(startTime);
        newNote.setVelocity(defaultVelocity);
        gen.add(newNote);
      }
    }
    
    NoteEvent[] genResultArr = new NoteEvent[gen.size()];
    return gen.toArray(genResultArr);
    
    
    
    //NoteEvent[] seed = deepClone(seedIn);
    
    //if (seed.length == 0) {
    //  return seed;
    //}
    
    //ArrayList<NoteEvent> gen = new ArrayList<NoteEvent>();
    //boolean seedNoteIsBass = false;
    //boolean seedNoteIsMid = false;
    //boolean seedNoteIsHigh = false;
    //float voicingOrderRandomNumber = random(1f);
    //if (voicingOrderRandomNumber < 0.33f) {
    //  seedNoteIsBass = true;
    //}
    //else if (voicingOrderRandomNumber < 0.66f) {
    //  seedNoteIsMid = true;
    //}
    //else {
    //  seedNoteIsHigh = true;
    //}

    //for (int i = 0; i < seed.length; ++i) {
    //  NoteEvent curNote = seed[i];
    //  int harmCount = int(random(MIN_HARM_COUNT, MAX_HARM_COUNT));
    //  if (seedNoteIsBass) {
    //    NoteEvent[] harms = harmonize(curNote, harmCount, true);
    //    gen.addAll(Arrays.asList(harms));
    //  }
    //  else if (seedNoteIsMid) {
    //    int harmCountBelow = int(random(harmCount - 0.99f));
    //    int harmCountAbove = harmCount - harmCountBelow;
        
    //    NoteEvent[] harmsBelow = harmonize(curNote, harmCountBelow, false);
    //    NoteEvent[] harmsAbove = harmonize(curNote, harmCountAbove, true);
    //    gen.addAll(Arrays.asList(harmsBelow));
    //    gen.addAll(Arrays.asList(harmsAbove));
    //  }
    //  // High
    //  else {
    //    NoteEvent[] harms = harmonize(curNote, harmCount, false);
    //    gen.addAll(Arrays.asList(harms));
    //  }
      
    //  gen.add(curNote);
    //}
    
    //NoteEvent[] genResultArr = new NoteEvent[gen.size()];
    //return gen.toArray(genResultArr);
  }
  
  //// Does not include the note. The caller side can add it if needed.
  //private NoteEvent[] harmonize(NoteEvent note, int harmCount, boolean harmAboveNote) {
  //  NoteEvent[] harms = new NoteEvent[harmCount];
    
  //  int direction = 1;
  //  if (!harmAboveNote) {
  //    direction = -1;
  //  }
    
  //  NoteEvent curNote = note;
  //  int addedNoteCount = 0;
  //  for (int i = 0; i < harmCount; ++i) {
  //    NoteEvent harm = new NoteEvent(curNote);
  //    // TODO: This probably excludes MAX_HARM_INTERVAL.
  //    int newPitch = harm.getPitch() + (direction * int(random(MAX_HARM_INTERVAL)));
  //    if (newPitch > NoteEvent.PITCH_MAX) {
  //      continue;
  //    }
  //    harm.setPitch(newPitch);
  //    // It's important that we don't use i here, as i might skip the addition.
  //    harms[addedNoteCount] = harm;
  //    curNote = harm;
  //    ++addedNoteCount;
  //  }
    
  //  NoteEvent[] res = new NoteEvent[addedNoteCount];
  //  for (int i = 0; i < addedNoteCount; ++i) {
  //    res[i] = harms[i]; 
  //  }
    
  //  return res;
  //}
}
