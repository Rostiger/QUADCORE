class Pulser {

	float currentValue, currentTarget, previousTarget;
	int repeats;
	boolean reversed;
	
	Pulser() {
		currentValue = -1;
		reversed = false;
	}

	float pulse(float _startValue, float _targetValue, float _speed, float _easingFactor, int _repeats) {
		// sets parameters once
		if (currentValue == -1) {
			currentValue = _startValue;
			currentTarget = _targetValue;
			previousTarget = _startValue;
			repeats = _repeats;
		}

		float diff = currentTarget - previousTarget;
		float step = dtInSeconds / _speed * diff;

		// checks which is the smaller or larger value - needed for the constrain function below
		float smallerValue = previousTarget < currentTarget ? previousTarget : currentTarget;
		float largerValue  = previousTarget > currentTarget ? previousTarget : currentTarget;

		// approaches the current target value
		currentValue = constrain(currentValue + step, smallerValue, largerValue);

		// reverses the direction
		if (currentValue == currentTarget && repeats != 1) {

			if (currentTarget == _startValue) {
				currentTarget = _targetValue;
				previousTarget = _startValue;
			} else {
				currentTarget = _startValue;
				previousTarget = _targetValue;
			}
			if (repeats != -1) repeats--;
		}

		return ease(currentValue,currentTarget,previousTarget,_easingFactor);
	}

	float ease(float _currentValue, float _startValue, float _targetValue, float _easingFactor) {
		// this function eases a _startValue towards a _targetValue using an _easingFactor
		float normedValue = norm(_currentValue, _startValue, _targetValue);
		float easedValue = pow(normedValue, _easingFactor);
		return map(easedValue,0,1,_startValue,_targetValue);
	}

}
