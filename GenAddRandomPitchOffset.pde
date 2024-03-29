import java.util.ArrayList;

class GenAddRandomPitchOffset extends GenerationMethod {
  
  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seed, DataPacketSet dataSet) {
    println("Adding random offset.");
    ArrayList<NoteEvent> gen = new ArrayList<NoteEvent>();
    
    int defaultVelocity = int(map(
      pieceState.loudness.getValue(), 
      StateProperty.MIN_VAL, 
      StateProperty.MAX_VAL,
      NoteEvent.VELOCITY_MIN,
      NoteEvent.VELOCITY_MAX));
    
    for (NoteEvent note : seed) {
      int newPitch = min(note.getPitch() + int(random(12)), NoteEvent.PITCH_MAX);
      gen.add(new NoteEvent(
            newPitch,
            defaultVelocity,
            note.getStartTime(),
            note.getDuration()));
    }
    
    NoteEvent[] genResultArr = new NoteEvent[gen.size()];
    return gen.toArray(genResultArr);
  }
}
