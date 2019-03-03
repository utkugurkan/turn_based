import java.util.ArrayList;

// Transposes notes in their timing.
// Transposed version cannot be in negative time,
// but it can end after the seed would.
class GenDisplaced extends GenerationMethod {
  
  static final int MAX_TIME_ADDITION_TO_SEED = 500; // in ms
  
  @Override
  NoteEvent[] generateFromSeed(NoteEvent[] seed) {
    println("Generating displaced.");
    
    int minDisplacement = -1 * seed[0].getStartTime();
    int displacement = int(random(minDisplacement, MAX_TIME_ADDITION_TO_SEED));
    
    //// Dummy note that will evaluate to minimum in the loop.
    //NoteEvent latestEndingNote = new NoteEvent(0, 0, 0, 0);
    //int maxDisplacement;
    //for (NoteEvent note : seed) {
    //  if (note.getEndTime() > latestEndingNote.getEndTime()) {
    //    latestEndingNote = 
    //  }
    //}
    
    NoteEvent[] gen = deepClone(seed);
    for (NoteEvent note : gen) {
      note.setStartTime(note.getStartTime() + displacement);
      note.setVelocity(int(random(NoteEvent.VELOCITY_MIN, NoteEvent.VELOCITY_MAX)));
    }
    
    return gen;
  }
}
