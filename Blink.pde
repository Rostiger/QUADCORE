class Blink {

	float blinkTime;
	int alpha;

	Blink() {
		blinkTime = 0;
		alpha = 0;
	}

	int blink(int _alpha1, int _alpha2, float _speed) {
		// switches between two alpha values with a given speed
		if (blinkTime > 0) blinkTime -= 1;
		else {

			if (alpha != _alpha2) alpha = _alpha2;
			else alpha = _alpha1;			

			blinkTime = _speed;
		}

		return alpha;
	}
}