NoteEvent[] currentSeed;
Model model;
Player player;

boolean runTests = false;

void setup() {
  int baseTime = 0;
  currentSeed = new NoteEvent[5];
  currentSeed[0] = new NoteEvent(55, 80, baseTime + 0, 1000);
  currentSeed[1] = new NoteEvent(59, 80, baseTime + 1000, 1000);
  currentSeed[2] = new NoteEvent(63, 80, baseTime + 2000, 1000);
  currentSeed[3] = new NoteEvent(52, 80, baseTime + 3000, 1000);
  currentSeed[4] = new NoteEvent(57, 80, baseTime + 4000, 1000);
  
  
  // TODO: Remove after testing.
  //currentSeed = new NoteEvent[5];
  //currentSeed[0] = new NoteEvent(55, 80, baseTime + 0, 1000);
  //currentSeed[1] = new NoteEvent(55, 80, baseTime + 1000, 1000);
  //currentSeed[2] = new NoteEvent(55, 80, baseTime + 2000, 1000);
  //currentSeed[3] = new NoteEvent(55, 80, baseTime + 3000, 1000);
  //currentSeed[4] = new NoteEvent(55, 80, baseTime + 4000, 1000);
  
  //println("End of seed: " + currentSeed[4].getEndTime());
  
  int midiOutputDevice = 1;
  player = new Player(midiOutputDevice, 1);
  //player.addNotes(seed);
  
  model = new Model();
  
  //PriorityQueue<NoteEvent> pq = new PriorityQueue<NoteEvent>(1, new SortNoteEventByStartTime());
  //pq.add(currentSeed[4]);
  //pq.add(currentSeed[2]);
  //pq.add(currentSeed[3]);
  //pq.add(currentSeed[1]);
  //pq.add(currentSeed[0]);
  
  //println(pq.poll().getStartTime());
  //println(pq.poll().getStartTime());
  //println(pq.poll().getStartTime());
  //println(pq.poll().getStartTime());
  //println(pq.poll().getStartTime());
}

void draw() {
  if (!runTests) {
    currentSeed = model.update(currentSeed);
  }
  else {
    testRunner.runAllTestsOnce();
  }
}
