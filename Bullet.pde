class Bullet {
	int id, xDir, yDir, damage, wrapCounter, alpha;
	float xPos, yPos, size, hSize, vSize, xCenter, yCenter, speed, hitEffectSpeed;
	boolean hasPlayed, delete;

	Bullet(int _playerId, float _xPosPlayerCursor, float _yPosPlayerCursor, int _xDir, int _yDir, float _charge) {
		id = _playerId;
		size = _charge;
		if (size > 0)	{ hSize = size; vSize = size; }
		else 			{ hSize = 0; vSize = 0; }
		xPos = _xPosPlayerCursor - hSize / 2;
		yPos = _yPosPlayerCursor - vSize / 2;
		xCenter = xPos + hSize / 2;
		yCenter = yPos + vSize / 2;
		xDir = _xDir;
		yDir = _yDir;
		speed = map(_charge,CELL_SIZE / 2, CELL_SIZE, 10.0, 5.0);
		damage = floor(map(_charge,CELL_SIZE / 2, CELL_SIZE, 1.0, 10.0));
		delete = false;
		wrapCounter = 0;
		alpha = 255;
		hitEffectSpeed = 1.0;
		hasPlayed = false;
	}
	
	void update() {

		draw();

		// check for collisions
		boolean collision = false;
		collision = checkCollision();

		// if the bullet collides or moves outside the screen a second time, subtract damage
		if (collision || wrapCounter > 1) damage = 0;

		// if the bullet can do damage, move it around
		if (damage > 0) {
			// update the center coordinates
			xCenter = xPos + hSize / 2;
			yCenter = yPos + vSize / 2;

			// move the bullet
			xPos += speed * xDir * dt;
			yPos += speed * yDir * dt;

			// count screenwraps
			if (xPos > VIEW_WIDTH || xPos + hSize < 0 || yPos > VIEW_HEIGHT || yPos + vSize < 0) wrapCounter++;

			// wrap it around the screen
			if (wrapCounter <= 1) {
				if (xPos > VIEW_WIDTH) xPos = -hSize / 2;
				if (xPos + hSize < 0) xPos = VIEW_WIDTH - hSize / 2;

				if (yPos > VIEW_HEIGHT) yPos = -vSize / 2;
				if (yPos + vSize < 0) yPos = VIEW_HEIGHT - vSize / 2;
			}

		} else {
  			if (!hasPlayed) {
  				bulletHit01.trigger();
  				hasPlayed = true;
  			}
		}
	}

	void draw() {

		canvas.noStroke();
		canvas.rectMode(CORNER);
		canvas.fill(colors.player[id],alpha);

		if (damage > 0) {
			canvas.rect(xPos,yPos,hSize,vSize);
		} else {
			float hitEffectX = xCenter + hSize * xDir;
			float hitEffectY = yCenter + vSize * yDir; 

			int tmpDirX = 0;
			int tmpDirY = 0;
			int tmpAcc = 10;
			
			hitEffectSpeed += tmpAcc;

			for (int i=0; i<4; i++) {
				switch(i) {
					case 0: tmpDirX = -1; tmpDirY = -1; break;
					case 1: tmpDirX = 1; tmpDirY = -1; break;
					case 2: tmpDirX = 1; tmpDirY = 1; break;
					case 3: tmpDirX = -1; tmpDirY = 1; break;
				}

				float tmpX = hitEffectX + hitEffectSpeed * tmpDirX * dt;
				float tmpY = hitEffectY + hitEffectSpeed * tmpDirY * dt;

				canvas.rect(tmpX,tmpY,hSize / 2, vSize / 2);
			}

			if (alpha > 0) alpha -= tmpAcc * 6 * dt;
			else delete = true;

		}

		// set position to check collision for
		// float checkX = centerX + hSize * xDir;
		// float checkY = centerY + vSize * yDir;
		// float checkHSize = hSize / 1.5;
		// float checkVSize = vSize / 1.5;

		if (debugger.debugDraw) {
			canvas.fill(255,255,255,100);
			// canvas.rect(checkX,checkY,checkHSize,checkVSize);
			canvas.fill(255,255,255,255);
			canvas.rect(xPos,yPos,2,2);
			canvas.rect(xCenter-2,yCenter-2,4,4);
			canvas.text("XPOS " + floor(xPos),xPos,yPos+vSize+debugger.fontSize);
			canvas.text("YPOS " + floor(yPos),xPos,yPos+vSize+debugger.fontSize * 2);
			canvas.text("HSIZE " + hSize,xPos,yPos+vSize+debugger.fontSize * 3);
			canvas.text("VSIZE " + hSize,xPos,yPos+vSize+debugger.fontSize * 4);
			canvas.text("WRAPS " + wrapCounter,xPos,yPos+vSize+debugger.fontSize * 5);
		}
	}

	boolean checkCollision(){				
		for (Solid s : oManager.solids) {
			if (collision.checkBoxCollision(xPos+speed*xDir,yPos+speed*yDir,hSize,vSize,s.xPos,s.yPos,s.hSize,s.vSize)) return true; 
		}
		return false;
	}
}