class Player {

	//properties
	int id, xDir, yDir, hp, defaultHp, shieldHp, defaultShieldHp, alpha;
	float xPos, yPos, size, hSize ,vSize, hpHSize, hpVSize, hSpeed, vSpeed, centerX, centerY, minCharge, maxCharge, drawScale;
	boolean hit, respawn, dead, invincible, knockBack, hasMultiShot, hasShield, hasLockDown;
	
	// stats
	int bullets, kills, deaths, shots, items, score, nodesOwned, nodesCaptured, nodesLost, wins;
	boolean hasDiedOnce;

	//counters
	int initRespawnTime, respawnTime, respawnCounter, invincibility, invincibilityTime, trailCount, blink;
	float charge, chargeDelay, initChargeDelay;
	boolean countDown;

	//cursor
	float xPosCursor, yPosCursor, hSizeCursor, vSizeCursor;

	// boosting
	boolean hasBoost, boosting;
	int boostTime = 30;
	int boostDuration = boostTime;
	int boostTrailDensity = 2;
	int boostTrailParticleLimiter = boostTrailDensity;
	float[] trailX = new float[boostTime / boostTrailDensity];
	float[] trailY = new float[boostTime / boostTrailDensity];

	//multishot
	float msIndicatorSize, msMaxSize;

	// item display
	int itemAlpha;
	boolean showItem;
	float itemYPos, itemShowDuration;
	String currentItem, prevItem = "";

	//shaking
	Shake shake = new Shake();
	boolean shaking;

	public Input input;
	
	Player(int _id) {

		id = _id;
		input = new Input(id);

		// set player variables
		size = CELL_SIZE;
		if (size > 0)	{ hSize = size; vSize = size; }
		else 			{ hSize = 0; vSize = 0; }

		setStartPosition();

		// set cursor variables
		xPosCursor = xPos;
		yPosCursor = yPos;

		// player center
		centerX = xPos + hSize / 2;
		centerY = yPos + vSize / 2;

		//properties
		defaultHp = 10;
		hp = defaultHp;
		shieldHp = 0;
		defaultShieldHp = 10;
		xDir = 0;
		yDir = 1;
		alpha = 255;
		drawScale = 1;

		hit = false;
		respawn = true;
		dead = true;
		invincible = true;
		boosting = false;
		hasBoost = true;
		hasMultiShot = false;
		hasShield = false;
		hasLockDown = true;
		showItem = false;
		shaking = false;

		//stats
		bullets = 0;
		score = 0;
		deaths = 0;
		kills = 0;
		items = 0;
		nodesOwned = 0;
		nodesCaptured = 0;
		nodesLost = 0;
		wins = 0;
		hasDiedOnce = false;

		//counters
		maxCharge = CELL_SIZE;
		minCharge = CELL_SIZE / 2;
		charge = minCharge;
		initChargeDelay = 10;
		chargeDelay = initChargeDelay;
		initRespawnTime = 2;
		respawnTime = initRespawnTime;
		respawnCounter = 0;
		countDown = false;
		invincibilityTime = 150;
		invincibility = invincibilityTime;
		trailCount = 100000;
		blink = 0;

		// multishot display variables
		msMaxSize = hSize / 6;
		msIndicatorSize = msMaxSize;	
	}

	void update() {

		input.update();

		// if the player died fade the alpha to 0
		if (dead) {

			if (alpha > 0) alpha -= 10 * dt;
			else if (!respawn && !gManager.matchOver) respawn = true;

		} else {
			// decrease the player rectangle to display health state
			hpHSize = hSize / 2 * hp / 10;
			hpVSize = vSize / 2 * hp / 10;

			// if hp goes under 0, kill the player
			if (hp <= 0) {
				dead = true;
				die01.trigger();
				deaths++;
				hasDiedOnce = true;
				respawnTime *= 2;
				gManager.activePlayers--;
			}

			// maintain the shield status
			if (shieldHp <= 0) hasShield = false;
			else hasShield = true;

			//if the player is invincible, count down the timer and start blinking
			if (invincible) {
				if (invincibility > 0) {
					blink(0,255,10);
					// only count down if invincibility isn't switched on in the console
					if (!debugger.invincibility) invincibility -= dt;
				}
				else {
					invincible = false;
					invincibility = invincibilityTime;
					alpha = 255;
				}
			}		
		}

		// if the player is dead, respawn with a delay
		if (respawn) {
			// count down until respawn is possible
			if (respawnCounter > 0) {
				if (!hud.visible) {
					if (countDown) { respawnCounter--; countDown = false; }
				} else countDown = true;
			} else if (input.shootReleased && !gManager.matchOver) {
				spawn();
				respawnCounter = respawnTime;
			}

			// let the player move around to change respawn position
			if (hasDiedOnce) move();

			drawRespawnIndicator();

		} else {
			// let the player move, face a direction, shoot and get hit when not dead
			if (!invincible) hit();
			move();
			face();
			draw();
			if(!gManager.matchOver && !respawn && !dead) shoot();

			// lock down nodes
			if (input.useItemPressed && hasLockDown) lockDown();
		}
				
		//check how many nodes the player owns (must be more than one)
		if (nodesOwned == oManager.nodes.size() && nodesOwned != 0 && !gManager.matchOver) {
			wins ++;
			if (wins == 3) gManager.gameOver = true;
			gManager.matchOver = true;
			gManager.winnerID = id;
		}
	}

	void draw() {


		centerX = xPos + hSize / 2;
		centerY = yPos + vSize / 2;

		hSizeCursor = charge / 4;
		vSizeCursor = charge / 4;

		canvas.rectMode(CENTER);

		// player background
		canvas.strokeWeight(size / 32);	
		canvas.fill(colors.player[id],alpha/5);
		canvas.stroke(colors.player[id],alpha/2);
		canvas.pushMatrix();
		canvas.scale(1.0);
		canvas.rect(centerX,centerY,hSize,vSize);
		canvas.popMatrix();

		//draw the player core background
		canvas.noStroke();
		canvas.fill(colors.player[id],alpha/3);
		canvas.rect(centerX,centerY,hSize/2,vSize/2);

		// draw the multishot indicator
		if (hasMultiShot) drawMultiShotIndicator();

		// draw the boost indicator
		if (hasBoost) drawBoostIndicator();

		// draw the boost trail
		drawBoostTrail();

		// draw shield
		if (hasShield) {
			float offset = size / 16;
			canvas.noFill();
			canvas.stroke(colors.player[id],alpha);
			float weight = map(shieldHp,0,defaultShieldHp,1,6);
			canvas.strokeWeight(weight);
			canvas.rect(centerX + offset,centerY + offset,hSize - offset * 2,vSize - offset * 2);
		}

		// draw the player core
		canvas.noStroke();
		canvas.fill(colors.player[id],alpha);
		canvas.rect(centerX,centerY,hpHSize,hpVSize);

		// draw the cursor
		canvas.rect(xPosCursor,yPosCursor,hSizeCursor,vSizeCursor);
		
		// draw the item name on pickup
		if (showItem) drawItemName();

		if (debugger.debugDraw) {
			canvas.fill(255,255,255,255);
			canvas.rect(xPos,yPos,hSize / 4,vSize / 4);
			canvas.rect(centerX,centerY,hSize / 4,vSize / 4);
			canvas.textSize(debugger.fontSize);
			canvas.textAlign(CENTER);
			canvas.fill(colors.player[id],255);
			int playerID = id;
			float textPosY = centerY + vSize + debugger.fontSize;
			canvas.text("ID: " + id,centerX,textPosY);
			canvas.text("ALPHA: " + alpha,centerX,textPosY+debugger.fontSize);
			// canvas.text("BOOSTING: " + strokeWidth,centerX,textPosY+debugger.fontSize*2);
			// canvas.text("UP: " + upPressed,centerX,textPosY+debugger.fontSize);
			// canvas.text("DOWN: " + downPressed,centerX,textPosY+debugger.fontSize*2);
			// canvas.text("LEFT: " + leftPressed,centerX,textPosY+debugger.fontSize*3);
			// canvas.text("RIGHT: " + rightPressed,centerX,textPosY+debugger.fontSize*4);
		}
	}

	void drawRespawnIndicator() {
		canvas.rectMode(CORNER);
		canvas.noFill();
		canvas.strokeWeight(CELL_SIZE / (CELL_SIZE / 3));
		canvas.stroke(colors.player[id],100);
		canvas.strokeCap(SQUARE);
		canvas.line(xPos,yPos,xPos + hSize/4,yPos);
		canvas.line(xPos + hSize - hSize/4,yPos,xPos + hSize,yPos);
		canvas.line(xPos,yPos,xPos,yPos + vSize / 4);
		canvas.line(xPos,yPos + vSize - vSize / 4,xPos,yPos + vSize);
		canvas.line(xPos + hSize,yPos,xPos + hSize,yPos + vSize / 4);
		canvas.line(xPos + hSize,yPos + vSize - vSize / 4,xPos + hSize,yPos + vSize);
		canvas.line(xPos,yPos + vSize,xPos + hSize/4,yPos + vSize);
		canvas.line(xPos + vSize - hSize / 4,yPos + vSize,xPos + hSize,yPos + vSize);
		canvas.noStroke();
		canvas.fill(colors.player[id],50);
		canvas.rect(xPos + CELL_SIZE / 10, yPos + CELL_SIZE / 10, hSize - CELL_SIZE / 5, vSize - CELL_SIZE / 5);
		canvas.textAlign(CENTER);
		canvas.textSize(CELL_SIZE / 1.5);
		canvas.fill(colors.player[id],200);
		canvas.pushMatrix();
		switch (id) {
			case 0:
				canvas.translate(xPos + hSize / 2,yPos+vSize / 2.8);
				canvas.rotate(radians(180)); break;
			case 1: 
				canvas.translate(xPos + hSize / 2,yPos+vSize / 1.5);
				canvas.rotate(radians(0)); break;
			case 2: 
				canvas.translate(xPos + hSize / 1.5,yPos+vSize / 2);
				canvas.rotate(radians(270)); break;
			case 3: 
				canvas.translate(xPos + hSize / 2.8,yPos+vSize / 2);
				canvas.rotate(radians(90)); break;
		}
		if (respawnCounter > 0) canvas.text(respawnCounter,0,0);
		else canvas.text("GO!",0,0);
		canvas.popMatrix();
		canvas.strokeWeight(0);
		canvas.rectMode(CORNER);
	}

	void drawBoostIndicator() {
		// setup some temp variables for later adjustment
		float x1 = 0, y1 = 0, x2 = 0, y2 = 0, x3 = 0, y3 = 0;
		float lineDistance = hSize / 8; 

		canvas.strokeWeight(CELL_SIZE / 16);
		canvas.pushMatrix();
		// set the drawing origin to the center of the player
		canvas.translate(centerX,centerY);

		// set the positions depending on the direction of the player
		if (yDir == 0) {
			x1 = -hSize / 2 * xDir;
			y1 = -vSize / 2;
			x2 = -hSize / 2 * xDir;
			y2 = vSize / 2;
		} else if (xDir == 0) {
			x1 = -hSize / 2;
			y1 = -vSize / 2 * yDir;
			x2 = hSize / 2;
			y2 = -vSize / 2 * yDir;
		} else {
			x1 = -hSize / 2 * xDir;
			y1 = 0;
			x2 = -hSize / 2 * xDir;
			y2 = -vSize / 2 * yDir;
			x3 = 0;
			y3 = -vSize / 2 * yDir;			
		} 

		for (int i=1;i<=3;i++) {
			canvas.stroke(colors.player[id],alpha / i);
			if (xDir != 0) { x1 -= lineDistance * xDir; x2 -= lineDistance * xDir; x3 -= lineDistance * xDir; }
			if (yDir != 0) { y1 -= lineDistance * yDir; y2 -= lineDistance * yDir; y3 -= lineDistance * yDir; }
			canvas.line(x1,y1,x2,y2);
			if (xDir != 0 && yDir != 0) canvas.line(x2,y2,x3,y3);
		}
		canvas.popMatrix();
	}

	void drawMultiShotIndicator() {

		float msMinSize = hSize / 12;
		float msSpeed = 0.2;

		if (msIndicatorSize <= msMinSize || msIndicatorSize >= msMaxSize) msSpeed *= -1;
		msIndicatorSize += msSpeed;

		canvas.fill(colors.player[id],alpha);
		for (int xD=-1;xD<=1;xD++) {
			for (int yD=-1;yD<=1;yD++) {
			    if (xD == 0 && yD == 0) {}
			    else canvas.rect(centerX + hSize / 4 * xD,centerY + vSize / 4 * yD,msIndicatorSize,msIndicatorSize);
			}
		}
	}

	void drawBoostTrail() {
		// draw the boost trail
		if (boosting) {
			if (trailCount < boostTime) {
				trailX[trailCount] = centerX;
				trailY[trailCount] = centerY;

				canvas.noFill();
				canvas.strokeWeight(CELL_SIZE / 32);	

				for (int i=0;i<trailCount;i++) {
					float trailSize = map(i,0,trailCount,CELL_SIZE / 8,CELL_SIZE);
					float trailAlpha = map(i,0,trailCount,0,255);
					canvas.stroke(colors.player[id],trailAlpha);
					canvas.rect(trailX[i],trailY[i],trailSize,trailSize);
				}

				if (boostTrailParticleLimiter > 1) boostTrailParticleLimiter--;
				else {
					trailCount++;
					boostTrailParticleLimiter = boostTrailDensity;
				}
			}
		} else {
			float[] trailX = new float[boostTime / boostTrailDensity];
			float[] trailY = new float[boostTime / boostTrailDensity];
			trailCount = 0;
		}
	}

	void drawItemName() {
		
		if (prevItem != currentItem) itemYPos = 0;

		prevItem = currentItem;
		
		canvas.pushMatrix();
		canvas.translate(centerX,centerY);

		if (TOP_VIEW) {
			switch (id) {
				case 0: canvas.rotate(radians(180)); break;
				case 1: canvas.rotate(radians(0)); break;
				case 2: canvas.rotate(radians(270)); break;
				case 3: canvas.rotate(radians(90)); break;
			}
		}
		
		canvas.textAlign(CENTER);
		canvas.textSize(CELL_SIZE);

		float itemYPosMax = -CELL_SIZE;
		float easing = 0.2;
		float itemDistance = itemYPosMax - itemYPos;
		float itemShowTime = 30;

		// set the text position
		if (itemYPos > itemYPosMax && abs(itemDistance) > 1) {
			// move the text up
			itemYPos += itemDistance * easing * dt;

			// set the text transparency depending on the text position
			itemAlpha = (int)map(itemYPos,0,itemYPosMax,0,255);

			itemShowDuration = itemShowTime;
		} else {
			// let the text stand there for a little while
			if (itemShowDuration > 0) itemShowDuration -= dt;
			else {
				// fade out the text
				int fadeOutSpeed = 20;
				if (itemAlpha > 0) itemAlpha -= fadeOutSpeed;
				else {
					itemYPos = 0;
					itemShowDuration = itemShowTime;
					showItem = false;
				}
			}
		} 

		// set the color and alpha
		canvas.fill(colors.player[id],itemAlpha);

		// draw the actual text
		canvas.text(currentItem,0,itemYPos);
		canvas.popMatrix();
	}

	void blink(int _value1, int _value2, int _speed) {

		if (blink > 0) blink -= dt;
		else {

			if (alpha < _value2) alpha = _value2;
			else alpha = _value1;

			blink = _speed;
		}
	}

	float getVSpeed(float _acc, float _dec, float _maxSpeed) {
		// determine vertical speed
		if (input.upPressed || (boosting && yDir == -1)) {
			if (vSpeed > -_maxSpeed) vSpeed -= _acc;
			else vSpeed = -_maxSpeed;
		} else if (input.downPressed || (boosting && yDir == 1)) {
			if (vSpeed < _maxSpeed) vSpeed += _acc;
			else vSpeed = _maxSpeed;
		} else {
			if (abs(vSpeed) > 0.1) vSpeed *= _dec;
			else vSpeed = 0;
		}
		// return the vertical speed
		return vSpeed;
	}

	float getHSpeed(float _acc, float _dec, float _maxSpeed) {
		// determine horizontal speed
		if (input.leftPressed || (boosting && xDir == -1)) {
			if (hSpeed > -_maxSpeed) hSpeed -= _acc;
			else hSpeed = -_maxSpeed;
		} else if (input.rightPressed || (boosting && xDir == 1)) {
			if (hSpeed < _maxSpeed) hSpeed += _acc;
			else hSpeed = _maxSpeed;
		} else {
			if (abs(hSpeed) > 0.1) hSpeed *= _dec;
			else hSpeed = 0;
		}	
		// return the horizontal speed
		return hSpeed;
	}

	void move() {
		// movement properties
		float maxSpeed = 3.5 * dt;
		float acceleration = 0.5 * dt;
		float deceleration = 0.2 * dt;			

		// boost triggering
		// check if the player has a boost counter higher than 0
		// and hasn't boosted last update
		if (input.useItemPressed && !respawn) {
			// only boost if the player isn't already boosting and
			// doesn have the multishot item
			if (hasBoost && !boosting) {
				boosting = true;
				hasBoost = false;
				boost01.trigger();
			}
		}

		// change movement properties when boosting
		if (boosting) {
			maxSpeed = 8.0;
			acceleration = 1.0;

			if (boostDuration > 0) boostDuration -= dt;
			else {
				boosting = false;
				boostDuration = boostTime;
			}
		}

		getVSpeed(acceleration, deceleration, maxSpeed);
		getHSpeed(acceleration, deceleration, maxSpeed);

		// player shaking
		hSpeed += shake.offset.x;
		vSpeed += shake.offset.y;

		//collision bools
		boolean collisionTop = false;
		boolean collisionBottom = false;
		boolean collisionLeft = false;
		boolean collisionRight = false;

		//check for collisions with other players
		for (Player p : gManager.players) {

			// only check for collisions when:
			// the id is different from the players id
			// when the other player isn't dead
			// when the player isn't in respawn mode
			// and when there isn't already a collision

			if (id != p.id && !p.dead && !respawn) {
				if (!collisionTop) 		collisionTop = collision.checkBoxCollision(xPos,yPos - abs(vSpeed),hSize,vSize,p.xPos,p.yPos,p.hSize,p.hSize);
				if (!collisionBottom)	collisionBottom = collision.checkBoxCollision(xPos,yPos + abs(vSpeed),hSize,vSize,p.xPos,p.yPos,p.hSize,p.hSize);
				if (!collisionLeft)		collisionLeft = collision.checkBoxCollision(xPos - abs(hSpeed),yPos,hSize,vSize,p.xPos,p.yPos,p.hSize,p.hSize);
				if (!collisionRight)	collisionRight = collision.checkBoxCollision(xPos + abs(hSpeed),yPos,hSize,vSize,p.xPos,p.yPos,p.hSize,p.hSize);
 			}

		}

		//check for collisions with solids
		for (Solid s : oManager.solids) {
				if (!collisionTop)		collisionTop = collision.checkBoxCollision(xPos,yPos - abs(vSpeed),hSize,vSize,s.xPos,s.yPos,s.hSize,s.vSize);
				if (!collisionBottom)	collisionBottom = collision.checkBoxCollision(xPos,yPos + abs(vSpeed),hSize,vSize,s.xPos,s.yPos,s.hSize,s.vSize);
				if (!collisionLeft)		collisionLeft = collision.checkBoxCollision(xPos - abs(hSpeed),yPos,hSize,vSize,s.xPos,s.yPos,s.hSize,s.vSize);
				if (!collisionRight)	collisionRight = collision.checkBoxCollision(xPos + abs(hSpeed),yPos,hSize,vSize,s.xPos,s.yPos,s.hSize,s.vSize);
		}

		// if there are no collisions set vertical speed
		if (vSpeed <= 0 && !collisionTop) yPos += vSpeed;
		if (vSpeed >= 0 && !collisionBottom) yPos += vSpeed;

		// if there are no collisions set horizontal speed
		if (hSpeed <= 0 && !collisionLeft) xPos += hSpeed;
		if (hSpeed >= 0 && !collisionRight) xPos += hSpeed;

		// screenwrapping
		if (xPos > VIEW_WIDTH) xPos = -hSize;
		else if (xPos + hSize < 0) xPos = VIEW_WIDTH;

		if (yPos > VIEW_HEIGHT) yPos = -vSize;
		else if (yPos + vSize < 0) yPos = VIEW_HEIGHT;

	}

	void face() {
		// this class determines which direction the player is facing and sets the player cursor appropriately
		if (input.upPressed) {
			yDir = -1;
			if (!input.leftPressed && !input.rightPressed) xDir = 0;
		}
		else if (input.downPressed) {
			yDir = 1;
			if (!input.leftPressed && !input.rightPressed) xDir = 0;
		}
		
		if (input.leftPressed) {
			xDir = -1;
			if (!input.upPressed && !input.downPressed) yDir = 0;
		}
		else if (input.rightPressed) {
			xDir = 1;
			if (!input.upPressed && !input.downPressed) yDir = 0;
		}

		//evaluate the position of the cursor depending on the player direction
		if (yDir > 0) yPosCursor = yPos + vSize;
		else if (yDir < 0) yPosCursor = yPos;
		else yPosCursor = yPos + vSize / 2;

		if (xDir > 0) xPosCursor = xPos + hSize;
		else if (xDir < 0) xPosCursor = xPos;
		else xPosCursor = xPos + hSize / 2;
	}

	void shoot() {
		//shoot bullets!

		if (input.shootReleased) {
		    oManager.addBullet(id,xPosCursor,yPosCursor,xDir,yDir,charge);
		    shot01.trigger();
		    shots++;
			charge = minCharge;
			input.shootReleased = false;
			chargeDelay = initChargeDelay;
		} else if (input.shootWasPressed) {
			if (chargeDelay > 0) chargeDelay -= dt;
			else {
				if (charge < maxCharge) charge += 1.01 * dt;
				else charge = maxCharge;
			}
		}

		// use multishot item!
		if (input.useItemPressed && hasMultiShot) {
			multiShot01.trigger();
			for (int xD=-1;xD<=1;xD++) {
				for (int yD=-1;yD<=1;yD++) {
				    if (xD == 0 && yD == 0) {}
				    else oManager.addBullet(id,centerX,centerY,xD,yD,minCharge);
				}
			}
			hasMultiShot = false;
		}
	}

	void hit() {
		//go through each existing bullet and check if the player collides with any of them
		for (Bullet b : oManager.bullets) {

			// skip the players own bullets
			if (id == b.id) continue;

			//only check collisions when the player isn't dead
			if (!dead) hit = collision.checkBoxCollision(xPos,yPos,hSize,vSize,b.xPos,b.yPos,b.hSize,b.vSize);

			// if the player was hit by a bullet
			if (hit) {

				Player p = gManager.players[b.id];				// get the id of the shooter
				
				if (b.damage != 0 && !hasShield) {				// if the bullet hasn't hit yet, shake the target 
					shake.startShaking = true;	
				}

				if (!hasShield) hp -= b.damage;					// if the target has no shield, subtract hp
				else shieldHp -= b.damage;						// subtract damage from shield
				
				b.damage = 0;									// set the bullet damage to 0 (used to determine if it still can do damage)
				
				if (hp <= 0) p.kills++;							// add the shooters killcount if the bullet killed the target
				break;											// exit the loop
			}

		}

		hit = false;
	}

	void knockBack(int _xDir, int _yDir) {
		// knocks the player back when hit
		int knockBackStrength = 5;

		// hSpeed = knockBackStrength * _xDir * dt; 
		// vSpeed = knockBackStrength * _yDir * dt; 

		//play a sound
		hurt01.trigger();

		knockBack = true;		// this doesn't do anything but can be used later if needed
	}

	void lockDown() {
		for (Node n : oManager.nodes) {
			n.wasLockedDown = true;
		}
		hasLockDown = false;
	}

	void spawn() {

		// set cursor variables
		xPosCursor = xPos;
		yPosCursor = yPos;

		// respawn the player and reset it's properties
		dead = false;
		respawn = false;
		invincible = true;
		hp = defaultHp;
		alpha = 255;
		spawn01.trigger();
		gManager.activePlayers++;

		checkSpawnKill();
	}

	void checkSpawnKill() {

		boolean spawnKill = false;

		//check for collisions with other players and kill them when spawning on top of them
		for (Player p : gManager.players) {
			// skip own player id
			if (id == p.id) continue;
			// don't check when dead
			if (!p.dead) {
				spawnKill = collision.checkBoxCollision(xPos,yPos,hSize,vSize,p.xPos,p.yPos,p.hSize,p.hSize);
 			}
 			if (spawnKill) p.hp -= p.hp;
		}
	}

	void setStartPosition() {
		// starting position
		xPos = gManager.playerStartPosX[id];
		yPos = gManager.playerStartPosY[id];			
	}

	void reset() {
		dead = true;
		alpha = 0;
		nodesOwned = 0;
		respawnCounter = 0;
		respawnTime = initRespawnTime;
		hasDiedOnce = false;
		charge = minCharge;
		hasBoost = false;
		hasMultiShot = false;
		hasLockDown = false;
		shieldHp = 0;
		kills = 0;
		deaths = 0;
		items = 0;
		shots = 0;
		nodesCaptured = 0;
		nodesLost = 0;
		showItem = false;
		if (gManager.gameOver) wins = 0;
		setStartPosition();
	}
}
