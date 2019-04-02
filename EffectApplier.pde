// The order matters in this array!!
final EffectMethod[] ENFORCED_EFFECTS = {
  //new EffectDynamicRangeEnforcer(),
  new EffectVaryKeyPress(),
  new EffectTonalityEnforcer()};

final EffectMethod[] EFFECTS = {
    new EffectIdentity(),
    //new EffectTransposePitch(),
    //new EffectDynamicRange(),
    //new EffectStaccato()
};

final ProbabilityBasedEffectApplier[] PROBABILISTICALLY_APPLIED_EFFECTS = {
  new ProbabilityBasedEffectApplier(new EffectDynamicRange()),
  new ProbabilityBasedEffectApplier(new EffectStaccato()), 
};

void applyAllEnforcedEffects(NoteEvent[] seed) {
  for (EffectMethod effect : ENFORCED_EFFECTS) {
    effect.apply(seed);
  }
}

void applyRandomEffect(NoteEvent[] seed) {
  int effectIndex = int(random(EFFECTS.length));
  EFFECTS[effectIndex].apply(seed);
}

void applyProbabilisticallyAppliedEffects(NoteEvent[] seed) {
  for (ProbabilityBasedEffectApplier effect : PROBABILISTICALLY_APPLIED_EFFECTS) {
    effect.maybeApply(seed);
  }
}

void updateProbabilisticallyAppliedEffects() {
  for (ProbabilityBasedEffectApplier effect : PROBABILISTICALLY_APPLIED_EFFECTS) {
    effect.update();
  }
}
