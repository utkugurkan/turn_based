
public class DataPacketSet {
  public DataPacket[] data;
  
  public DataPacketSet getCopy() {
    DataPacketSet newSet = new DataPacketSet();
    if (data == null) {
      newSet.data = null;
    }
    else {
      DataPacket[] newData = new DataPacket[data.length];
      for (int i = 0; i < data.length; ++i) {
        newData[i] = new DataPacket(data[i]);
      }
      newSet.data = newData;
    }
    return newSet;
  }
}

public class DataPacket<T> {  
  public Class<?> type;
  public T value;
  
  public DataPacket(T valueIn) {
    type = valueIn.getClass();
    value = valueIn;
  }
  
  public DataPacket(DataPacket<T> other) {
    type = other.type;
    value = other.value;
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
