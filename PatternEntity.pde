public class PatternEntity {
  public PatternEntity(int pitchIn, int lengthIn) {
    pitchDiff = pitchIn;
    length = lengthIn;
  }
  
  public void print() {
    println("Pattern entity with pitch difference: " + pitchDiff + ", with length: " + length);
  }
  
  // Set to 0 for the first note.
  public int pitchDiff;
  public int length; // in terms of unit note.
}
