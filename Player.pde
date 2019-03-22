import java.util.PriorityQueue;
import java.util.Map;
import themidibus.*;

class Player {
  public Player(int midiOutputDeviceIndex, int midiChannel) {
    _toPlay = new PriorityQueue<NoteEvent>(1, new SortNoteEventByStartTime());
    _toStop = new PriorityQueue<NoteEvent>(1, new SortNoteEventByEndTime());
    
    initPlayCounts();
    
    _midiChannel = midiChannel;
    initMidi(midiOutputDeviceIndex);
  }
  
  public void update() {
    playNotes();
    stopNotes();
  }
  
  public void addNotes(NoteEvent[] newNotes) {
    for (NoteEvent note : newNotes) {
      _toPlay.add(note);
    }
  }
  
  private void playNotes() {
    while (_toPlay.peek() != null && millis() >= _toPlay.peek().getStartTime()) {
      NoteEvent noteToPlay = _toPlay.poll();
      // TODO: Get rid of this.
      //noteToPlay.setVelocity(30);
      //println("Playing " + noteToPlay.getPitch() + " with Velocity " + noteToPlay.getVelocity());
      _midiBus.sendNoteOn(_midiChannel, noteToPlay.getPitch(), noteToPlay.getVelocity());
      _toStop.add(noteToPlay);
    }
  }
  
  private void stopNotes() {
    while (_toStop.peek() != null && millis() >= _toStop.peek().getEndTime()) {
      NoteEvent noteToPlay = _toStop.poll();
      _midiBus.sendNoteOff(_midiChannel, noteToPlay.getPitch(), noteToPlay.getVelocity());
    }
  }
  
  // These functions assume that the conditions such as timing to play or stop
  // have been checked.
  
  private void playTop() {
    _midiBus.sendNoteOn(1, 66, 100);
  }
  
  private void stopTop() {
    
  }
  
  private void initPlayCounts() {
    pitchToPlayCount = new HashMap<Integer, Integer>();
    for (int i = NoteEvent.PITCH_MIN; i < NoteEvent.PITCH_MAX; ++i) {
      pitchToPlayCount.put(i, 0);
    }
  }
  
  private void initMidi(int midiOutputDeviceIndex) {
    _midiBus = new MidiBus(this, -1, midiOutputDeviceIndex);
    _midiBus.sendTimestamps(false);
  }
  
  private PriorityQueue<NoteEvent> _toPlay;
  private PriorityQueue<NoteEvent> _toStop;
  private HashMap<Integer, Integer> pitchToPlayCount;
  
  private int _midiChannel;
  private MidiBus _midiBus;
}
