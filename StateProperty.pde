public class StateProperty {
  
  static final float MIN_VAL = 0.;
  static final float MAX_VAL = 1.;
  
  public StateProperty(String name) {
    _name = name;
    _currentValue = 0.;
    _changeRatePerTurn = .1;
    _targetValue = .5;
    _updateCountAtTarget = 0;
    _updateCountToReset = 1;
  }
  
  public void copyParameters(StateProperty other) {
    if (other == null) {
      println("You are NULLLL");
      return;
    }
    println("Copy parameters went through");
    _currentValue = other._currentValue;
    _changeRatePerTurn = other._changeRatePerTurn;
    _targetValue = other._targetValue;
    _updateCountAtTarget = other._updateCountAtTarget;
    _updateCountToReset = other._updateCountToReset;
  }
  
  public void print() {
    println(_name + " value: " + getValue() + ", change rate: " + getChangeRatePerTurn() + 
    ", target: " + getTargetValue() + ", updates at target: " + _updateCountAtTarget + "/" + _updateCountToReset);
  }
  
  public void update() {
    if (_currentValue == _targetValue) {
      ++_updateCountAtTarget;
      //println("Target value reached.");
    } else {
      float newValue = _currentValue + _changeRatePerTurn;
      if ((_targetValue > _currentValue && _targetValue < newValue) ||
          (_targetValue < _currentValue && _targetValue > newValue)) {
        newValue = _targetValue;         
       }
      setValue(newValue);
    }
  }
  
  public void resetProgress() {
    _updateCountAtTarget = 0;
  }
  
  public String getName() {
    return _name;
  }
  
  public boolean reachedResetCondition() {
    return _currentValue == _targetValue && _updateCountAtTarget >= _updateCountToReset;
  }
  
  public float getValue() {
    return _currentValue;
  }
  
  public float getChangeRatePerTurn() {
    return _changeRatePerTurn;
  }
  
  public float getTargetValue() {
    return _targetValue;
  }
  
  public int getUpdateCountToReset() {
    return _updateCountToReset; 
  }
  
  public void setValue(float val) {
    _currentValue = val;
    if (_currentValue < MIN_VAL) {
      _currentValue = MIN_VAL;
    }
    else if (_currentValue > MAX_VAL) {
      _currentValue = MAX_VAL; 
    }
  }
  
  public void setChangeRatePerTurn(float rate) {
    _changeRatePerTurn = rate;
  }
  
  public void setTargetValue(float val) {
    _targetValue = val;
    if (_targetValue < MIN_VAL) {
      _targetValue = MIN_VAL;
    }
    else if (_targetValue > MAX_VAL) {
      _targetValue = MAX_VAL; 
    }
  }
  
  public void setUpdateCountToReset(int val) {
    _updateCountToReset = val; 
  }
  
  protected String _name;
  protected float _currentValue;
  protected float _changeRatePerTurn;
  protected float _targetValue;
  // Number of times the update was called when the value was at the target.
  protected int _updateCountAtTarget;
  protected int _updateCountToReset;
}
