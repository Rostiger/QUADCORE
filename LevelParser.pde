class LevelParser {
	
	LevelParser() {}

	void parseLevel(int _levelID) {

		int levelID = _levelID;
		// load the level from the level list by looking up its id
		// String [] level = levelList.get(levelID);
		PImage level = levelList.get(levelID);
		// load the images pixels
		level.loadPixels();

		int solidID = 0;
		int nodeID = 0;
		int itemID = 0;

		// step through the level file - for each horizontal line...
		for (int y=0; y<height; y++) {
			// step through all vertical characters
			for (int x=0; x<width; x++) {
				// store the pixel color that is encountered
				color pixelColor = level.get(x,y);
				// store an in-game xPos and a yPos for each character
				float xPos = CELL_SIZE * x;
				float yPos = CELL_SIZE * y;

				// convert the position to a vector 
				PVector pos = new PVector(CELL_SIZE * x, CELL_SIZE * y);

				// add objects to the game at the stored position, according to the specific color that was encountered
				if (pixelColor == color(0,0,0)) 		oManager.addSolid(solidID++,pos);
				if (pixelColor == color(128,128,128)) 	oManager.addNode(nodeID++,xPos,yPos);
				if (pixelColor == color(255,160,0)) 	oManager.addItem(itemID++,xPos,yPos);
				if (pixelColor == color(255,0,0)) 		oManager.addPlayer(0,pos);
				if (pixelColor == color(255,255,0)) 	oManager.addPlayer(1,pos);
				if (pixelColor == color(0,255,0)) 		oManager.addPlayer(2,pos);
				if (pixelColor == color(0,0,255)) 		oManager.addPlayer(3,pos);
			}			
		}
		// the level is parsed into the game - huzzah!
		// this is a super simple technique to load levelsl, i still feel super smart to have figured it out myself!
	}
}