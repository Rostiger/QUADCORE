class GameObject {
	
	int id;
	PVector siz, pos, cen, hp;
	boolean destroy;

	GameObject() {
		siz = new PVector( CELL_SIZE, CELL_SIZE );
		pos = new PVector();
		cen = new PVector();
		hp  = new PVector();
		destroy = false;
	}

}