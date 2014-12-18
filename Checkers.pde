class Checkers {
	
	int switchTime, alpha, alpha1, alpha2;
	
	Checkers() {
		switchTime = 0;
		alpha = 0;
		alpha1 = 0;
		alpha2 = 0;
	}

	void drawCheckers(int _color, int _alpha1, int _alpha2, int _switchSpeed, int _scale) {
		
		if (switchTime > 0) switchTime--;
		else {

			if (alpha1 == _alpha1) alpha1 = _alpha2;
			else alpha1 = _alpha1;

			if (alpha2 == _alpha2) alpha2 = _alpha1;
			else alpha2 = _alpha2;

			switchTime = _switchSpeed;
		}
		
		for (float x = canvasPos.x; x < VIEW_WIDTH; x += CELL_SIZE * _scale) {

			if (alpha == alpha2) alpha = alpha1;
			else alpha = alpha2;

			for (float y = canvasPos.y; y < VIEW_HEIGHT; y += CELL_SIZE * _scale) {

				if (alpha == alpha2) alpha = alpha1;
				else alpha = alpha2;

				rectMode(CORNER);
				fill(_color,alpha);
				noStroke();
				rect(x,y,CELL_SIZE * _scale,CELL_SIZE * _scale);
			}
		}
	}
}