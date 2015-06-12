class Solid extends GameObject {

	boolean destroy;
	
	Solid(int _id, PVector _pos) {
		id = _id;
		pos.set(_pos);
		destroy = false;
	}

	void update() {
		draw();
	}

	void draw() {
		canvas.rectMode(CORNER);
		canvas.noStroke();
		canvas.fill(colors.solid,255);
		canvas.rect(pos.x,pos.y,siz.x,siz.y);

		if (debugger.debugDraw) debugDraw();
	}

	void debugDraw() {

			float fontSize 	= CELL_SIZE / 4 * CELL_SIZE / 50.0;
			float indent 	= CELL_SIZE / 8;
			float weight 	= CELL_SIZE / 16;

			canvas.fill(255,255,255,200);
			canvas.textAlign(LEFT);
			canvas.textSize(fontSize);
			canvas.text("ID:" + id,pos.x+indent,pos.y + CELL_SIZE / 3.5);
			canvas.text("X:" + floor(pos.x),pos.x+indent,pos.y + CELL_SIZE / 1.7);
			canvas.text("Y:" + floor(pos.y),pos.x+indent,pos.y + CELL_SIZE / 1.1);

			canvas.stroke(255,255,255,50);
			canvas.strokeWeight(weight);
			canvas.rect(pos.x,pos.y,siz.x,siz.y);
	}
}
