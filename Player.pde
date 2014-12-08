class Player extends GameObject {

	//properties
	PVector dir, speed, sizCore;

	int id, hp, defaultHp, shieldHp, defaultShieldHp, alpha;
	float minCharge, maxCharge, drawScale;
	boolean hit, respawn, dead, invincible, knockBack, hasMultiShot, hasShield, hasLockDown;
	
	// stats
	int bullets, kills, deaths, shots, items, score, nodesOwned, nodesCaptured, nodesLost, wins;
	boolean hasDiedOnce;

	//counters
	int respawnDuration, respawnTime, respawnDurationMultiplier;
	int invincibleDuration, invincibleTime;
	int trailCount, blink;
	float charge, chargeDelay, initChargeDelay;

	//cursor
	PVector cursorPos, cursorSiz;

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
		pos 		= new PVector( gManager.playerStartPos[id].x, gManager.playerStartPos[id].y );
		cen 		= new PVector( pos.x + siz.x / 2, pos.y + siz.x / 2);
		sizCore		= new PVector( siz.x, siz.y );
		cursorPos 	= new PVector( pos.x, pos.y );
		cursorSiz 	= new PVector( siz.x, siz.y );
		speed 		= new PVector( 0,0 );
		dir 		= new PVector( 0,1 );

		//properties
		defaultHp = 10;
		hp = defaultHp;
		shieldHp = 0;
		defaultShieldHp = 10;
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
		wasKilledOnce = false;

		//counters
		maxCharge = CELL_SIZE;
		minCharge = CELL_SIZE / 2;
		charge = minCharge;
		initChargeDelay = 10;
		chargeDelay = initChargeDelay;
		respawnDuration = 2;
		respawnTime = respawnDuration;
		respawnDurationMultiplier = 2;

		invincibleDuration = 150;
		invincibleTime = invincibleDuration;
		trailCount = 100000;
		blink = 0;

		// multishot display variables
		msMaxSize = siz.x / 6;
		msIndicatorSize = msMaxSize;	
	}

	void update() {

		input.update();

		updateVectors();

		if (ALIVE) {

			if (KILLED) {

				if (alpha > 0) alpha -= 10 * dt;
				else if (!respawn && !gManager.matchOver) {
					ALIVE = false;
					KILLED = false;
				}

			}

			// if hp goes under 0, kill the player
			if (hp <= 0) {
				KILLED = true;
				die01.trigger();
				deaths++;
				wasKilledOnce = true;
				respawnDuration *= respawnDurationMultiplier;
				gManager.activePlayers--;
			}

			// maintain the shield status
			if (shieldHp <= 0) hasShield = false;
			else hasShield = true;

			//if the player is invincible, count down the timer and start blinking
			if (INVINCIBLE) {

				if (invincibleTime > 0) {

					blink(0,255,10);
					invincibility -= dt;
				
				} else {

					if (!debugger.invincibility) INVINCIBLE = false;
					invincibleTime = invincibleDuration;
					alpha = 255;
				
				}
			}
		} else {

			// count down until respawn is possible
			if (respawnTime > 0 && !canRespawn) respawnTime -= dtInSeconds;
			else {
				canRespawn = true;
				respawnTime = respawnDuration;
			}

			if (input.shootReleased && !gManager.matchOver && canRespawn) {
				spawn();
			}

			// let the player move around to change respawn position
			if (wasKilledOnce) move();

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


		}


		}


				
		//check how many nodes the player owns (must be more than one)
		if (nodesOwned == oManager.nodes.size() && nodesOwned != 0 && !gManager.matchOver) {
			wins ++;
			if (wins == 3) gManager.gameOver = true;
			gManager.matchOver = true;
			gManager.winnerID = id;
		}
	}

	void updateVectors() {

		cen.x = pos.x + siz.x / 2;
		cen.y = pos.y + siz.y / 2;

		sizCore.x = siz.x / 2 * hp / 10;
		sizCore.y = siz.y / 2 * hp / 10;

		cursorSiz.x = charge / 4;
		cursorSiz.y = charge / 4;

	}
	void draw() {

		canvas.rectMode(CENTER);

		// player background
		canvas.strokeWeight(siz.x / 32);	
		canvas.fill(colors.player[id],alpha/5);
		canvas.stroke(colors.player[id],alpha/2);
		canvas.pushMatrix();
		canvas.scale(1.0);
		canvas.rect(cen.x,cen.y,siz.x,siz.y);
		canvas.popMatrix();

		//draw the player core background
		canvas.noStroke();
		canvas.fill(colors.player[id],alpha/3);
		canvas.rect(cen.x,cen.y,siz.x/2,siz.y/2);

		// // draw the multishot indicator
		// if (hasMultiShot) drawMultiShotIndicator();

		// // draw the boost indicator
		// if (hasBoost) drawBoostIndicator();

		// // draw the boost trail
		// drawBoostTrail();

		// draw shield
		// if (hasShield) {
		// 	float offset = size / 16;
		// 	canvas.noFill();
		// 	canvas.stroke(colors.player[id],alpha);
		// 	float weight = map(shieldHp,0,defaultShieldHp,1,6);
		// 	canvas.strokeWeight(weight);
		// 	canvas.rect(cen.x + offset,cen.y + offset,siz.x - offset * 2,siz.y - offset * 2);
		// }

		// draw the player core
		canvas.noStroke();
		canvas.fill(colors.player[id],alpha);
		canvas.rect(cen.x,cen.y,sizCore.x,sizCore.x);

		// draw the cursor
		canvas.rect(cursorPos.x,cursorPos.y,cursorSiz.x,cursorSiz.y);
		
		// draw the item name on pickup
		if (showItem) drawItemName();

		if (debugger.debugDraw) {
			// canvas.fill(255,255,255,255);
			// canvas.rect(pos.x,pos.y,siz.x / 4,siz.y / 4);
			// canvas.rect(cen.x,cen.y,siz.x / 4,siz.y / 4);
			// canvas.textSize(debugger.fontSize);
			// canvas.textAlign(CENTER);
			// canvas.fill(colors.player[id],255);
			// int playerID = id;
			// float textPosY = cen.y + siz.x + debugger.fontSize;
			// canvas.text("ID: " + id,cen.x,textPosY);
			// canvas.text("ALPHA: " + alpha,cen.x,textPosY+debugger.fontSize);
			// canvas.text("BOOSTING: " + strokeWidth,cen.x,textPosY+debugger.fontSize*2);
			// canvas.text("UP: " + upPressed,cen.x,textPosY+debugger.fontSize);
			// canvas.text("DOWN: " + downPressed,cen.x,textPosY+debugger.fontSize*2);
			// canvas.text("LEFT: " + leftPressed,cen.x,textPosY+debugger.fontSize*3);
			// canvas.text("RIGHT: " + rightPressed,cen.x,textPosY+debugger.fontSize*4);
		}
	}

	void drawRespawnIndicator() {
		canvas.rectMode(CORNER);
		canvas.noFill();
		canvas.strokeWeight(CELL_SIZE / (CELL_SIZE / 3));
		canvas.stroke(colors.player[id],100);
		canvas.strokeCap(SQUARE);
		canvas.line(pos.x,pos.y,pos.x + siz.x/4,pos.y);
		canvas.line(pos.x + siz.x - siz.x/4,pos.y,pos.x + siz.x,pos.y);
		canvas.line(pos.x,pos.y,pos.x,pos.y + siz.x / 4);
		canvas.line(pos.x,pos.y + siz.x - siz.x / 4,pos.x,pos.y + siz.x);
		canvas.line(pos.x + siz.x,pos.y,pos.x + siz.x,pos.y + siz.x / 4);
		canvas.line(pos.x + siz.x,pos.y + siz.x - siz.x / 4,pos.x + siz.x,pos.y + siz.x);
		canvas.line(pos.x,pos.y + siz.x,pos.x + siz.x/4,pos.y + siz.x);
		canvas.line(pos.x + siz.x - siz.x / 4,pos.y + siz.x,pos.x + siz.x,pos.y + siz.x);
		canvas.noStroke();
		canvas.fill(colors.player[id],50);
		canvas.rect(pos.x + CELL_SIZE / 10, pos.y + CELL_SIZE / 10, siz.x - CELL_SIZE / 5, siz.x - CELL_SIZE / 5);
		canvas.textAlign(CENTER);
		canvas.textSize(CELL_SIZE / 1.5);
		canvas.fill(colors.player[id],200);
		canvas.pushMatrix();
		switch (id) {
			case 0:
				canvas.translate(pos.x + siz.x / 2,pos.y+siz.x / 2.8);
				canvas.rotate(radians(180)); break;
			case 1: 
				canvas.translate(pos.x + siz.x / 2,pos.y+siz.x / 1.5);
				canvas.rotate(radians(0)); break;
			case 2: 
				canvas.translate(pos.x + siz.x / 1.5,pos.y+siz.x / 2);
				canvas.rotate(radians(270)); break;
			case 3: 
				canvas.translate(pos.x + siz.x / 2.8,pos.y+siz.x / 2);
				canvas.rotate(radians(90)); break;
		}
		if (respawnCounter > 0) canvas.text(respawnCounter,0,0);
		else canvas.text("GO!",0,0);
		canvas.popMatrix();
	}

	void drawBoostIndicator() {
		// setup some temp variables for later adjustment
		float x1 = 0, y1 = 0, x2 = 0, y2 = 0, x3 = 0, y3 = 0;
		float lineDistance = siz.x / 8; 

		canvas.strokeWeight(CELL_SIZE / 16);
		canvas.pushMatrix();
		// set the drawing origin to the center of the player
		canvas.translate(cen.x,cen.y);

		// set the positions depending on the direction of the player
		if (dir.y == 0) {
			x1 = -siz.x / 2 * dir.x;
			y1 = -siz.x / 2;
			x2 = -siz.x / 2 * dir.x;
			y2 = siz.x / 2;
		} else if (dir.x == 0) {
			x1 = -siz.x / 2;
			y1 = -siz.x / 2 * dir.y;
			x2 = siz.x / 2;
			y2 = -siz.x / 2 * dir.y;
		} else {
			x1 = -siz.x / 2 * dir.x;
			y1 = 0;
			x2 = -siz.x / 2 * dir.x;
			y2 = -siz.x / 2 * dir.y;
			x3 = 0;
			y3 = -siz.x / 2 * dir.y;			
		} 

		for (int i=1;i<=3;i++) {
			canvas.stroke(colors.player[id],alpha / i);
			if (dir.x != 0) { x1 -= lineDistance * dir.x; x2 -= lineDistance * dir.x; x3 -= lineDistance * dir.x; }
			if (dir.y != 0) { y1 -= lineDistance * dir.y; y2 -= lineDistance * dir.y; y3 -= lineDistance * dir.y; }
			canvas.line(x1,y1,x2,y2);
			if (dir.x != 0 && dir.y != 0) canvas.line(x2,y2,x3,y3);
		}
		canvas.popMatrix();
	}

	void drawMultiShotIndicator() {

		float msMinSize = siz.x / 12;
		float msSpeed = 0.2;

		if (msIndicatorSize <= msMinSize || msIndicatorSize >= msMaxSize) msSpeed *= -1;
		msIndicatorSize += msSpeed;

		canvas.fill(colors.player[id],alpha);
		for (int xD=-1;xD<=1;xD++) {
			for (int yD=-1;yD<=1;yD++) {
			    if (xD == 0 && yD == 0) {}
			    else canvas.rect(cen.x + siz.x / 4 * xD,cen.y + siz.x / 4 * yD,msIndicatorSize,msIndicatorSize);
			}
		}
	}

	void drawBoostTrail() {
		// draw the boost trail
		if (boosting) {
			if (trailCount < boostTime) {
				trailX[trailCount] = cen.x;
				trailY[trailCount] = cen.y;

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
		canvas.translate(cen.x,cen.y);

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
		if (input.upPressed || (boosting && dir.y == -1)) {
			if (speed.y > -_maxSpeed) speed.y -= _acc;
			else speed.y = -_maxSpeed;
		} else if (input.downPressed || (boosting && dir.y == 1)) {
			if (speed.y < _maxSpeed) speed.y += _acc;
			else speed.y = _maxSpeed;
		} else {
			if (abs(speed.y) > 0.1) speed.y *= _dec;
			else speed.y = 0;
		}
		// return the vertical speed
		return speed.y;
	}

	float getHSpeed(float _acc, float _dec, float _maxSpeed) {
		// determine horizontal speed
		if (input.leftPressed || (boosting && dir.x == -1)) {
			if (speed.x > -_maxSpeed) speed.x -= _acc;
			else speed.x = -_maxSpeed;
		} else if (input.rightPressed || (boosting && dir.x == 1)) {
			if (speed.x < _maxSpeed) speed.x += _acc;
			else speed.x = _maxSpeed;
		} else {
			if (abs(speed.x) > 0.1) speed.x *= _dec;
			else speed.x = 0;
		}	
		// return the horizontal speed
		return speed.x;
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
		speed.x += shake.offset.x;
		speed.y += shake.offset.y;

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
				if (!collisionTop) 		collisionTop = collision.checkBoxCollision(pos.x,pos.y - abs(speed.y),siz.x,siz.x,p.pos.x,p.pos.y,p.siz.x,p.siz.x);
				if (!collisionBottom)	collisionBottom = collision.checkBoxCollision(pos.x,pos.y + abs(speed.y),siz.x,siz.x,p.pos.x,p.pos.y,p.siz.x,p.siz.x);
				if (!collisionLeft)		collisionLeft = collision.checkBoxCollision(pos.x - abs(speed.x),pos.y,siz.x,siz.x,p.pos.x,p.pos.y,p.siz.x,p.siz.x);
				if (!collisionRight)	collisionRight = collision.checkBoxCollision(pos.x + abs(speed.x),pos.y,siz.x,siz.x,p.pos.x,p.pos.y,p.siz.x,p.siz.x);
 			}

		}

		//check for collisions with solids
		for (Solid s : oManager.solids) {
				if (!collisionTop)		collisionTop = collision.checkBoxCollision(pos.x,pos.y - abs(speed.y),siz.x,siz.x,s.pos.x,s.pos.y,s.siz.x,s.siz.y);
				if (!collisionBottom)	collisionBottom = collision.checkBoxCollision(pos.x,pos.y + abs(speed.y),siz.x,siz.x,s.pos.x,s.pos.y,s.siz.x,s.siz.y);
				if (!collisionLeft)		collisionLeft = collision.checkBoxCollision(pos.x - abs(speed.x),pos.y,siz.x,siz.x,s.pos.x,s.pos.y,s.siz.x,s.siz.y);
				if (!collisionRight)	collisionRight = collision.checkBoxCollision(pos.x + abs(speed.x),pos.y,siz.x,siz.x,s.pos.x,s.pos.y,s.siz.x,s.siz.y);
		}

		// if there are no collisions set vertical speed
		if (speed.y <= 0 && !collisionTop) pos.y += speed.y;
		if (speed.y >= 0 && !collisionBottom) pos.y += speed.y;

		// if there are no collisions set horizontal speed
		if (speed.x <= 0 && !collisionLeft) pos.x += speed.x;
		if (speed.x >= 0 && !collisionRight) pos.x += speed.x;

		// screenwrapping
		if (pos.x > VIEW_WIDTH) pos.x = -siz.x;
		else if (pos.x + siz.x < 0) pos.x = VIEW_WIDTH;

		if (pos.y > VIEW_HEIGHT) pos.y = -siz.x;
		else if (pos.y + siz.x < 0) pos.y = VIEW_HEIGHT;

	}

	void face() {
		// this class determines which direction the player is facing and sets the player cursor appropriately
		if (input.upPressed) {
			dir.y = -1;
			if (!input.leftPressed && !input.rightPressed) dir.x = 0;
		}
		else if (input.downPressed) {
			dir.y = 1;
			if (!input.leftPressed && !input.rightPressed) dir.x = 0;
		}
		
		if (input.leftPressed) {
			dir.x = -1;
			if (!input.upPressed && !input.downPressed) dir.y = 0;
		}
		else if (input.rightPressed) {
			dir.x = 1;
			if (!input.upPressed && !input.downPressed) dir.y = 0;
		}

		//evaluate the position of the cursor depending on the player direction
		if (dir.y > 0) cursorPos.y = pos.y + siz.x;
		else if (dir.y < 0) cursorPos.y = pos.y;
		else cursorPos.y = pos.y + siz.x / 2;

		if (dir.x > 0) cursorPos.x = pos.x + siz.x;
		else if (dir.x < 0) cursorPos.x = pos.x;
		else cursorPos.x = pos.x + siz.x / 2;
	}

	void shoot() {
		//shoot bullets!

		if (input.shootReleased) {
		    oManager.addBullet(id,cursorPos,dir,charge);
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
				    if (xD != 0 && yD != 0) {
				    	PVector direction = new PVector( xD, yD );
				    	oManager.addBullet(id,cen,direction,minCharge);
				    }
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
			if (!dead) hit = collision.checkBoxCollision(pos.x,pos.y,siz.x,siz.x,b.pos.x,b.pos.y,b.siz.x,b.siz.y);

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

	void knockBack(PVector dir) {
		// knocks the player back when hit
		int knockBackStrength = 5;

		// speed.x = knockBackStrength * _dir.x * dt; 
		// speed.y = knockBackStrength * _dir.y * dt; 

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
		cursorPos.set(pos);

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
				spawnKill = collision.checkBoxCollision(pos.x,pos.y,siz.x,siz.x,p.pos.x,p.pos.y,p.siz.x,p.siz.x);
 			}
 			if (spawnKill) p.hp -= p.hp;
		}
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
		pos.set(gManager.playerStartPos[id]);
	}
}
