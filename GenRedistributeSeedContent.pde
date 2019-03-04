// Keeps the seed same.
class GenRedistributeSeedContent extends GenerationMethod {
  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seed, DataPacketSet dataSet) {
    
    println("Generating Redistribution.");
    int endTime = getEndTime(seed);
    NoteEvent[] genResult = new NoteEvent[seed.length];
    int noteDuration = endTime / seed.length;
    
    for (int i = 0; i < seed.length; ++i) {
      NoteEvent adjustedNote = new NoteEvent(seed[i].getPitch(), seed[i].getVelocity(), noteDuration * i, noteDuration);
      genResult[i] = adjustedNote;
    }
    
    return genResult;
  }
}
