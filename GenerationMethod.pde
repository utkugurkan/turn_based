//import java.lang.Class;
import java.lang.reflect.Constructor;
//import java.io.Console;
//import java.nio.charset.Charset;
//import java.lang.reflect.Constructor;
//import java.lang.reflect.Field;
//import java.lang.reflect.InvocationTargetException;
//import static java.lang.System.out;

public abstract class GenerationMethod {
  
  //public GenerationMethod() {
  
  //}
  
  public GenerationMethod getNewInstance() throws Exception {
    //return Console.class.getDeclaredConstructors()[0].newInstance();
    //return this.getClass().getConstructor().newInstance();
    
    Class<?> c = this.getClass();
    Constructor<?> ctor = c.getConstructor(new Class[] { });
    return ((GenerationMethod) ctor.newInstance(new Object[] { }));
  }
  
  // Must not change the original seed.
  // Must not depend on the contents of seed staying constant.
  abstract NoteEvent[] generateFromSeed(NoteEvent[] seed);
  
  protected int _numberOfGenerationsRecommended;
  protected int _numberOfGenerationsExecuted = 0;
}
