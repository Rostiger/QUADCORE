class Checkers {
	
	int switchTime, alpha, alpha1, alpha2;
	
	Checkers() {
		switchTime = 0;
		alpha = 0;
		alpha1 = 0;
		alpha2 = 0;
	}

	void drawCheckers(int _color, int _alpha1, int _alpha2, int _switchSpeed, PVector _size, float _scale) {
		
		if (switchTime > 0) switchTime--;
		else {

			if (alpha1 == _alpha1) alpha1 = _alpha2;
			else alpha1 = _alpha1;

			if (alpha2 == _alpha2) alpha2 = _alpha1;
			else alpha2 = _alpha2;

			switchTime = _switchSpeed;
		}

		rectMode(CORNER);
		noStroke();

		PVector numCells = new PVector( floor(VIEW_WIDTH / (_size.x * _scale)), floor(VIEW_HEIGHT / (_size.y * _scale)) );
		PVector cellSize = new PVector( VIEW_WIDTH / numCells.x, VIEW_HEIGHT / numCells.y);

		boolean toggleAlphaOnLineBreak = numCells.x%2 != 0;

		alpha = alpha2;

		for (float y = 0; y < numCells.y; y++) {
		
			for (float x = 0; x < numCells.x; x++) {

				float xPos = canvasPos.x + cellSize.x * x;
				float yPos = canvasPos.y + cellSize.y * y;

				if (x != 0 || toggleAlphaOnLineBreak) {
					alpha = alpha == alpha2 ? alpha1 : alpha2;
				}

				fill(_color,alpha);
				rect(xPos,yPos,cellSize.x,cellSize.x);
			}
		}

	}
}