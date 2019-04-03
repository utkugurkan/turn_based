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

//ArrayList<PedalEvent> smoothenPedaling(ArrayList<PedalEvent> pedaling, int pressDuration, int releaseDuration, PedalEvent lastPedaling) {
//  ArrayList<PedalEvent> res = new ArrayList<PedalEvent>();
//  PedalEvent curPedaling = new PedalEvent(lastPedaling.getVelocity(), 0);
  
//  for (int i = 0; i < pedaling.size(); ++i) {
//    PedalEvent nextPedaling = pedaling.get(i);
//    boolean isRelease = nextPedaling.getVelocity() == 0;
//    if (
//  }
  
//  return res;
//}

static final int NUM_DIVISIONS_FOR_SMOOTH_PEDAL_CHANGE = 10;
static final float INTERPOLATION_AMOUNT_FOR_SMOOTH_PEDAL_CHANGE = 0.1f;
ArrayList<PedalEvent> getSmoothPedalChange(int startingVelocity, int finalVelocity, int baseTime, int changeDuration) {
  
  // Lerp method.
  
  //int diff = (finalVelocity - startingVelocity) * -1;
  //ArrayList<Integer> diffList = new ArrayList<Integer>();
  //diffList.add(diff);
  //while (abs(diff) > 1) {
  //  float newDiff = lerp(diff, 0f, INTERPOLATION_AMOUNT_FOR_SMOOTH_PEDAL_CHANGE);
  //  diff = int(newDiff);
  //  diffList.add(diff);
  //}
  
  //int divisionCount = diffList.size();
  //int divisionLength = changeDuration / divisionCount;
  
  //ArrayList<PedalEvent> res = new ArrayList<PedalEvent>();
  //for (int i = 0; i < divisionCount; ++i) {
  //  int velocity = diffList.get(i) + finalVelocity;
  //  int time = baseTime + i * divisionLength;
    
  //  PedalEvent pedal = new PedalEvent(velocity, time);
  //  res.add(pedal);
  //}
  
  //PedalEvent finalPedal = new PedalEvent(finalVelocity, baseTime + changeDuration);
  //res.add(finalPedal);
  
  ////println("Starting velocity is : " + startingVelocity + " and final is : " + finalVelocity);
  ////for (PedalEvent pedal : res) {
  ////  println("Velocity: " + pedal.getVelocity());
  ////}
  
  
  //return res;
  
  // Linear method.
  
  ArrayList<PedalEvent> res = new ArrayList<PedalEvent>();
  
  int divisionLength = changeDuration / NUM_DIVISIONS_FOR_SMOOTH_PEDAL_CHANGE;
  int changeRate = (finalVelocity - startingVelocity) / NUM_DIVISIONS_FOR_SMOOTH_PEDAL_CHANGE;
  
  // We add the final pedaling manually to avoid more calculated calculations.
  for (int i = 0; i < NUM_DIVISIONS_FOR_SMOOTH_PEDAL_CHANGE; ++i) {
    int velocity = startingVelocity + i * changeRate;
    int time = baseTime + i * divisionLength;
    PedalEvent pedal = new PedalEvent(velocity, time);
    res.add(pedal);
  }
  
  PedalEvent finalPedal = new PedalEvent(finalVelocity, baseTime + changeDuration);
  res.add(finalPedal);
  
  //for (PedalEvent pedal : res) {
  //  println("Velocity: " + pedal.getVelocity());
  //}
  
  return res;
}

class SortPedalEventByStartTime implements Comparator<PedalEvent> {
  public int compare(PedalEvent lhs, PedalEvent rhs) {
    return lhs.getStartTime() - rhs.getStartTime();
  }
}
