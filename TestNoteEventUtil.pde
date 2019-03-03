TestNoteEventUtil testNoteEventUtil = new TestNoteEventUtil();

class TestNoteEventUtil {
  public void runAllTests() {
    println();
    println("Running TestNoteEventUtil...");
    testCalculatePitch();
    testCalculateKey();
    testGetClosestPitch();
  }

  
  public void testCalculatePitch() {
    println("Running TestNoteEventUtil.testCalculatePitch");
    
    assert calculatePitch(Key.A, 2) == 45;
    assert calculatePitch(Key.C_SHARP, 0) == 25;
    assert calculatePitch(Key.D_SHARP, 6) == 99;
    assert calculatePitch(Key.C, 7) == 108;
    
    println("Test passed");
  }


    public void testCalculateKey() {
    println("Running TestNoteEventUtil.testCalculateKey");
    
    assert calculateKey(new NoteEvent(45, 0, 0, 0)) == Key.A;
    assert calculateKey(new NoteEvent(25, 0, 0, 0)) == Key.C_SHARP;
    assert calculateKey(new NoteEvent(99, 0, 0, 0)) == Key.D_SHARP;
    assert calculateKey(new NoteEvent(108, 0, 0, 0)) == Key.C;
    
    println("Test passed");
  }
  
  public void testGetClosestPitch() {
    println("Running TestNoteEventUtil.testGetClosestPitch");
    
    assert getClosestPitch(Key.A, new NoteEvent(21, 0, 0, 0)) == 21;
    assert getClosestPitch(Key.G, new NoteEvent(47, 0, 0, 0)) == 43;
    assert getClosestPitch(Key.G, new NoteEvent(59, 0, 0, 0)) == 55;
    
    assert getClosestPitch(Key.B, new NoteEvent(21, 0, 0, 0)) == 23;
    println(getClosestPitch(Key.D, new NoteEvent(108, 0, 0, 0)));
    assert getClosestPitch(Key.D, new NoteEvent(108, 0, 0, 0)) == 98;
    
    println("Test passed");
  }
}
