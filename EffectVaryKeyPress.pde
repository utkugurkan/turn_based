class EffectVaryKeyPress extends EffectMethod {
  
  static final int VELOCITY_VARIATION = 4;
  static final int START_TIME_VARIATION = 10;
  static final int DURATION_VARIATION = 10;
  
  @Override
  void apply(NoteEvent[] seed) {
    for (NoteEvent note : seed) {
      note.setVelocity(int(random(note.getVelocity() - VELOCITY_VARIATION, note.getVelocity() + VELOCITY_VARIATION)));
      note.setStartTime(int(random(note.getStartTime() - START_TIME_VARIATION, note.getStartTime() + START_TIME_VARIATION)));
      note.setDuration(int(random(note.getDuration() - DURATION_VARIATION, note.getDuration() + DURATION_VARIATION)));
    }
    
  }
}
