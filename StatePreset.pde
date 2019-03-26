StatePreset[] statePresets = new StatePreset[] {
  new EbbStatePreset(),
  new BlowingFeatherStatePreset(),
};

abstract class StatePreset {
  
  public StateProperty speed = null;
  public StateProperty loudness = null;
  public TonalityStateProperty tonality = null;
  public StateProperty noteDensity = null;
  public StateProperty sustainPedalLevel = null;
  
  public GenerationMethod[] genMethods = null;
  
  //private StateProperty[] _properties = { speed, loudness, tonality, noteDensity, sustainPedalLevel };
  
  public void applyPreset(PieceState pState, Generator[] generators) {
    println("Applying preset " + this.getClass().getName());
    StateProperty[] properties = getPropertiesArray();
    for (int i = 0; i < properties.length; ++i) {
      if (properties[i] != null) {
        pState.properties[i].copyParameters(properties[i]);
      }
    }
    
    if (genMethods != null && generators != null) {
      for (int i = 0; i < generators.length; ++i) {
        if (genMethods[i] != null) {
          generators[i].setState(new GeneratorState(genMethods[i], null));
        }
      }
    } 
  }
  
  protected StateProperty[] getPropertiesArray() {
    return new StateProperty[] { speed, loudness, tonality, noteDensity, sustainPedalLevel };
  }
}

class EbbStatePreset extends StatePreset {
  private static final int LENGTH = 15;
  
  public EbbStatePreset() {
    speed = new StateProperty("speed");
    speed.setValue(0.1f);
    speed.setTargetValue(0.1f);
    speed.setChangeRatePerTurn(0.0f);
    speed.setUpdateCountToReset(LENGTH);
    
    
    loudness = new StateProperty("loudness");
    loudness.setValue(0.05f);
    loudness.setTargetValue(0.05f);
    loudness.setChangeRatePerTurn(0.0f);
    loudness.setUpdateCountToReset(LENGTH);
  }
}

class BlowingFeatherStatePreset extends StatePreset {
  private static final int LENGTH = 15;
  
  public BlowingFeatherStatePreset() {
    speed = new StateProperty("speed");
    speed.setValue(0.95f);
    speed.setTargetValue(0.95f);
    speed.setChangeRatePerTurn(0.0f);
    speed.setUpdateCountToReset(LENGTH);
    
    
    loudness = new StateProperty("loudness");
    loudness.setValue(0.05f);
    loudness.setTargetValue(0.05f);
    loudness.setChangeRatePerTurn(0.0f);
    loudness.setUpdateCountToReset(LENGTH);
  }
}
