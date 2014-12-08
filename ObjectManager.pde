class ObjectManager {

    ArrayList <Bullet> bullets;  
    ArrayList <Solid> solids;
    ArrayList <Node> nodes;
    ArrayList <Item> items;

    ObjectManager() {
	    bullets = new ArrayList();
	    solids = new ArrayList();
	    nodes = new ArrayList();
	    items = new ArrayList();
	}

	void update() {
		updateSolids();
        updateNodes();
        updateItems();
        updateBullets();
        deleteSolids();
		deleteBullets(100);
	}

	void addBullet(int _playerId, PVector _pos, PVector _dir, float _charge) {
		Bullet b = new Bullet(_playerId, _pos, _dir, _charge);
		bullets.add(b);
	}

	void addSolid(int _id, PVector _pos) {
        Solid s = new Solid(_id, _pos);
		solids.add(s);
	}

	void addNode(int _id, float _xPos, float _yPos) {
		Node n = new Node(_id,_xPos,_yPos);
		nodes.add(n);
	}

	void addItem(int _id, float _xPos, float _yPos) {
		Item i = new Item(_id,_xPos,_yPos);
		items.add(i);
	}
	
	void updateBullets() {
		for (Bullet b : bullets) {
			b.update();
		}
	}

	void updateSolids() {
		for (Solid s : solids){
			s.update();
		}
	}

	void updateNodes() {
		for (Node n : nodes) {
			n.update();
		}
	}

	void updateItems() {
		for (Item i : items) {
			i.update();
		}
	}

	void deleteBullets(int maxArraySize) {
		for (int i=0;i<bullets.size();i++) {
			Bullet b = bullets.get(i);
			if (b.destroy) bullets.remove(i);
		}

		 while(bullets.size() > maxArraySize) bullets.remove(0);
	}

	void deleteSolids() {
		for (int i=0;i<solids.size();i++) {
			Solid s = solids.get(i);
			if (s.destroy) solids.remove(i);
		}
	}
}