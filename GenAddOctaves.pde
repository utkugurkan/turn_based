import java.util.ArrayList;

class GenAddOctaves extends GenerationMethod {
  
  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seed_in, DataPacketSet dataSet) {
    println("Adding octaves.");
    NoteEvent[] seed = deepClone(seed_in);
    ArrayList<NoteEvent> gen = new ArrayList<NoteEvent>();
    
    int defaultVelocity = int(map(
      pieceState.loudness.getValue(), 
      StateProperty.MIN_VAL, 
      StateProperty.MAX_VAL,
      NoteEvent.VELOCITY_MIN,
      NoteEvent.VELOCITY_MAX));
    
    for (NoteEvent note : seed) {
      NoteEvent newNote = new NoteEvent(note);
      newNote.setVelocity(defaultVelocity);
      gen.add(newNote);
      int octavePitch = note.getPitch() + 12;
      if (octavePitch <= NoteEvent.PITCH_MAX) {
        gen.add(new NoteEvent(
            octavePitch,
            defaultVelocity,
            note.getStartTime(),
            note.getDuration()));
      }
    }
    
    NoteEvent[] genResultArr = new NoteEvent[gen.size()];
    return gen.toArray(genResultArr);
  }
}
