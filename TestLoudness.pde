TestLoudness testLoudness = new TestLoudness();

class TestLoudness {
  public void runAllTests() {
    println();
    println("Running TestLoudness...");
    testValueAdjustments();
  }

  
  // Set to loudest and make sure every note is getting adjusted accordingly.
  public void testValueAdjustments() {
    println("Running TestLoudness.testValueAdjustments");
    
    EffectDynamicRangeEnforcer loudnessEnforcer = new EffectDynamicRangeEnforcer();
    StateProperty loudnessProp = pieceState.loudness;
    
    // Make sure it's as loud as possible.
    loudnessProp.setValue(StateProperty.MAX_VAL);
    
    int baseTime = 0;
    NoteEvent[] seed = new NoteEvent[6];
    seed[0] = new NoteEvent(37, 80, baseTime + 0, 1000);
    seed[1] = new NoteEvent(37, 40, baseTime + 0, 1000);
    seed[2] = new NoteEvent(37, 110, baseTime + 0, 1000);
    seed[3] = new NoteEvent(37, 20, baseTime + 0, 1000);
    seed[4] = new NoteEvent(37, 35, baseTime + 0, 1000);
    seed[5] = new NoteEvent(37, 60, baseTime + 0, 1000);
    
    loudnessEnforcer.apply(seed);
    
    for (NoteEvent note : seed) {
      if (note.getVelocity() != EffectDynamicRangeEnforcer.MAX_VELOCITY) {
        println("Test failed.");
        printNoteEvent(note);
      }
    }
    println("Test passed!");
  }
}
