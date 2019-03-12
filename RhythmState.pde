public class RhythmState {
  public float[] fractions;
  public int timeLeft;
  
  public void printState() {
    print("Rhythm state with fractions ");
    for (float f : fractions) {
      print(f + ", ");
    }
    println(" time left: " + timeLeft);
  }
}
