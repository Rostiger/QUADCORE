class TrailParticle {

	PVector pos;
	float lifeTime, siz, origSiz;
	int col, alp;
	boolean remove;


	TrailParticle(PVector _pos, float _siz, int _col) {
		pos = _pos;
		origSiz = _siz;
		siz = _siz;
		col = _col;
		alp = 255;
		remove = false;
	}

	void update() {
		if (siz > 0) siz--;
		else remove = true;
		alp = (int)map(siz,0,origSiz,0,255);
		draw();
	}

	void draw() {
		canvas.rectMode(CENTER);
		canvas.noFill();
		canvas.strokeWeight(1);
		canvas.stroke(col,alp);
		canvas.rect(pos.x,pos.y,siz,siz);
	}
}