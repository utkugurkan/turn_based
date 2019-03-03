// The order matters in this array!!
final EffectMethod[] ENFORCED_EFFECTS = {
  new EffectDynamicRangeEnforcer(),
  new EffectVaryKeyPress(),
  new EffectTonalityEnforcer()};

final EffectMethod[] EFFECTS = {
    new EffectTransposePitch(),
    new EffectDynamicRange(),
    new EffectStaccato()};

void applyAllEnforcedEffects(NoteEvent[] seed) {
  for (EffectMethod effect : ENFORCED_EFFECTS) {
    effect.apply(seed);
  }
}

void applyRandomEffect(NoteEvent[] seed) {
  int effectIndex = int(random(EFFECTS.length));
  EFFECTS[effectIndex].apply(seed);
}
