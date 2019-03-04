//import java.lang.reflect.Constructor;

public abstract class GenerationMethod {
  
  //public GenerationMethod() {
  
  //}
  
  //public GenerationMethod getNewInstance() throws Exception {
  //  //return Console.class.getDeclaredConstructors()[0].newInstance();
  //  //return this.getClass().getConstructor().newInstance();
    
  //  Class<?> c = this.getClass();
  //  Constructor<?> ctor = c.getConstructor(new Class[] { });
  //  return ((GenerationMethod) ctor.newInstance(new Object[] { }));
  //}
  
  // Must not change the original seed.
  // Must not depend on the contents of seed staying constant.
  // Can use the dataPacket to store a state for continuity to be used
  // in the next generation. Can also update the dataPacket.
  // It should not rely on the dataPacket's current value having produced by the
  // same type of GenerationMethod.
  abstract NoteEvent[] generateFromSeed(NoteEvent[] seed, DataPacketSet dataSet);
  
  //protected int _numberOfGenerationsRecommended;
  //protected int _numberOfGenerationsExecuted = 0;
}
