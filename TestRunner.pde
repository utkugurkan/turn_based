TestRunner testRunner = new TestRunner();

public class TestRunner {
  public boolean haveRunTests = false;
  
  
  void runAllTestsOnce() {
    if (haveRunTests) {
      return;
    }
    haveRunTests = true;
    
    testRhythmController.runAllTests();
    testTonality.runAllTests();
    testLoudness.runAllTests();
    testNoteEventUtil.runAllTests();
    testStatsUtil.runAllTests();
    testDataPacket.runAllTests();
  }
}
