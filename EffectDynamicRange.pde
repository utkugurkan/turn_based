class EffectDynamicRange extends EffectMethod {
  
  final int[] DYNAMIC_RANGE_CENTER_POINTS = {NoteEvent.VELOCITY_MIN, 50, 70, 90, NoteEvent.VELOCITY_MAX};
  private static final int _INDEX_RADIUS = 1;
  
  @Override
  void apply(NoteEvent[] seed) {
    println("Effect DynamicRange");
    
    for (NoteEvent note : seed) {
      int velocity = note.getVelocity();
      int closestIndex = findClosestDynamicRangeIndex(velocity);
      int minIndex = max(0, closestIndex - _INDEX_RADIUS);
      int maxIndex = min(DYNAMIC_RANGE_CENTER_POINTS.length - 1, closestIndex + _INDEX_RADIUS);
      int velIndex = int(random(minIndex, maxIndex + 0.5));
      
      note.setVelocity(DYNAMIC_RANGE_CENTER_POINTS[velIndex]);
    }
  }
  
  private int findClosestDynamicRangeIndex(int velocity) {
    int closestDiff = NoteEvent.VELOCITY_MAX;
    int closestIdx = -1;
    
    for (int i = 0; i < DYNAMIC_RANGE_CENTER_POINTS.length; ++i) {
      int thisDiff = abs(velocity - DYNAMIC_RANGE_CENTER_POINTS[i]);
      if (thisDiff < closestDiff) {
        closestDiff = thisDiff;
        closestIdx = i;
      }
    }
    
    return closestIdx;
  }
}
