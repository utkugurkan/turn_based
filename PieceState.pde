PieceState pieceState = new PieceState();

public class PieceState {
  static final float MIN_CHANGE_RATE = 0.02;
  static final float MAX_CHANGE_RATE = 0.2;
  
  static final int MIN_UPDATE_COUNT_TO_RESET = 1;
  static final int MAX_UPDATE_COUNT_TO_RESET = 15;
  
  public StateProperty speed = new StateProperty("speed");
  public StateProperty loudness = new StateProperty("loudness");
  public TonalityStateProperty tonality = new TonalityStateProperty("tonality");
  public StateProperty noteDensity = new StateProperty("noteDensity");
  public StateProperty sustainPedalLevel = new StateProperty("sustainPedalLevel");
  
  public StateProperty[] properties = { speed, loudness, tonality, noteDensity, sustainPedalLevel };
  
  // This is not update! Sets the state values randomly.
  public void genState() {
    for (StateProperty prop : properties) {
      resetProperty(prop);
    }
    
    //tonality.setValue(1.0f);
    //speed.setValue(0.9f);
    printAllProperties();
  }
  
  public void update() {
    for (StateProperty prop : properties) {
      if (prop.reachedResetCondition()) {
        println("Resetting property " + prop.getName() + ".");
        resetProperty(prop);
      } else {
        prop.update();
      }
    }
     
    //tonality.setValue(1.0f);
    //speed.setValue(0.9f);
    printAllProperties();
  }
  
  public void resetProperty(StateProperty prop) {
    prop.resetProgress();
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
  
  public void printAllProperties() {
    for (StateProperty prop : properties) {
      prop.print();
    }
  }
}
