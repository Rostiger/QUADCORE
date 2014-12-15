class ObjectManager {

    ArrayList < Bullet > bullets;  
    ArrayList < Solid > solids;
    ArrayList < Node > nodes;
    ArrayList < Item > items;

    int activePlayers;
	int maxPlayers = 4;
	Player[] players = new Player[maxPlayers];

    ObjectManager() {
    	bullets 	= new ArrayList();
	    solids 		= new ArrayList();
	    nodes 		= new ArrayList();
	    items 		= new ArrayList();
	}

	void update() {
        destroyBullet();
		updateGameObjects();
	}

	void updateGameObjects() {
		// updates all game objects
		for (Solid o : solids) 		o.update();
		for (Item o : items) 		o.update();
		for (Node o : nodes) 		o.update();
		for (Player o : players) 	o.update();
		for (Bullet o : bullets) 	o.update();
	}

	void destroyBullet() {
		// removes a specific game object from the array list
		for (int i=0;i<bullets.size();i++) {
			Bullet b = bullets.get(i);
			if (b.destroy) bullets.remove(i);
		}
	}


	void clearGameObjects() {
		bullets.clear();
		solids.clear();
		nodes.clear();
		items.clear();
	}

	void addPlayer(int _id, PVector _startPos) {
		// adds an inactive players
		Player p = new Player(_id, _startPos);
		players[_id] = p;
	}

	void resetPlayers() {
		// resets all players
		for (Player p : players) p.reset();
	}

	void addBullet(int _id, PVector _pos, PVector _dir, float _charge) {
		Bullet b = new Bullet(_id, _pos, _dir, _charge);
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

	void keyPressed() {
		//check keyPresses for all players if the aren't using a gamepad
		if (players != null) {
			for (Player p : players) {
				if (p.input.hasGamePad) continue;
				else p.input.keyPressed();
			}
		}		
	}

	void keyReleased() {
		//check keyReleases for all players if the aren't using a gamepad
		if (players != null) {
			for (Player p : players) {
				if (p.input.hasGamePad) continue;
				else p.input.keyReleased();
			}
		}
	}
}