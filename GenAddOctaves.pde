import java.util.ArrayList;

class GenAddOctaves extends GenerationMethod {
  
  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seed_in, DataPacketSet dataSet) {
    println("Adding octaves.");
    NoteEvent[] seed = deepClone(seed_in);
    ArrayList<NoteEvent> gen = new ArrayList<NoteEvent>();
    
    for (NoteEvent note : seed) {
      gen.add(note);
      int octavePitch = note.getPitch() + 12;
      if (octavePitch <= NoteEvent.PITCH_MAX) {
        gen.add(new NoteEvent(
            octavePitch,
            note.getVelocity(),
            note.getStartTime(),
            note.getDuration()));
      }
    }
    
    NoteEvent[] genResultArr = new NoteEvent[gen.size()];
    return gen.toArray(genResultArr);
  }
}
