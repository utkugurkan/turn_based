TestRhythmController testRhythmController = new TestRhythmController();

class TestRhythmController {
  
  public void runAllTests() {
    println();
    println("Running TestRhythmController...");
    
    testIdentity();
    testBasic();
    testAvoidingMeasureBoundary();
    testCalculateSeedMeasureCount();
    testStretchSeed();
  }
  
  public void testIdentity() {
    println("Running TestRhythmController.testIdentity");
    RhythmController rc = new RhythmController();
    
    int baseTime = 0;
    NoteEvent[] seed = new NoteEvent[5];
    seed[0] = new NoteEvent(55, 80, baseTime + 0, 1000);
    seed[1] = new NoteEvent(59, 80, baseTime + 1000, 1000);
    seed[2] = new NoteEvent(63, 80, baseTime + 2000, 1000);
    seed[3] = new NoteEvent(52, 80, baseTime + 3000, 1000);
    seed[4] = new NoteEvent(57, 80, baseTime + 4000, 1000);
    
    rc.setUnitNoteLength(1000);
    rc.setNotesPerMeasure(5);
    
    println("Original seed:");
    printNoteEvents(seed);
    println("Quantized seed:");
    printNoteEvents(rc.quantize(seed, 0));
    println();
  }
  
    public void testBasic() {
    println("Running TestRhythmController.testBasic");
    RhythmController rc = new RhythmController();
    
    int baseTime = 0;
    NoteEvent[] seed = new NoteEvent[5];
    seed[0] = new NoteEvent(55, 80, baseTime + 0, 1000);
    seed[1] = new NoteEvent(59, 80, baseTime + 1000, 1000);
    seed[2] = new NoteEvent(63, 80, baseTime + 2000, 1000);
    seed[3] = new NoteEvent(52, 80, baseTime + 3030, 1000);
    seed[4] = new NoteEvent(57, 80, baseTime + 4200, 1000);
    
    rc.setUnitNoteLength(1000);
    rc.setNotesPerMeasure(5);
    
    println("Original seed:");
    printNoteEvents(seed);
    println("Quantized seed:");
    printNoteEvents(rc.quantize(seed, 1));
    println();
  }
  
  public void testMultipleMeasures() {
    println("Running TestRhythmController.testSingle");
    RhythmController rc = new RhythmController();
    
    int baseTime = 0;
    NoteEvent[] seed = new NoteEvent[15];
    
    // Measure 1
    seed[0] = new NoteEvent(55, 80, baseTime + 0, 1000);
    seed[1] = new NoteEvent(59, 80, baseTime + 1000, 1000);
    seed[2] = new NoteEvent(63, 80, baseTime + 2000, 1000);
    seed[3] = new NoteEvent(52, 80, baseTime + 3030, 1000);
    seed[4] = new NoteEvent(57, 80, baseTime + 4200, 1000);
    
    // Measure 2
    seed[5] = new NoteEvent(55, 80, baseTime + 5000, 1000);
    seed[6] = new NoteEvent(59, 80, baseTime + 6000, 1000);
    seed[7] = new NoteEvent(63, 80, baseTime + 7000, 1000);
    seed[8] = new NoteEvent(52, 80, baseTime + 8030, 1000);
    seed[9] = new NoteEvent(57, 80, baseTime + 9200, 1000);
    
    // Measure 3
    seed[10] = new NoteEvent(55, 80, baseTime + 10000, 1000);
    seed[11] = new NoteEvent(59, 80, baseTime + 11111, 1000);
    seed[12] = new NoteEvent(63, 80, baseTime + 12000, 1000);
    seed[13] = new NoteEvent(52, 80, baseTime + 13030, 1000);
    seed[14] = new NoteEvent(57, 80, baseTime + 14200, 1000);
    
    rc.setUnitNoteLength(1000);
    rc.setNotesPerMeasure(5);
    
    println("Original seed:");
    printNoteEvents(seed);
    println("Quantized seed:");
    printNoteEvents(rc.quantize(seed, 2));
    println();
  }
  
    public void testAvoidingMeasureBoundary() {
    println("Running TestRhythmController.testAvoidingMeasureBoundary");
    RhythmController rc = new RhythmController();
    
    int baseTime = 0;
    NoteEvent[] seed = new NoteEvent[10];
    
    // Measure 1
    seed[0] = new NoteEvent(55, 80, baseTime + 0, 1000);
    seed[1] = new NoteEvent(59, 80, baseTime + 1000, 1000);
    seed[2] = new NoteEvent(63, 80, baseTime + 2000, 1000);
    seed[3] = new NoteEvent(52, 80, baseTime + 3000, 1000);
    // This should be quantized down even though it's closest
    // to the next measure.
    seed[4] = new NoteEvent(57, 80, baseTime + 3990, 10);
    
    // Measure 2
    seed[5] = new NoteEvent(55, 80, baseTime + 5000, 1000);
    seed[6] = new NoteEvent(59, 80, baseTime + 6000, 1000);
    seed[7] = new NoteEvent(63, 80, baseTime + 7000, 1000);
    seed[8] = new NoteEvent(52, 80, baseTime + 8000, 1000);
    // This should be quantized down even though it's closest
    // to the next measure.
    seed[9] = new NoteEvent(57, 80, baseTime + 9970, 30);
    
    rc.setUnitNoteLength(1000);
    rc.setNotesPerMeasure(5);
    
    println("Original seed:");
    printNoteEvents(seed);
    println("Quantized seed:");
    printNoteEvents(rc.quantize(seed, 3));
    println();
  }
  
  public void testCalculateSeedMeasureCount() {
    println("Running TestRhythmController.testCalculateSeedMeasureCount");
    RhythmController rc = new RhythmController();
    
    rc.setUnitNoteLength(1000);
    rc.setNotesPerMeasure(2);
    
    int baseTime = 0;
    NoteEvent[] seed = new NoteEvent[4];
    
    seed[0] = new NoteEvent(55, 80, baseTime + 0, 1000);
    seed[1] = new NoteEvent(59, 80, baseTime + 1000, 1000);
    seed[2] = new NoteEvent(63, 80, baseTime + 2000, 1000);
    seed[3] = new NoteEvent(52, 80, baseTime + 3000, 1000);
    
    int measureCount = rc.calculateSeedMeasureCount(seed);
    if (measureCount != 2) {
      println("TEST FAILED!");
      return;
    }
    
    seed = new NoteEvent[5];
    seed[0] = new NoteEvent(55, 80, baseTime + 0, 1000);
    seed[1] = new NoteEvent(59, 80, baseTime + 1000, 1000);
    seed[2] = new NoteEvent(63, 80, baseTime + 2000, 1000);
    seed[3] = new NoteEvent(52, 80, baseTime + 3000, 1000);
    seed[4] = new NoteEvent(52, 80, baseTime + 4200, 100);
    
    measureCount = rc.calculateSeedMeasureCount(seed);
    if (measureCount != 3) {
      println("TEST FAILED!");
      println();
      return;
    }
    
    println("TEST PASSED!");
    println();
  }
  
  public void testStretchSeed() {
    println("Running TestRhythmController.testStretchSeed");
    RhythmController rc = new RhythmController();
    
    int baseTime = 0;
    
    // Identity
    rc.setUnitNoteLength(2000);
    rc.setNotesPerMeasure(2);
    
    NoteEvent[] seed = new NoteEvent[4];
    seed[0] = new NoteEvent(55, 80, baseTime + 0, 1000);
    seed[1] = new NoteEvent(59, 80, baseTime + 1000, 1000);
    seed[2] = new NoteEvent(63, 80, baseTime + 2000, 1000);
    seed[3] = new NoteEvent(52, 80, baseTime + 3000, 1000);
    
    rc.stretchSeed(seed);
    println();
    println("Identity: ");
    printNoteEvents(seed);
    
    // Also identity
    rc.setUnitNoteLength(1000);
    rc.setNotesPerMeasure(2);
    seed = new NoteEvent[4];
    seed[0] = new NoteEvent(55, 80, baseTime + 0, 1000);
    seed[1] = new NoteEvent(59, 80, baseTime + 1000, 1000);
    seed[2] = new NoteEvent(63, 80, baseTime + 2000, 1000);
    seed[3] = new NoteEvent(52, 80, baseTime + 3000, 1000);
    
    rc.stretchSeed(seed);
    println();
    println("Identity: ");
    printNoteEvents(seed);
    
    // Stretch
    rc.setUnitNoteLength(1000);
    rc.setNotesPerMeasure(4);
    seed = new NoteEvent[6];
    seed[0] = new NoteEvent(55, 80, baseTime + 0, 1000);
    seed[1] = new NoteEvent(59, 80, baseTime + 1000, 1000);
    seed[2] = new NoteEvent(63, 80, baseTime + 2000, 1000);
    seed[3] = new NoteEvent(52, 80, baseTime + 3000, 1000);
    seed[4] = new NoteEvent(55, 80, baseTime + 4000, 1000);
    seed[5] = new NoteEvent(59, 80, baseTime + 5000, 1000);
    
    rc.stretchSeed(seed);
    println();
    println("Stretched: ");
    printNoteEvents(seed);
    println();
  }
}
