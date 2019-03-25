// Keeps the seed same.
class GenIdentity extends GenerationMethod {
  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seed, DataPacketSet dataSet) {
    println("Generating identity.");
    NoteEvent[] gen = deepClone(seed);
    
    int defaultVelocity = int(map(
      pieceState.loudness.getValue(), 
      StateProperty.MIN_VAL, 
      StateProperty.MAX_VAL,
      NoteEvent.VELOCITY_MIN,
      NoteEvent.VELOCITY_MAX));
      
    for (NoteEvent note : gen) {
      note.setVelocity(defaultVelocity);
    }
      
    return gen;
  }
}
