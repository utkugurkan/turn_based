NoteEvent[] deepClone(NoteEvent[] noteEvents) {
   NoteEvent[] result = new NoteEvent[noteEvents.length];
    for (int i = 0; i < noteEvents.length; ++i) {
      result[i] = new NoteEvent(noteEvents[i]);
    }
    return result;
}

void printNoteEvent(NoteEvent note) {
  println("Pitch: " + note.getPitch() + ", Velocity: " + note.getVelocity() +
        ", Start Time: " + note.getStartTime() + ", Duration: " + note.getDuration());
}

void printNoteEvents(NoteEvent[] noteEvents) {
  for (NoteEvent note : noteEvents) {
    printNoteEvent(note);
  }
}

int getEndTime(NoteEvent[] noteEvents) {
  int endTime = 0;
    
    for (int i = 0; i < noteEvents.length; ++i) {
      endTime = max(endTime, noteEvents[i].getEndTime()); 
    }
    
    return endTime;
}

// nextNoteThreshold is used to determine how far the notes' start times need to be to considered separate.
// Return -1 if none found.
final int NEXT_NOTE_THRESHOLD = 50; // in ms.
int findNextNoteIndex(int curNoteIndex, NoteEvent[] noteEvents) {
  return findNextNoteIndex(curNoteIndex, noteEvents, NEXT_NOTE_THRESHOLD);
}

int findNextNoteIndex(int curNoteIndex, NoteEvent[] noteEvents, int nextNoteThreshold) {
    int resIndex = -1;
    
    int curNoteStartTime = noteEvents[curNoteIndex].getStartTime();
    for (int i = curNoteIndex + 1; i < noteEvents.length; ++i) {
      if (noteEvents[i].getStartTime() - curNoteStartTime >= nextNoteThreshold) {
        resIndex = i;
        break;
      }
    }
    
    return resIndex;
}

int calculatePitch(Key key, int octave) {
  return key.getValue() + octave * 12 + MIN_MIDI_NOTE;
}

Key calculateKey(NoteEvent note) {
  //print("Debug calculateKey: ");
  //printNoteEvent(note);
  return Key.values()[(note.getPitch() - MIN_MIDI_NOTE) % 12];
}

// Return the pitch number of the closest pitch of key to note.
int getClosestPitch(Key key, NoteEvent note) {
  
  int referencePitch = note.getPitch();
  int octave = 0;
  int pitch = calculatePitch(key, octave);
  int closestPitch = 0; // Not a valid number, and farther than an octave from every valid note.

  while (pitch >= MIN_MIDI_NOTE && pitch <= MAX_MIDI_NOTE) {  
    if (abs(pitch - referencePitch) < abs(closestPitch - referencePitch)) {
      closestPitch = pitch;
    }
    pitch = calculatePitch(key, octave);
    ++octave;
  }
  
  return closestPitch;
}
