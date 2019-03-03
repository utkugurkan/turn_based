// Keeps the seed same.
class GenForestAccompaniment extends GenerationMethod {
  //static final int MIN_NOTE_PER_SUBSET = 3;
  //static final int MAX_NOTE_PER_SUBSET = 8;
  
  static final int MIN_NOTE_DURATION = 125;
  static final int MAX_NOTE_DURATION = 500;
  
  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seed) {
    // Order for each subset: seed note, boundary note, everything else.
    // Pitch-wise:
    // Boundary note is the farthest any generated note can get from the seed note.
    // "Everything else" will be between the seed and boundary.
    
    //int genNotesPerSeedNote = 5; // TODO: Might want to have a variety in the future.
    //int genNotesPerSeedNote = int(map(
    //    pieceState.speed.getValue(), 
    //    StateProperty.MIN_VAL, 
    //    StateProperty.MAX_VAL, 
    //    MIN_NOTE_PER_SUBSET, 
    //    MAX_NOTE_PER_SUBSET)); 
        
    int genNoteDuration = int(map(
        pieceState.speed.getValue(),
        StateProperty.MAX_VAL,
        StateProperty.MIN_VAL, 
        MIN_NOTE_DURATION, 
        MAX_NOTE_DURATION));
    
    int maxDistanceFromSeedNote = 14; // How far the forest accompaniment subset can get from the seed note.
    int minDistanceFromSeedNoteForBoundaryNote = 8;
    //int minDurationPerGenNote = 140; // in ms
    
    println("Generating Forest Accompaniment with note length " + genNoteDuration);
    
    // Take out the notes that are played at the same time.
    ArrayList<NoteEvent> reducedSeed = new ArrayList<NoteEvent>();
    int curNote = 0;
    reducedSeed.add(seed[curNote]);
    
    int nextNote = curNote;
    // TODO: Reconsider/refactor hardcoded number.
    while ((nextNote = findNextNoteIndex(nextNote, seed, 500)) > 0) {
      reducedSeed.add(seed[nextNote]);
    }
    
    ArrayList<NoteEvent> genResult = new ArrayList<NoteEvent>();
    //NoteEvent[] genResult = new NoteEvent[reducedSeed.size() * genNotesPerSeedNote];
    boolean genAbove = true;
    for (int i = 0; i < reducedSeed.size(); ++i) {
      NoteEvent seedNote = reducedSeed.get(i);
      int timeForGen;
      if (i + 1 < reducedSeed.size()) {
         timeForGen = reducedSeed.get(i + 1).getStartTime() - seedNote.getStartTime();
      }
      else {
        timeForGen = seedNote.getDuration();
      }
      
      //int timeForEachGenNote = timeForGen / genNotesPerSeedNote;
      
      if (seedNote.getPitch() - maxDistanceFromSeedNote < NoteEvent.PITCH_MIN) {
        genAbove = true;
      }
      else if (seedNote.getPitch() + maxDistanceFromSeedNote > NoteEvent.PITCH_MAX) {
        genAbove = false;
      }
      
      int baseTime = seedNote.getStartTime(); 
      
      // Put seed note with adjusted start time and duration.
      genResult.add(new NoteEvent(
          seedNote.getPitch(), 
          seedNote.getVelocity(), 
          seedNote.getStartTime(), 
          genNoteDuration));
      //println("Forest subset");
      //print("Seed note: " + seedNote.getPitch());
      
      if (timeForGen < genNoteDuration * 2) {
        continue;
      }
      
      // Pick second (boundary note)
      int boundaryNotePitch;
      if (genAbove) {
        boundaryNotePitch = int(random(
            seedNote.getPitch() + minDistanceFromSeedNoteForBoundaryNote, 
            seedNote.getPitch() +  maxDistanceFromSeedNote));
      } else {
        boundaryNotePitch = int(random(
            seedNote.getPitch() - minDistanceFromSeedNoteForBoundaryNote, 
            seedNote.getPitch() -  maxDistanceFromSeedNote));
      }
      genResult.add(new NoteEvent(
          boundaryNotePitch, 
          seedNote.getVelocity(), 
          baseTime + genNoteDuration, 
          genNoteDuration));
      //print(", " + boundaryNotePitch);
          
          
      // Put all other notes in between these two.
      int timestamp = baseTime + genNoteDuration * 2;
      while (timestamp < baseTime + timeForGen) {
        int pitchMax = max(seedNote.getPitch(), boundaryNotePitch);
        int pitchMin = min(seedNote.getPitch(), boundaryNotePitch);
        int determinedPitch = int(random(pitchMin, pitchMax));
        genResult.add(new NoteEvent(
            determinedPitch,
            seedNote.getVelocity(), 
            timestamp, 
            genNoteDuration));
        //print(", " + determinedPitch);
        
        timestamp += genNoteDuration;
      }
      //println();
      
      genAbove = !genAbove;
    }
    
    NoteEvent[] genResultArr = new NoteEvent[genResult.size()];
    return genResult.toArray(genResultArr);
    //return genResult;
  }
}
