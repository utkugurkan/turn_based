
public class DataPacketSet {
  public DataPacket[] data;
}

public class DataPacket<T> {  
  public Class<?> type;
  public T value;
  
  public DataPacket(T valueIn) {
    type = valueIn.getClass();
    value = valueIn;
  }
  
  //public DataPacketType type;
  //public T value;
  
  //public DataPacket(DataPacketType typeIn, T valueIn) {
  //  //type = DataPacketType.values()[val.class];
  //  //type = DataPacketType(val.class);
    
  //  type = typeIn;
  //  value = valueIn;
  //}
}

public enum DataPacketType {
  PATTERN_ENTITY(PatternEntity.class),
  PATTERN_ENTITY_ARRAY(PatternEntity[].class),
  
  NOTE_EVENT(NoteEvent.class),
  NOTE_EVENT_ARRAY(NoteEvent[].class);
  
  private final Class<?> _type;
  
  private DataPacketType(Class<?> type) {
    _type = type; 
  }
}
