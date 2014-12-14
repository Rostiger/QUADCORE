class Bullet extends GameObject {
	PVector dir, vel, hitVel;
	int damage, wrapCounter;
	float speed;
	boolean hasHit;

	Bullet(int _playerId, PVector _pos, PVector _dir, float _charge) {
		id 		= _playerId;
		siz 	= new PVector( _charge, _charge );
		pos 	= new PVector( _pos.x - siz.x / 2, _pos.y - siz.y / 2 );
		cen 	= new PVector( _pos.x + siz.x / 2, _pos.x + siz.x / 2 );
		dir 	= new PVector( _dir.x, _dir.y );
		vel 	= new PVector();
		hitVel 	= new PVector( 0,0 );

		speed 	= map(_charge,CELL_SIZE / 2, CELL_SIZE, 300.0, 150.0);
		damage 	= floor(map(_charge,CELL_SIZE / 2, CELL_SIZE, 1.0, 10.0));
		wrapCounter = 0;
	}
	
	void update() {

		boolean collision = false;

		if (!hasHit) {
			// set the velocity
			vel.set( speed * dir.x, speed * dir.y);
			vel.mult(dtInSeconds);

			// update the center coordinates
			cen.x = pos.x + siz.x / 2;
			cen.y = pos.y + siz.y / 2;

			// check for collisions
			collision = checkCollision();
		}

		// if the bullet collides or moves outside the screen a second time, subtract damage
		if (!hasHit && (collision || wrapCounter > 1 || damage == 0)) {
  			bulletHit01.trigger();
			hasHit = true;
			damage = 0;
		}

		if (!hasHit) {

			// move the bullet
			pos.add(vel);

			// count screenwraps
			if (pos.x > VIEW_WIDTH || pos.x + siz.x < 0 || pos.y > VIEW_HEIGHT || pos.y + siz.y < 0) wrapCounter++;

			// wrap it around the screen
			if (wrapCounter <= 1) {
				if (pos.x > VIEW_WIDTH) pos.x = -siz.x / 2;
				if (pos.x + siz.x < 0) pos.x = VIEW_WIDTH - siz.x / 2;

				if (pos.y > VIEW_HEIGHT) pos.y = -siz.y / 2;
				if (pos.y + siz.y < 0) pos.y = VIEW_HEIGHT - siz.y / 2;
			}

			drawBullet();

		} else drawHitEffect();

		if (debugger.debugDraw) debugDraw();

	}

	void drawBullet() {

		canvas.noStroke();
		canvas.rectMode(CENTER);
		canvas.fill(colors.player[id],alpha);
		canvas.rect(cen.x,cen.y,siz.x,siz.y);
	
	}

	void drawHitEffect() {

		canvas.noStroke();
		canvas.rectMode(CENTER);
		canvas.fill(colors.player[id],alpha);
 
		PVector hitDir = new PVector();
		float hitAcc = 2.5;

		hitVel.x += hitAcc;
		hitVel.y += hitAcc;

		for (int i=0; i<4; i++) {

			switch(i) {
				case 0: hitDir = new PVector( -1,-1 ); break;
				case 1: hitDir = new PVector(  1,-1 ); break;
				case 2: hitDir = new PVector(  1, 1 ); break;
				case 3: hitDir = new PVector( -1, 1 ); break;
			}

			PVector hitPos = new PVector( cen.x, cen.y );
			hitPos.x += hitVel.x * hitDir.x;
			hitPos.y += hitVel.y * hitDir.y;
			
			canvas.rect( hitPos.x, hitPos.y, siz.x / 2, siz.y / 2 );
		}

		if (alpha > 0) alpha -= 40;
		else destroy = true;

	}

	void debugDraw() {

			canvas.fill(255,255,255,100);
			canvas.rect(pos.x,pos.y,2,2);
			canvas.rect(cen.x-2,cen.y-2,4,4);
			canvas.text("XPOS " + floor(pos.x),pos.x,pos.y+siz.y+debugger.fontSize);
			canvas.text("YPOS " + floor(pos.y),pos.x,pos.y+siz.y+debugger.fontSize * 2);
			canvas.text("WRAPS " + wrapCounter,pos.x,pos.y+siz.y+debugger.fontSize * 5);

	}

	boolean checkCollision(){				

		for (Solid s : oManager.solids) {
			if (collision.checkBoxCollision(pos.x,pos.y,siz.x,siz.y,s.pos.x,s.pos.y,s.siz.x,s.siz.y)) return true; 
		}

		return false;
	}
}