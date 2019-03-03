import java.lang.Object;

final GenerationMethod[] GEN_METHODS = {
    //new GenAddOctaves(),
    //new GenAddRandomPitchOffset(),
    ////new GenFillBetweenNotes(),
    //new GenEmpty(),
    //new GenIdentity(),
    //new GenDisplaced(),
    //new GenRedistributeSeedContent(),
    //new GenForestAccompaniment(),
    //new GenHarmony(),
    //new GenMelody(),
    new GenAccompanimentPattern()
};

//final Class[] GEN_METHOD_TYPES = {
//  GenAccompanimentPattern.class
//};

//GenAccompanimentPattern pt = (GenAccompanimentPattern)GEN_METHOD_TYPES[0].newInstance();

class Generator {
  public Generator() {
    resetState();
  }
  
  public void update() {
    if (millis() >= _jobFinishTime) {
      resetState();
    }
  }
  
  public boolean isAvailable() {
    return !_busy;
  }
  
  public void setJobFinishTime(int finishTime) {
    _jobFinishTime = finishTime;
  }
  
  public NoteEvent[] generate(NoteEvent[] seed) {
    if (!isAvailable()) {
      return new NoteEvent[]{};
    }
    
    _busy = true; // Set busy until all the generated material is played (based on the end time).
    //GenerationMethod randomGenMethod = GEN_METHODS[int(random(GEN_METHODS.length))];
    selectGenMethod();
    NoteEvent[] genResult = _genMethod.generateFromSeed(seed);
    
    // Set the end time of the generated material. This Generator will become available
    // at _jobFinishTime.
    _jobFinishTime = millis() + getEndTime(seed);
    
    return genResult;
  }
  
  private void resetState() {
    _busy = false;
    _jobFinishTime = 0;
  }
  
  private void selectGenMethod() {
    if (_genMethod != null && random(1.0) <= _genMethodRepeatRate) {
      return;
    }
    else {
      _genMethod = GEN_METHODS[int(random(GEN_METHODS.length))];
    }
  }
  
  private boolean _busy;
  private int _jobFinishTime;
  private GenerationMethod _genMethod = null;
  private float _genMethodRepeatRate = 0.5;
}
