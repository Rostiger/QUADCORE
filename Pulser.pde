class Pulser {

	float currentValue;
	int dur;
	boolean reversed;
	
	Pulser() {
		currentValue = -1;
		reversed = false;
	}

	float pulse(float _startValue, float _targetValue, float _speed, float _easingFactor, int _duration) {
		//pulses stuff
		float diff = _targetValue - _startValue;

		// sets parameters once
		if (currentValue == -1) {
			currentValue = _startValue;
			dur = _duration;
		}

		// determines the current value
		if (currentValue < _targetValue && !reversed && dur != 0) {

			currentValue += dtInSeconds / _speed * diff;
			if (dur != -1) dur--;

		} else if(currentValue > _startValue) {

			reversed = true;
			currentValue -= dtInSeconds / _speed * diff;

		} else {
			reversed = false;
		}

		return currentValue;
		// ease(easeControl,_targetValue,_startValue,_easingFactor);

	}

	float ease(float _currentValue, float _startValue, float _targetValue, float _easingFactor) {
		// this function eases a _startValue towards a _targetValue using an _easingFactor
		float normedValue = norm(_currentValue, _startValue, _targetValue);
		float easedValue = pow(normedValue, _easingFactor);
		return map(easedValue,0,1,_startValue,_targetValue);
	}

}