class Item {

	int id, ownedByPlayer, occupiedByPlayer, respawnTime;
	float size, xPos, yPos, hSize, vSize, respawn, alphh;
	boolean pickUp, pickedUp;
	String[] items = new String[]{"BOOST","HEALTH","MULTISHOT","LOCKDOWN","SHIELD"};
	String itemName;

	// health vars
	float hxPos, hyPos, hScale, hScaleSpeed, hScaleMax, hScaleMin;

	// boost vars
	float bxPos, byPos, bScale, bScaleSpeed, bScaleMax, bScaleMin;

	// multishot vars
	float msSpeed, msDistance, msScale, msScaleMax, msScaleMin;

	// shield vars
	float sStroke, sStrokeMin, sStrokeMax, sStrokeSpeed;

	// health vars
	int a, aMax, aMin, aSpeed, b;

	// lockdown vars
	float ldPos, ldPosFactor, ldPosMin, ldPosMax, ldSpeed;

	Item(int _id, float _xPos, float _yPos) {
		id = _id;
		xPos = _xPos;
		yPos = _yPos;
		size = CELL_SIZE;
		if (size > 0)	{ hSize = size; vSize = size; }
		else 			{ hSize = 0; vSize = 0; }
		pickedUp = true;
		pickUp = false;
		itemName = items[floor(random(0,items.length))];
		alphh = 255;

		respawnTime = 0;

		bxPos = -hSize / 2;
		bxPos = -vSize / 2;
		bScaleMax = 0.8;
		bScaleMin = 0.3;
		bScale = bScaleMax;
		bScaleSpeed = 0.01;

		hxPos = -hSize / 2;
		hxPos = -vSize / 2;
		hScaleMax = 1.0;
		hScaleMin = 0.0;
		hScale = hScaleMin;
		hScaleSpeed = 0.01;

		msDistance = 0;
		msSpeed = 0.5;
		msScaleMax = 1.0;
		msScaleMin = 0.2;
		msScale = msScaleMax;

		sStrokeMin = size / 32;
		sStrokeMax = size / 4;
		sStroke = sStrokeMax;
		sStrokeSpeed = 0.3;

		aMax = 100;
		aMin = 40;
		a = aMax;
		b = a * 2;
		aSpeed = 2;

		ldPosMax = size / 2.5;
		ldPosMin = 4;
		ldPos = ldPosMax;
		ldPosFactor = ldPosMax;
		ldSpeed = 0.3;
	}

	void update() {

		if (!pickedUp) {
			
			draw();

			for (Player p : gManager.players) {
				
				// if the player is dead or respawning, skip to the next player
				if (!p.ALIVE) continue;

				// check for collisions
				pickUp = collision.checkBoxCollision(xPos,yPos,hSize,vSize,p.pos.x,p.pos.y,p.siz.x,p.siz.y);

				if (pickUp) {
					if (itemName == "BOOST") { 
						p.hasBoost = true;
						p.hasMultiShot = false;
						p.hasLockDown = false;
					} else if (itemName == "MULTISHOT") {
						p.hasBoost = false;
						p.hasMultiShot = true;
						p.hasLockDown = false;
					} else if (itemName == "LOCKDOWN") {
						p.hasBoost = false;
						p.hasMultiShot = false;
						p.hasLockDown = true;
					} else if (itemName == "SHIELD") {
						p.shieldHp.x = p.shieldHp.y;
					} else if (itemName == "HEALTH") p.hp.x = p.hp.y;

					p.currentItem = itemName;
					p.showItem = true;
					p.items++;

					pickedUp = true;
					powerUpGet01.trigger();
					break;
				}  
			}
		} else {

			// item respawning
			if (respawn > 0) respawn -= dt;
			else {

				// choose an item by it's likelihood
				int randomNumber = floor(random(0,100));

				// {"BOOST","HEALTH","MULTISHOT","LOCKDOWN","SHIELD"}
				if (randomNumber < 5) 			itemName = "LOCKDOWN";
				else if (randomNumber < 15)		itemName = "SHIELD";
				else if (randomNumber < 30)		itemName = "MULTISHOT";
				else if (randomNumber < 50)		itemName = "HEALTH";
				else 							itemName = "BOOST"; 

				pickedUp = false;
				respawn = floor(random(200,1000));
				powerUpSpawn01.trigger();
			}
		}
	}

	void draw() {
		if (itemName == "HEALTH") { drawHealthItem(); }
		else if (itemName == "BOOST") { drawBoostItem(); } 
		else if (itemName == "MULTISHOT") { drawMultiShotItem(); }
		else if (itemName == "LOCKDOWN") { drawLockDownItem(); }
		else if (itemName == "SHIELD") { drawShieldItem(); }
	}

	void drawHealthItem(){
		if (a <= aMin || a >= aMax) aSpeed *= -1;
		a += aSpeed;
		b = a * 3;

		int[][] squares = {	{a, b, a},
							{b, b, b},
							{a, b, a}	};
		int squaresLength = squares[0].length;
		float offset = size / 16;
		float squareSize = (size - offset * 2) / squaresLength;

		// health item visuals	
		canvas.rectMode(CORNER);
		canvas.stroke(colors.bg);
		canvas.strokeWeight(squareSize / 8);
		canvas.pushMatrix();
		canvas.translate(xPos + hSize / 2 + offset,yPos + vSize / 2 + offset);
		for (int r=0;r<squaresLength;r++) {
			for (int c=0;c<squaresLength;c++) {
				float x = -hSize / 2 + squareSize * r;
				float y = -vSize / 2 + squareSize * c;
				canvas.fill(colors.item,squares[r][c]);
				canvas.rect(x,y,squareSize,squareSize);
			}
		}
		canvas.popMatrix();
		canvas.noFill();
		canvas.stroke(colors.item);
		canvas.strokeWeight(squareSize / 16);
		canvas.rect(xPos,yPos,hSize,vSize);
	}

	void drawBoostItem() {
		// boost item visuals
		canvas.noStroke();
		canvas.rectMode(CORNER);
		canvas.pushMatrix();
		// set the pivot to the center of the item
		canvas.translate(xPos + hSize / 2,yPos + vSize / 2);

		// draw a pulsing rectangle in the background
		canvas.pushMatrix();
		alphh = (int)map(bScale,bScaleMax,bScaleMin,50,150);
		canvas.fill(colors.item,alphh);
		if (bScale <= bScaleMin || bScale >= bScaleMax) bScaleSpeed *= -1;
		bScale += bScaleSpeed;
		canvas.scale(bScale);
		canvas.rect(-hSize / 2,-vSize / 2, hSize, vSize);
		canvas.popMatrix();

		// set the position of the little rectangle
		if (bxPos < hSize / 4) bxPos += dt;
		else {
			if (hud.visible) bxPos = -hSize / 2;
		}
		byPos = -vSize / 2;
		// map the position of the little rectangle to the alphh value the trail should hhve
		alphh = (int)map(bxPos,hSize/4,-hSize / 2,0,255);
		// draw four rectangles with a little fake trail
		for (int r=0;r<4;r++) {
			// now rotate from the center
			canvas.rotate(radians(90 * r));
			canvas.stroke(colors.item, alphh);
			canvas.strokeWeight(CELL_SIZE / 5);
			// draw the trail
			canvas.line(-hSize / 2 + hSize / 8, -vSize / 2 + vSize / 8,bxPos + hSize / 8,byPos + vSize / 8);
			canvas.strokeWeight(1.0);
			canvas.noStroke();
			canvas.fill(colors.item,255);
			// draw the little rectangle
			canvas.rect(bxPos,byPos,hSize/4,vSize/4);
		}
		canvas.popMatrix();		
	}

	void drawMultiShotItem() {
		float centerX = xPos + hSize / 2 - hSize / 8;
		float centerY = yPos + vSize / 2 - vSize / 8;

		canvas.rectMode(CORNER);
		canvas.noStroke();
		canvas.pushMatrix();
		// set the pivot to the center of the item
		canvas.translate(xPos + hSize / 2,yPos + vSize / 2);
		// draw a pulsing rectangle in the background
		// let the scale move between it's min and max range
		if (msScale <= msScaleMin || msScale >= msScaleMax) msSpeed *= -1;
		msScale += msSpeed / 30;
		// map the alphh to the current scale value
		alphh = (int)map(msScale,msScaleMax,msScaleMin,50,150);
		canvas.fill(colors.item,alphh);
		// draw the rectangle
		canvas.scale(msScale);
		canvas.rect(-hSize / 2,-vSize / 2, hSize, vSize);
		canvas.popMatrix();

		// draw 8 little bullets moving in 8 directions
		float msDistanceMax = hSize / 2;
		if (msDistance < msDistanceMax) msDistance += abs(msSpeed);
		else msDistance = 0;
		
		alphh = (int)map(msDistance,msDistanceMax,0,50,255);
		canvas.fill(colors.item,alphh);
		for (int xD=-1;xD<=1;xD++) {
			for (int yD=-1;yD<=1;yD++) {
			    if (xD == 0 && yD == 0) {}
			    else canvas.rect(centerX + hSize / 16 + msDistance * xD,centerY + vSize /16 + msDistance * yD,hSize / 8, vSize / 8);
			}
		}
	}

	void drawLockDownItem() {
		if (ldPos <= ldPosMin ||  ldPos >= ldPosMax) ldSpeed *= -1;
		
		ldPos += ldSpeed;

		float ldSize = size / 2.5;
		float alpha = map(ldPos,ldPosMin,ldPosMax,10,250);

		canvas.rectMode(CENTER);
		canvas.fill(colors.item,alpha);
		canvas.noStroke();
		canvas.pushMatrix();
		canvas.translate(xPos + hSize / 2,yPos + vSize / 2);
		canvas.rect(-ldPos,-ldPos,ldSize,ldSize);			
		canvas.rect(ldPos,-ldPos,ldSize,ldSize);			
		canvas.rect(-ldPos,ldPos,ldSize,ldSize);			
		canvas.rect(ldPos,ldPos,ldSize,ldSize);			
		canvas.stroke(colors.item,255);
		canvas.strokeWeight(size / 8);
		canvas.line(-ldPos,-ldPos,ldPos,ldPos);			
		canvas.line(ldPos,-ldPos,-ldPos,ldPos);			
		canvas.popMatrix();
	}

	void drawShieldItem() {
		if (sStroke <= sStrokeMin || sStroke >= sStrokeMax) sStrokeSpeed *= -1;
		sStroke += sStrokeSpeed;

		canvas.rectMode(CENTER);
		canvas.noFill();
		canvas.stroke(colors.item);
		canvas.pushMatrix();
		canvas.translate(xPos + hSize / 2,yPos + vSize / 2);
		canvas.strokeWeight(size / 32);
		canvas.rect(0,0,hSize,vSize);
		canvas.strokeWeight(sStroke);
		canvas.rect(0,0,hSize / 1.7,vSize / 1.7);
		canvas.popMatrix();
	}
}