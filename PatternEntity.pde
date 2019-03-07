public class PatternEntity {
  public PatternEntity(int pitchIn, int lengthIn, boolean isRestIn) {
    pitchDiff = pitchIn;
    length = lengthIn;
    isRest = isRestIn;
  }
  
  public PatternEntity(PatternEntity other) {
    this(other.pitchDiff, other.length, other.isRest);
  }
  
  public void print() {
    println("Pattern entity with pitch difference: " + pitchDiff + ", with length: " + length);
  }
  
  // Set to 0 for the first note.
  public int pitchDiff;
  public int length; // in terms of unit note.
  public boolean isRest; // Indicates silent portions.
  
}
