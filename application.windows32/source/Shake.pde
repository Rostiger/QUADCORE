class Shake {

	float shakeTime, strength, strenghtFalloff;
	PVector offset, newOffset, dir;
	boolean startShaking, isShaking, moveBack;
	
	Shake() {

		shakeTime = 0;
		offset = new PVector(0,0);
		newOffset = new PVector(0,0);
		dir = new PVector();
		startShaking = false;
		isShaking = false;
		moveBack = false;
	
	}

	void update() {

		strength -= strenghtFalloff;
		dir = new PVector( getDir(), getDir() );

		if (shakeTime > 0) {
			
			if (moveBack) {
				newOffset.mult(-1);
				moveBack = false;
			} else {
				newOffset.x = strength * dir.x;
				newOffset.y = strength * dir.y;
				moveBack = true;
			}

			offset.set(newOffset);

			shakeTime--;

		} else {

			if (moveBack) {
				newOffset.mult(-1);
				offset.set(newOffset);
			}
			
			shakeTime = 0;
			isShaking = false;

		}
	}

	void shake(float _strenght, float _duration) {

			shakeTime = _duration / dtInSeconds;
			strength = _strenght;
			strenghtFalloff = _strenght / shakeTime;
			isShaking = true;

	}

	float getDir() {
		
		float newDir = random( -1, 1 );

		if (newDir > 0) newDir = 1;
		else newDir = -1;	

		return newDir;	
	}
}
