class Bullet extends GameObject {
	PVector dir, center;
	int damage, wrapCounter, alpha;
	float speed, hitEffectSpeed;
	boolean hasPlayed;

	Bullet(int _playerId, PVector _pos, PVector _dir, float _charge) {
		id 		= _playerId;
		siz 	= new PVector( _charge, _charge );
		pos 	= new PVector( _pos.x, _pos.y );
		center 	= new PVector( pos.x + siz.x / 2,  pos.x + siz.x / 2 );
		dir 	= new PVector( _dir.x, _dir.y );		

		speed 	= map(_charge,CELL_SIZE / 2, CELL_SIZE, 10.0, 5.0);
		damage 	= floor(map(_charge,CELL_SIZE / 2, CELL_SIZE, 1.0, 10.0));
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
			center.x = pos.x + siz.x / 2;
			center.y = pos.y + siz.y / 2;

			// move the bullet
			pos.x += speed * dir.x * dt;
			pos.y += speed * dir.y * dt;

			// count screenwraps
			if (pos.x > VIEW_WIDTH || pos.x + siz.x < 0 || pos.y > VIEW_HEIGHT || pos.y + siz.y < 0) wrapCounter++;

			// wrap it around the screen
			if (wrapCounter <= 1) {
				if (pos.x > VIEW_WIDTH) pos.x = -siz.x / 2;
				if (pos.x + siz.x < 0) pos.x = VIEW_WIDTH - siz.x / 2;

				if (pos.y > VIEW_HEIGHT) pos.y = -siz.y / 2;
				if (pos.y + siz.y < 0) pos.y = VIEW_HEIGHT - siz.y / 2;
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
			canvas.rect(pos.x,pos.y,siz.x,siz.y);
		} else {
			float hitEffectX = center.x + siz.x * dir.x;
			float hitEffectY = center.y + siz.y * dir.y; 

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

				canvas.rect(tmpX,tmpY,siz.x / 2, siz.y / 2);
			}

			if (alpha > 0) alpha -= tmpAcc * 6 * dt;
			else destroy = true;

		}

		// set position to check collision for
		// float checkX = center.x + siz.x * dir.x;
		// float checkY = center.y + siz.y * dir.y;
		// float checkHSize = siz.x / 1.5;
		// float checkVSize = siz.y / 1.5;

		if (debugger.debugDraw) {
			canvas.fill(255,255,255,100);
			// canvas.rect(checkX,checkY,checkHSize,checkVSize);
			canvas.fill(255,255,255,255);
			canvas.rect(pos.x,pos.y,2,2);
			canvas.rect(center.x-2,center.y-2,4,4);
			canvas.text("XPOS " + floor(pos.x),pos.x,pos.y+siz.y+debugger.fontSize);
			canvas.text("YPOS " + floor(pos.y),pos.x,pos.y+siz.y+debugger.fontSize * 2);
			canvas.text("HSIZE " + siz.x,pos.x,pos.y+siz.y+debugger.fontSize * 3);
			canvas.text("VSIZE " + siz.x,pos.x,pos.y+siz.y+debugger.fontSize * 4);
			canvas.text("WRAPS " + wrapCounter,pos.x,pos.y+siz.y+debugger.fontSize * 5);
		}
	}

	boolean checkCollision(){				
		for (Solid s : oManager.solids) {
			if (collision.checkBoxCollision(pos.x+speed*dir.x,pos.y+speed*dir.y,siz.x,siz.y,s.pos.x,s.pos.y,s.siz.x,s.siz.y)) return true; 
		}
		return false;
	}
}