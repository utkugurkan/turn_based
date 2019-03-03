TestTonality testTonality = new TestTonality();

class TestTonality {
  public void runAllTests() {
    println();
    println("Running TestTonality...");
    testIdentity();
    testFullyTonal();
  }
  
  public void testIdentity() {
    println("Running TestTonality.testIdentity");
    
    EffectTonalityEnforcer tonalityEnforcer = new EffectTonalityEnforcer();
    TonalityStateProperty tonalityProp = pieceState.tonality;
    
    // Set to C major.
    tonalityProp.setKey(Key.C);
    tonalityProp.setScaleIndex(0);
    // Make sure the notes will not be adjusted based on tonality. 
    tonalityProp.setValue(StateProperty.MIN_VAL);
    
    int baseTime = 0;
    // Nothing in the seed will be in C major.
    NoteEvent[] seed = new NoteEvent[8];
    seed[0] = new NoteEvent(37, 80, baseTime + 0, 1000); // C#
    seed[1] = new NoteEvent(39, 80, baseTime + 0, 1000); // D#
    seed[2] = new NoteEvent(40, 80, baseTime + 0, 1000); // E (in key)
    seed[3] = new NoteEvent(41, 80, baseTime + 0, 1000); // F (in key)
    seed[4] = new NoteEvent(42, 80, baseTime + 0, 1000); // F#
    seed[5] = new NoteEvent(44, 80, baseTime + 0, 1000); // G#
    seed[6] = new NoteEvent(46, 80, baseTime + 0, 1000); // A#
    seed[7] = new NoteEvent(48, 80, baseTime + 0, 1000); // C
    
    NoteEvent[] resSeed = deepClone(seed);
    tonalityEnforcer.apply(resSeed);
    
    for (int i = 0; i < seed.length; ++i) {
      if (seed[i].getPitch() != resSeed[i].getPitch()) {
        println("Test failed.");
        return;
      }
    }
    
    println("Test passed!");
  }
  
  // Pass a seed that is not obeying the tonal rules of the set key.
  // Then test whether the tonality enforcer puts it in key.
  public void testFullyTonal() {
    println("Running TestTonality.testFullyTonal");
    
    EffectTonalityEnforcer tonalityEnforcer = new EffectTonalityEnforcer();
    TonalityStateProperty tonalityProp = pieceState.tonality;
    
    // Set to C major.
    tonalityProp.setKey(Key.C);
    tonalityProp.setScaleIndex(0);
    // Make sure it's fully tonal.
    tonalityProp.setValue(StateProperty.MAX_VAL);
    
    int baseTime = 0;
    // Nothing in the seed will be in C major.
    NoteEvent[] seed = new NoteEvent[8];
    seed[0] = new NoteEvent(37, 80, baseTime + 0, 1000); // C#
    seed[1] = new NoteEvent(39, 80, baseTime + 0, 1000); // D#
    seed[2] = new NoteEvent(40, 80, baseTime + 0, 1000); // E (in key)
    seed[3] = new NoteEvent(41, 80, baseTime + 0, 1000); // F (in key)
    seed[4] = new NoteEvent(42, 80, baseTime + 0, 1000); // F#
    seed[5] = new NoteEvent(44, 80, baseTime + 0, 1000); // G#
    seed[6] = new NoteEvent(46, 80, baseTime + 0, 1000); // A#
    seed[7] = new NoteEvent(48, 80, baseTime + 0, 1000); // C
    
    tonalityEnforcer.apply(seed);
    
    for (NoteEvent note : seed) {
      if (!isInKey(note)) {
        println("Test failed.");
        printNoteEvent(note);
      }
    }
    println("Test passed!");
  }
}
