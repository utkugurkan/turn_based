class GenEmpty extends GenerationMethod {
  
  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seed) {
    println("Generating empty.");
    return new NoteEvent[0];
  }
}
