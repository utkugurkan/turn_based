// Keeps the seed same.
class GenIdentity extends GenerationMethod {
  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seed, DataPacketSet dataSet) {
    println("Generating identity.");
    return deepClone(seed);
  }
}
