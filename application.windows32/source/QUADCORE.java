import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Arrays; 
import ddf.minim.*; 
import org.gamecontrolplus.gui.*; 
import org.gamecontrolplus.*; 
import net.java.games.input.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class QUADCORE extends PApplet {

				// import the java array class for level loading			
						// import the sound library
		// import the gui library for configuring the gamepads
			// import the gamepad library
			// import the input library

// initialise input control and gamepads
ControlIO control;
Configuration config;
ArrayList < ControlDevice > gPads = new ArrayList < ControlDevice >();

// // initialise the sound library and audio files
Minim minim;
AudioSample 
	bulletHit01, capture01, die01, hurt01, 
	shot01, shot02, multiShot01, spawn01, boost01, 
	powerUpSpawn01, powerUpGet01, lockDown01,lockDownStopAlert01,
	lockDownStop01;

GameManager gManager = new GameManager();
ObjectManager oManager = new ObjectManager();
Colors colors = new Colors();
LevelParser levelParser = new LevelParser();
Menu menu;
Debugger debugger;
Hud hud;
Collision collision;

PGraphics canvas;
PFont font;
PFont debugFont;

ArrayList < PImage > levelList; 
PImage  lg1, lg2;

int WIN_WIDTH;				// stores the width of the display resolution
int WIN_HEIGHT;				// stores the height of the display resolution		
float WIN_SCALE = 0.5f;		// window scale factor - set to 1 for non-windows fullscreen
int VIEW_WIDTH;			// width of the game area
int VIEW_HEIGHT;			// height of the game area
int CELL_SIZE;			// size of a single tile
float dt;					// this value is initialised and update in the GameManager() class
float dtInSeconds;
int FONT_SIZE;
int DEBUG_FONT_SIZE;
int ARENA_BORDER;
boolean TOP_VIEW = true;		// playing on the hansG?
boolean SHADERS = false;
PVector canvasPos, canvasCen;
int bgColor = 0xff000000;
float version = 0.5f;

float gridSize = 32 * WIN_SCALE;

Shake screenShake = new Shake();
Blink blink = new Blink();

//post processing variables
PShader blur;
PGraphics pass1, pass2;

public void setup() {

	setupWindow();
	frameRate(30);

	initGamePads();
	printDebug();
	loadLevels();
	loadSounds();
	loadTextures();
	loadFonts();
	
	// reset the game
	gManager.reset();
	menu = new Menu();

	// set up a canvas to draw onto
	canvas = createGraphics(VIEW_WIDTH,VIEW_HEIGHT);
	canvasPos = new PVector(WIN_WIDTH / 2 - VIEW_WIDTH / 2, ARENA_BORDER);
	canvasCen = new PVector(WIN_WIDTH / 2, WIN_HEIGHT / 2);

	// initialise the debugger
	debugger = new Debugger();
	
	// set up the shaders
	blur = loadShader("blur.glsl");
	blur.set("blurSize", 3);
	blur.set("sigma", 20.f);

	pass1 = createGraphics(width, height, P2D);
	pass1.noSmooth();  

	pass2 = createGraphics(width, height, P2D);
	pass2.noSmooth();
}

public void draw() {
	noCursor();
	background(bgColor);
	textFont(font);

	if (screenShake.isShaking) {
		screenShake.update();
		canvasCen.add(screenShake.offset);
	}

	noStroke();
	imageMode(CENTER);
  	image( canvas, canvasCen.x, canvasCen.y	);

	canvas.beginDraw();
	canvas.background(colors.bg);
	canvas.textFont(font);
	gManager.update();
	canvas.endDraw();

	noStroke();
	fill(0,0,0,255);
	rectMode(CORNER);
	rect(0,0,canvasPos.x - ARENA_BORDER,WIN_HEIGHT);
	rect(canvasPos.x + VIEW_WIDTH + ARENA_BORDER, 0, canvasPos.x, WIN_HEIGHT);

	if (SHADERS) postProcessing();

	textFont(debugFont);
	debugger.update();
}

public void postProcessing() {
	PImage dst = get();
	imageMode(CORNER);

	// Applying the blur shader along the vertical direction   
	blur.set("horizontalPass", 0);
	pass1.beginDraw();            
	pass1.shader(blur);  
	pass1.image(dst, 0, 0);
	pass1.endDraw();

	// Applying the blur shader along the horizontal direction      
	blur.set("horizontalPass", 1);
	pass2.beginDraw();            
	pass2.shader(blur);  
	pass2.image(pass1, 0, 0);
	pass2.endDraw();

	tint(255, 100);
	blendMode(SCREEN);
 	image(pass2, 0, 0);
 	noTint();
	blendMode(MULTIPLY);
 	image(pass2, 0, 0);
	blendMode(BLEND);

	tint(255, 100);
	image(pass2, 0, 0);
	noTint();
}

public void keyPressed() {
	debugger.keyPressed();
	if (!gManager.debug) oManager.keyPressed();
	if (menu.active) menu.keyPressed();
}

public void keyReleased() {
	debugger.keyReleased();
	if (!gManager.debug) oManager.keyReleased();
	if (menu.active) menu.keyReleased();
	
	if (key == '[') {
		if (WIN_SCALE == 1.0f) WIN_SCALE = 0.8f;
		else WIN_SCALE = 1.0f;
		setupWindow();
		sketchFullScreen();
		gManager.reset();
		menu = new Menu();
	}
}

public void setupWindow() {
	// setup the window and renderer
	size(ceil(768 * WIN_SCALE * 1.333f),ceil(768 * WIN_SCALE),P2D);

	// get the width of the current display and set the height so it's a 4:3 ratio
	WIN_HEIGHT 	= ceil(768 * WIN_SCALE);	
	// WIN_HEIGHT 	= ceil(displayHeight * WIN_SCALE);	
	WIN_WIDTH 	= ceil(WIN_HEIGHT * 1.333f);
	ARENA_BORDER = ceil(WIN_HEIGHT * 0.063f);
	FONT_SIZE = ceil(WIN_HEIGHT * 0.04f);
	DEBUG_FONT_SIZE = ceil(WIN_WIDTH * 0.02f);
}

public boolean sketchFullScreen() {
	// sets the sketch to true fullscreen
	if (WIN_SCALE == 1.0f) return true;
	else return false;
}

public void initGamePads() {
	// GAMEPAD
	// Initialise the ControlIO
	control = ControlIO.getInstance(this);
	// check how many devices are found
	int numberOfDevices = control.getNumberOfDevices();
	// load configurations for different controllers
	Configuration ps3 = Configuration.makeConfiguration(this,"ps3");
	Configuration xBoxWireless = Configuration.makeConfiguration(this,"XBOXWireless");
	// step through the number of devices and see if any of the devices match one of the configurations
	for (int i=0;i<numberOfDevices;i++) {
		ControlDevice device = control.getDevice(i);
		// if the configuration matches, add the device
		if (device.matches(ps3) || device.matches(xBoxWireless)) gPads.add(device);
		else device.close();
	}
}

public void printDebug() {
	// print some debug output
	println("Loading...");
	println("-------------------------------");
	println("Game started.");
	println("-------------------------------");
	println("Display size: " + displayWidth + " x " + displayHeight);
	println("Window size: " + WIN_WIDTH + " x " + WIN_HEIGHT);
	float scaleInPercent = WIN_SCALE * 100;
	println("Window scale: " + scaleInPercent + "%");
	println("Gamepads found: " + gPads.size());
	if (gPads.size() > 0) {
		for (int i = 0; i < gPads.size(); i++ ) println(i + ": " + gPads.get(i));
	}
	println("-------------------------------");	
}

public void loadLevels() {
	// LEVELS
	// go through the levels folder and store the found files in an array list
	File f = new File(dataPath("levels/")); 
	ArrayList < String > filesInFolder = new ArrayList < String >(Arrays.asList(f.list()));

	// create a list holding string arrays
	levelList = new ArrayList < PImage >();
	
	// step through each file on the levels folder
	for (int i=0;i<filesInFolder.size();i++) {
		String currentLevelFile = filesInFolder.get(i);
		// check if the file ends with .txt
		if (currentLevelFile.toLowerCase().contains(".gif")) {
			// put together a string that looks like this foldername/levelname.gif
			String fileName = f.getPath() + "/" + currentLevelFile;
			// store each line in the file into a string array
			PImage level = loadImage(fileName);
			// now add the string array to the levels list
			levelList.add(level);
		}
	}	
}

public void loadSounds() {
	//SOUNDS
	// initialise sound library
	minim = new Minim(this);
	bulletHit01 = minim.loadSample("sounds/bulletHit01.wav",512);
	capture01 = minim.loadSample("sounds/capture01.wav",512);
	die01 = minim.loadSample("sounds/die01.wav",512);
	hurt01 = minim.loadSample("sounds/hurt01.wav",512);
	shot01 = minim.loadSample("sounds/shot01.wav",512);
	shot02 = minim.loadSample("sounds/spawn01.wav",512);
	multiShot01 = minim.loadSample("sounds/multiShot01.wav",512);
	spawn01 = minim.loadSample("sounds/spawn01.wav",512);
	boost01 = minim.loadSample("sounds/boost01.wav",512);
	powerUpSpawn01 = minim.loadSample("sounds/powerUpSpawn01.wav",512);
	powerUpGet01 = minim.loadSample("sounds/powerUpGet01.wav",512);
	lockDown01 = minim.loadSample("sounds/lockDown01.wav",512);
	lockDownStopAlert01 = minim.loadSample("sounds/lockDownStopAlert01.wav",512);
	lockDownStop01 = minim.loadSample("sounds/lockDownStop01.wav",512);
}

public void loadTextures() {
	// load textures
	lg1 = loadImage("images/logo_zamSpielen.png");
}

public void loadFonts() {
	//load the font files
	font = createFont("DS-DIGIB.TTF",128,false);
	debugFont = createFont("victor-pixel.ttf",32,false);
}
class Blink {

	float blinkTime;
	int alpha;

	Blink() {
		blinkTime = 0;
		alpha = 0;
	}

	public int blink(int _alpha1, int _alpha2, float _speed) {
		// switches between two alpha values with a given speed
		if (blinkTime > 0) blinkTime -= 1;
		else {

			if (alpha != _alpha2) alpha = _alpha2;
			else alpha = _alpha1;			

			blinkTime = _speed;
		}

		return alpha;
	}
}
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

		speed 	= map(_charge,CELL_SIZE / 2, CELL_SIZE, CELL_SIZE / 0.08f, CELL_SIZE / 0.15f);
		damage 	= floor(map(_charge,CELL_SIZE / 2, CELL_SIZE, 1.0f, 10.0f));
		wrapCounter = 0;
	}
	
	public void update() {

		boolean collision = false;

		if (!hasHit) {
			// set the velocity
			vel.set( speed * dtInSeconds * dir.x, speed * dtInSeconds * dir.y);

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

	public void drawBullet() {
		// draws the bullet
		canvas.noStroke();
		canvas.rectMode(CENTER);
		canvas.fill(colors.player[id],alpha);
		canvas.rect(cen.x,cen.y,siz.x,siz.y);
	}

	public void drawHitEffect() {
		// draws the hit effect
		canvas.noStroke();
		canvas.rectMode(CENTER);
		canvas.fill(colors.player[id],alpha);
 
		PVector hitDir = new PVector();
		float hitAcc = 2.5f;

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

	public void debugDraw() {
		// debug draw
		canvas.fill(255,255,255,100);
		canvas.rect(pos.x,pos.y,2,2);
		canvas.rect(cen.x-2,cen.y-2,4,4);
		canvas.text("XPOS " + floor(pos.x),pos.x,pos.y+siz.y+debugger.fontSize);
		canvas.text("YPOS " + floor(pos.y),pos.x,pos.y+siz.y+debugger.fontSize * 2);
		canvas.text("WRAPS " + wrapCounter,pos.x,pos.y+siz.y+debugger.fontSize * 5);
	}

	public boolean checkCollision(){				
		// checks for collisions with solids
		for (Solid s : oManager.solids) {
			if (collision.checkBoxCollision(pos.x,pos.y,siz.x,siz.y,s.pos.x,s.pos.y,s.siz.x,s.siz.y)) return true; 
		}
		return false;
	}
}
class Collision {
	public boolean checkBoxCollision (
		float xPosA, float yPosA, float hSizeA, float vSizeA,
		float xPosB, float yPosB, float hSizeB, float vSizeB) {

		float aTop = yPosA;
		float aRight = xPosA + hSizeA;
		float aBottom = yPosA + vSizeA;
		float aLeft = xPosA;

		float bTop = yPosB;
		float bRight = xPosB + hSizeB;
		float bBottom = yPosB + vSizeB;
		float bLeft = xPosB;

		return (bRight > aLeft && aRight > bLeft && bBottom > aTop && aBottom > bTop);
	}
}
class Colors {

	int bg, solid, node1, node2, item, hudBg;
	int[] player = new int[4];
	int[] player2 = new int[4];

	Colors() {}

	public void pickColorScheme(String _name) {
		String name = _name;
		int numberOfColorShemes = 4;
		int colorScheme = 0;

		if (name == "DARK_PURPLE") colorScheme = 1;
		else if (name == "VIOLET_BLUE") colorScheme = 2;
		else if (name == "PURPLE_YELLOW") colorScheme = 3;
		else if (name == "BLUE_ORANGE") colorScheme = 4;
		else if (name == "RANDOM") {
			colorScheme = ceil(random(0,numberOfColorShemes));
		} else {
			println("CAN'T FIND COLOR SCHEME");
			colorScheme = 1;
		}

		switch (colorScheme) {
			case 1:
				bg = 0xff6B4EAC;
				solid = 0xff5039A9;
				node1 = 0xff8A80DF;
				node2 = 0xff574CA5;
				item = 0xffC082FF;
				player[0] = 0xffF13687;
				player[1] = 0xffF1F187;
				player[2] = 0xff20F187;
				player[3] = 0xff31ccff;
				player2[0] = 0xffff76aa;
				player2[1] = 0xffffffbf;
				player2[2] = 0xff66ffb1;
				player2[3] = 0xff8be2ff;
			break;
			case 2:
				bg = 0xff69D6C0;
				solid = 0xff755EA2;
				node1 = 0xffB2A9CF;
				node2 = 0xff766C98;
				player[0] = 0xffC7506B;
				player[1] = 0xffF0F25E;
				player[2] = 0xff00960F;
				player[3] = 0xff0080DB;
				player2[0] = 0xffff76aa;
				player2[1] = 0xffffffbf;
				player2[2] = 0xff66ffb1;
				player2[3] = 0xff8be2ff;
			break;
			case 3:
				bg = 0xffDEE07B;
				solid = 0xff9256B3;
				node1 = 0xff9553B8;
				node2 = 0xffAA77C9;
				player[0] = 0xffBF345F;
				player[1] = 0xff8A7138;
				player[2] = 0xff6ABB00;
				player[3] = 0xff2F8BFF;
				player2[0] = 0xffff76aa;
				player2[1] = 0xffffffbf;
				player2[2] = 0xff66ffb1;
				player2[3] = 0xff8be2ff;
			break;
			case 4:
				bg = 0xffE0AF7F;
				solid = 0xff5980B3;
				node1 = 0xff5680B8;
				node2 = 0xff7B9FC9;
				player[0] = 0xffFE2CB1;
				player[1] = 0xffFFEA29;
				player[2] = 0xff7BF37C;
				player[3] = 0xff2452FF;
				player2[0] = 0xffff76aa;
				player2[1] = 0xffffffbf;
				player2[2] = 0xff66ffb1;
				player2[3] = 0xff8be2ff;
			break;
		}
	}
}
class DebugOption {

	public String name;
	public boolean active;

	DebugOption(String _name, boolean _active) {

		name = _name;
		active = _active;

	}

	public void toggleActive(){}
}
class Debugger {

	float fontSize;

	PVector consolePos;
	PVector consoleSize;
	int 	consoleAlpha;
	boolean consoleActive;

	boolean debugDraw, invincibility, autoShoot, drawWinnerGrid;
	int autoShootInterval, autoShootCount;

	DebugOption[] debugOptions = new DebugOption[5];
	int selectedOption;

	Input input = new Input(0);

	Debugger() {
		consoleSize = new PVector(VIEW_WIDTH / 2, WIN_HEIGHT);
		consolePos = new PVector(canvasPos.x - consoleSize.x,0);
		consoleAlpha = 0;
		consoleActive = false;

		debugDraw 		= false;
		invincibility 	= false;
		autoShoot 		= false;
		drawWinnerGrid 	= true;

		autoShootInterval = 20;
		autoShootCount = autoShootInterval;
		
		debugOptions[0] = new DebugOption("DEBUG DRAW",false);
		debugOptions[1] = new DebugOption("INVINCIBILITY",false);
		debugOptions[2] = new DebugOption("AUTO FIRE",false);
		debugOptions[3] = new DebugOption("DRAW WINNER GRID",false);
		debugOptions[4] = new DebugOption("PAUSE",false);

		selectedOption = 0;
	}

	public void update() {
		if (debugOptions[0].active) debugDraw = true;
		else debugDraw = false;

		if (debugOptions[1].active) invincibility = true;
		else invincibility = false;

		if (debugOptions[2].active) autoShoot = true;
		else autoShoot = false;

		if (debugOptions[3].active) drawWinnerGrid = true;
		else drawWinnerGrid = false;
		
		// set the font size
		fontSize = DEBUG_FONT_SIZE;

		// toggle console
		if (gManager.debug) {
			if (!consoleActive) println("Console Activated.");
			consoleActive = true;
			toggleConsole(canvasPos.x - ARENA_BORDER);
		} else {
			if (consoleActive) toggleConsole(canvasPos.x - ARENA_BORDER - consoleSize.x);
		}

		if (consoleActive) {
			draw();
		}

		// counter for autoshooting interval
		boolean canShoot = false;
		if (autoShoot) {
			if (autoShootCount > 0) autoShootCount--;
			else {
				canShoot = true;
				autoShootCount = autoShootInterval;
			}
		}

		// trigger invincibility and autoshoot in all players when turned on
		if (oManager.players != null && (invincibility || autoShoot)) {
			for (Player p : oManager.players) {

				if (invincibility) p.INVINCIBLE = true;
				if (canShoot && !gManager.matchOver && p.ALIVE) {
					p.input.shootReleased = true;
					p.shoot();
				}

			}
		}

		// set the debug cursor position on input
		if (input.upPressed) {
			if (selectedOption > 0) selectedOption--;
			else selectedOption = debugOptions.length - 1;
			input.upPressed = false;
		}

		if (input.downPressed) {
			if (selectedOption < debugOptions.length - 1) selectedOption++;
			else selectedOption = 0;
			input.downPressed = false;
		}
	}

	public void draw() {
		float indentFactor = 0.05f;
		PVector textIndent = new PVector(consoleSize.x * indentFactor,consoleSize.y * indentFactor);
		PVector textPos = new PVector(consolePos.x + textIndent.x,consolePos.y + indentFactor + fontSize);
		float hSize = consoleSize.x - textIndent.x;
		String state = "VOID";

		// set up drawing
		noStroke();
		textSize(fontSize);
		textAlign(LEFT);

		// draw console background
		fill(colors.solid,consoleAlpha * 0.8f);
		rectMode(CORNER);
		rect(consolePos.x,consolePos.y,consoleSize.x,consoleSize.y);

		// draw frame rate & other game variables
		fill(255,255,255,consoleAlpha);
		text("FPS " + (int)frameRate,textPos.x,textPos.y);
		text("WIN SIZE " + WIN_WIDTH + " X " + WIN_HEIGHT,textPos.x,textPos.y * 2);
		text("VIEW SIZE " + VIEW_WIDTH + " X " + VIEW_HEIGHT,textPos.x,textPos.y * 3);
		text("CELLSIZE " + CELL_SIZE,textPos.x,textPos.y * 4);
		text("FONTSIZE " + fontSize,textPos.x,textPos.y * 5);

		float gameStatsYPos = 7;

		text("GAMESTATS",textPos.x,textPos.y * gameStatsYPos);

		drawDivider(consolePos.x,textPos.y * gameStatsYPos,textIndent.x);

		text("PLAYERS " + oManager.activePlayers,textPos.x,textPos.y * (gameStatsYPos+1));
		text("SOLIDS " + oManager.solids.size(),textPos.x,textPos.y * (gameStatsYPos+2));
		text("NODES " + oManager.nodes.size(),textPos.x,textPos.y * (gameStatsYPos+3));
		text("BULLETS " + oManager.bullets.size(),textPos.x,textPos.y * (gameStatsYPos+4));
		text("LEVEL " + gManager.nextLevelID + "/" + levelList.size(),textPos.x,textPos.y * (gameStatsYPos+5));

		gameStatsYPos = 14;

		// switchable debug settings
		text("DEBUG SETTINGS",textPos.x,textPos.y * gameStatsYPos);

		drawDivider(consolePos.x,textPos.y * gameStatsYPos,textIndent.x);

		// step through the debug options array
		for (int i=0; i<debugOptions.length; i++) {

			String name = debugOptions[i].name;
			String active = "OFF";

			if (i == selectedOption) {

				name = "> " + debugOptions[i].name;

				// turn the option on or off
				if (input.leftPressed || input.rightPressed) {

					debugOptions[i].active = !debugOptions[i].active;
					input.leftPressed = false;
					input.rightPressed = false;

				}
			}

			if (debugOptions[i].active) active = "ON";
			else active = "OFF";

			text(name,textPos.x,textPos.y * (gameStatsYPos+i+1));
			text(active,textPos.x + hSize - hSize / 4,textPos.y * (gameStatsYPos+i+1));
		}
	}

	public void toggleConsole(float _targetX) {

		// this function scales the console background width
		// and fades its alpha as well as the text alpha
		// using a nice easing effect

		// get the distance to the target and set a target dead zone
		float distanceX = _targetX - consolePos.x;
		float deadZoneX = _targetX * 0.2f;

		// move the console until it reaches its target
		// using an easing factor of 0.2
		if (abs(distanceX) > abs(deadZoneX)) consolePos.x += distanceX * 0.2f;
		else {

			consolePos.x = _targetX;

			// turn off console drawing when debug is turned off and the console finished moving away
			if (!gManager.debug) {
				consoleActive = false;
				println("Console Deactivated.");
			}
		}

		// get the difference of the current alpha and the target alpha
		int targetAlpha = 0;

		if (gManager.debug) targetAlpha = 255;
		else targetAlpha = 0;
		
		int alphaDistance = targetAlpha - consoleAlpha;

		// set the alpha
		if (abs(consoleAlpha) > targetAlpha) consoleAlpha += alphaDistance * 0.2f;
		else consoleAlpha = targetAlpha;
	}

	public void drawDivider(float _xPos, float _yPos, float _padding) {
		// set a padding
		float xPos = _xPos + _padding;
		float yPos = _yPos + (fontSize * 0.5f);
		float hSize = consoleSize.x - (_padding * 2);

		// draw the divider line
		for (int x = 0; x <= hSize; x += fontSize / 2) {
			text("-",xPos + x, yPos);
		}		
	}

	public void keyPressed() {
		input.keyPressed();
	}

	public void keyReleased() {
		input.keyReleased();
		
		//toggle debug mode
		if (key == '~' || key == '`' || key == '^') {
			if (!gManager.debug) gManager.debug = true;
			else gManager.debug = false;
		}

		//reset game
		if (!gManager.debug && keyCode == ENTER) gManager.reset();
	}
}
class GameManager {
	float prevMillis;

	boolean debug = false;
	boolean paused = false;
	boolean gameOver = false;
	boolean matchOver = false;

	int winnerID;
	int prevLevelID;
	int nextLevelID;
	int alpha;

	Grid grid;
	Pulser gridPulser;

	GameManager() {
	    prevLevelID = 100;
    	prevMillis = millis();
    	grid = new Grid();
    	gridPulser = new Pulser();
    	alpha = 0;
   	}

	public void reset() {
		// make sure all game objects (except players) are removed
		oManager.clearGameObjects();

		// pick a color scheme
		colors.pickColorScheme("DARK_PURPLE");

		// choose a random new level from the list of available levels
		nextLevelID = (int)random(0,levelList.size());
		// never pick the same level again after it has been played
		while (nextLevelID == prevLevelID) nextLevelID = (int)random(0,levelList.size());

		// determine level proportions depending on the amount of characters in the first line of the level file
		CELL_SIZE = floor((WIN_HEIGHT - ARENA_BORDER * 2) / levelList.get(nextLevelID).height);
		VIEW_HEIGHT = CELL_SIZE * levelList.get(nextLevelID).height;
		VIEW_WIDTH = VIEW_HEIGHT;
		canvas = createGraphics(VIEW_WIDTH,VIEW_HEIGHT);
		canvasPos = new PVector(WIN_WIDTH / 2 - VIEW_WIDTH / 2, ARENA_BORDER);

		// parse the level
		levelParser.parseLevel(nextLevelID);

		// print some level info
		println("Level No." + nextLevelID + " | " + "Cellsize: " + CELL_SIZE + " | " + "Levelsize: " + levelList.get(nextLevelID).width + " x " + levelList.get(nextLevelID).width );

		prevLevelID = nextLevelID;

		// reset the players
		oManager.resetPlayers();

		// reset the game state
		gameOver = false;
		matchOver = false;
		
	    // finally add a new hud and collision class
	    // these come after parsing the level, because they are dependend on the CELL_SIZE value
		hud = new Hud();
		collision = new Collision();
	}

	public void update() {
		// DELTA TIME
		// millis() returns the milliseconds passed since starting the program
		// get the duration of the lastFrame by subtracting the value of millis()
		// from the last frame by the current value of millis()
		float lastFrameDuration = millis() - prevMillis;
		prevMillis = millis();
		
		// save dt in seconds
		dtInSeconds = lastFrameDuration / 1000;

		// update game objects
		if (menu.active) menu.update();
		else {

			// if (matchOver || debugger.drawCheckers) {
			// 	blink(100,0,5);
			// 	fill(colors.player[winnerID], alpha);
			// 	noStroke();
			// 	rectMode(CENTER);
			// 	canvas.rect(WIN_WIDTH / 2,WIN_HEIGHT / 2,VIEW_WIDTH, VIEW_HEIGHT);
			// }
			oManager.update();
			hud.update();

			// store a background image when paused
			if (paused) {
				menu.bg = canvas.get();
				menu.active = true;
			} updateGrid();			
		}
	}

	public void updateGrid() {
		// grid (pos, siz, cellSize, pointSize, pointWeight, color, alpha)
		pushMatrix();
		translate(WIN_WIDTH / 2, WIN_HEIGHT / 2);
		PVector gridPos = new PVector(-VIEW_WIDTH / 2, -VIEW_HEIGHT / 2);
		PVector gridSiz = new PVector(VIEW_WIDTH , VIEW_HEIGHT);

        // change the grid color to the winner
        float drawScale = 1;
        int gridColor = colors.item;
        int alp = 50;
		// if (matchOver || debugger.drawWinnerGrid) {
		// 	gridColor = colors.player[winnerID];
		// 	drawScale = gridPulser.pulse(1,8,0.5,1,-1);
		// 	alp = 150;
		// }
		grid.drawGrid(gridPos, gridSiz, CELL_SIZE, CELL_SIZE / 8 * drawScale, 1 * drawScale, gridColor, alp);
		grid.drawGrid(gridPos, gridSiz, CELL_SIZE * 4, CELL_SIZE / 2 * drawScale, 1 * drawScale, gridColor, alp);
		popMatrix();
	}
}
class GameObject {
	
	int id, alpha;
	PVector siz, pos, cen, hp;
	float drawScale, repeatTime;
	boolean destroy, repeat;

	GameObject() {
		// shared variables for all game objects
		siz = new PVector( CELL_SIZE, CELL_SIZE );
		pos = new PVector();
		cen = new PVector();
		hp  = new PVector();
		drawScale = 1.0f;
		destroy = false;
		alpha = 255;
	}

	public boolean repeat(float _interval) {
		// switches a bool with a given interval - useful for triggering events at a specific rate
		repeat = false;

		if (repeatTime > 0) repeatTime -= 1;
		else {
			repeat = true;
			repeatTime = _interval;
		}

		return repeat;
	}
}
class Grid {
	
	// PVector pos, siz;
	float cellSize, pointSize, pointWeight;
	int switchTime, alpha, alpha1, alpha2;
	boolean drawCheckers;
	
	Grid() {
		switchTime = 0;
		alpha = 0;
		alpha1 = 0;
		alpha2 = 0;
		drawCheckers = false;
	}

	public void drawGrid(PVector _pos, PVector _siz, float _cellSize, float _pointSize, float _pointWeight, int _color, int _alpha){
		PVector pos = _pos;
		PVector siz = _siz;
		float cellSize = _cellSize;

		for (float x=0; x<=siz.x; x+=cellSize) {

			for (float y=0; y<=siz.y; y+=cellSize) {

				drawGridPoint(pos.x + x, pos.y + y, _pointSize, _pointWeight, _color, _alpha);
			}

		}

		if (drawCheckers) drawCheckers(pos, siz, cellSize, _color, _alpha);
	}

	public void drawGridPoint(float _x, float _y, float _size, float _weight, int _color, int _alpha) {
		PVector pos = new PVector(_x,_y);
		float siz = _size;
		stroke(_color, _alpha);
		strokeWeight(_weight);
		line(pos.x - siz / 2, pos.y, pos.x + siz / 2, pos.y);
		line(pos.x, pos.y - siz / 2, pos.x, pos.y + siz / 2);
	}

	public void drawCheckers(PVector _pos, PVector _siz, float _cellSize, int _color, int _alpha) {

		PVector siz = _siz;
		PVector pos = _pos;
		float cellSize = _cellSize;

		int altAlpha = 4;
		
		if (switchTime > 0) switchTime--;
		else {

			if (alpha1 == _alpha) alpha1 = _alpha / altAlpha;
			else alpha1 = _alpha;

			if (alpha2 == _alpha / altAlpha) alpha2 = _alpha / altAlpha;
			else alpha2 = _alpha / altAlpha;

			switchTime = 14;
		}

		rectMode(CORNER);
		noStroke();

		PVector numCells = new PVector( siz.x / cellSize, siz.y / cellSize );

		boolean toggleAlphaOnLineBreak = numCells.x%2 != 0;

		alpha = alpha2;

		for (float y = 0; y <=numCells.y; y++) {
		
			for (float x = 0; x <=numCells.x; x++) {

				float xPos = pos.x + cellSize * x;
				float yPos = pos.y + cellSize * y;

				if (x != 0 || toggleAlphaOnLineBreak) {
					alpha = alpha == alpha2 ? alpha1 : alpha2;
				}

				fill(_color,alpha);
				rect(xPos,yPos,cellSize,cellSize);
			}
		}

	}
}
class Hud {
	int alpha;
	int blink;
	float rotation, statsDistance, easeControl, waitTime, waitDuration;
	boolean visible, showEndScreen;
	Pulser score = new Pulser();

	Hud() {
		blink = 0;
		rotation = 0;
		statsDistance = 0;
		easeControl = 0;
		showEndScreen = false;
		waitDuration = 100;
		waitTime = waitDuration;
	}

	public void update() {
		// blinking timer
		int blinkDuration = 14;
		if (blink > 0) blink -= 1 * dtInSeconds;
		else {
			if (alpha < 255) {
				alpha = 255;
				rotation += radians(90);
				visible = true;
			}
			else {
				visible = false;
				alpha = 0;
			}

			blink = blinkDuration;
		}

		if (gManager.matchOver) {
			if (waitTime > 0) waitTime--;
			else {
				showEndScreen = true;
				waitTime = waitDuration;
			}
		} else showEndScreen = false;

		draw();
	}

	public void draw() {	
		if (showEndScreen) {
		
			noStroke();
			fill(0,0,0,200);
			rect(0,0,WIN_WIDTH,WIN_HEIGHT);

			pushMatrix();

			translate(WIN_WIDTH / 2, WIN_HEIGHT / 2);

			//rotate the canvas to the winner
			switch (gManager.winnerID) {
				case 0: rotate(radians(180)); break;
				case 1: rotate(radians(0)); break;
				case 2: rotate(radians(270)); break;
				case 3: rotate(radians(90)); break;
			}

			drawStats();

			popMatrix();

		} else {

			for (int i=0; i<oManager.players.length; i++) {

				Player player = oManager.players[i];
				
				if (player.ALIVE) continue;
				else {
		
					pushMatrix();

					// set a pivot at the center of the view
					translate(WIN_WIDTH/2,WIN_HEIGHT/2);

					//rotate the canvas for each player
					switch (i) {
						case 0: rotate(radians(180)); break;
						case 1: rotate(radians(0)); break;
						case 2: rotate(radians(270)); break;
						case 3: rotate(radians(90)); break;
					}

					// set the draw color to the player color
					fill(colors.player[i],alpha);
					textAlign(CENTER);
					textSize(FONT_SIZE);

					// choose a text to draw
					String hudMessage;

					if (player.respawnTime > 0) hudMessage = "RESPAWN IN " + str(ceil(player.respawnTime));
					else if (player.spawnedOnce) hudMessage = "FIRE!";
					else hudMessage = "PRESS FIRE TO JOIN";
					
					// set the text position
					float textYPos = WIN_HEIGHT / 2 - ARENA_BORDER / 3;

					// draw the actual text
					text(hudMessage,0,textYPos);
					
					popMatrix();

				}
			}
		}
	}

	public void drawStats() {
		drawBars();

		fill(colors.player[gManager.winnerID]);
		textAlign(CENTER);

		// header and footer setup
		String headerText = "";
		String footerText = "";

		if (!gManager.gameOver) {
			headerText = "ROUND OVER";
			footerText = "PRESS START TO CONTINUE";
		} else {
			headerText = "MATCH OVER";
			footerText = "PRESS START TO PLAY AGAIN";
		}

		// draw header
		textSize(FONT_SIZE * 4);
		text(headerText,0, -VIEW_HEIGHT / 2 + ARENA_BORDER * 1.5f);

		// draw footer
		textSize(ARENA_BORDER);
		text(footerText,0,WIN_HEIGHT / 2 - ARENA_BORDER);
	}

	public void drawBars() {
		String subText = "";
		float fontSizeL = FONT_SIZE * 3;
		float fontSizeS = FONT_SIZE;
		int playerWithMostWins = checkMostWins();
		int lineNumberCount = 0;
		int lineNumber = 0;

		PVector barSizeS	=	new PVector(WIN_HEIGHT * 0.4f, VIEW_HEIGHT / 6);
		PVector barSizeL 	= 	new PVector(WIN_HEIGHT, barSizeS.y * 0.7f);
		PVector barPos		=	new PVector(-WIN_HEIGHT / 2,0);
		float baseOffsetY	= 	-VIEW_HEIGHT / 4;
		float barsYSpacing 	= 	VIEW_HEIGHT / 32;
		int barsAlpha 		= 	200;
		float drawScale = score.pulse(3,1,0.8f,0.5f,1);
		
		rectMode(CENTER);

		for (int i=0; i<oManager.players.length; i++) {

			Player player = oManager.players[i];

			lineNumberCount++;

			// puts the player with the most wins in the first row
			if (i == playerWithMostWins) {
				lineNumber = 0;
				lineNumberCount--;
			} else lineNumber = lineNumberCount; 
			
			// set the bars y position
			barPos.y = baseOffsetY + (barsYSpacing + barSizeS.y) * lineNumber;

			// draw bars
			noStroke();
			fill(colors.solid,barsAlpha);
			rect(0, barPos.y, barSizeL.x, barSizeL.y);
			fill(colors.player[i],barsAlpha);
			rect(barPos.x + barSizeS.x / 2, barPos.y, barSizeS.x, barSizeS.y);
			
			// check the players stats and choose a fitting text
			String[] playerName = new String[]{"RED","YELLOW","GREEN","BLUE"};
			subText = playerName[i] + " " + getDescription(i);

			// set the subtext position
			PVector subTextPos	= new PVector(barPos.x + barSizeS.x + barSizeL.x / 16, barPos.y + fontSizeS * 0.25f);

			fill(colors.player[i]);
			textSize(fontSizeS);
			textAlign(LEFT);			
			text(subText,subTextPos.x,subTextPos.y);

			// set up the position and size of the squares to draw
			float boxSize = barSizeS.y * 0.333f;
			float boxSpacing = barSizeS.y * 0.333f;
			float offsetX = barSizeS.x / 2 - boxSize - boxSpacing;
			PVector pos = new PVector(barPos.x + offsetX, barPos.y);

			stroke(colors.solid);
			strokeWeight(barSizeS.y * 0.05f);

			// draw the squares
			for (int b=0; b<3; b++) {

				float alp = 255;
				float dScale = 1;

				// draw size
				if (player.id == gManager.winnerID && b == player.wins-1) {
					dScale = drawScale;
					alp = map(drawScale,1,3,255,0);
				}

				//set the color and alpha
				if (b < player.wins) {
					fill(colors.player[i],alp);
					stroke(colors.solid,alp);
				} else {
					fill(colors.solid,200);
					stroke(colors.solid,255);
				}

				offsetX = b * (boxSize + boxSpacing);
				rect(pos.x + offsetX, pos.y, boxSize * dScale, boxSize * dScale);
			}
		}
	}

	public String getDescription(int _playerID) {
		
		int winnerID = 100;
		int shots = 0; 
		int kills = 0; 
		int deaths = 0; 
		int items = 0;
		int mostShots = 100; 
		int mostKills = 100; 
		int mostDeaths = 100; 
		int mostItems = 100;
		String text = "";

		for (Player p : oManager.players) {

			// if the player is the winner, set the message and skip the rest of the loop
			if (p.id == gManager.winnerID) {
				winnerID = p.id;
				continue;
			}

			// otherwise check 
			if (p.shots > shots) {
				shots = p.shots;
				mostShots = p.id;
			}
			if (p.kills > kills) {
				shots = p.kills;
				mostKills = p.id;
			}
			if (p.deaths > deaths) {
				deaths = p.deaths;
				mostDeaths = p.id;
			}
			if (p.items > items) {
				items = p.items;
				mostItems = p.id;
			}
		}

		if (winnerID == _playerID) {
			if (!gManager.gameOver) text = "WON THE MATCH!";
			else text = "WON THE GAME!";
		} else if (mostShots == _playerID) text = "FIRED THE MOST SHOTS!";
		else if (mostKills == _playerID) text = "GOT THE MOST KILLS!";
		else if (mostDeaths == _playerID) text = "DIED MOST OFTEN!";
		else if (mostItems == _playerID) text = "GOT THE MOST ITEMS!";
		else text = "DIDN'T PLAY.";

		return text;
	}

	public void showPlayerEndScreen(int _playerID, float _xPos, float _yPos) {
	}

	public int checkMostWins() {
		int wins = 0;
		int mostWins = 0;

		for (Player p : oManager.players) {
			if (p.wins > wins) {
				wins = p.wins;
				mostWins = p.id;
			}
		}

		return mostWins;
	}
}
class Input {
	
	int id;
	boolean hasGamePad;

	boolean upPressed, upWasPressed, upReleased;
	boolean downPressed, downWasPressed, downReleased;
	boolean leftPressed, leftWasPressed, leftReleased;
	boolean rightPressed, rightWasPressed, rightReleased;
	boolean shootPressed, shootWasPressed, shootReleased;
	boolean useItemPressed, useItemWasPressed, useItemReleased;
	boolean startPressed, startWasPressed, startReleased;
	boolean anyKeyPressed, anyKeyWasPressed, anyKeyReleased;
	boolean north, east, south, west;

	Input(int _id) {
		id = _id;

		upPressed		=	false; upWasPressed 	 	= false; upReleased 		= false;
		downPressed		=	false; downWasPressed 	 	= false; downReleased 		= false;
		leftPressed		=	false; leftWasPressed 		= false; leftReleased 		= false;
		rightPressed	=	false; rightWasPressed 		= false; rightReleased 		= false;
		shootPressed	=	false; shootWasPressed 		= false; shootReleased 		= false;
		useItemPressed	=	false; useItemWasPressed 	= false; useItemReleased 	= false;
		startPressed	=	false; startWasPressed 		= false; startReleased 		= false;
		anyKeyPressed 	= 	false;
		north = false;
		east = false;
		south = false;
		west = false;

		// check if player is using a game pad
		for ( int i = 0; i < gPads.size(); i++ ) {
			if (i == id) {
				hasGamePad = true;
				break;
			} else hasGamePad = false;
		}
	}

	public void update() {
		manageInputStates();
		if (hasGamePad) getGamePadInput(id);
		if (TOP_VIEW) setDirections();
		else {
			if (upPressed) north = true;
			else north = false;
			if (downPressed) south = true;
			else south = false;
			if (leftPressed) west = true;
			else west = false;
			if (rightPressed) east = true;
			else east = false;
		}
	}

	public void setDirections() {
		// sets the directions for each player
		if (upPressed) {
			switch (id) {
				case 0: south = true; break;
				case 1: north = true; break;
				case 2: west = true; break;
				case 3: east = true; break;
			}
		} else {
			switch (id) {
				case 0: south = false; break;
				case 1: north = false; break;
				case 2: west = false; break;
				case 3: east = false; break;
			}				
		}

		if (downPressed) {
			switch (id) {
				case 0: north = true; break;
				case 1: south = true; break;
				case 2: east = true; break;
				case 3: west = true; break;
			}
		}
		else {
			switch (id) {
				case 0: north = false; break;
				case 1: south = false; break;
				case 2: east = false; break;
				case 3: west = false; break;
			}
		}

		if (leftPressed) {
			switch (id) {
				case 0: east = true; break;
				case 1: west = true; break;
				case 2: south = true; break;
				case 3: north = true; break;
			}
		}
		else {
			switch (id) {
				case 0: east = false; break;
				case 1: west = false; break;
				case 2: south = false; break;
				case 3: north = false; break;
			}
		}

		if (rightPressed) {
			switch (id) {
				case 0: west = true; break;
				case 1: east = true; break;
				case 2: north = true; break;
				case 3: south = true; break;
			}
		}
		else {
			switch (id) {
				case 0: west = false; break;
				case 1: east = false; break;
				case 2: north = false; break;
				case 3: south = false; break;
			}
		}
	}

	public void getGamePadInput(int _id) {
		int id = _id;

		if (gPads.get(id).getSlider("LS_Y").getValue() < -0.2f || gPads.get(id).getButton("DP_UP").pressed()) upPressed = true;
		else upPressed = false;

		if (gPads.get(id).getSlider("LS_Y").getValue() > 0.2f || gPads.get(id).getButton("DP_DOWN").pressed()) downPressed = true;
		else downPressed = false;


		if (gPads.get(id).getSlider("LS_X").getValue() < -0.2f ||	gPads.get(id).getButton("DP_LEFT").pressed()) leftPressed = true;
		else leftPressed = false;

		if (gPads.get(id).getSlider("LS_X").getValue() > 0.2f || gPads.get(id).getButton("DP_RIGHT").pressed()) rightPressed = true;
		else rightPressed = false;

		shootPressed = gPads.get(id).getButton("BT_A").pressed();
		useItemPressed = gPads.get(id).getButton("BT_B").pressed();
		startPressed = gPads.get(id).getButton("BT_C").pressed();

		// handle any key boolean
		if (upPressed || downPressed || leftPressed || rightPressed || shootPressed || useItemPressed || startPressed) anyKeyPressed = true;
		else anyKeyPressed = false;
	}

	public void manageInputStates() {
		// take care of button presses/states
		if (upPressed) { upWasPressed = true; upReleased = false; }
		else {
			if (upWasPressed) upReleased = true;
			else upReleased = false;
			upWasPressed = false;
		}

		if (downPressed) { downWasPressed = true; downReleased = false; }
		else {
			if (downWasPressed) downReleased = true;
			else downReleased = false;
			downWasPressed = false;
		}

		if (leftPressed) { leftWasPressed = true; leftReleased = false; }
		else {
			if (leftWasPressed) leftReleased = true;
			else leftReleased = false;
			leftWasPressed = false;
		}

		if (rightPressed) { rightWasPressed = true; rightReleased = false; }
		else {
			if (rightWasPressed) rightReleased = true;
			else rightReleased = false;
			rightWasPressed = false;
		}

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
	}

	public void keyPressed() {
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
		if (upPressed || downPressed || leftPressed || rightPressed || shootPressed || useItemPressed || startPressed) anyKeyPressed = true;
	}

	public void keyReleased() {
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
		if (!upPressed || !downPressed || !leftPressed || !rightPressed || !shootPressed || !useItemPressed || !startPressed) anyKeyPressed = false;
	}
}
class Item extends GameObject {

	int respawnTime;
	float size, xPos, yPos, hSize, vSize, respawn;
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

		respawnTime = 0;

		bxPos = -hSize / 2;
		bxPos = -vSize / 2;
		bScaleMax = 0.8f;
		bScaleMin = 0.3f;
		bScale = bScaleMax;
		bScaleSpeed = 0.01f;

		hxPos = -hSize / 2;
		hxPos = -vSize / 2;
		hScaleMax = 1.0f;
		hScaleMin = 0.0f;
		hScale = hScaleMin;
		hScaleSpeed = 0.01f;

		msDistance = 0;
		msSpeed = 0.5f;
		msScaleMax = 1.0f;
		msScaleMin = 0.2f;
		msScale = msScaleMax;

		sStrokeMin = size / 32;
		sStrokeMax = size / 4;
		sStroke = sStrokeMax;
		sStrokeSpeed = 0.3f;

		aMax = 100;
		aMin = 40;
		a = aMax;
		b = a * 2;
		aSpeed = 2;

		ldPosMax = size / 2.5f;
		ldPosMin = 4;
		ldPos = ldPosMax;
		ldPosFactor = ldPosMax;
		ldSpeed = 0.3f;
	}

	public void update() {

		if (!pickedUp) {
			
			draw();

			for (Player p : oManager.players) {
				
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
			if (respawn > 0) respawn -= 1 * dtInSeconds;
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
				respawn = floor(random(5,10));
				powerUpSpawn01.trigger();
			}
		}
	}

	public void draw() {
		if (itemName == "HEALTH") { drawHealthItem(); }
		else if (itemName == "BOOST") { drawBoostItem(); } 
		else if (itemName == "MULTISHOT") { drawMultiShotItem(); }
		else if (itemName == "LOCKDOWN") { drawLockDownItem(); }
		else if (itemName == "SHIELD") { drawShieldItem(); }
	}

	public void drawHealthItem(){
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

	public void drawBoostItem() {
		// boost item visuals
		canvas.noStroke();
		canvas.rectMode(CORNER);
		canvas.pushMatrix();
		// set the pivot to the center of the item
		canvas.translate(xPos + hSize / 2,yPos + vSize / 2);

		// draw a pulsing rectangle in the background
		canvas.pushMatrix();
		alpha = (int)map(bScale,bScaleMax,bScaleMin,50,150);
		canvas.fill(colors.item,alpha);
		if (bScale <= bScaleMin || bScale >= bScaleMax) bScaleSpeed *= -1;
		bScale += bScaleSpeed;
		canvas.scale(bScale);
		canvas.rect(-hSize / 2,-vSize / 2, hSize, vSize);
		canvas.popMatrix();

		// set the position of the little rectangle
		if (bxPos < hSize / 4) bxPos += 30 * dtInSeconds;
		else {
			if (hud.visible) bxPos = -hSize / 2;
		}
		byPos = -vSize / 2;
		// map the position of the little rectangle to the alpha value the trail should have
		alpha = (int)map(bxPos,hSize/4,-hSize / 2,0,255);
		// draw four rectangles with a little fake trail
		for (int r=0;r<4;r++) {
			// now rotate from the center
			canvas.rotate(radians(90 * r));
			canvas.stroke(colors.item, alpha);
			canvas.strokeWeight(CELL_SIZE / 5);
			// draw the trail
			canvas.strokeCap(SQUARE);
			canvas.line(-hSize / 2 + hSize / 8, -vSize / 2 + vSize / 8,bxPos + hSize / 8,byPos + vSize / 8);
			canvas.strokeWeight(1.0f);
			canvas.noStroke();
			canvas.fill(colors.item,255);
			// draw the little rectangle
			canvas.rect(bxPos,byPos,hSize/4,vSize/4);
		}
		canvas.popMatrix();		
	}

	public void drawMultiShotItem() {
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
		// map the alpha to the current scale value
		alpha = (int)map(msScale,msScaleMax,msScaleMin,50,150);
		canvas.fill(colors.item,alpha);
		// draw the rectangle
		canvas.scale(msScale);
		canvas.rect(-hSize / 2,-vSize / 2, hSize, vSize);
		canvas.popMatrix();

		// draw 8 little bullets moving in 8 directions
		float msDistanceMax = hSize / 2;
		if (msDistance < msDistanceMax) msDistance += abs(msSpeed);
		else msDistance = 0;
		
		alpha = (int)map(msDistance,msDistanceMax,0,50,255);
		canvas.fill(colors.item,alpha);
		for (int xD=-1;xD<=1;xD++) {
			for (int yD=-1;yD<=1;yD++) {
			    if (xD == 0 && yD == 0) {}
			    else canvas.rect(centerX + hSize / 16 + msDistance * xD,centerY + vSize /16 + msDistance * yD,hSize / 8, vSize / 8);
			}
		}
	}

	public void drawLockDownItem() {
		if (ldPos <= ldPosMin ||  ldPos >= ldPosMax) ldSpeed *= -1;
		
		ldPos += ldSpeed;

		float ldSize = size / 2.5f;
		alpha = (int)map(ldPos,ldPosMin,ldPosMax,10,250);

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

	public void drawShieldItem() {
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
		canvas.rect(0,0,hSize / 1.7f,vSize / 1.7f);
		canvas.popMatrix();
	}
}
class LevelParser {
	
	LevelParser() {}

	public void parseLevel(int _levelID) {

		int levelID = _levelID;
		// load the level from the level list by looking up its id
		// String [] level = levelList.get(levelID);
		PImage level = levelList.get(levelID);
		level.loadPixels();

		int solidID = 0;
		int nodeID = 0;
		int itemID = 0;

		// step through the level file - for each horizontal line...
		for (int y=0; y<height; y++) {
			// step through all vertical characters
			for (int x=0; x<width; x++) {
				// store the character that is encountered
				int pixelColor = level.get(x,y);
				// store an in-game xPos and a yPos for each character
				float xPos = CELL_SIZE * x;
				float yPos = CELL_SIZE * y;

				PVector pos = new PVector(CELL_SIZE * x, CELL_SIZE * y);

				// check through the characters and add respective objects to the game at the stored position
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
	}
}
class Menu {
	
	boolean active = true;
	boolean tutorial = false;
	boolean credits = false;
	boolean settings = false;
	int alpha;
	int userId;
	PImage bg;
	float borderWeight, borderScale;
	float volumeSfx, volumeMsc;

	ArrayList < Input > input;

	// menus
	String[] pauseMenu = new String[]{"CONTINUE","SETTINGS","RESTART","HOW TO PLAY","EXIT"};
	String[] mainMenu = new String[]{"START GAME","SETTINGS","HOW TO PLAY","ABOUT"};
	String[] backMenu = new String[]{"BACK"};
	String[] settingsMenu = new String[]{"SFX VOLUME", "MUSIC VOLUME", "TOP_VIEW", "SHADERS"};
	int selectedItem, selectedSetting;
	float itemFontScale;

	// components
	Grid grid = new Grid();
	Pulser pulser1 = new Pulser();

	Menu() {
		alpha = 255;
		userId = (int)floor(random(0,4));

		selectedItem = 0;
		selectedSetting = 0;
		itemFontScale = 1;

		volumeSfx = 0.8f;
		volumeMsc = 0.8f;

		input = new ArrayList();
		for (int i=0; i<4; i++) {
			Input in = new Input(i);
			input.add(in);
		}

		borderWeight = ARENA_BORDER * 1.35f;
		borderScale = 2;
	}

	public void setUser(int _id) {
		userId = _id;
	}
	
	public void update() {
		if (active) {

			// check input
			for (Input i : input) {
				input.get(i.id).update();
				if (i.anyKeyPressed && i.id != userId)  {
					setUser(i.id);
					break;
				}
			}
			
			draw();

		} else selectedItem = 0;

		// handle the pause menu
		if (!tutorial && !credits && !settings) {
			if (gManager.paused) {
				if (input.get(userId).shootReleased) {
					switch( selectedItem ) {
						case 0: // CONTINUE 
							active = false;
							gManager.paused = false;
						break;
						case 1: settings = true; break;
						case 2: // RESTART
							active = false;
							gManager.paused = false;
							gManager.gameOver = true;
							gManager.reset();
						break;
						case 3: // HOW TO PLAY
							tutorial = true;
						break;
						case 4: // EXIT
							gManager.paused = false;
						break;
					}
					selectedItem = 0;
				}
			} else {
			// handle the main menu
				if (input.get(userId).shootReleased) {
					switch( selectedItem ) {
						case 0: // START GAME
							active = false; 
							gManager.reset();
						break;
						case 1: settings = true; break;
						case 2: tutorial = true; break;
						case 3: credits = true; break;
					}
					selectedItem = 0;
				}
			}
		} else {

			// handle the settings screen
			if (settings) {
				switch (selectedSetting) {
					case 0: volumeSfx = moveSlider(volumeSfx, 0.0f, 1.0f, 0.1f); break;
					case 1: volumeMsc = moveSlider(volumeMsc, 0.0f, 1.0f, 0.1f); break;
					case 2: TOP_VIEW = toggleBool(TOP_VIEW); break;
					case 3: SHADERS = toggleBool(SHADERS); break;
				}
			}

			// exit the submenu
			if (input.get(userId).shootReleased) {
				tutorial = false;
				credits = false;
				settings = false;
			}
		}
	}

	public float moveSlider(float _value, float _minRange, float _maxRange, float _step) {
		// moves a value between a range
		float value = _value;

		if (input.get(userId).rightReleased) {
			if (value < _maxRange) value += _step;
			else value = _maxRange;
		}
		
		if (input.get(userId).leftReleased) {
			if (value > _minRange) value -= _step;
			else value = _minRange;
		}

		if (value < _minRange) value = _minRange;
		if (value > _maxRange) value = _maxRange;

		return value;
	}

	public boolean toggleBool(boolean _bool) {
		boolean b = _bool;
		if (input.get(userId).rightReleased || input.get(userId).leftReleased) b = !b;
		return b;
	}

	public void draw() {
		// draw the background
		pushMatrix();
		translate(WIN_WIDTH / 2, WIN_HEIGHT / 2);
		
		if (gManager.paused) {
			imageMode(CENTER);
			image(bg,0,0);
			alpha = 75; 
		} else alpha = 255;

		// draw a background rectangle
		fill(colors.solid,alpha);
		stroke(colors.player[userId],255);
		strokeWeight(borderWeight * borderScale);		
		rectMode(CENTER);
		rect(0,0,WIN_HEIGHT,WIN_HEIGHT);

		//rotate the canvas to the player that's using the menu
		if (TOP_VIEW)
		switch (userId) {
			case 0: rotate(radians(180)); break;
			case 1: rotate(radians(0)); break;
			case 2: rotate(radians(270)); break;
			case 3: rotate(radians(90)); break;
		}

		// set positions
		float edgePos = WIN_HEIGHT / 2 - borderWeight;
		PVector posHeadline = new PVector(-edgePos + gridSize * 2, -edgePos + gridSize * 3.5f);
		PVector posLogo 	= new PVector(-edgePos + gridSize * 2, -edgePos + gridSize * 4);
		PVector posVersion 	= new PVector( edgePos - gridSize * 1.5f, gridSize * 2.5f);
		PVector menuPos 	= new PVector( 2, edgePos - gridSize + 5);

		if (!tutorial && !credits && !settings) {
			drawHeadLine(posHeadline, "ZAMSPIELEN PRESENTS");
			drawLogo(posLogo);
			drawVersion(posVersion);

			if (gManager.paused) drawMenu(pauseMenu, menuPos);
			else drawMenu(mainMenu, menuPos);
		}

		PVector gridPos = new PVector(-WIN_HEIGHT / 2 + borderWeight,-WIN_HEIGHT / 2 + borderWeight);
		PVector gridSiz = new PVector(VIEW_WIDTH + gridSize, VIEW_HEIGHT + gridSize);
		// grid (pos, siz, cellSize, pointSize, pointWeight, color, alpha)
		grid.drawGrid(gridPos, gridSiz, gridSize * 4, gridSize , 1, colors.player[userId], 100);
		grid.drawGrid(gridPos, gridSiz, gridSize / 2, gridSize / 8, 1, colors.player[userId], 50);

		if (tutorial || credits || settings) {
			drawSubMenu();
			drawMenu(backMenu, menuPos);
		}

		popMatrix();
	}

	public int navigateMenu(String[] _menuName, int _selectedItem) {
		// menu navigation
		if (input.get(userId).downReleased) {
			if (_selectedItem < _menuName.length - 1) _selectedItem++;
			else _selectedItem = 0;
		}

		if (input.get(userId).upReleased) {
			if (_selectedItem > 0) _selectedItem--;
			else _selectedItem = _menuName.length - 1;
		}

		return _selectedItem;
	}

	public void drawMenu(String[] _menuName, PVector _pos) {
		selectedItem = navigateMenu(_menuName, selectedItem);
		
		// draw pause text
		if (gManager.paused && !tutorial && !credits && !settings) {
			fill(colors.player[userId],blink.blink(255,0,14));
			textAlign(RIGHT);
			textSize(FONT_SIZE);
			noStroke();
			text("//GAME PAUSED", 0, VIEW_HEIGHT * 0.22f);
		}

		PVector pos = new PVector( _pos.x, _pos.y - gridSize * _menuName.length + gridSize / 2 );
		float hSize = gridSize * 11;

		// menu item colors
		int bg1 = 0;
		int bg2 = 0;
		int st1 = 0;
		int st2 = 0;
		int txt = 0;

		rectMode(CENTER);
		strokeWeight(1);
		textAlign(CENTER);
		textSize(FONT_SIZE * 0.8f);

		// draws the contents of a spcified menu array
		for (int i = 0; i < _menuName.length; i++) {

			float y = pos.y + gridSize * i;

			if (i == selectedItem) {
				bg1 = colors.bg;
				bg2 = colors.player[userId];
				st1 = colors.player[userId];
				st2 = colors.player[userId];
				txt = colors.player[userId];
			} else {
				bg1 = colors.solid;
				bg2 = colors.bg;
				st1 = colors.player[userId];
				st2 = colors.player[userId];
				txt = colors.player[userId];
			}

			stroke(st1,255);
			fill(bg1,255);
			rect(pos.x, y, hSize, gridSize);

			fill(bg2,255);
			stroke(st2,255);
			rect(pos.x + hSize / 2, y, gridSize, gridSize);
			rect(pos.x - hSize / 2, y, gridSize, gridSize);

			fill(txt,255);
			noStroke();
			text(_menuName[i], pos.x, y + gridSize * 0.25f);
		}
	}

	public void drawSubMenu() {
		PVector offset = new PVector(-WIN_HEIGHT / 2 + borderWeight + gridSize, -WIN_HEIGHT / 2 + borderWeight + gridSize * 5.5f);
		PVector boxSiz = new PVector( WIN_HEIGHT - borderWeight * 2 - gridSize, gridSize * 2);

		rectMode(CORNER);
		fill(colors.player[userId], 255);
		stroke(colors.player[userId], 255);
		rect(offset.x - gridSize * 0.5f, offset.y - gridSize * 1.5f, boxSiz.x, boxSiz.y );
		
		textSize(FONT_SIZE * 1.5f);
		textAlign(LEFT);
		fill(colors.solid);
		String headline = "";
		if (tutorial) headline = "H";
		else if (credits) headline = "C";
		else headline = "S";

		text("//QUADCORE - " + headline, offset.x, offset.y);

		offset.y += gridSize * 2;
		fill(colors.solid, 200);
		rect(offset.x - gridSize * 0.5f, offset.y - gridSize * 1.5f, boxSiz.x, boxSiz.y * 5);

		fill(colors.player[userId],255);
		noStroke();
		textSize(FONT_SIZE);

		if (tutorial) {

			String[] tutText = new String[]{
				"USE     TO MOVE YOUR QUAD.",
				"PRESS     TO SHOOT.",
				"HOLD     TO CHARGE A SHOT.",
				"PRESS     TO USE ITEMS.",
				"PRESS     TO RESPAWN.",
				"SPAWN ONTO OTHER PLAYERS TO KILL THEM.",
				"RESPAWN TIME INCREASES WITH EACH DEATH.",
				"CAPTURE ALL     TO WIN."
			};

			for (int i=0; i<tutText.length; i++) {

				text(tutText[i],offset.x, offset.y + gridSize * i);
				float iconPos = getSubStringPosition(tutText[i],"     ");
				if (iconPos != -1) {
					String iconType = "";
					switch(i) {
						case 0: iconType = "DPAD"; break;
						case 1: iconType = "BTN3"; break;
						case 2: iconType = "BTN3"; break;
						case 3: iconType = "BTN1"; break;
						case 4: iconType = "BTN3"; break;
						case 7: iconType = "NODE"; break;
					}
					drawIcon(offset.x + iconPos, offset.y + gridSize * i, 1, iconType);
				}
				
			}

		} else if (credits) {

			String[] credText = new String[]{
				"A GAME BY CLEMENS SCOTT OF BROKEN RULES",
				"MADE FOR HANS G. & ZAMSPIELEN",
				" ",
				"CO_PRODUCED BY JOSEF WIESNER",
				"ADDITIONAL LEVELS BY TANJA SCHANTL",
				" ",
				"MADE WITH PROCESSING",
				"BEN FRY | CASEY REAS | DAN SHIFFMAN",
				"SOUND LIBRARY BY DAMIEN DI FEDE",
				"SOUND FX MADE WITH CFXR",
				"GAME PAD LIBRARY BY PETER LAGER"
			};

			textSize(FONT_SIZE * 0.8f);

			for (int i=0; i<credText.length; i++) {
				text(credText[i],offset.x, offset.y + gridSize * i * 0.8f - gridSize / 2);
			}

		} else {
			float optionWidth =  gridSize * 8;
			PVector optionPos = new PVector(offset.x + VIEW_WIDTH / 3, offset.y - FONT_SIZE * 0.8f / 3);

			textSize(FONT_SIZE * 0.8f);

			selectedSetting = navigateMenu(settingsMenu, selectedSetting);

			for (int i=0; i<settingsMenu.length; i++) {
				boolean selected = i == selectedSetting ? true : false;
				float y = offset.y + gridSize * i;

				alpha = selected ? 255 : 150;

				fill(colors.player[userId], alpha);
				stroke(colors.player[userId], alpha);
				textAlign(LEFT);
				text(settingsMenu[i], offset.x, y);

				switch (i) {
					case 0: drawSlider	(optionPos.x, optionPos.y, optionWidth, volumeSfx, new PVector(0, 1)); break;
					case 1: drawSlider	(optionPos.x, optionPos.y + gridSize, optionWidth, volumeMsc, new PVector(0, 1)); break;
					case 2: drawBool	(optionPos.x, offset.y + gridSize * 2, optionWidth, TOP_VIEW, selected); break;
					case 3: drawBool	(optionPos.x, offset.y + gridSize * 3, optionWidth, SHADERS, selected); break;
				}
			}
		}
	}

	public void drawSlider(float _posX, float _posY, float _siz, float _val, PVector _range) {
		PVector pos = new PVector(_posX, _posY);
		float siz = _siz;
		float val = _val;

		strokeWeight(gridSize * 0.15f);
		line(pos.x, pos.y, pos.x + siz, pos.y);

		noStroke();
		float knobPos = map(val, _range.x, _range.y, 0, siz);
		rectMode(CENTER);
		rect(pos.x + knobPos, pos.y, gridSize * 0.7f, gridSize * 0.7f);
	}

	public void drawBool(float _posX, float _posY, float _siz, boolean _bool, boolean _active) {
		PVector pos = new PVector(_posX, _posY);
		String value = _bool ? "TRUE" : "FALSE";
		textAlign(CENTER);
		text(value, pos.x + _siz / 2, pos.y);

		float triSiz;
		if (_active && (input.get(userId).leftReleased || input.get(userId).rightReleased)) triSiz = gridSize * 0.5f;
		else triSiz = gridSize * 0.3f;

		noStroke();
		pos.y -= FONT_SIZE * 0.8f / 3;
		triangle(pos.x, pos.y, pos.x + triSiz, pos.y - triSiz / 2, pos.x + triSiz, pos.y + triSiz / 2);
		triangle(pos.x + _siz, pos.y, pos.x + _siz - triSiz, pos.y - triSiz / 2, pos.x + _siz - triSiz, pos.y + triSiz / 2);
	}

	public float getSubStringPosition(String _string, String _searchString) {
		// searches for a given substring within a string and returns its position
		String subString = "";
		float pos = 0;

		for (int i=0; i<_string.length(); i++) {
			if (i == _string.indexOf(_searchString)) {
				subString = _string.substring(0,i);
				pos = textWidth(subString);
				break;
			} else pos = -1;
		}

		return pos;
	}

	public void drawLogo(PVector _pos) {
		// draws QUADCORE
		float scl = WIN_SCALE;
		float wght = scl * 4; 
		PVector pos = _pos;
		PVector siz = new PVector(528 * scl, 256 * scl);
		PVector letterSiz = new PVector(siz.x / 4, siz.y / 2);
		int[] verts = new int[]{0,0};
		int[] lines = new int[]{0,0};

		if (!gManager.paused) {
			// draws the grid inside the logo
			// float weight = pulser1.pulse(wght * 0.2, wght * 0.4, 1.0, 0.5, -1);
			float weight = wght * 0.4f;
			grid.drawGrid(pos,siz,gridSize / 4, gridSize / 8, 1, colors.player[userId], 255);
			// draw the logo contour
			fill(colors.solid,255);
			stroke(colors.solid,255);
			strokeWeight(wght * 2);
		
			beginShape();
			vertex(pos.x, pos.y);
			vertex(pos.x + siz.x, pos.y);
			vertex(pos.x + siz.x, pos.y + siz.y);
			vertex(pos.x, pos.y + siz.y);

			for (int i=0; i<8; i++){
				verts = getLetterVerts(i);
				beginContour();
				drawLogoLetter(pos, verts, scl, true);
				endContour();
			}

			endShape(CLOSE);
			fill(colors.player[userId],30);
			stroke(colors.player[userId], 255);		
		} else {
			fill(colors.player[userId], 255);		
			stroke(colors.solid,255);
		}
		strokeWeight(wght);
		// draw the letter shapes with outlines
		for (int i=0; i<8; i++){
			verts = getLetterVerts(i);
			beginShape();
			drawLogoLetter(pos, verts, scl, true);
			endShape();
		}

		// draw non-shape lines of each letter
		for (int i=0; i<8; i++) {
			switch(i) {
				case 0: lines = new int[]{ 64,48, 64,80 }; break;
				case 1: lines = new int[]{ 192,0, 192,32 }; break;
				case 2: lines = new int[]{ 320,128, 320,96, 304,96, 336,96 }; break;
				case 3: lines = new int[]{ 448,48, 448,80 }; break;
				case 4: lines = new int[]{ 112,176, 112,208, 112,192, 144,192 }; break;
				case 5: lines = new int[]{ 208,176, 208,208 }; break;
				case 6: lines = new int[]{ 336,176, 336,208 }; break;
				case 7: lines = new int[]{ 464,176, 464,208 }; break;
			}
			drawLogoLetter(pos, lines, scl, false);
		}
	}

	public int[] getLetterVerts(int _letter) {
		int[] verts = new int[]{0,0};
			switch(_letter) {
				case 0: //Q
					verts = new int[]{ 0,0, 128,0, 128,96, 144,96, 128,128, 16,128, 0,112, 0,0, }; break;
				case 1: //U
					verts = new int[]{ 128,0, 256,0, 256,112, 240,128, 128,128, 144,96, 128,96, 128,0 }; break;
				case 2: //A
					verts = new int[]{ 256,16, 272,0, 368,0, 384,16, 384,128, 240,128, 256,112, 256,16, }; break;
				case 3: //D
					verts = new int[]{ 384,0, 480,0, 512,32, 512,128, 384,128, 384,0, 384,0 }; break;
				case 4: //C
					verts = new int[]{ 16,128, 144,128, 144,256, 32,256, 16,240, 16,128 }; break;
				case 5: //O
					verts = new int[]{ 144,128, 256,128, 272,144, 272,256, 160,256, 144,240, 144,128 }; break;
				case 6: //R
					verts = new int[]{ 256,128, 384,128, 400,144, 400,224, 368,224, 400,256, 272,256, 272,144, 256,128 }; break;
				case 7: //E
					verts = new int[]{ 384,128, 528,128, 528,192, 496,224, 528,224, 528,256, 400,256, 368,224, 400,224, 400,144, 384,128 }; break;
			}
			return verts;
	}

	public void drawLogoLetter(PVector _pos, int[] _coords, float _scl, boolean _contours) {
		// draws a single logo letter
		float scl = _scl;
		PVector pos = _pos;
		int[] coords = _coords;

		if (_contours) {
			strokeCap(PROJECT);
			for (int i=0; i<coords.length; i+=2) { vertex( pos.x + coords[i] * scl, pos.y + coords[i+1] * scl ); }
		} else {
			strokeCap(SQUARE);
			for (int i=0; i<coords.length; i+=4){ line( pos.x + coords[i] * scl, pos.y + coords[i+1] * scl, pos.x + coords[i+2] * scl, pos.y + coords[i+3] * scl ); }
		}
	}

	public void drawHeadLine(PVector _pos, String _headline) {
		fill(colors.player[userId]);
		noStroke();
		textSize(FONT_SIZE);
		textAlign(LEFT);
		text(_headline, _pos.x, _pos.y);
	}

	public void drawVersion(PVector _pos) {
		fill(colors.player[userId], 255);
		textSize(FONT_SIZE * 0.5f);
		textAlign(RIGHT);
		text("V." + version, _pos.x, _pos.y);
	}

	public void drawIcon(float _posx, float _posy, float _scale, String _type) {
		PVector pos = new PVector(_posx,_posy);
		float siz = floor(gridSize * _scale);
		PGraphics icon =  createGraphics((int)siz, (int)siz);
		icon.beginDraw();
		icon.fill(colors.player[userId]);
		icon.stroke(colors.player[userId]);
		icon.pushMatrix();
		icon.translate(siz / 2, siz / 2);

		if (_type == "DPAD") {

			for(int i=0;i<4;i++) {
				icon.stroke(colors.player[userId]);
				icon.rotate(radians(90 * i));	
				icon.strokeWeight(siz / 10);
				icon.line(0,0,0,-siz / 8);
				icon.noStroke();
				icon.triangle(0, -siz / 2, -siz / 6, -siz / 4, siz / 6, - siz / 4);
			}

		} else if(_type == "BTN0" || _type == "BTN1" || _type == "BTN2" || _type == "BTN3" ) {

			String no = str(_type.charAt(_type.length() - 1));

			for(int i=0;i<4;i++) {
				if (str(i).equals(no)) icon.fill(colors.player[userId]);
				else {
					icon.noFill();
					icon.stroke(colors.player[userId]);
				}
				icon.rotate(radians(-90 * i));
				icon.ellipse(0, -siz / 4, siz / 4, siz / 4);

			}

		} else if (_type == "NODE") {

			icon.strokeWeight(floor(siz / 4));
			icon.fill(colors.solid);
			icon.rectMode(CENTER);
			icon.rect(0, 0, siz, siz);
			icon.strokeWeight(floor(siz / 8));
			icon.rect(0, 0, siz / 3, siz / 3);

		} else {
			icon.rectMode(CENTER);
			icon.fill(colors.player[userId]);
			icon.noStroke();
			icon.rect(0, 0, siz, siz);
		}
		icon.popMatrix();
		icon.endDraw();
		imageMode(CORNER);
	  	image( icon, pos.x + siz * 0.1f, pos.y - siz * 0.8f);
	}

	public void keyPressed()  {
		if (active) {
			for (Input i : input) i.keyPressed();
		}
	}

	public void keyReleased() { 
		if (active) {
			for (Input i : input) i.keyReleased();
		}
	}

}
class Node extends GameObject {
	
	int ownedByPlayer, occupiedByPlayer;
	int nodeColor1, nodeColor2;
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
		lockDownScale = 1.5f;
		lockDownScaleSpeed = 0.1f;
	}

	public void update(){
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
				lockDownScale = 1.5f;
			}

		} else pulseNode = true;

		if (lockDown) {

			wasLockedDown = false;

			// warn when the node is about to unlock
			if (lockDownTime < lockDownDuration * 0.2f) {
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

		if (pulseNode) drawScale = pulser.pulse( 1.0f, 1.5f, 0.1f, 0.5f, -1);

	}

	public void draw() {
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

	public void lockNode() {
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
		if (lockDownScale > 1.0f) lockDownScale -= lockDownScaleSpeed;
		else lockDownScale = 1.0f;
	}
}
class ObjectManager {

    ArrayList < Bullet > bullets;  
    ArrayList < Solid > solids;
    ArrayList < Node > nodes;
    ArrayList < Item > items;

    int activePlayers;
	int maxPlayers = 4;
	Player[] players = new Player[maxPlayers];

    ObjectManager() {
    	bullets 	= new ArrayList();
	    solids 		= new ArrayList();
	    nodes 		= new ArrayList();
	    items 		= new ArrayList();
	}

	public void update() {
        destroyBullet();
		updateGameObjects();
	}

	public void updateGameObjects() {
		// updates all game objects
		for (Solid o : solids) 		o.update();
		for (Item o : items) 		o.update();
		for (Node o : nodes) 		o.update();
		for (Player o : players) 	o.update();
		for (Bullet o : bullets) 	o.update();
	}

	public void destroyBullet() {
		// removes a specific game object from the array list
		for (int i=0;i<bullets.size();i++) {
			Bullet b = bullets.get(i);
			if (b.destroy) bullets.remove(i);
		}
	}

	public void clearGameObjects() {
		bullets.clear();
		solids.clear();
		nodes.clear();
		items.clear();
	}

	public void addPlayer(int _id, PVector _startPos) {
		// adds an inactive players - only if there isn't a player stored at the current position
		if (players[_id] == null) {
			Player p = new Player(_id, _startPos);
			players[_id] = p;
		} else players[_id].startPos = _startPos;
	}

	public void resetPlayers() {
		// resets all players
		for (Player p : players) p.reset();
	}

	public void addBullet(int _id, PVector _pos, PVector _dir, float _charge) {
		Bullet b = new Bullet(_id, _pos, _dir, _charge);
		bullets.add(b);
	}

	public void addSolid(int _id, PVector _pos) {
        Solid s = new Solid(_id, _pos);
		solids.add(s);
	}

	public void addNode(int _id, float _xPos, float _yPos) {
		Node n = new Node(_id,_xPos,_yPos);
		nodes.add(n);
	}

	public void addItem(int _id, float _xPos, float _yPos) {
		Item i = new Item(_id,_xPos,_yPos);
		items.add(i);
	}

	public void keyPressed() {
		//check keyPresses for all players if the aren't using a gamepad
		if (players != null) {
			for (Player p : players) {
				if (p.input.hasGamePad) continue;
				else p.input.keyPressed();
			}
		}		
	}

	public void keyReleased() {
		//check keyReleases for all players if the aren't using a gamepad
		if (players != null) {
			for (Player p : players) {
				if (p.input.hasGamePad) continue;
				else p.input.keyReleased();
			}
		}
	}
}
class Player extends GameObject {

	//properties
	PVector startPos, dir, speed, sizCore, shieldHp;

	int id, alpha;
	float minCharge, maxCharge, drawScale, initialDrawScale, drawScaleShield;
	boolean ALIVE, KILLED, INVINCIBLE;
	boolean hit, knockBack, hasMultiShot, hasShield, hasLockDown;
	boolean wrapH, wrapV;
	
	// stats
	int bullets, kills, deaths, shots, items, score, nodesOwned, nodesCaptured, nodesLost, wins;
	boolean spawnedOnce;

	//counters
	float initialRespawnDuration, respawnDuration, respawnTime, respawnDurationMultiplier;
	float invincibleDuration, invincibleTime;
	float shootDelayDuration, shootDelayTime;
	int trailCount;
	float charge, chargeDelay, initChargeDelay;

	//cursor
	PVector cursorPos, cursorSiz;

	// boosting
	boolean hasBoost, boosting;
	int boostDuration = 30;
	int boostTime = boostDuration;
	ArrayList <TrailParticle> boostParticles = new ArrayList <TrailParticle>();

	//multishot
	float msIndicatorSize, msMaxSize;

	// item display
	int itemAlpha;
	boolean showItem;
	float itemYPos, itemShowDuration;
	String currentItem, prevItem = "";

	Input input;
	
	Player(int _id, PVector _startPos) {

		id = _id;
		input = new Input(id);

		// set player variables
		startPos 	= new PVector( _startPos.x, _startPos.y );
		pos 		= new PVector( startPos.x, startPos.y );
		cen 		= new PVector( pos.x + siz.x / 2, pos.y + siz.x / 2);
		sizCore		= new PVector( siz.x, siz.y );
		cursorPos 	= new PVector( pos.x, pos.y );
		cursorSiz 	= new PVector( siz.x, siz.y );
		speed 		= new PVector( 0,0 );
		dir 		= new PVector( 0,1 );
		hp 			= new PVector( 10,10 );
		shieldHp 	= new PVector( 10,10 );

		wins = 0;
		
		if (input.hasGamePad) println("Player " + id + " uses a game pad.");
		else  println("Player " + id + " doesn't use a game pad.");
	}

	public void reset() {
		// reset is called at every start of the level and is used to (re)initialise player variables
		siz = new PVector( CELL_SIZE, CELL_SIZE );

		hit = false;
		ALIVE = false;
		INVINCIBLE = false;
		KILLED = false;
		boosting = false;
		hasBoost = false;
		hasMultiShot = false;
		hasShield = false;
		hasLockDown = false;
		showItem = false;
		spawnedOnce = false;
		
		//properties
		alpha = 255;
		initialDrawScale = 5;
		drawScale = initialDrawScale;
		drawScaleShield = 1;
		wrapH = false;
		wrapV = false;

		//stats
		bullets = 0;
		score = 0;
		deaths = 0;
		kills = 0;
		items = 0;
		nodesOwned = 0;
		nodesCaptured = 0;
		nodesLost = 0;
		if (gManager.gameOver) wins = 0;
		pos.set(startPos);

		// bullet charge
		maxCharge = CELL_SIZE;
		minCharge = CELL_SIZE / 2;
		charge = minCharge;
		initChargeDelay = 0.01f;
		chargeDelay = initChargeDelay;
		shootDelayDuration = 1.5f;
		shootDelayTime = 0;

		// respawn timers
		respawnDuration = 0;
		respawnTime = respawnDuration;
		respawnDurationMultiplier = 2;
		// invicibility
		invincibleDuration = 2;
		invincibleTime = invincibleDuration;
		// boost
		trailCount = 100000;

		// multishot
		msMaxSize = siz.x / 6;
		msIndicatorSize = msMaxSize;
		// shield
		shieldHp.x = 0;
	}

	public void update() {
		// update the inputs if the debug console isn't open
		if (!gManager.debug) input.update();

		// pauses the game
		if (input.startReleased) {
			if (gManager.matchOver) {
				if (hud.showEndScreen) gManager.reset();
			} else {
				gManager.paused = !gManager.paused;
				menu.setUser(id);
			}
		}

		updateVectors();

		if (!KILLED) move();
		draw();
		face();
		boost();
		
		if (ALIVE && !KILLED) {

			if (drawScale > 1) drawScale *= 0.8f;
			else drawScale = 1;

			if (drawScaleShield > 1) drawScaleShield *= 0.8f;
			else drawScaleShield = 1;

			//if the player is invincible, count down the timer and start blinking
			if (INVINCIBLE) {
				if (invincibleTime > 0) {
					alpha = blink.blink(0,255,3);
					invincibleTime -= 1 * dtInSeconds;

				} else {
					if (!debugger.invincibility) INVINCIBLE = false;
					invincibleTime = invincibleDuration;
					alpha = 255;
				
				}

			} else hit();

			// if hp.x goes under 0, kill the player
			if (hp.x <= 0) die();

			// maintain the shield status
			if (shieldHp.x <= 0) hasShield = false;
			else hasShield = true;
			
			if(!gManager.matchOver) {

				if (shootDelayTime > 0) shootDelayTime--;
				else shoot();

				useItem();
				checkNodeCount();
			}

		} else if (KILLED) {
			// reset any powerups
			boosting = false;
			hasBoost = false;
			hasMultiShot = false;
			hasShield = false;
			hasLockDown = false;
			showItem = false;		
			
			// decrease alpha && increase drawScale
			if (alpha > 0) {
				alpha -= 10;
				drawScale++;
			} else if (!gManager.matchOver) {
				ALIVE = false;
				KILLED = false;
			}

		} else {
			// count down until respawn is possible
			if (respawnTime > 0) respawnTime -= 1 * dtInSeconds;
			else if (input.shootReleased && !gManager.matchOver) spawn();
		}
	}

	public void useItem() {
		if (input.useItemPressed && ALIVE && !KILLED) {

			if (hasLockDown) {
				for (Node n : oManager.nodes) {
					n.wasLockedDown = true;
				}
				hasLockDown = false;
			}
			
			if (hasBoost && !boosting) {
				boosting = true;
				hasBoost = false;
				boost01.trigger();
			}

			if (hasMultiShot) {
				multiShot01.trigger();

				for (int xD = -1; xD <= 1; xD++) {
					for (int yD = -1; yD <= 1; yD++) {

					    if (xD != 0 || yD != 0) {
					    	PVector direction = new PVector( xD, yD );
					    	oManager.addBullet(id,cen,direction,maxCharge * 0.7f);
					    }

					}
				}
				hasMultiShot = false;
			}
		}
	}

	public void checkNodeCount() {
		//check how many nodes the player owns (must be more than one)
		if (nodesOwned == oManager.nodes.size() && nodesOwned != 0 && !gManager.matchOver) {
			wins ++;
			if (wins == 3) gManager.gameOver = true;
			gManager.matchOver = true;
			gManager.winnerID = id;
		}		
	}

	public void updateVectors() {
		cen.x = pos.x + siz.x / 2;
		cen.y = pos.y + siz.y / 2;

		sizCore.x = siz.x / 2 * hp.x / 10;
		sizCore.y = siz.y / 2 * hp.x / 10;

		cursorSiz.x = charge / 4;
		cursorSiz.y = charge / 4;
	}

	public void draw() {

		canvas.rectMode(CENTER);

		if (ALIVE) {
			// player background
			canvas.strokeWeight(siz.x / 32);	
			canvas.fill(colors.player[id],alpha/5);
			canvas.stroke(colors.player[id],alpha);
			canvas.rect(cen.x,cen.y,siz.x * drawScale,siz.y * drawScale);

			//draw the player core background
			canvas.noStroke();
			canvas.fill(colors.player[id],alpha/3);
			canvas.rect(cen.x,cen.y,siz.x/2 * drawScale,siz.y/2 * drawScale);

			// draw the multishot indicator
			if (hasMultiShot) drawMultiShotIndicator();

			// draw the boost indicator
			if (hasBoost) drawBoostIndicator();

			// draw shield
			if (hasShield) {
				float offset = 1.5f;
				float shieldAlpha = shieldHp.x / 10 * alpha;
				canvas.noFill();
				canvas.stroke(colors.player[id],shieldAlpha);
				float weight = map(shieldHp.x,0,shieldHp.y,1,3);
				canvas.strokeWeight(weight);
				canvas.rect(cen.x,cen.y,siz.x * offset * drawScaleShield,siz.y * offset * drawScaleShield);
			}

			// draw the player cores
			canvas.noStroke();
			canvas.fill(colors.player[id],alpha);
			canvas.rect(cen.x,cen.y,sizCore.x * drawScale,sizCore.x * drawScale);

			// draw the cursor
			canvas.rect(cursorPos.x,cursorPos.y,cursorSiz.x * drawScale,cursorSiz.y * drawScale);
			
			// draw the item name on pickup
			if (showItem) drawItemName();

		} else if (!KILLED) drawRespawnIndicator();

		if (debugger.debugDraw) debugDraw();
	}

	public void drawRespawnIndicator() {
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
		canvas.textSize(CELL_SIZE / 1.5f);
		canvas.fill(colors.player[id],200);
		canvas.pushMatrix();
		switch (id) {
			case 0:
				canvas.translate(pos.x + siz.x / 2,pos.y+siz.x / 2.8f);
				canvas.rotate(radians(180)); break;
			case 1: 
				canvas.translate(pos.x + siz.x / 2,pos.y+siz.x / 1.5f);
				canvas.rotate(radians(0)); break;
			case 2: 
				canvas.translate(pos.x + siz.x / 1.5f,pos.y+siz.x / 2);
				canvas.rotate(radians(270)); break;
			case 3: 
				canvas.translate(pos.x + siz.x / 2.8f,pos.y+siz.x / 2);
				canvas.rotate(radians(90)); break;
		}
		if (respawnTime > 0) canvas.text(ceil(respawnTime),0,0);
		else canvas.text("GO!",0,0);
		canvas.popMatrix();
	}

	public void drawBoostIndicator() {
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

	public void drawMultiShotIndicator() {

		float msMinSize = siz.x / 12;
		float msSpeed = 0.2f;

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

	public void boost() {
		// manages boosting and trail particles
		if (boosting && boostTime > 0) {

			boostTime -= 1 * dtInSeconds;
			
			// adds particles
			boolean createParticle = repeat(2);
			if (createParticle) {
				TrailParticle p = new TrailParticle(new PVector(cen.x,cen.y),siz.x,colors.player[id]);
				boostParticles.add(p);
			}

		} else {
			boosting = false;
			boostTime = boostDuration;
		}

		// update particles
		for (TrailParticle p : boostParticles) {
			if (p.remove) {
				boostParticles.remove(p);
				break;
			} else p.update();
		}
	}

	public void drawItemName() {
		
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
		float easing = 0.3f;
		float itemDistance = itemYPosMax - itemYPos;
		float itemShowTime = 0.5f;

		// set the text position
		if (itemYPos > itemYPosMax && abs(itemDistance) > 1) {
			// move the text up
			itemYPos += itemDistance * easing;

			// set the text transparency depending on the text position
			itemAlpha = (int)map(itemYPos,0,itemYPosMax,0,255);

			itemShowDuration = itemShowTime;
		} else {
			// let the text stand there for a little while
			if (itemShowDuration > 0) itemShowDuration -= 1 * dtInSeconds;
			else {
				// fade out the text
				int fadeOutSpeed = 70;
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

	public void debugDraw() {
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

	public float getVSpeed(float _acc, float _dec, float _maxSpeed) {
		// determine vertical speed
		if (input.north || ((boosting || wrapV) && dir.y == -1)) {
			if (speed.y > -_maxSpeed) speed.y -= _acc;
			else speed.y = -_maxSpeed;
		} else if (input.south || ((boosting || wrapV) && dir.y == 1)) {
			if (speed.y < _maxSpeed) speed.y += _acc;
			else speed.y = _maxSpeed;
		} else if (!wrapV) {
			if (abs(speed.y) > 0.1f) speed.y *= _dec;
			else speed.y = 0;
		} 
		// return the vertical speed
		return speed.y * dtInSeconds;
	}

	public float getHSpeed(float _acc, float _dec, float _maxSpeed) {
		// determine horizontal speed
		if (input.west || ((boosting || wrapH) && dir.x == -1)) {
			if (speed.x > -_maxSpeed) speed.x -= _acc;
			else speed.x = -_maxSpeed;
		} else if (input.east || ((boosting || wrapH) && dir.x == 1)) {
			if (speed.x < _maxSpeed) speed.x += _acc;
			else speed.x = _maxSpeed;
		} else if (!wrapH) {
			if (abs(speed.x) > 0.1f) speed.x *= _dec;
			else speed.x = 0;
		}	
		// return the horizontal speed
		return speed.x * dtInSeconds;
	}

	public void move() {
		// movement properties
		float maxSpeed = CELL_SIZE / 7;
		float acceleration = CELL_SIZE / 15;
		float deceleration = 0.1f;			

		// change movement properties when boosting
		if (boosting) {
			maxSpeed = CELL_SIZE / 2;
			acceleration = 1.0f;
		}

		if (boosting) {
			maxSpeed = 8.0f;
			acceleration = 1.0f;
		}

		getVSpeed(acceleration, deceleration, maxSpeed);
		getHSpeed(acceleration, deceleration, maxSpeed);

		//collision bools
		boolean collisionTop = false;
		boolean collisionBottom = false;
		boolean collisionLeft = false;
		boolean collisionRight = false;

		//check for collisions with other players
		for (Player p : oManager.players) {

			// only check for collisions when:
			// the id is different from the players id
			// when the other player isn't dead
			// when the player isn't in respawn mode
			// and when there isn't already a collision

			if (id != p.id && p.ALIVE && ALIVE) {
				if (!collisionTop) 		collisionTop = collision.checkBoxCollision(pos.x,pos.y - abs(speed.y),siz.x,siz.x,p.pos.x,p.pos.y,p.siz.x,p.siz.x);
				if (!collisionBottom)	collisionBottom = collision.checkBoxCollision(pos.x,pos.y + abs(speed.y),siz.x,siz.x,p.pos.x,p.pos.y,p.siz.x,p.siz.x);
				if (!collisionLeft)		collisionLeft = collision.checkBoxCollision(pos.x - abs(speed.x),pos.y,siz.x,siz.x,p.pos.x,p.pos.y,p.siz.x,p.siz.x);
				if (!collisionRight)	collisionRight = collision.checkBoxCollision(pos.x + abs(speed.x),pos.y,siz.x,siz.x,p.pos.x,p.pos.y,p.siz.x,p.siz.x);
 			}

		}

		// screenwrapping
		wrapH = checkWrapping("Horizontal");
		wrapV = checkWrapping("Vertical");
		if (wrapH) {
			input.east = false;
			input.west = false;
		}

		if (wrapV) {
			input.north = false;
			input.south = false;
		}

		//check for collisions with solids
		for (Solid s : oManager.solids) {
			if (wrapV) {
				if (!collisionTop)		collisionTop 		= collision.checkBoxCollision(pos.x,VIEW_HEIGHT - abs(speed.y),siz.x,siz.y,s.pos.x,s.pos.y,s.siz.x,s.siz.y);
				if (!collisionBottom) 	collisionBottom 	= collision.checkBoxCollision(pos.x,-siz.y + abs(speed.y),siz.x,siz.y,s.pos.x,s.pos.y,s.siz.x,s.siz.y);
				if (collisionTop || collisionBottom) dir.y *= -1;
			} else {
				if (!collisionTop)		collisionTop 	= collision.checkBoxCollision(pos.x,pos.y - abs(speed.y),siz.x,siz.x,s.pos.x,s.pos.y,s.siz.x,s.siz.y);
				if (!collisionBottom)	collisionBottom = collision.checkBoxCollision(pos.x,pos.y + abs(speed.y),siz.x,siz.x,s.pos.x,s.pos.y,s.siz.x,s.siz.y);
			}

			if (wrapH) {
				if (!collisionLeft)		collisionLeft = collision.checkBoxCollision(VIEW_WIDTH - abs(speed.x),pos.y,siz.x,siz.y,s.pos.x,s.pos.y,s.siz.x,s.siz.y);
				if (!collisionRight)	collisionRight = collision.checkBoxCollision(0 + abs(speed.x),pos.y,siz.x,siz.x,s.pos.x,s.pos.y,s.siz.x,s.siz.y);				
				if (collisionLeft || collisionRight) dir.x *= -1;
			} else {
				if (!collisionLeft)		collisionLeft = collision.checkBoxCollision(pos.x - abs(speed.x),pos.y,siz.x,siz.x,s.pos.x,s.pos.y,s.siz.x,s.siz.y);
				if (!collisionRight)	collisionRight = collision.checkBoxCollision(pos.x + abs(speed.x),pos.y,siz.x,siz.x,s.pos.x,s.pos.y,s.siz.x,s.siz.y);				
			}
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

		if (pos.y > VIEW_HEIGHT) pos.y = -siz.y;
		else if (pos.y + siz.y < 0) pos.y = VIEW_HEIGHT;
	}

	public boolean checkWrapping(String _direction) {
		// checks if the player is wrapping around the screen
		boolean wrapping = false;

		if (_direction == "Horizontal") wrapping = (pos.x + siz.x > VIEW_WIDTH || pos.x < 0) ? true : false;
		if (_direction == "Vertical") wrapping = (pos.y + siz.y > VIEW_HEIGHT || pos.y < 0) ? true : false;

		return wrapping;
	}

	public void face() {
		// this method determines which direction the player is facing and sets the player cursor appropriately
		if (input.north) {
			dir.y = -1;
			if (!input.west && !input.east) dir.x = 0;
		}
		else if (input.south) {
			dir.y = 1;
			if (!input.west && !input.east) dir.x = 0;
		}
		
		if (input.west) {
			dir.x = -1;
			if (!input.north && !input.south) dir.y = 0;
		}
		else if (input.east) {
			dir.x = 1;
			if (!input.north && !input.south) dir.y = 0;
		}

		//evaluate the position of the cursor depending on the player direction
		if (dir.y > 0) cursorPos.y = pos.y + siz.x;
		else if (dir.y < 0) cursorPos.y = pos.y;
		else cursorPos.y = pos.y + siz.x / 2;

		if (dir.x > 0) cursorPos.x = pos.x + siz.x;
		else if (dir.x < 0) cursorPos.x = pos.x;
		else cursorPos.x = pos.x + siz.x / 2;
	}

	public void shoot() {
		//shoot bullets!
		if (input.shootReleased) {
			
		    oManager.addBullet(id,cursorPos,dir,charge);
		    shot01.trigger();
		    shots++;
			charge = minCharge;
			input.shootReleased = false;
			chargeDelay = initChargeDelay;
			shootDelayTime = shootDelayDuration;
		
		} else if (input.shootWasPressed) {

			if (chargeDelay > 0) chargeDelay--;
			else {
				if (charge < maxCharge) charge++;
				else charge = maxCharge;
			}
		
		}
	}

	public void hit() {
		//go through each existing bullet and check if the player collides with any of them
		for (Bullet b : oManager.bullets) {

			// skip the players own bullets
			if (id == b.id) continue;

			//only check collisions when the player isn't dead
			if (ALIVE) hit = collision.checkBoxCollision(pos.x,pos.y,siz.x,siz.x,b.pos.x,b.pos.y,b.siz.x,b.siz.y);

			// if the player was hit by a bullet
			if (hit) {

				Player p = oManager.players[b.id];				// get the id of the shooter
				
				if (b.damage != 0) {
					screenShake.shake(1,0.2f);

					if (!hasShield) {
						drawScale = 1.5f;
						hp.x -= b.damage;
					} else {
						drawScaleShield = 1.5f;
						shieldHp.x -= b.damage;
					}
				}
				
				b.damage = 0;									// set the bullet damage to 0 (used to determine if it still can do damage)
				if (hp.x <= 0) p.kills++;						// add the shooters killcount if the bullet killed the target
			}

		}

		hit = false;
	}

	public void die() {
		KILLED = true;
		die01.trigger();
		screenShake.shake(7,1.2f);
		deaths++;
		if (respawnDuration != 0) respawnDuration *= respawnDurationMultiplier;
		else respawnDuration = respawnDurationMultiplier;
		respawnTime = respawnDuration;		
		oManager.activePlayers--;
	}

	public void knockBack(PVector dir) {
		// knocks the player back when hit
		int knockBackStrength = 5;

		// speed.x = knockBackStrength * _dir.x * dtInSeconds; 
		// speed.y = knockBackStrength * _dir.y * dtInSeconds; 

		//play a sound
		hurt01.trigger();

		knockBack = true;		// this doesn't do anything but can be used later if needed
	}

	public void spawn() {
		// respawns the player if possible
		boolean canSpawn = checkSpawnKill();

		if (canSpawn) {
			// respawn the player and reset it's properties
			ALIVE = true;
			INVINCIBLE = true;
			spawnedOnce = true;
			hp.x = hp.y;
			alpha = 255;
			drawScale = initialDrawScale;
			spawn01.trigger();
			oManager.activePlayers++;
		}
	}

	public boolean checkSpawnKill() {
		boolean canSpawn = true;
		boolean spawnKill = false;

		//check for collisions with other players and kill them when spawning on top of them
		for (Player p : oManager.players) {
			// skip own player id and dead players
			if (id == p.id || !p.ALIVE) continue;

			spawnKill = collision.checkBoxCollision(pos.x,pos.y,siz.x,siz.x,p.pos.x,p.pos.y,p.siz.x,p.siz.x);
				
 			if (spawnKill) {
 				if (!p.INVINCIBLE) p.hp.x -= p.hp.x; 					
 				else canSpawn = false;
 			}
		}
		return canSpawn;
	}
}
class Pulser {

	float currentValue, currentTarget, previousTarget;
	int repeats;
	boolean reversed;
	
	Pulser() {
		currentValue = -1;
		reversed = false;
	}

	public float pulse(float _startValue, float _targetValue, float _speed, float _easingFactor, int _repeats) {
		// sets parameters once
		if (currentValue == -1) {
			currentValue = _startValue;
			currentTarget = _targetValue;
			previousTarget = _startValue;
			repeats = _repeats;
		}

		float diff = currentTarget - previousTarget;
		float step = dtInSeconds / _speed * diff;

		// checks which is the smaller or larger value - needed for the constrain function below
		float smallerValue = previousTarget < currentTarget ? previousTarget : currentTarget;
		float largerValue  = previousTarget > currentTarget ? previousTarget : currentTarget;

		// approaches the current target value
		currentValue = constrain(currentValue + step, smallerValue, largerValue);

		// reverses the direction
		if (currentValue == currentTarget && repeats != 1) {

			if (currentTarget == _startValue) {
				currentTarget = _targetValue;
				previousTarget = _startValue;
			} else {
				currentTarget = _startValue;
				previousTarget = _targetValue;
			}
			if (repeats != -1) repeats--;
		}

		return ease(currentValue,currentTarget,previousTarget,_easingFactor);
	}

	public float ease(float _currentValue, float _startValue, float _targetValue, float _easingFactor) {
		// this function eases a _startValue towards a _targetValue using an _easingFactor
		float normedValue = norm(_currentValue, _startValue, _targetValue);
		float easedValue = pow(normedValue, _easingFactor);
		return map(easedValue,0,1,_startValue,_targetValue);
	}

}
class Shake {

	float shakeTime, strength, strenghtFalloff;
	PVector offset, newOffset, dir;
	boolean startShaking, isShaking, moveBack;
	
	Shake() {

		shakeTime = 0;
		offset = new PVector(0,0);
		newOffset = new PVector(0,0);
		dir = new PVector();
		startShaking = false;
		isShaking = false;
		moveBack = false;
	
	}

	public void update() {

		strength -= strenghtFalloff;
		dir = new PVector( getDir(), getDir() );

		if (shakeTime > 0) {
			
			if (moveBack) {
				newOffset.mult(-1);
				moveBack = false;
			} else {
				newOffset.x = strength * dir.x;
				newOffset.y = strength * dir.y;
				moveBack = true;
			}

			offset.set(newOffset);

			shakeTime--;

		} else {

			if (moveBack) {
				newOffset.mult(-1);
				offset.set(newOffset);
			}
			
			shakeTime = 0;
			isShaking = false;

		}
	}

	public void shake(float _strenght, float _duration) {

			shakeTime = _duration / dtInSeconds;
			strength = _strenght;
			strenghtFalloff = _strenght / shakeTime;
			isShaking = true;

	}

	public float getDir() {
		
		float newDir = random( -1, 1 );

		if (newDir > 0) newDir = 1;
		else newDir = -1;	

		return newDir;	
	}
}
class Solid extends GameObject {

	boolean destroy;
	
	Solid(int _id, PVector _pos) {
		id = _id;
		pos.set(_pos);
		destroy = false;
	}

	public void update() {
		draw();
	}

	public void draw() {
		canvas.rectMode(CORNER);
		canvas.noStroke();
		canvas.fill(colors.solid,255);
		canvas.rect(pos.x,pos.y,siz.x,siz.y);

		if (debugger.debugDraw) debugDraw();
	}

	public void debugDraw() {

			float fontSize 	= CELL_SIZE / 4 * CELL_SIZE / 50.0f;
			float indent 	= CELL_SIZE / 8;
			float weight 	= CELL_SIZE / 16;

			canvas.fill(255,255,255,200);
			canvas.textAlign(LEFT);
			canvas.textSize(fontSize);
			canvas.text("ID:" + id,pos.x+indent,pos.y + CELL_SIZE / 3.5f);
			canvas.text("X:" + floor(pos.x),pos.x+indent,pos.y + CELL_SIZE / 1.7f);
			canvas.text("Y:" + floor(pos.y),pos.x+indent,pos.y + CELL_SIZE / 1.1f);

			canvas.stroke(255,255,255,50);
			canvas.strokeWeight(weight);
			canvas.rect(pos.x,pos.y,siz.x,siz.y);
	}
}
class TrailParticle {

	PVector pos;
	float lifeTime, siz, origSiz;
	int col, alp;
	boolean remove;


	TrailParticle(PVector _pos, float _siz, int _col) {
		pos = _pos;
		origSiz = _siz;
		siz = _siz;
		col = _col;
		alp = 255;
		remove = false;
	}

	public void update() {
		if (siz > 0) siz--;
		else remove = true;
		alp = (int)map(siz,0,origSiz,0,255);
		draw();
	}

	public void draw() {
		canvas.rectMode(CENTER);
		canvas.noFill();
		canvas.strokeWeight(1);
		canvas.stroke(col,alp);
		canvas.rect(pos.x,pos.y,siz,siz);
	}
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "QUADCORE" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
