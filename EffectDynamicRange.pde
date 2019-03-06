class EffectDynamicRange extends EffectMethod {
  
  final int[] DYNAMIC_RANGE_CENTER_POINTS = {NoteEvent.VELOCITY_MIN, 50, 70, 90, NoteEvent.VELOCITY_MAX};
  
  @Override
  void apply(NoteEvent[] seed) {
    int centerPointIndex = int(random(DYNAMIC_RANGE_CENTER_POINTS.length));
    int centerPoint = DYNAMIC_RANGE_CENTER_POINTS[centerPointIndex];
    
    for (NoteEvent note : seed) {
      note.setVelocity(centerPoint);
    }
    
    // Vary the velocity a bit.
    EffectVaryKeyPress variationEffect = new EffectVaryKeyPress();
    variationEffect.apply(seed);
  }
  
}
