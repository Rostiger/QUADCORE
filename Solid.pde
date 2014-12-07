class Solid {

	int id;
	float xPos, yPos, size, hSize, vSize;
	boolean delete;
	
	Solid(int _id, float _xPos, float _yPos) {
		id = _id;
		size = CELL_SIZE;
		if (size > 0)	{ hSize = size; vSize = size; }
		else 			{ hSize = 0; vSize = 0; }
		delete = false;
		xPos = _xPos;
		yPos = _yPos;
	}

	void update() {
		
		draw();
	}

	void draw() {
		canvas.rectMode(CORNER);
		if (debugger.debugDraw) {

			float fontSize = CELL_SIZE / 4 * CELL_SIZE / 50.0;
			float indent = CELL_SIZE / 8;

			canvas.textAlign(LEFT);
			canvas.stroke(255,255,255,50);
			canvas.fill(colors.solid,255);
			canvas.rect(xPos,yPos,hSize,vSize);
			canvas.noStroke();
			canvas.fill(255,255,255,200);
			canvas.rect(xPos,yPos,2,2);
			canvas.textSize(fontSize);
			canvas.text("ID:" + id,xPos+indent,yPos + CELL_SIZE / 3.5);
			canvas.text("X:" + floor(xPos),xPos+indent,yPos + CELL_SIZE / 1.7);
			canvas.text("Y:" + floor(yPos),xPos+indent,yPos + CELL_SIZE / 1.1);
		} else {
			canvas.noStroke();
			canvas.fill(colors.solid,255);
			canvas.rect(xPos,yPos,hSize,vSize);
		}
	}
}