class EffectTonalityEnforcer extends EffectMethod {
  final int MIN_VELOCITY = 40;
  final int MAX_VELOCITY = 110;
  //final int MIN_MIDI_NOTE = 21; // The lowest midi note, also an A.
  
  @Override
  void apply(NoteEvent[] seed) {
    // This coefficient is used as the likelihood of "fixing" each note to follow
    // the current scale.
    float tonalityCoeff = pieceState.tonality.getValue();
    int[] currentScale = pieceState.tonality.getCurrentScalePitches();
    // TODO: This should probably be cached somewhere.
    // Remove the MIDI offset from the notes for comparison purposes.
    for (int i = 0; i < currentScale.length; ++i) {
      //println("currentScale: " + currentScale[i]); 
      currentScale[i] = (currentScale[i] - MIN_MIDI_NOTE) % 12;
      //println("currentScale: " + currentScale[i]); 
    }
    
    for (NoteEvent note : seed) {
      if (random(1.) < tonalityCoeff) {
        int originalPitch = note.getPitch();
        int basedPitch = originalPitch - MIN_MIDI_NOTE;
        // 12 stands for an octave in terms of semi-tones.
        int compPitch = basedPitch % 12;
        int octavesToAddBack = (basedPitch) / 12;
        //println("octavesToAddBack " + octavesToAddBack);
        // For the tonality purposes, round to closest tonal pitch.
        int minOffset = 12;
        for (int i = 0; i < currentScale.length; ++i) {
          // TODO: Careful! This is biased towards rounding down. Might want to fix.
          if (abs(currentScale[i] - compPitch) < abs(minOffset)) {
            minOffset = currentScale[i] - compPitch;
          }
        }
        
        int finalPitch = MIN_MIDI_NOTE + compPitch + minOffset + (12 * octavesToAddBack);
        note.setPitch(finalPitch);
        //println("Set pitch from " + originalPitch + " to " + finalPitch);
      }
    }
  }
}
