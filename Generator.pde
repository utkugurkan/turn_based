import java.lang.Object;

final GenerationMethod[] GEN_METHODS = {
    new GenAddOctaves(),
    new GenAddRandomPitchOffset(),
    //new GenFillBetweenNotes(),
    new GenEmpty(),
    new GenIdentity(),
    //new GenDisplaced(),
    //new GenRedistributeSeedContent(),
    //new GenForestAccompaniment(),
    new GenHarmony(),
    new GenMelody(),
    new GenAccompanimentPattern()
};

//final Class[] GEN_METHOD_TYPES = {
//  GenAccompanimentPattern.class
//};

//GenAccompanimentPattern pt = (GenAccompanimentPattern)GEN_METHOD_TYPES[0].newInstance();

class Generator {
  public Generator() {
    resetState();
    _genMethodState = new DataPacketSet();
  }
  
  public void update() {
    if (millis() >= _jobFinishTime) {
      resetState();
    }
  }
  
  public boolean isAvailable() {
    // TODO: Reconsider whether we actually need this.
    return true;
    //return !_busy;
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
    if (_genMethod == null) {
      println("_genMethod is NULL!!!!!!!");
    }
    NoteEvent[] genResult = _genMethod.generateFromSeed(seed, _genMethodState);
    
    // Set the end time of the generated material. This Generator will become available
    // at _jobFinishTime.
    _jobFinishTime = millis() + getEndTime(seed);
    ++_genMethodRepeatCurrentCount;
    
    println("Generator finished generation.");
    return genResult;
  }
  
  public void dropStateData() {
    _genMethodState = new DataPacketSet();
  }
  
  public GeneratorState getState() {
    return new GeneratorState(_genMethod, _genMethodState);
  }
  
  public void setState(GeneratorState state) {
    _genMethod = state.genMethod;
    _genMethodState = state.dataPacket;
    if (_genMethod == null) {
      setRandomGenerationMethod();
    }
    setNewRepeatData();
  }
  
  private void resetState() {
    _busy = false;
    _jobFinishTime = 0;
  }
  
  private void selectGenMethod() {
    // Repeated as many times as the target.
    if (_genMethodRepeatCurrentCount >= _genMethodRepeatTarget) {
      //println("Picking new generation method.");
      setRandomGenerationMethod();
      setNewRepeatData();
    }
  }
  
  private void setRandomGenerationMethod() {
    _genMethod = GEN_METHODS[int(random(GEN_METHODS.length))];
  }
  
  private void setNewRepeatData() {
      int minRepetition = _genMethod.getMinRecommendedGenerationCount();
      int maxRepetition = _genMethod.getMaxRecommendedGenerationCount();
      int halfRange = (maxRepetition - minRepetition) / 2;
      int mean = halfRange + minRepetition;
      
      _genMethodRepeatTarget = int(randomTruncatedGaussian(minRepetition, maxRepetition, mean, halfRange));
      println("Generation method will be repeated for times: " + _genMethodRepeatTarget);
      _genMethodRepeatCurrentCount = 0;
  }
  
  
  private boolean _busy;
  private int _jobFinishTime;
  private GenerationMethod _genMethod = null;
  //private float _genMethodRepeatRate = 0.5;
  private DataPacketSet _genMethodState = null;
  private int _genMethodRepeatTarget;
  private int _genMethodRepeatCurrentCount;
  
}

// Used to describe the state of what GenerationMethod is being used with what
// data.
public class GeneratorState {
  public GeneratorState(GenerationMethod genMethodIn, DataPacketSet dataPacketIn) {
    dataPacket = dataPacketIn.getCopy();
    genMethod = genMethodIn;
  }
  
  GenerationMethod genMethod;
  DataPacketSet dataPacket;
}
