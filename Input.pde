class Input {
	
	int id;
	boolean upPressed, downPressed, leftPressed, rightPressed, shootPressed, useItemPressed, startPressed;
	boolean shootWasPressed, useItemWasPressed, startWasPressed;
	boolean shootReleased, useItemReleased, startReleased;
	boolean hasGamePad;

	Input(int _id) {
		id = _id;

		upPressed			=	false;
		downPressed			=	false;
		leftPressed			=	false;
		rightPressed		=	false;
		shootPressed		=	false;
		useItemPressed		=	false;
		startPressed		=	false;
		shootWasPressed		=	false;
		useItemWasPressed	=	false;
		startWasPressed 	= 	false;
		shootReleased		=	false;
		useItemReleased		=	false;
		startReleased		= 	false;

	}

	void update() {
		if (hasGamePad) getGamePadInput();


		// take care of button presses/states
		if (shootPressed) { shootWasPressed = true; shootReleased = false; }
		else {
			if (shootWasPressed) shootReleased = true;
			else shootReleased = false;
			shootWasPressed = false;
		}

		if (useItemPressed) { useItemWasPressed = true; useItemReleased = false; }
		else {
			if (useItemWasPressed) useItemReleased = true;
			else useItemReleased = false;
			useItemWasPressed = false;
		}		

		if (startPressed) { startWasPressed = true; startReleased = false; }
		else {
			if (startWasPressed) startReleased = true;
			else startReleased = false;
			startWasPressed = false;
		}		
		// get the id of the player that last pressed the start button
		if (startReleased) gManager.lastStartPressId = id;

	}

	void getGamePadInput() {
		if (gPads.get(id).getSlider("LS_Y").getValue() < -0.2 || gPads.get(id).getButton("DP_UP").pressed()) {

			if (TOP_VIEW) {
				switch (id) {
					case 0: downPressed = true; break;
					case 1: upPressed = true; break;
					case 2: leftPressed = true; break;
					case 3: rightPressed = true; break;
				}
			} else upPressed = true;
		
		} else {

			if (TOP_VIEW) {
				switch (id) {
					case 0: downPressed = false; break;
					case 1: upPressed = false; break;
					case 2: leftPressed = false; break;
					case 3: rightPressed = false; break;
				}
			} else upPressed = false;
		}

		if (gPads.get(id).getSlider("LS_Y").getValue() > 0.2 || gPads.get(id).getButton("DP_DOWN").pressed()) {

			if (TOP_VIEW) {
				switch (id) {
					case 0: upPressed = true; break;
					case 1: downPressed = true; break;
					case 2: rightPressed = true; break;
					case 3: leftPressed = true; break;
				}
			} else downPressed = true;

		} else {

			if (TOP_VIEW) {
				switch (id) {
					case 0: upPressed = false; break;
					case 1: downPressed = false; break;
					case 2: rightPressed = false; break;
					case 3: leftPressed = false; break;
				}
			} else downPressed = false;

		}

		if (gPads.get(id).getSlider("LS_X").getValue() < -0.2 ||	gPads.get(id).getButton("DP_LEFT").pressed()) {

			if (TOP_VIEW) {
				switch (id) {
					case 0: rightPressed = true; break;
					case 1: leftPressed = true; break;
					case 2: downPressed = true; break;
					case 3: upPressed = true; break;
				}
			} else leftPressed = true;

		} else {

			if (TOP_VIEW) {
				switch (id) {
					case 0: rightPressed = false; break;
					case 1: leftPressed = false; break;
					case 2: downPressed = false; break;
					case 3: upPressed = false; break;
				}
			} else leftPressed = false;

		}

		if (gPads.get(id).getSlider("LS_X").getValue() > 0.2 || gPads.get(id).getButton("DP_RIGHT").pressed()) {

			if (TOP_VIEW) {
				switch (id) {
					case 0: leftPressed = true; break;
					case 1: rightPressed = true; break;
					case 2: upPressed = true; break;
					case 3: downPressed = true; break;
				}
			} else rightPressed = true;

		} else {

			if (TOP_VIEW) {
				switch (id) {
					case 0: leftPressed = false; break;
					case 1: rightPressed = false; break;
					case 2: upPressed = false; break;
					case 3: downPressed = false; break;
				}
			} else rightPressed = false;
		}

		shootPressed = gPads.get(id).getButton("BT_A").pressed();
		useItemPressed = gPads.get(id).getButton("BT_B").pressed();
		startPressed = gPads.get(id).getButton("BT_C").pressed();
	}

	void keyPressed() {
		switch(id) {
			case 0:
				if (keyCode == UP) upPressed = true;
				if (keyCode == DOWN) downPressed = true;
				if (keyCode == LEFT) leftPressed = true;
				if (keyCode == RIGHT) rightPressed = true;
				if (key == '/') shootPressed = true;
				if (keyCode == SHIFT) useItemPressed = true;
				if (key == ' ') startPressed = true;
			break;
			case 1:
				if (key == 'w') upPressed = true;
				if (key == 's') downPressed = true;
				if (key == 'a') leftPressed = true;
				if (key == 'd') rightPressed = true;
				if (key == 'f') shootPressed = true;
				if (key == 'r') useItemPressed = true;
				if (key == 'q') startPressed = true;
			break;
			case 2:
				if (key == 'i') upPressed = true;
				if (key == 'k') downPressed = true;
				if (key == 'j') leftPressed = true;
				if (key == 'l') rightPressed = true;
				if (key == 'h') shootPressed = true;
				if (key == 'y') useItemPressed = true;
				if (key == 'o') startPressed = true;
			break;
			case 3:
				if (key == '8') upPressed = true;
				if (key == '5') downPressed = true;
				if (key == '4') leftPressed = true;
				if (key == '6') rightPressed = true;
				if (key == '0') shootPressed = true;
				if (key == '1') useItemPressed = true;
				if (key == '2') startPressed = true;
			break;
		}
	}

	void keyReleased() {

		switch(id) {
			case 0:
				if (keyCode == UP) upPressed = false;
				if (keyCode == DOWN) downPressed = false;
				if (keyCode == LEFT) leftPressed = false;
				if (keyCode == RIGHT) rightPressed = false;
				if (key == '/') shootPressed = false;
				if (keyCode == SHIFT) useItemPressed = false;
				if (key == ' ') startPressed = false;
			break;
			case 1:
				if (key == 'w') upPressed = false;
				if (key == 's') downPressed = false;
				if (key == 'a') leftPressed = false;
				if (key == 'd') rightPressed = false;
				if (key == 'f') shootPressed = false;
				if (key == 'r') useItemPressed = false;
				if (key == 'q') startPressed = false;
			break;
			case 2:
				if (key == 'i') upPressed = false;
				if (key == 'k') downPressed = false;
				if (key == 'j') leftPressed = false;
				if (key == 'l') rightPressed = false;
				if (key == 'h') shootPressed = false;
				if (key == 'y') useItemPressed = false;
				if (key == 'o') startPressed = false;
			break;
			case 3:
				if (key == '8') upPressed = false;
				if (key == '5') downPressed = false;
				if (key == '4') leftPressed = false;
				if (key == '6') rightPressed = false;
				if (key == '0') shootPressed = false;
				if (key == '1') useItemPressed = false;
				if (key == '2') startPressed = false;
			break;
		}
	}
}