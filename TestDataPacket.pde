TestDataPacket testDataPacket = new TestDataPacket();

class TestDataPacket {
  public void runAllTests() {
    println();
    println("Running TestDataPacket...");
    testBasic();
  }
  
  private void testBasic() {
    println("Running TestDataPacket.testBasic");
    
    NoteEvent note = new NoteEvent(50, 30, 100, 100);
    NoteEvent[] noteArr = { new NoteEvent(30, 30, 30, 30), new NoteEvent(40, 40, 40, 40) };
    
    //DataPacket data = new DataPacket(DataPacketType.NOTE_EVENT, note);
    DataPacket data = new DataPacket(note);
    assert data.type == note.getClass();
    assert ((NoteEvent)data.value).getPitch() == note.getPitch();
    
    data = new DataPacket(noteArr);
    assert data.type == noteArr.getClass();
    NoteEvent[] dataNoteArr = (NoteEvent[])data.value;
    assert dataNoteArr[0].Equals(noteArr[0]);
    assert dataNoteArr[1].Equals(noteArr[1]);
    
    // Test DataPacketSet
    DataPacketSet dataSet = new DataPacketSet();
    dataSet.data = new DataPacket[2];
    dataSet.data[0] = new DataPacket(note);
    dataSet.data[1] = new DataPacket(noteArr);
    
    assert dataSet.data[0].type == note.getClass();
    assert ((NoteEvent)dataSet.data[0].value).getPitch() == note.getPitch();
    
    assert dataSet.data[1].type == noteArr.getClass();
    NoteEvent[] dataSetNoteArr = (NoteEvent[])dataSet.data[1].value;
    assert dataSetNoteArr[0].Equals(noteArr[0]);
    assert dataSetNoteArr[1].Equals(noteArr[1]);
    
    println("Test passed.");
  }

  
  
}
