import java.util.ArrayList;

class GenAddRandomPitchOffset extends GenerationMethod {
  
  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seed) {
    println("Adding random offset.");
    ArrayList<NoteEvent> gen = new ArrayList<NoteEvent>();
    
    for (NoteEvent note : seed) {
      int newPitch = min(note.getPitch() + int(random(12)), NoteEvent.PITCH_MAX);
      gen.add(new NoteEvent(
            newPitch,
            note.getVelocity(),
            note.getStartTime(),
            note.getDuration()));
    }
    
    NoteEvent[] genResultArr = new NoteEvent[gen.size()];
    return gen.toArray(genResultArr);
  }
}
