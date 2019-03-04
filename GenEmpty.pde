class GenEmpty extends GenerationMethod {
  
  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seed, DataPacketSet dataSet) {
    println("Generating empty.");
    return new NoteEvent[0];
  }
}
