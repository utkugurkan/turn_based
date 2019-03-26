public class TonalityStateProperty extends StateProperty {
  
  public TonalityStateProperty(String name) {
    super(name);
    resetProgress();
  }
  
  private Key _currentKey;
  private int _scaleIndex;
  
  @Override
  public void resetProgress() {
    super.resetProgress();
    
    _currentKey = getRandomKey(); 
    //println(SCALES[0].length);
    _scaleIndex = int(random(SCALES.length));
    
    //println("Current key is " + _currentKey.getValue());
  }
  
  public int[] getCurrentScalePitches() {
    int[] res = new int[SCALES[_scaleIndex].length];
    for (int i = 0; i < res.length; ++i) {
      res[i] = SCALES[_scaleIndex][i] + _currentKey.getValue();
    }
    return res;
  }
  
  public Key getKey() {
    return _currentKey;
  }
  
  public void setKey(Key newKey) {
    // TODO: Error check?
    _currentKey = newKey;
  }
  
  public int getScaleIndex() {
    return _scaleIndex; 
  }
  
  // Pass the index of the scale from the SCALES array in Key.
  public void setScaleIndex(int index) {
    // TODO: Error check?
    _scaleIndex = index;
  }
}
