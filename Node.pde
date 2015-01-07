class Node extends GameObject {
	
	int ownedByPlayer, occupiedByPlayer;
	color nodeColor1, nodeColor2;
	boolean pulseNode = false;

	//lockdown
	boolean lockDown, wasLockedDown;
	int lockDownTime, lockDownDuration;
	float lockDownCounter, lockDownScale, lockDownScaleSpeed;

	Pulser pulser = new Pulser();

	Node(int _id, float _xPos, float _yPos) {
		id 	= _id;
		pos = new PVector(_xPos, _yPos);
		cen = new PVector( pos.x + siz.x / 2, pos.y + siz.x / 2);

		nodeColor1 = colors.node1;
		nodeColor2 = colors.node2;

		ownedByPlayer = 100;
		occupiedByPlayer = 100;

		lockDown = false;
		wasLockedDown = false;
		lockDownDuration = 350;
		lockDownTime= lockDownDuration;
		lockDownScale = 1.5;
		lockDownScaleSpeed = 0.1;
	}

	void update(){
		boolean wasCaptured = false;
		draw();
		
		if (!gManager.matchOver) {

			if (drawScale <= 1 && pulseNode) pulseNode = false;

			// check if the node is captured by a player
			if (!lockDown) {

				for (Player p : oManager.players) {

					// only check for players that are alive
					if (!p.ALIVE) {
						if (occupiedByPlayer == p.id) occupiedByPlayer = 100;
						continue;
					}

					// check for the collision
					boolean collides = collision.checkBoxCollision(pos.x,pos.y,siz.x,siz.y,p.pos.x,p.pos.y,p.siz.x,p.siz.y);

					// make sure the previous owner isn't on the node
					if (occupiedByPlayer == p.id && (!collides)) occupiedByPlayer = 100;

					// only capture the node if it isn't owned by the player capturing it
					if (ownedByPlayer != p.id && collides && occupiedByPlayer > 4) wasCaptured = true;
					else wasCaptured = false;

					if (wasCaptured) {

						//if the node was captured before, get the ID of the previous owner and subtract their node count
						if (ownedByPlayer != 100) {
							Player pl = oManager.players[ownedByPlayer];
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

			}
			
			// set node lock down variables once per lockdown
			if (wasLockedDown) {
				lockDownTime = lockDownDuration;
				lockDown = true;
				alpha = 255;
				lockDown01.trigger();
				lockDownScale = 1.5;
			}

		} else pulseNode = true;

		if (lockDown) {

			wasLockedDown = false;

			// warn when the node is about to unlock
			if (lockDownTime < lockDownDuration * 0.2) {
				alpha = blink.blink(0,255,10);
				repeat(10);
				if (repeat)lockDownStopAlert01.trigger();
			} 

			// count down node lock time
			if (lockDownTime > 0) lockDownTime -= 1;
			else {
				lockDown = false;
				lockDownTime = lockDownDuration;
				lockDownStop01.trigger();
			}
		}

		if (pulseNode) drawScale = pulser.pulse( 1.0, 1.5, 0.1, 0.5, -1);

	}

	void draw() {
		canvas.pushMatrix();
		canvas.rectMode(CENTER);
		canvas.strokeWeight(siz.x / 8);
		canvas.stroke(nodeColor1);
		canvas.fill(nodeColor2);

		// translate to center of the node
		canvas.translate(pos.x + (siz.x / 2), pos.y + (siz.y / 2));
		canvas.rect(0,0,siz.x * drawScale, siz.y * drawScale);
		canvas.rect(0,0, siz.x / 2, siz.y / 2);
		canvas.popMatrix();
		
		if (lockDown) lockNode();
	}

	void lockNode() {
		// draws a lock overlay over the node 
		float rectWidth = siz.x / 2;
		float rectHeight = siz.y / 2;
		
		canvas.fill(colors.solid, alpha);
		canvas.noStroke();
		canvas.pushMatrix();
		canvas.translate(pos.x + (siz.x / 2), pos.y + (siz.y / 2));
		canvas.rectMode(CENTER);
		canvas.scale(lockDownScale);
		canvas.rect(-rectWidth,-rectHeight,rectWidth,rectHeight);			
		canvas.rect(rectWidth,-rectHeight,rectWidth,rectHeight);			
		canvas.rect(-rectWidth,rectHeight,rectWidth,rectHeight);			
		canvas.rect(rectWidth,rectHeight,rectWidth,rectHeight);			
		canvas.stroke(colors.solid, alpha);
		canvas.strokeWeight(siz.x / 4);
		canvas.line(-rectWidth,-rectHeight,rectWidth,rectHeight);			
		canvas.line(rectWidth,-rectHeight,-rectWidth,rectHeight);			
		canvas.popMatrix();

		// set the scale of the lockdown overlay
		if (lockDownScale > 1.0) lockDownScale -= lockDownScaleSpeed;
		else lockDownScale = 1.0;
	}
}