class Pulser {

	float easeControl;
	boolean reversed;
	
	Pulser() {
		easeControl = -1;
		reversed = false;
	}

	float pulse(float _startValue, float _targetValue, float _duration, float _easingFactor) {
		//pulses stuff
		float diff = _targetValue - _startValue;

		if (easeControl == -1) easeControl = _startValue;

		if (easeControl < _targetValue && !reversed) {

			easeControl += dtInSeconds / _duration * diff;

		} else if(easeControl > _startValue) {

			reversed = true;
			easeControl -= dtInSeconds / _duration * diff;

		} else reversed = false;

		return ease(easeControl,_targetValue,_startValue,_easingFactor);

	}

	float ease(float _currentValue, float _startValue, float _targetValue, float _easingFactor) {
		// this function eases a _startValue towards a _targetValue using an _easingFactor
		float normedValue = norm(_currentValue, _startValue, _targetValue);
		float easedValue = pow(normedValue, _easingFactor);
		return map(easedValue,0,1,_startValue,_targetValue);
	}

}