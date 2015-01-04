class Grid {
	
	// PVector pos, siz;
	float cellSize, pointSize, pointWeight;
	int switchTime, alpha, alpha1, alpha2;
	boolean drawCheckers;
	
	Grid() {
		switchTime = 0;
		alpha = 0;
		alpha1 = 0;
		alpha2 = 0;
		drawCheckers = false;
	}

	void drawGrid(PVector _pos, PVector _siz, float _cellSize, float _pointSize, float _pointWeight, int _color, int _alpha){
		PVector pos = _pos;
		PVector siz = _siz;
		float cellSize = _cellSize;

		for (float x=0; x<=siz.x; x+=cellSize) {

			for (float y=0; y<=siz.y; y+=cellSize) {

				drawGridPoint(pos.x + x, pos.y + y, _pointSize, _pointWeight, _color, _alpha);
			}

		}

		if (drawCheckers) drawCheckers(pos, siz, cellSize, _color, _alpha);
	}

	void drawGridPoint(float _x, float _y, float _size, float _weight, int _color, int _alpha) {
		PVector pos = new PVector(_x,_y);
		float siz = _size;
		stroke(_color, _alpha);
		strokeWeight(_weight);
		line(pos.x - siz / 2, pos.y, pos.x + siz / 2, pos.y);
		line(pos.x, pos.y - siz / 2, pos.x, pos.y + siz / 2);
	}

	void drawCheckers(PVector _pos, PVector _siz, float _cellSize, int _color, int _alpha) {

		PVector siz = _siz;
		PVector pos = _pos;
		float cellSize = _cellSize;

		int altAlpha = 4;
		
		if (switchTime > 0) switchTime--;
		else {

			if (alpha1 == _alpha) alpha1 = _alpha / altAlpha;
			else alpha1 = _alpha;

			if (alpha2 == _alpha / altAlpha) alpha2 = _alpha / altAlpha;
			else alpha2 = _alpha / altAlpha;

			switchTime = 14;
		}

		rectMode(CORNER);
		noStroke();

		PVector numCells = new PVector( siz.x / cellSize, siz.y / cellSize );

		boolean toggleAlphaOnLineBreak = numCells.x%2 != 0;

		alpha = alpha2;

		for (float y = 0; y <=numCells.y; y++) {
		
			for (float x = 0; x <=numCells.x; x++) {

				float xPos = pos.x + cellSize * x;
				float yPos = pos.y + cellSize * y;

				if (x != 0 || toggleAlphaOnLineBreak) {
					alpha = alpha == alpha2 ? alpha1 : alpha2;
				}

				fill(_color,alpha);
				rect(xPos,yPos,cellSize,cellSize);
			}
		}

	}
}