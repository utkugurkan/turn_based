final int MIN_MIDI_NOTE = 21; // The lowest midi note, also an A.
final int MAX_MIDI_NOTE = 108; // The lowest midi note, also an A.

boolean isInKey(NoteEvent note) {
  int pitch = note.getPitch();
  Key curKey = pieceState.tonality.getKey();
  int scaleIndex = pieceState.tonality.getScaleIndex();
  
  int basedPitch = (pitch - MIN_MIDI_NOTE) % 12;
  for (int i = 0; i < SCALES[scaleIndex].length; ++i) {
    // Add the current key's offset to adjust the sample scale to match the current key. 
    if (basedPitch == (SCALES[scaleIndex][i] + curKey.getValue() - MIN_MIDI_NOTE) % 12) {
      return true;
    }
  }
  
  //println(pitch);
  //println(basedPitch);
  //println(scaleIndex);
  //println(curKey.getValue());
  return false;
}
