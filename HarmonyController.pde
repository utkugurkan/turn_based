import java.util.TreeMap;

HarmonyController harmonyController = new HarmonyController();

public class HarmonyController {
  // The max interval between each harm note.
  static final int MAX_HARM_INTERVAL = 7;
  static final int MIN_HARM_COUNT = 2;
  static final int MAX_HARM_COUNT = 5;
  
  public HarmonyController() {
    //_genHarmony = new GenHarmony();
  }
  
  public void update(NoteEvent[] seed) {
    //_harmonizedSeed = _genHarmony.generateFromSeed(seed);
    harmonizeSeed(seed);
  }
  
  public TreeMap<Integer, NoteEvent[]> getHarmonizedSeed() {
    // TODO: Return clone?
    return _harmonizedSeed;
  }
  
  
  void harmonizeSeed(NoteEvent[] seed) {
    if (!_harmonizedSeed.isEmpty()) {
      _previousHarmony = _harmonizedSeed.lastEntry().getValue();
    } else {
      _previousHarmony = null;
    }
    _harmonizedSeed.clear();
    
    //NoteEvent[] seed = deepClone(seedIn);
    
    if (seed.length == 0) {
      return;
    }
    
    //ArrayList<NoteEvent> gen = new ArrayList<NoteEvent>();
    boolean seedNoteIsBass = false;
    boolean seedNoteIsMid = false;
    boolean seedNoteIsHigh = false;
    float voicingOrderRandomNumber = random(1f);
    if (voicingOrderRandomNumber < 0.33f) {
      seedNoteIsBass = true;
    }
    else if (voicingOrderRandomNumber < 0.66f) {
      seedNoteIsMid = true;
    }
    else {
      seedNoteIsHigh = true;
    }

    for (int i = 0; i < seed.length; ++i) {
      NoteEvent curNote = seed[i];
      int harmCount = int(random(MIN_HARM_COUNT, MAX_HARM_COUNT));
      ArrayList<NoteEvent> gen = new ArrayList<NoteEvent>();
      
      if (seedNoteIsBass) {
        NoteEvent[] harms = harmonize(curNote, harmCount, true);
        gen.addAll(Arrays.asList(harms));
      }
      else if (seedNoteIsMid) {
        int harmCountBelow = int(random(harmCount - 0.99f));
        int harmCountAbove = harmCount - harmCountBelow;
        
        NoteEvent[] harmsBelow = harmonize(curNote, harmCountBelow, false);
        NoteEvent[] harmsAbove = harmonize(curNote, harmCountAbove, true);
        gen.addAll(Arrays.asList(harmsBelow));
        gen.addAll(Arrays.asList(harmsAbove));
      }
      // High
      else {
        NoteEvent[] harms = harmonize(curNote, harmCount, false);
        gen.addAll(Arrays.asList(harms));
      }
      
      gen.add(curNote);
      
      NoteEvent[] genResultArr = new NoteEvent[gen.size()];
      genResultArr = gen.toArray(genResultArr);
      _harmonizedSeed.put(curNote.getStartTime(), genResultArr);
    }
  }
  
  // Does not include the note. The caller side can add it if needed.
  private NoteEvent[] harmonize(NoteEvent note, int harmCount, boolean harmAboveNote) {
    NoteEvent[] harms = new NoteEvent[harmCount];
    
    int direction = 1;
    if (!harmAboveNote) {
      direction = -1;
    }
    
    NoteEvent curNote = note;
    int addedNoteCount = 0;
    for (int i = 0; i < harmCount; ++i) {
      NoteEvent harm = new NoteEvent(curNote);
      // TODO: This probably excludes MAX_HARM_INTERVAL.
      int newPitch = harm.getPitch() + (direction * int(random(MAX_HARM_INTERVAL)));
      if (newPitch > NoteEvent.PITCH_MAX || newPitch < NoteEvent.PITCH_MIN) {
        continue;
      }
      harm.setPitch(newPitch);
      // It's important that we don't use i here, as i might skip the addition.
      harms[addedNoteCount] = harm;
      curNote = harm;
      ++addedNoteCount;
    }
    
    NoteEvent[] res = new NoteEvent[addedNoteCount];
    for (int i = 0; i < addedNoteCount; ++i) {
      res[i] = harms[i]; 
    }
    
    return res;
  }
  
  public NoteEvent[] getHarmonyAtTime(int time) {
    if (time < 0) {
      time = 0;
    }
    
    // Try to return these in order:
    // Harmony active at time according to this seed.
    // If this seed does not have an entry as early as requested time,
    // Try to use the last harmony from the previous seed.
    // If that does not exist either, return a random harm.
    
    Map.Entry<Integer, NoteEvent[]> harmonyAtTime = _harmonizedSeed.floorEntry(time);
    if (harmonyAtTime != null) {
      return deepClone(harmonyAtTime.getValue());
    }
    else if (_previousHarmony != null) {
      return deepClone(_previousHarmony);
    }
    else {
      // Just a random filler.
      return new NoteEvent[] { new NoteEvent(55, 0, 0, 0) };
    }
  }
  
  public int[] getHarmonyStartTimes() {
    int[] res = new int[_harmonizedSeed.size()];
    int i = 0;
    for(Map.Entry<Integer, NoteEvent[]> entry : _harmonizedSeed.entrySet()) {
      res[i] = entry.getKey();
      ++i;
    }
    
    return res;
  }
  
  //private GenHarmony _genHarmony;
  //private NoteEvent[] _harmonizedSeed;
  // From start times to an array of notes that form the harmony active at that time.
  private TreeMap<Integer, NoteEvent[]> _harmonizedSeed = new TreeMap<Integer, NoteEvent[]>();
  // Use this to store the last harmony of the previous seed.
  private NoteEvent[] _previousHarmony;
}
