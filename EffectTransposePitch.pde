class EffectTransposePitch extends EffectMethod {
  @Override
  void apply(NoteEvent[] seed) {
    transposeByStep(seed, 1); // Transpose by multiples of 1.
  }
  
  // The minimum transposition "grain" is step.
  protected void transposeByStep(NoteEvent[] seed, int step) {
    int minPitch = NoteEvent.PITCH_MAX;
    int maxPitch = NoteEvent.PITCH_MIN;
    
    for (NoteEvent note : seed) {
      minPitch = min(minPitch, note.getPitch());
      maxPitch = max(maxPitch, note.getPitch());
    }
    
    int maxDownStep = (NoteEvent.PITCH_MIN - minPitch) / step;
    int maxUpStep = (NoteEvent.PITCH_MAX - maxPitch) / step;
    
    //println("Max Down Step is " + maxDownStep);
    //println("Max Up Step is " + maxUpStep);
    
    int transposeAmount = int(random(maxDownStep, maxUpStep)) * step;
    
    for (NoteEvent note : seed) {
      note.setPitch(note.getPitch() + transposeAmount); 
    }
  }
}
