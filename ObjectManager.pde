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

	void addBullet(int _playerId, float _xPosPlayer, float _yPosPlayer, int _xDir, int _yDir, float _charge) {
		Bullet b = new Bullet(_playerId,_xPosPlayer,_yPosPlayer,_xDir,_yDir,_charge);
		bullets.add(b);
	}

	void addSolid(int _id, float _xPos, float _yPos) {
        Solid s = new Solid(_id,_xPos,_yPos);
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
			if (b.delete) bullets.remove(i);
		}

		 while(bullets.size() > maxArraySize) bullets.remove(0);
	}

	void deleteSolids() {
		for (int i=0;i<solids.size();i++) {
			Solid s = solids.get(i);
			if (s.delete) solids.remove(i);
		}
	}
}