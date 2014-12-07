class Shake {

	int dir;
	float shakeTime, strength;
	PVector offset, newOffset;
	boolean startShaking, isShaking, moveBack;
	
	Shake() {

		dir = 1;
		shakeTime = 0;
		offset = new PVector(0,0);
		newOffset = new PVector(0,0);
		startShaking = false;
		isShaking = false;
		moveBack = false;
	
	}

	void update() {

		if (shakeTime !=0) println("shakeTime: "+shakeTime);

		if (shakeTime > 0) {
			
			moveBack = !moveBack;

			newOffset.x = strength;
			newOffset.y = strength;

			offset.set(newOffset);

			if (moveBack) strength *= -1;

			shakeTime--;

		} else {

			shakeTime = 0;
			isShaking = false;

		}
	}

	void shake(float _strenght, float _duration) {

			strength = _strenght;
			shakeTime = _duration / dtInSeconds;
			isShaking = true;

	}
}