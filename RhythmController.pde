// What fractions of the unit note are allowable.
public static final float[] ALLOWABLE_FRACTIONS = {
  //4f,
  //2f,
  1f,
  1f / 2f,
  1f / 3f,
  1f / 4f,
  1f / 6f,
  1f / 8f,
  //1f / 16f,
  //1f / 32f
  1f / 7.2f,
  1f / 13.1f,
};

public static final float RHYTHM_ENABLE_PROBABILITY = 1f; // 0.05f;

RhythmController rhythmController = new RhythmController();

public class RhythmController {
  
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
      res[i].setStartTime(getQuantizedTime(res[i]));
    }
    
    return res;
  }
  
  private int getQuantizedTime(NoteEvent note) {
    int noteStartTime = note.getStartTime();
    int measureStartTime = getBaseMeasureTime(note);
    int offset = getMeasureOffset(noteStartTime - measureStartTime);
    return noteStartTime + offset;
  }
  
  private int getMeasureOffset(int startTimeInMeasure) {
    int closestQuantizedOffset = getMeasureLength(); // set it to a large value.
    //println("For note at: " + startTimeInMeasure);
    
    // TODO: Make more efficient by avoiding unnecessary comparisons that derive from another fraction.
    for (float fraction : ALLOWABLE_FRACTIONS) {
      int offset = getOffsetFromFractionGrid(startTimeInMeasure, fraction);
      
      if (abs(offset) < abs(closestQuantizedOffset)) {
        closestQuantizedOffset = offset;
      }
    }
    
    return closestQuantizedOffset;
  }
  
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
  private boolean _isActive = false;
}
