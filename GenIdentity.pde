// Keeps the seed same.
class GenIdentity extends GenerationMethod {
  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seed) {
    println("Generating identity.");
    return deepClone(seed);
  }
}
