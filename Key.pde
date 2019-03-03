// Simply represents the root note of a key.
public enum Key {
  A(0), A_SHARP(1), B(2), C(3), C_SHARP(4), 
  D(5), D_SHARP(6), E(7), F(8), F_SHARP(9),
  G(10), G_SHARP(11);
  
  public static final int MIN_PITCH = 0;
  public static final int MAX_PITCH = 11;
  
  private int _val;
  
  private Key(int val) {
    if (val < MIN_PITCH) {
      val = MIN_PITCH;
    } else if (val > MAX_PITCH) {
      val = MAX_PITCH;
    }
    _val = val;
  }
  
  public int getValue() {
    return _val; 
  }
};

int[][] SCALES = {
  { 21, 23, 25, 26, 28, 30, 32 }, // Major scale (A major)
  { 21, 23, 24, 26, 28, 29, 32 }, // Harmonic minor scale (A minor)
};
