class EffectDynamicRangeEnforcer extends EffectMethod {
  public static final int MIN_VELOCITY = 40;
  public static final int MAX_VELOCITY = 110;
  
  @Override
  void apply(NoteEvent[] seed) {
    float pieceLoudnessStateCoeff = pieceState.loudness.getValue();
    
    int noteVelocity = int(map(
      pieceLoudnessStateCoeff,
      StateProperty.MIN_VAL,
      StateProperty.MAX_VAL, 
      MIN_VELOCITY, 
      MAX_VELOCITY));
    //println("Note velocity: " + noteVelocity);
    
    for (NoteEvent note : seed) {
      note.setVelocity(noteVelocity);
    }
  }
}
