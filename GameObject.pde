class GameObject {
	
	int id;
	PVector siz, pos, cen;
	boolean destroy;

	GameObject() {
		siz = new PVector( CELL_SIZE, CELL_SIZE );
		pos = new PVector();
		cen = new PVector();
		destroy = false;
	}

}