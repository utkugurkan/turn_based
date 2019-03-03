class EffectDynamicRange extends EffectMethod {
  
  final int[] DYNAMIC_RANGE_CENTER_POINTS = {20, 50, 70, 90, 110};
  
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
