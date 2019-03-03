class EffectStaccato extends EffectMethod {
  
  static final int MIN_DURATION = 26;
  static final int MAX_DURATION = 34;
  
  @Override
  void apply(NoteEvent[] seed) {
    println("Effect Staccato");
    for (NoteEvent note : seed) {
      note.setDuration(int(random(MIN_DURATION, MAX_DURATION)));
    }
  }
}
