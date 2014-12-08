class LevelParser {

	LevelParser() {}

	void parseLevel(int _levelID) {

		int levelID = _levelID;
		// load the level from the level list by looking up its id
		// String [] level = levelList.get(levelID);
		PImage level = levelList.get(levelID);
		level.loadPixels();

		int solidID = 0;
		int nodeID = 0;
		int itemID = 0;

		// step through the level file - for each vertical line...
		for (int x=0; x<width; x++) {
			// step through all horizontal characters
			for (int y=0; y<height; y++) {
				// store the character that is encountered
				color pixelColor = level.get(x,y);
				// store an in-game xPos and a yPos for each character
				float xPos = CELL_SIZE * x;
				float yPos = CELL_SIZE * y;

				PVector pos = new PVector(CELL_SIZE * x, CELL_SIZE * y);

				// check through the characters and add respective objects to the game at the stored position
				if (pixelColor == color(0,0,0)) oManager.addSolid(solidID++,pos);
				if (pixelColor == color(128,128,128)) oManager.addNode(nodeID++,xPos,yPos);
				if (pixelColor == color(255,160,0)) oManager.addItem(itemID++,xPos,yPos);
				if (pixelColor == color(255,0,0)) gManager.setPlayerStartPosition(0,pos);
				if (pixelColor == color(255,255,0)) gManager.setPlayerStartPosition(1,pos);
				if (pixelColor == color(0,255,0)) gManager.setPlayerStartPosition(2,pos);
				if (pixelColor == color(0,0,255)) gManager.setPlayerStartPosition(3,pos);
			}			
		}
		// the level is parsed into the game - huzzah!
	}
}