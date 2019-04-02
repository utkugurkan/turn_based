
// There is a minimum and maximum chance of effect application.
// The idea is to create a spike from the minimum to the maximum, and
// then decay to minimum.
class ProbabilityBasedEffectApplier {
  
  public ProbabilityBasedEffectApplier(EffectMethod effect) {
    _effect = effect;
    _curProb = _MIN_APPLICATION_PROBABILITY;
  }
  
  public void maybeApply(NoteEvent[] seed) {
    if (random(1.0) < _curProb) {
      _effect.apply(seed);
      // If we're at MIN, we create a spike to MAX.
      if (abs(_curProb - _MIN_APPLICATION_PROBABILITY) < _COMPARISON_THRESHOLD) {
        _curProb = _MAX_APPLICATION_PROBABILITY;
      }
      else {
        _curProb = min(_curProb + _PROBABILITY_INCREASE_RATE, _MAX_APPLICATION_PROBABILITY);
      }
      println("Changing effect chance to " + _curProb);
    }
  }
  
  public void update() {
    _curProb = max(_curProb - _PROBABILITY_DECAY_RATE, _MIN_APPLICATION_PROBABILITY);
    println("Effect chance: " + _curProb);
  }
  
  private static final float _MIN_APPLICATION_PROBABILITY = 0.05f;
  private static final float _MAX_APPLICATION_PROBABILITY = 0.20f;
  
  private static final float _PROBABILITY_DECAY_RATE = 0.05f;
  private static final float _PROBABILITY_INCREASE_RATE = 0.05f;
  
  private static final float _COMPARISON_THRESHOLD = 0.01;
  
  private EffectMethod _effect;
  private float _curProb;
}
