UnaCordaPedalController unaCordaPedalController = new UnaCordaPedalController();

class UnaCordaPedalController {
  
  // Will only press pedal if the 
  private static final float LOUDNESS_UPPER_BOUND = 0.1f;
  private static final int MIN_ACTIVE_PEDAL_VELOCITY = 30;
  public PedalEvent[] genPedaling() {
    float pieceLoudness = pieceState.loudness.getValue();
    if (pieceLoudness > LOUDNESS_UPPER_BOUND) {
      return new PedalEvent[] { new PedalEvent(PedalEvent.MIN_PEDAL_VELOCITY, 0) };
    }
    
    // The closer pieceLoudness is to 0, the higher the pedal velocity is.
    int velocity = int(map(
      pieceLoudness,
      StateProperty.MIN_VAL,
      LOUDNESS_UPPER_BOUND,
      PedalEvent.MAX_PEDAL_VELOCITY,
      MIN_ACTIVE_PEDAL_VELOCITY));
      
    return new PedalEvent[] { new PedalEvent(velocity, 0) };
  }
  
}
