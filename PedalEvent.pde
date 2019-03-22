public class PedalEvent {
  public PedalEvent(int velocity, int startTime) {
    _velocity = velocity;
    _startTime = startTime;
  }
  
  public int getVelocity() {
    return _velocity;
  }
  
  public int getStartTime() {
    return _startTime;
  }
  
  public void setStartTime(int startTime) {
    _startTime = startTime;
  }
  
  public static final int MIN_PEDAL_VELOCITY = 0; // Means off.
  public static final int MAX_PEDAL_VELOCITY = 120;
  
  private int _velocity;
  private int _startTime;
}

class SortPedalEventByStartTime implements Comparator<PedalEvent> {
  public int compare(PedalEvent lhs, PedalEvent rhs) {
    return lhs.getStartTime() - rhs.getStartTime();
  }
}
