private class TemplateState {
  public TemplateState(PatternEntity[] templateIn, int curIndexIn, int unitNoteLengthIn, NoteEvent prevNoteIn) {
    template = templateIn;
    curIndex = curIndexIn;
    unitNoteLength = unitNoteLengthIn;
    prevNote = prevNoteIn;
  }
  public PatternEntity[] template;
  public int curIndex;
  public int unitNoteLength;
  public NoteEvent prevNote;
}
