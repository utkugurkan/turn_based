import java.util.PriorityQueue;
import java.util.Map;
import themidibus.*;

class Player {
  public Player(int midiOutputDeviceIndex, int midiChannel) {
    _notesToPlay = new PriorityQueue<NoteEvent>(1, new SortNoteEventByStartTime());
    _notesToStop = new PriorityQueue<NoteEvent>(1, new SortNoteEventByEndTime());
    _sustainPedalingToPlay = new PriorityQueue<PedalEvent>(1, new SortPedalEventByStartTime());
    
    initPlayCounts();
    
    _midiChannel = midiChannel;
    initMidi(midiOutputDeviceIndex);
  }
  
  public void update() {
    playNotes();
    stopNotes();
    playSustainPedal();
  }
  
  public void addNotes(NoteEvent[] newNotes) {
    for (NoteEvent note : newNotes) {
      _notesToPlay.add(note);
    }
  }
  
  public void addSustainPedaling(PedalEvent[] pedaling) {
    for (PedalEvent pedal : pedaling) {
      _sustainPedalingToPlay.add(pedal);
    }
  }
  
  private void playNotes() {
    while (_notesToPlay.peek() != null && millis() >= _notesToPlay.peek().getStartTime()) {
      NoteEvent noteToPlay = _notesToPlay.poll();
      // TODO: Get rid of this.
      //noteToPlay.setVelocity(30);
      //println("Playing " + noteToPlay.getPitch() + " with Velocity " + noteToPlay.getVelocity());
      _midiBus.sendNoteOn(_midiChannel, noteToPlay.getPitch(), noteToPlay.getVelocity());
      _notesToStop.add(noteToPlay);
    }
  }
  
  private void stopNotes() {
    while (_notesToStop.peek() != null && millis() >= _notesToStop.peek().getEndTime()) {
      NoteEvent noteToPlay = _notesToStop.poll();
      _midiBus.sendNoteOff(_midiChannel, noteToPlay.getPitch(), noteToPlay.getVelocity());
    }
  }
  
  private void playSustainPedal() {
    while (_sustainPedalingToPlay.peek() != null && millis() >= _sustainPedalingToPlay.peek().getStartTime()) {
      PedalEvent pedalingToPlay = _sustainPedalingToPlay.poll();
      _midiBus.sendControllerChange(_midiChannel, SUSTAIN_PEDAL_CONTROL_NUMBER, pedalingToPlay.getVelocity()); // Send a controllerChange
      //_midiBus.sendNoteOn(_midiChannel, noteToPlay.getPitch(), noteToPlay.getVelocity());
      //_notesToStop.add(noteToPlay);
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
  
  private static final int SUSTAIN_PEDAL_CONTROL_NUMBER = 64;
  private static final int UNA_CORDA_CONTROL_NUMBER = 67;
  
  private PriorityQueue<NoteEvent> _notesToPlay;
  private PriorityQueue<NoteEvent> _notesToStop;
  private HashMap<Integer, Integer> pitchToPlayCount;
  
  private PriorityQueue<PedalEvent> _sustainPedalingToPlay; 
  
  private int _midiChannel;
  private MidiBus _midiBus;
}
