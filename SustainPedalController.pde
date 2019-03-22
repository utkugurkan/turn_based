SustainPedalController sustainPedalController = new SustainPedalController(); 

class SustainPedalController {
  
  public PedalEvent[] genPedaling(ArrayList<NoteEvent[]> noteLists, int endTime) {
    int[] harmonyStartTimes = harmonyController.getHarmonyStartTimes();
    int[] numNotesPerHarmony = new int[harmonyStartTimes.length];
    
    for (int i = 0; i < numNotesPerHarmony.length; ++i) {
      numNotesPerHarmony[i] = 0;
    }
    
    for (NoteEvent[] notes : noteLists) {
      int harmIdx = 0;
      int noteIdx = 0;
      while (noteIdx < notes.length) {
        if (harmIdx + 1 >= harmonyStartTimes.length) {
          numNotesPerHarmony[harmIdx] = numNotesPerHarmony[harmIdx] + (notes.length - noteIdx);
          break;
        }
        else {
          // If we are still in the same harmony
          if (notes[noteIdx].getStartTime() < harmonyStartTimes[harmIdx + 1]) {
            ++numNotesPerHarmony[harmIdx];
            ++noteIdx;
          }
          else {
            ++harmIdx;
          }
        }
      }
    }
    
    return genPedalingFromHarmonyBuckets(harmonyStartTimes, numNotesPerHarmony, endTime);
  }
  
  private static final int MIN_NOTE_PER_HARMONY = 0;
  private static final int MAX_NOTE_PER_HARMONY = 15;
  private static final int PEDAL_RELEASE_DURATION = 100; // in ms
  private static final int MIN_PEDAL_PRESS_DURATION = 100; // in ms
  private PedalEvent[] genPedalingFromHarmonyBuckets(int[] harmonyStartTimes, int[] numNotesPerHarmony, int endTime) {
    ArrayList<PedalEvent> pedalEvents = new ArrayList<PedalEvent>();
    //boolean isPressed = false;
    for (int i = 0; i < harmonyStartTimes.length; ++i) {
      int harmStartTime = harmonyStartTimes[i];
      PedalEvent releaseEvent = new PedalEvent(PedalEvent.MIN_PEDAL_VELOCITY, harmStartTime);
      pedalEvents.add(releaseEvent);
      
      int harmEndTime;
      if (i + 1 < harmonyStartTimes.length) {
        harmEndTime = harmonyStartTimes[i + 1];
      }
      else {
        harmEndTime = endTime;
      }
      
      if (harmEndTime - harmStartTime > PEDAL_RELEASE_DURATION + MIN_PEDAL_PRESS_DURATION) {
        int pressVelocity = int(map(
          min(numNotesPerHarmony[i], MAX_NOTE_PER_HARMONY),
          MIN_NOTE_PER_HARMONY,
          MAX_NOTE_PER_HARMONY,
          PedalEvent.MIN_PEDAL_VELOCITY,
          PedalEvent.MAX_PEDAL_VELOCITY));
        PedalEvent pressEvent = new PedalEvent(pressVelocity, harmStartTime + PEDAL_RELEASE_DURATION);
        pedalEvents.add(pressEvent);
      }
    }
    
    PedalEvent[] resArr = new PedalEvent[pedalEvents.size()];
    return pedalEvents.toArray(resArr);
  }
  
  
}

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
