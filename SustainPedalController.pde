SustainPedalController sustainPedalController = new SustainPedalController(); 

class SustainPedalController {
  
  public static final float MIN_LEVEL_TO_PEDAL = 0.2;
  public PedalEvent[] genPedaling(ArrayList<NoteEvent[]> noteLists, int endTime) {
    if (pieceState.sustainPedalLevel.getValue() < MIN_LEVEL_TO_PEDAL) {
      
      // Return pedal release
      ArrayList<PedalEvent> res = new ArrayList<PedalEvent>();
      ArrayList<PedalEvent> releasePedaling = 
        getSmoothPedalChange(_prevVelocity, PedalEvent.MIN_PEDAL_VELOCITY, 0, PEDAL_RELEASE_DURATION);
        
      addPedalingToList(res, releasePedaling);
      
      PedalEvent[] resArr = new PedalEvent[res.size()];
      return res.toArray(resArr);
      
      //return new PedalEvent[] { new PedalEvent(PedalEvent.MIN_PEDAL_VELOCITY, 0) };
    }
    
    
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
  private static final int MIN_ACTIVE_PEDAL_VELOCITY = 30; // We technically do go lower.
  private static final float NOTE_COUNT_CONTRIBUTION_CONSTANT = 0.2f;
  private static final float SUSTAIN_PEDAL_LEVEL_CONTRIBUTION_CONSTANT = 0.2f;
  private static final float LOUDNESS_LEVEL_CONTRIBUTION_CONSTANT = 0.6f;
  // Calculate a pedal velocity based on the note count during a period as well as the piece state property.
  
  private PedalEvent[] genPedalingFromHarmonyBuckets(int[] harmonyStartTimes, int[] numNotesPerHarmony, int endTime) {
    ArrayList<PedalEvent> pedalEvents = new ArrayList<PedalEvent>();
    //boolean isPressed = false;
    for (int i = 0; i < harmonyStartTimes.length; ++i) {
      int harmStartTime = harmonyStartTimes[i];
      ArrayList<PedalEvent> releasePedaling = 
        getSmoothPedalChange(_prevVelocity, PedalEvent.MIN_PEDAL_VELOCITY, harmStartTime, PEDAL_RELEASE_DURATION);
      addPedalingToList(pedalEvents, releasePedaling);
      //PedalEvent releaseEvent = new PedalEvent(PedalEvent.MIN_PEDAL_VELOCITY, harmStartTime);
      //pedalEvents.add(releaseEvent);
      
      int harmEndTime;
      if (i + 1 < harmonyStartTimes.length) {
        harmEndTime = harmonyStartTimes[i + 1];
      }
      else {
        harmEndTime = endTime;
      }
      
      if (harmEndTime - harmStartTime > PEDAL_RELEASE_DURATION + MIN_PEDAL_PRESS_DURATION) {
        int pressVelocityBasedOnNoteCount = int(map(
          min(numNotesPerHarmony[i], MAX_NOTE_PER_HARMONY),
          MIN_NOTE_PER_HARMONY,
          MAX_NOTE_PER_HARMONY,
          MIN_ACTIVE_PEDAL_VELOCITY,
          PedalEvent.MAX_PEDAL_VELOCITY));
        int pressVelocityBasedOnPedalLevel = int(map(
          pieceState.sustainPedalLevel.getValue(),
          StateProperty.MIN_VAL,
          StateProperty.MAX_VAL,
          MIN_ACTIVE_PEDAL_VELOCITY,
          PedalEvent.MAX_PEDAL_VELOCITY));
          
        int pressVelocityBasedOnLoudnessLevel = int(map(
          pieceState.loudness.getValue(),
          StateProperty.MIN_VAL,
          StateProperty.MAX_VAL,
          MIN_ACTIVE_PEDAL_VELOCITY,
          PedalEvent.MAX_PEDAL_VELOCITY));
          
        int finalPressVelocity = 
          int(pressVelocityBasedOnNoteCount * NOTE_COUNT_CONTRIBUTION_CONSTANT + 
          pressVelocityBasedOnPedalLevel * SUSTAIN_PEDAL_LEVEL_CONTRIBUTION_CONSTANT +
          pressVelocityBasedOnLoudnessLevel * LOUDNESS_LEVEL_CONTRIBUTION_CONSTANT);
        
        // The time to start pressing.
        int pressTime = harmStartTime + PEDAL_RELEASE_DURATION;
          
        ArrayList<PedalEvent> pressPedaling = 
          getSmoothPedalChange(_prevVelocity, finalPressVelocity, pressTime, MIN_PEDAL_PRESS_DURATION);
        addPedalingToList(pedalEvents, pressPedaling);
        
        //PedalEvent pressEvent = new PedalEvent(finalPressVelocity, pressTime);
        //pedalEvents.add(pressEvent);
        //println("Adding pedals: " + pressVelocity + " for bucket size " + numNotesPerHarmony[i]);
      }
      else {
        //println("Not adding pedals.");
      }
    }
    
    PedalEvent[] resArr = new PedalEvent[pedalEvents.size()];
    return pedalEvents.toArray(resArr);
  }
  
  private void addPedalingToList(ArrayList<PedalEvent> pedaling, PedalEvent toAdd) {
    _prevVelocity = toAdd.getVelocity();
    pedaling.add(toAdd);
  }
  
  private void addPedalingToList(ArrayList<PedalEvent> pedaling, ArrayList<PedalEvent> toAdd) {
    _prevVelocity = toAdd.get(toAdd.size() - 1).getVelocity();
    pedaling.addAll(toAdd);
  }

  private int _prevVelocity = 0;
}
