import java.util.*;

class NoteEvent {
  static final int PITCH_MIN = 21;
  static final int PITCH_MAX = 108;
  
  static final int VELOCITY_MIN = 30; //30
  static final int VELOCITY_MAX = 127; //127
  
  public NoteEvent(int pitch, int velocity, int startTime, int duration) {
    if (pitch < PITCH_MIN) {
      println("Pitch is less than minimum.");
      pitch = PITCH_MIN;
    }
    else if (pitch > PITCH_MAX) {
      println("Pitch is greater than maximum.");
      pitch = PITCH_MAX;
    }
    
    if (velocity < VELOCITY_MIN) {
      println("Velocity is less than minimum.");
      velocity = VELOCITY_MIN;
    }
    else if (velocity > VELOCITY_MAX) {
      println("Velocity is greater than maximum.");
      velocity = VELOCITY_MAX;
    }
    
    
    _pitch = pitch;
    _velocity = velocity;
    _startTime = startTime;
    _duration = duration;
  }
  
  // Construct from Key and octave
  public NoteEvent(Key key, int octave, int velocity, int startTime, int duration) {
    this(calculatePitch(key, octave), velocity, startTime, duration);
  }
  
  public NoteEvent(NoteEvent other) {
    _pitch = other._pitch;
    _velocity = other._velocity;
    _startTime = other._startTime;
    _duration = other._duration;
  }
  
  int getPitch() {
    return _pitch;
  }
  
  int getVelocity() {
    return _velocity;
  }
  
  int getStartTime() {
    return _startTime;
  }
  
  int getDuration() {
    return _duration;
  }
  
  int getEndTime() {
    return _startTime + _duration;
  }
  
  void setPitch(int pitch) {
    _pitch = pitch;
  }
  
  void setVelocity(int velocity) {
    _velocity = velocity;
  }
  
  void setStartTime(int startTime) {
    _startTime = startTime;
  }
  
  void setDuration(int duration) {
    _duration = duration;
  }
  
  boolean Equals(NoteEvent other) {
    return 
      _pitch == other._pitch &&
      _velocity == other._velocity &&
      _startTime == other._startTime &&
      _duration == other._duration;
  }
  
  private int _pitch;
  private int _velocity;
  private int _startTime;
  private int _duration;
}

class SortNoteEventByStartTime implements Comparator<NoteEvent> {
  public int compare(NoteEvent lhs, NoteEvent rhs) {
    return lhs.getStartTime() - rhs.getStartTime();
  }
}

class SortNoteEventByEndTime implements Comparator<NoteEvent> {
  public int compare(NoteEvent lhs, NoteEvent rhs) {
    return lhs.getEndTime() - rhs.getEndTime();
  }
}
