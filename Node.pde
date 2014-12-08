class Node {
	
	int id, ownedByPlayer, occupiedByPlayer, blinkCounter, blinkTime;
	float nAlpha, nScale;
	PVector nPos, nSize;
	color nodeColor1, nodeColor2;
	boolean pulseNode = false;
	boolean reverse = false;
	float easeControl;

	//lockdown
	boolean lockDown, wasLockedDown;
	int lockDownTime;
	float lockDownCounter, lockDownScale, lockDownScaleSpeed;

	Node(int _id, float _xPos, float _yPos) {
		id = _id;
		nPos = new PVector(_xPos, _yPos);
		nSize = new PVector(CELL_SIZE, CELL_SIZE);
		nScale = 1;
		nAlpha = 255;
		nodeColor1 = colors.node1;
		nodeColor2 = colors.node2;
		ownedByPlayer = 100;
		occupiedByPlayer = 100;
		lockDown = false;
		wasLockedDown = false;
		lockDownTime = 500;
		lockDownCounter = lockDownTime;
		blinkTime = 10;
		blinkCounter = blinkTime;
		lockDownScale = 1.5;
		lockDownScaleSpeed = 0.1;
		easeControl = -1;
	}

	void update(){
		boolean wasCaptured = false;
		draw();
		
		if (!gManager.matchOver) {
			
			if (wasLockedDown) {
				lockDownCounter = lockDownTime;
				lockDown = true;
				nAlpha = 255;
				lockDown01.trigger();
				lockDownScale = 1.5;
			}

		} else {

			

		}

		if (lockDown) {

			if (lockDownCounter > 0) {
				if (lockDownCounter < lockDownTime * 0.2) {
					if (blinkCounter > 0) blinkCounter -= dt;
					else {
						if (nAlpha > 0) { nAlpha = 0; lockDownStopAlert01.trigger(); }
						else nAlpha = 255;
						blinkCounter = blinkTime;
					}
				}
				lockDownCounter -= dt;
			} else {
				lockDown = false;
				lockDownCounter = lockDownTime;
				lockDownStop01.trigger();
			}
			wasLockedDown = false;

		} else if (!gManager.matchOver) {

			for (Player p : gManager.players) {
				// skip to the next player if the current one is dead
				if (!p.ALIVE) {
					if (occupiedByPlayer == p.id) occupiedByPlayer = 100;
					continue;
				}

				// check for the collision
				boolean collides = collision.checkBoxCollision(nPos.x,nPos.y,nSize.x,nSize.y,p.pos.x,p.pos.y,p.siz.x,p.siz.y);

				// make sure the previous owner isn't on the node
				if (occupiedByPlayer == p.id && (!collides)) occupiedByPlayer = 100;

				// only capture the node if it isn't owned by the player capturing it
				if (ownedByPlayer != p.id && collides && occupiedByPlayer > 4) wasCaptured = true;
				else wasCaptured = false;

				//if the node was newly captured
				if (wasCaptured) {
					//if the node was captured before, get the ID of the previous owner and subtract their node count
					if (ownedByPlayer != 100) {
						Player pl = gManager.players[ownedByPlayer];
						pl.nodesOwned--;
						pl.nodesLost++;
					}
					//set the node color to the color of it's new owner
					nodeColor1 = color (colors.player[p.id],200);
					nodeColor2 = color (colors.player[p.id],100);

					// play the capture sound file
					capture01.trigger();

					// trigger the node pulse effect
					pulseNode = true;

					// set the id of the node to the players id who captured it
					ownedByPlayer = p.id;
					occupiedByPlayer = p.id;

					// update player stats
					p.nodesOwned++;
					p.nodesCaptured++;
				}
			}

			// play the node pulse effect
			if (pulseNode) {
				float startValue = 1;
				float targetValue = 1.5;
				float duration = 0.15;
				float diff = targetValue - startValue;

				if (easeControl == -1) easeControl = startValue;

				if (easeControl < targetValue && !reverse) {
					nScale = ease(easeControl,startValue,targetValue,0.5);
					easeControl += dtInSeconds / duration * diff;
				} else if(easeControl > startValue) {
					reverse = true;
					nScale = ease(easeControl,targetValue,startValue,0.5);
					easeControl -= dtInSeconds / duration * diff;
				} else {
					pulseNode = false;
					reverse = false;
				}
			}
		}
	}

	void draw() {
		canvas.pushMatrix();
		canvas.rectMode(CENTER);
		canvas.strokeWeight(nSize.x / 8);
		canvas.stroke(nodeColor1);
		canvas.fill(nodeColor2);

		// translate to center of the node
		canvas.translate(nPos.x + (nSize.x / 2), nPos.y + (nSize.y / 2));
		canvas.scale(nScale);
		canvas.rect(0,0,nSize.x, nSize.y);
		canvas.rect(0,0, nSize.x / 2, nSize.y / 2);
		canvas.popMatrix();
		
		if (lockDown) {

			float rectWidth = nSize.x / 2;
			float rectHeight = nSize.y / 2;
			
			canvas.fill(colors.solid, nAlpha);
			canvas.noStroke();
			canvas.pushMatrix();
			canvas.translate(nPos.x + (nSize.x / 2), nPos.y + (nSize.y / 2));
			canvas.rectMode(CENTER);
			canvas.scale(lockDownScale);
			canvas.rect(-rectWidth,-rectHeight,rectWidth,rectHeight);			
			canvas.rect(rectWidth,-rectHeight,rectWidth,rectHeight);			
			canvas.rect(-rectWidth,rectHeight,rectWidth,rectHeight);			
			canvas.rect(rectWidth,rectHeight,rectWidth,rectHeight);			
			canvas.stroke(colors.solid, nAlpha);
			canvas.strokeWeight(nSize.x / 4);
			canvas.line(-rectWidth,-rectHeight,rectWidth,rectHeight);			
			canvas.line(rectWidth,-rectHeight,-rectWidth,rectHeight);			
			canvas.popMatrix();

			// set the scale of the lockdown overlay
			if (lockDownScale > 1.0) lockDownScale -= lockDownScaleSpeed * dt;
			else lockDownScale = 1.0;
		}
	}
}