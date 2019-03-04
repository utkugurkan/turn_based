PieceState pieceState = new PieceState();

public class PieceState {
  static final float MIN_CHANGE_RATE = 0.02;
  static final float MAX_CHANGE_RATE = 0.2;
  
  static final int MIN_UPDATE_COUNT_TO_RESET = 1;
  static final int MAX_UPDATE_COUNT_TO_RESET = 15;
  
  public StateProperty speed = new StateProperty("speed");
  public StateProperty loudness = new StateProperty("loudness");
  public TonalityStateProperty tonality = new TonalityStateProperty("tonality"); 
  
  private StateProperty[] _properties = { speed, loudness, tonality };
  
  // This is not update! Sets the state values randomly.
  public void genState() {
    for (StateProperty prop : _properties) {
      resetProperty(prop);
    }
    
    //println("Speed value: " + speed.getValue() + ", change rate: " + speed.getChangeRatePerTurn() + 
    //", target: " + speed.getTargetValue());
    //println("Loudness value: " + loudness.getValue() + ", change rate: " + loudness.getChangeRatePerTurn() + 
    //", target: " + loudness.getTargetValue());
    //println("Tonality value: " + tonality.getValue() + ", change rate: " + tonality.getChangeRatePerTurn() + 
    //", target: " + tonality.getTargetValue());
    
    speed.print();
    loudness.print();
  }
  
  public void update() {
    for (StateProperty prop : _properties) {
      if (prop.reachedResetCondition()) {
        println("Resetting!!!!!!");
        resetProperty(prop);
      } else {
        prop.update();
      }
    }
    //println("Speed value: " + speed.getValue() + ", change rate: " + speed.getChangeRatePerTurn() + 
    //", target: " + speed.getTargetValue());
    //println("Loudness value: " + loudness.getValue() + ", change rate: " + loudness.getChangeRatePerTurn() + 
    //", target: " + loudness.getTargetValue());
    //println("Tonality value: " + tonality.getValue() + ", change rate: " + tonality.getChangeRatePerTurn() + 
    //", target: " + tonality.getTargetValue());
     
    speed.setValue(1.0f);
    speed.print();
    loudness.print();
  }
  
  public void resetProperty(StateProperty prop) {
    prop.reset();
    prop.setValue(random(StateProperty.MIN_VAL, StateProperty.MAX_VAL));
    prop.setTargetValue(random(StateProperty.MIN_VAL, StateProperty.MAX_VAL));
    float changeRate = random(MIN_CHANGE_RATE, MAX_CHANGE_RATE);
    if (prop.getValue() < prop.getTargetValue()) {
      prop.setChangeRatePerTurn(changeRate);
    }
    else {
      prop.setChangeRatePerTurn(changeRate * -1.);
    }
    prop.setUpdateCountToReset(int(random(
      MIN_UPDATE_COUNT_TO_RESET, 
      MAX_UPDATE_COUNT_TO_RESET)));
      
    println("After reset: ");
    loudness.print();
  }
}
