RhythmController rhythmController = new RhythmController();

boolean metronome_on = true;

public class RhythmController {
  public static final float RHYTHM_ENABLE_PROBABILITY = 1f; // 0.05f;
  // What fractions of the unit note are allowable.
  // In order of priority.
  // (if multiple fractions are applicable, the earlier one will be used)
  public final float[] ALLOWABLE_FRACTIONS = {
    //1f / 4f,
    //1f / 6f,
    //1f / 7f,
    //1f / 13f,
    1f
  };
  
  // Allowable grid divisions.
  // Some sort of a duration factor.
  public final int MAX_NOTE_DURATION_AS_UNIT_NOTE_FACTOR = 4;
  
  public final int VELOCITY_INCREASE_FOR_MEASURE_START = 10;
  //public final int VELOCITY_INCREASE_FOR_ON_BEAT = 5;
  
  public RhythmController() {
    
  }
  
  public boolean isEnabled() {
    if (!_isActive) {
      return false;
    }
    return _measuresLeft != 0;
  }
  
  public void update() {
    if (!_isActive) {
      return;
    }
    
    if (millis() < _nextUpdateTime) {
      return;
    }
    
    // If rhythm is enabled.
    if (_measuresLeft != 0) {
      --_measuresLeft;
      //println("Remaining measures with rhythm: " + _measuresLeft + ", note length: " + _unitNoteLength + ", notes per measure: " + _notesPerMeasure);
    }
    else {
      if (random(1) < RHYTHM_ENABLE_PROBABILITY) {
        println("Enabling Rhythm");
        // TODO: Don't hardcode this once initial testing is done.
        _unitNoteLength = int(random(200, 500));
        _notesPerMeasure = int(random(3, 4));
        int approximateDuration = int(random(20000, 60000)); // Takes between these values in ms.
        //_measuresLeft = 20;
        _measuresLeft = approximateDuration / getMeasureLength();
      } else {
        return;
      }
    }
    
    _nextUpdateTime = millis() + getMeasureLength();
  }
  
  public int getUnitNoteLength() {
    return _unitNoteLength;
  }
  
  public void setUnitNoteLength(int unitNoteLength) {
    _unitNoteLength = unitNoteLength;
  }
  
  public int getNotesPerMeasure() {
    return _notesPerMeasure;
  }
  
  public void setNotesPerMeasure(int notesPerMeasure) {
    _notesPerMeasure = notesPerMeasure;
  }
  
  public int getMeasuresLeft() {
    return _measuresLeft;
  }
  
  private static final int METRONOME_MEASURE_START_PITCH = NoteEvent.PITCH_MAX;
  private static final int METRONOME_ON_BEAT_PITCH = METRONOME_MEASURE_START_PITCH - 1;
  private static final int METRONOME_VELOCITY = 80;
  private static final int METRONOME_NOTE_DURATION = 50;
  public NoteEvent[] getMetronomeNotesForSeed(NoteEvent[] seed) {
    int measureCount = calculateSeedMeasureCount(seed);
    int seedLength = getMeasureLength() * measureCount;
    
    ArrayList<NoteEvent> gen = new ArrayList<NoteEvent>();
    for (int startTime = 0; startTime < seedLength; startTime+= _unitNoteLength) {
      int pitch;
      if (startTime % getMeasureLength() == 0) {
        pitch = METRONOME_MEASURE_START_PITCH;
      }
      else {
        pitch = METRONOME_ON_BEAT_PITCH;
      }
      gen.add(new NoteEvent(pitch, METRONOME_VELOCITY, startTime, METRONOME_NOTE_DURATION));
    }
    
    NoteEvent[] genResultArr = new NoteEvent[gen.size()];
    return gen.toArray(genResultArr);
  }
  
  public NoteEvent[] quantizeSeed(NoteEvent[] seed) {
    NoteEvent[] stretchedSeed = deepClone(seed);
    stretchSeed(stretchedSeed);
    
    return stretchedSeed;
  }
  
  // Stretches the seed contents such that they take exactly a number of measures.
  // TODO: This currently prevents having silence at the end of a measure.
  // We might wanna find a way of methodically introducing it.
  public void stretchSeed(NoteEvent[] seed) {
    int measureCount = calculateSeedMeasureCount(seed);
    float stretchFactor = float(measureCount * getMeasureLength()) / getEndTime(seed);
    for (NoteEvent note : seed) {
      note.setStartTime(int(note.getStartTime() * stretchFactor));
      note.setDuration(int(note.getDuration() * stretchFactor));
    }
  }
  // Calculates how many measures should the seed take.
  public int calculateSeedMeasureCount(NoteEvent[] seed) {
    int endTime = getEndTime(seed);
    int measureLength = getMeasureLength();
    int measureLowerBoundCount = endTime / measureLength;
    if (endTime % measureLength > 0) {
      ++measureLowerBoundCount;
    }
    return measureLowerBoundCount;
  }
  
  public NoteEvent[] quantize(NoteEvent[] input) {
    NoteEvent[] res = deepClone(input);
    
    for (int i = 0; i < res.length; ++i) {
      //res[i].setStartTime(getQuantizedTime(res[i]));
      quantizeNote(res[i]);
    }
    
    return res;
  }
  
  public void quantizeNote(NoteEvent note) {
    QuantizationState qState = new QuantizationState();
    setQuantizedTimeInfo(note, qState);
    setQuantizedDurationInfo(note, qState);
    
    note.setStartTime(note.getStartTime() + qState.quantizerOffset);
    note.setDuration(int(qState.fraction * _unitNoteLength * qState.durationMultiplier));
    setVelocity(note);
  }
  
  // These functions set the info in qState, not the note.
  private void setQuantizedTimeInfo(NoteEvent note, QuantizationState qState) {
    int noteStartTime = note.getStartTime();
    int measureStartTime = getBaseMeasureTime(note);
    setQuantizingOffsetAndFraction(noteStartTime - measureStartTime, qState);
  }
  
  private void setQuantizedDurationInfo(NoteEvent note, QuantizationState qState) {
    int closestMultiplier = 1;
    int closestDifference = getMeasureLength();
    int largestMultiplier = getLargestMultiplierForFraction(qState.fraction);
    
    for (int i = 1; i <= largestMultiplier; ++i) {
      // TODO: Consider a minimum note length?
      int noteLength = int(i * qState.fraction * _unitNoteLength);
      int thisDiff = abs(note.getDuration() - noteLength);
      if (thisDiff < closestDifference) {
        closestMultiplier = i;
        closestDifference = thisDiff;
      }
    }
    
    qState.durationMultiplier = closestMultiplier;
  }
  
  private void setVelocity(NoteEvent note) {
    if ((note.getStartTime() % getMeasureLength()) == 0) {
      println("Setting velocity for onbeat notes.");
      note.setVelocity(note.getVelocity() + VELOCITY_INCREASE_FOR_MEASURE_START);
    }
  }
  
  private int getLargestMultiplierForFraction(float fraction) {
    return int(1.0f / fraction) * MAX_NOTE_DURATION_AS_UNIT_NOTE_FACTOR;
  }
  
  private void setQuantizingOffsetAndFraction(int startTimeInMeasure, QuantizationState qState) {
    int closestQuantizedOffset = getMeasureLength(); // set it to a large value.
    float usedFraction = 1;
    
    for (int i = 0; i < ALLOWABLE_FRACTIONS.length; ++i) {
      int offset = getOffsetFromFractionGrid(startTimeInMeasure, ALLOWABLE_FRACTIONS[i]);
      
      if (abs(offset) < abs(closestQuantizedOffset)) {
        closestQuantizedOffset = offset;
        usedFraction = ALLOWABLE_FRACTIONS[i];
      }
    }
    
    qState.fraction = usedFraction;
    qState.quantizerOffset = closestQuantizedOffset;
  }
  
  //private int getQuantizedTime(NoteEvent note) {
  //  int noteStartTime = note.getStartTime();
  //  int measureStartTime = getBaseMeasureTime(note);
  //  int offset = getQuantizingOffset(noteStartTime - measureStartTime);
  //  return noteStartTime + offset;
  //}
  
  
  //private int getQuantizingOffset(int startTimeInMeasure) {
  //  int closestQuantizedOffset = getMeasureLength(); // set it to a large value.
  //  //println("For note at: " + startTimeInMeasure);
    
  //  for (float fraction : ALLOWABLE_FRACTIONS) {
  //    int offset = getOffsetFromFractionGrid(startTimeInMeasure, fraction);
      
  //    if (abs(offset) < abs(closestQuantizedOffset)) {
  //      closestQuantizedOffset = offset;
  //    }
  //  }
    
  //  return closestQuantizedOffset;
  //}
  
  // If only notes of length unitNoteLength * fraction could be used,
  // return the offset to the closest quantized point.
  private int getOffsetFromFractionGrid(int startTimeInMeasure, float fraction) {
    float gridUnit = _unitNoteLength * fraction;
    //println("Grid unit: " + gridUnit);
    
    int offsetFromBelow = int(startTimeInMeasure % gridUnit);
    int offsetFromAbove = int(gridUnit - offsetFromBelow);
    //println("Start time: " + startTimeInMeasure + " Offsets: " + offsetFromBelow + ", " + offsetFromAbove + " for fraction: " + fraction);
    
    // If offset from the next on-grid point is less and if that point is not beyond the measure.
    if (offsetFromAbove < offsetFromBelow && startTimeInMeasure + offsetFromAbove < getMeasureLength()) {
      return offsetFromAbove;
    }
    else {
      return offsetFromBelow * -1;
    }
  }
  
  // Given a note, returns the start time of the measure
  // the note belongs to.
  private int getBaseMeasureTime(NoteEvent note) {
    //println("Base measure time: " + (note.getStartTime() / getMeasureLength()) * getMeasureLength());
    return (note.getStartTime() / getMeasureLength()) * getMeasureLength();
  }
  
  private int getMeasureLength() {
    //println("Measure length:" + _unitNoteLength * _notesPerMeasure);
    return _unitNoteLength * _notesPerMeasure;
  }
  
  private int _unitNoteLength;
  private int _notesPerMeasure;
  // How many measures left with the current parameters.
  private int _measuresLeft;
  private int _nextUpdateTime = 0;
  private boolean _isActive = true;
  
  private class QuantizationState {
    float fraction;
    int quantizerOffset;
    float durationMultiplier;
  }
}



//RhythmController rhythmController = new RhythmController();

//public class RhythmController {
//  public static final float RHYTHM_ENABLE_PROBABILITY = 1f; // 0.05f;
//  // What fractions of the unit note are allowable.
//  public final float[] ALLOWABLE_FRACTIONS = {
//    //4f,
//    //2f,
//    1f,
//    1f / 2f,
//    1f / 3f,
//    1f / 4f,
//    1f / 6f,
//    1f / 8f,
//    //1f / 16f,
//    //1f / 32f
//    1f / 7.2f,
//    1f / 13.1f,
//  };
  
//  // Allowable grid divisions.
//  // Some sort of a duration factor.
  
//  //public final float[] ALLOWABLE_GRID_DIVISIONS = {
    
//  //}
  
//  public RhythmController() {
    
//  }
  
//  public boolean isEnabled() {
//    if (!_isActive) {
//      return false;
//    }
//    return _measuresLeft != 0;
//  }
  
//  public void update() {
//    if (!_isActive) {
//      return;
//    }
    
//    if (millis() < _nextUpdateTime) {
//      return;
//    }
    
//    // If rhythm is enabled.
//    if (_measuresLeft != 0) {
//      --_measuresLeft;
//      //println("Remaining measures with rhythm: " + _measuresLeft + ", note length: " + _unitNoteLength + ", notes per measure: " + _notesPerMeasure);
//    }
//    else {
//      if (random(1) < RHYTHM_ENABLE_PROBABILITY) {
//        println("Enabling Rhythm");
//        // TODO: Don't hardcode this once initial testing is done.
//        _unitNoteLength = int(random(200, 500));
//        _notesPerMeasure = int(random(3, 4));
//        int approximateDuration = int(random(20000, 60000)); // Takes between these values in ms.
//        //_measuresLeft = 20;
//        _measuresLeft = approximateDuration / getMeasureLength();
//      } else {
//        return;
//      }
//    }
    
//    _nextUpdateTime = millis() + getMeasureLength();
//  }
  
//  public int getUnitNoteLength() {
//    return _unitNoteLength;
//  }
  
//  public void setUnitNoteLength(int unitNoteLength) {
//    _unitNoteLength = unitNoteLength;
//  }
  
//  public int getNotesPerMeasure() {
//    return _notesPerMeasure;
//  }
  
//  public void setNotesPerMeasure(int notesPerMeasure) {
//    _notesPerMeasure = notesPerMeasure;
//  }
  
//  public int getMeasuresLeft() {
//    return _measuresLeft;
//  }
  
//  public NoteEvent[] quantizeSeed(NoteEvent[] seed) {
//    NoteEvent[] stretchedSeed = deepClone(seed);
//    stretchSeed(stretchedSeed);
    
//    return stretchedSeed;
//  }
  
//  // Stretches the seed contents such that they take exactly a number of measures.
//  // TODO: This currently prevents having silence at the end of a measure.
//  // We might wanna find a way of methodically introducing it.
//  public void stretchSeed(NoteEvent[] seed) {
//    int measureCount = calculateSeedMeasureCount(seed);
//    float stretchFactor = float(measureCount * getMeasureLength()) / getEndTime(seed);
//    for (NoteEvent note : seed) {
//      note.setStartTime(int(note.getStartTime() * stretchFactor));
//      note.setDuration(int(note.getDuration() * stretchFactor));
//    }
//  }
//  // Calculates how many measures should the seed take.
//  public int calculateSeedMeasureCount(NoteEvent[] seed) {
//    int endTime = getEndTime(seed);
//    int measureLength = getMeasureLength();
//    int measureLowerBoundCount = endTime / measureLength;
//    if (endTime % measureLength > 0) {
//      ++measureLowerBoundCount;
//    }
//    return measureLowerBoundCount;
//  }
  
//  public NoteEvent[] quantize(NoteEvent[] input) {
//    NoteEvent[] res = deepClone(input);
    
//    for (int i = 0; i < res.length; ++i) {
//      res[i].setStartTime(getQuantizedTime(res[i]));
//    }
    
//    return res;
//  }
  
//  private int getQuantizedTime(NoteEvent note) {
//    int noteStartTime = note.getStartTime();
//    int measureStartTime = getBaseMeasureTime(note);
//    int offset = getMeasureOffset(noteStartTime - measureStartTime);
//    return noteStartTime + offset;
//  }
  
//  private int getMeasureOffset(int startTimeInMeasure) {
//    int closestQuantizedOffset = getMeasureLength(); // set it to a large value.
//    //println("For note at: " + startTimeInMeasure);
    
//    // TODO: Make more efficient by avoiding unnecessary comparisons that derive from another fraction.
//    for (float fraction : ALLOWABLE_FRACTIONS) {
//      int offset = getOffsetFromFractionGrid(startTimeInMeasure, fraction);
      
//      if (abs(offset) < abs(closestQuantizedOffset)) {
//        closestQuantizedOffset = offset;
//      }
//    }
    
//    return closestQuantizedOffset;
//  }
  
//  // If only notes of length unitNoteLength * fraction could be used,
//  // return the offset to the closest quantized point.
//  private int getOffsetFromFractionGrid(int startTimeInMeasure, float fraction) {
//    float gridUnit = _unitNoteLength * fraction;
//    //println("Grid unit: " + gridUnit);
    
//    int offsetFromBelow = int(startTimeInMeasure % gridUnit);
//    int offsetFromAbove = int(gridUnit - offsetFromBelow);
//    //println("Start time: " + startTimeInMeasure + " Offsets: " + offsetFromBelow + ", " + offsetFromAbove + " for fraction: " + fraction);
    
//    // If offset from the next on-grid point is less and if that point is not beyond the measure.
//    if (offsetFromAbove < offsetFromBelow && startTimeInMeasure + offsetFromAbove < getMeasureLength()) {
//      return offsetFromAbove;
//    }
//    else {
//      return offsetFromBelow * -1;
//    }
//  }
  
//  // Given a note, returns the start time of the measure
//  // the note belongs to.
//  private int getBaseMeasureTime(NoteEvent note) {
//    //println("Base measure time: " + (note.getStartTime() / getMeasureLength()) * getMeasureLength());
//    return (note.getStartTime() / getMeasureLength()) * getMeasureLength();
//  }
  
//  private int getMeasureLength() {
//    //println("Measure length:" + _unitNoteLength * _notesPerMeasure);
//    return _unitNoteLength * _notesPerMeasure;
//  }
  
//  private int _unitNoteLength;
//  private int _notesPerMeasure;
//  // How many measures left with the current parameters.
//  private int _measuresLeft;
//  private int _nextUpdateTime = 0;
//  private boolean _isActive = true;
//}
