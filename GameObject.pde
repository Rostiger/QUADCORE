class GameObject {
	
	int id, alpha, blinkTime;
	PVector siz, pos, cen, hp;
	float drawScale, repeatTime;
	boolean destroy, repeat;

	GameObject() {
		// shared variables for all game objects
		siz = new PVector( CELL_SIZE, CELL_SIZE );
		pos = new PVector();
		cen = new PVector();
		hp  = new PVector();
		drawScale = 1.0;
		destroy = false;
		alpha = 255;
		blinkTime = 0;

	}

	void blink(int _alpha1, int _alpha2, int _speed) {
		// switches between two alpha values with a given speed
		if (blinkTime > 0) blinkTime -= 1 * dtInSeconds;
		else {

			if (alpha < _alpha2) alpha = _alpha2;
			else alpha = _alpha1;

			blinkTime = _speed;
		}
	}

	boolean repeat(float _interval) {
		// switches a bool with a given interval - useful for triggering events at a specific rate
		repeat = false;

		if (repeatTime > 0) repeatTime -= 1;
		else {
			repeat = true;
			repeatTime = _interval;
		}

		return repeat;
	}
}