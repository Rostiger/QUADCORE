//  ██████╗ ██╗   ██╗ █████╗ ██████╗  ██████╗ ██████╗ ██████╗ ███████╗
// ██╔═══██╗██║   ██║██╔══██╗██╔══██╗██╔════╝██╔═══██╗██╔══██╗██╔════╝
// ██║   ██║██║   ██║███████║██║  ██║██║     ██║   ██║██████╔╝█████╗  
// ██║▄▄ ██║██║   ██║██╔══██║██║  ██║██║     ██║   ██║██╔══██╗██╔══╝  
// ╚██████╔╝╚██████╔╝██║  ██║██████╔╝╚██████╗╚██████╔╝██║  ██║███████╗
//  ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
 
import java.util.Arrays;				// import the java array class for level loading			
import ddf.minim.*;						// import the sound library
import org.gamecontrolplus.gui.*;		// import the gui library for configuring the gamepads
import org.gamecontrolplus.*;			// import the gamepad library
import net.java.games.input.*;			// import the input library

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

GameManager 	gManager = new GameManager();		// handles the main game loop
ObjectManager 	oManager = new ObjectManager();		// updates/resets/deletes/etc. all game objects (players.bullets, etc.)
Colors 			colors = new Colors();				// color schemes are stored here
LevelParser 	levelParser = new LevelParser();	// parses levels from gifs!
Menu menu;											// contains menu logic
Debugger debugger;									// for debugging stuff!
Hud hud;											// manages the hud
Collision collision;								// 'calculates' collisions

PGraphics canvas;
PFont font;
PFont debugFont;

ArrayList < PImage > levelList; 
PImage  lg1, lg2;

// global variables
int 	WIN_WIDTH;				// stores the width of the display resolution
int 	WIN_HEIGHT;				// stores the height of the display resolution		
float 	WIN_SCALE = 0.8;		// window scale factor - set to 1 for non-windows fullscreen
int 	VIEW_WIDTH;				// width of the game area
int 	VIEW_HEIGHT;			// height of the game area
int 	CELL_SIZE;				// size of a single tile
float dt;						// delta time like the pros do!
float dtInSeconds;				// actual delta time in seconds
int FONT_SIZE;
int DEBUG_FONT_SIZE;
int ARENA_BORDER;
boolean TOP_VIEW = false;		// is the screen on the floor?
boolean SHADERS = false;			// experimental performance killer
int SHADER_INTENSITY = 150;
int COLOR_SCHEME = 1;
PVector canvasPos, canvasCen;
color bgColor = #000000;
float version = 0.5;

float gridSize = 32 * WIN_SCALE;

Shake screenShake = new Shake();	// camera shake!
Blink blink = new Blink();			// class for blinking stuff

//post processing variables
PShader blur;
PGraphics pass1, pass2;

void setup() {

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
    if (SHADERS) {
		blur = loadShader("data/blur.glsl");
		blur.set("blurSize", 3);
		blur.set("sigma", 20.f);

		pass1 = createGraphics(width, height, P2D);
		pass1.noSmooth();  

		pass2 = createGraphics(width, height, P2D);
		pass2.noSmooth();
    }
}

void draw() {
	// the main draw loop - this is where the magic happens!
	noCursor();
	background(bgColor);
	textFont(font);

	// update the screen shaker class
	if (screenShake.isShaking) {
		screenShake.update();
		canvasCen.add(screenShake.offset);
	}

	noStroke();
	imageMode(CENTER);
  	image( canvas, canvasCen.x, canvasCen.y	);

  	// the game is drawn onto a new canvas to be able to manipulate the image size and apply shaders
	canvas.beginDraw();
	canvas.background(colors.bg);
	canvas.textFont(font);
	gManager.update();
	canvas.endDraw();

	// here the canvas is actually displayed
	noStroke();
	fill(0,0,0,255);
	rectMode(CORNER);
	rect(0,0,canvasPos.x - ARENA_BORDER,WIN_HEIGHT);
	rect(canvasPos.x + VIEW_WIDTH + ARENA_BORDER, 0, canvasPos.x, WIN_HEIGHT);

	// now the shaders are applied
	if (SHADERS) postProcessing();

	textFont(debugFont);
	debugger.update();
}

void postProcessing() {
	// this is some very experimental code for appliying a bloom like shader
	// it eats most of the game's performance, so I reccomend using it with caution
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

	tint(255, SHADER_INTENSITY);
	blendMode(SCREEN);
 	image(pass2, 0, 0);
 	noTint();

	blendMode(MULTIPLY);
 	image(pass2, 0, 0);
	blendMode(BLEND);

	tint(255, 255 - SHADER_INTENSITY);
	image(pass2, 0, 0);
	noTint();
}

void keyPressed() {
	// update any and all key presses
	debugger.keyPressed();
	if (!gManager.debug) oManager.keyPressed();
	if (menu.active) menu.keyPressed();
}

void keyReleased() {
	// update any and all key releases
	debugger.keyReleased();
	if (!gManager.debug) oManager.keyReleased();
	if (menu.active) menu.keyReleased();
	
	if (key == '[') {
		if (WIN_SCALE == 1.0) WIN_SCALE = 0.8;
		else WIN_SCALE = 1.0;
		setupWindow();
		sketchFullScreen();
		gManager.reset();
		menu = new Menu();
	}
}

void settings() {
	// setup the window and renderer
	if (WIN_SCALE == 1.0) fullScreen();
	else size(ceil(768 * WIN_SCALE * 1.333),ceil(768 * WIN_SCALE),P2D);	
}

void setupWindow() {
	// get the width of the current display and set the height so it's a 4:3 ratio
	WIN_HEIGHT 	= ceil(768 * WIN_SCALE);	
	WIN_WIDTH 	= ceil(WIN_HEIGHT * 1.333);
	ARENA_BORDER = ceil(WIN_HEIGHT * 0.063);
	FONT_SIZE = ceil(WIN_HEIGHT * 0.04);
	DEBUG_FONT_SIZE = ceil(WIN_WIDTH * 0.02);
}

void initGamePads() {
	// GAMEPAD
	// Initialise the ControlIO
	control = ControlIO.getInstance(this);
	// check how many devices are found
	int numberOfDevices = control.getNumberOfDevices();
	// load configurations for different controllers
	Configuration ps3 = Configuration.makeConfiguration(this,"ps3");
	Configuration ps3win = Configuration.makeConfiguration(this,"ps3win");
	Configuration xBoxWireless = Configuration.makeConfiguration(this,"XBOXWireless");
	Configuration nes = Configuration.makeConfiguration(this,"nes");
	// step through the number of devices and see if any of the devices match one of the configurations
	for (int i=0;i<numberOfDevices;i++) {
		ControlDevice device = control.getDevice(i);
		// if the configuration matches, add the device
		if (device.matches(ps3) || device.matches(xBoxWireless) || device.matches(nes)) gPads.add(device);
		else device.close();
	}
}

void printDebug() {
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

void loadLevels() {
	// LEVELS
	// this method searches the levels folder for .gif files and stores them in
	// an array list called 'leveLList'
	// you can easily add new levels by adding new images to the levels folder
	// make sure the level image is stored as a .gif, otherwise it won't be parsed
	// the level parser checks the pixel colors and adds according objects, so 
	// make sure you are using the same colored pixels when adding new levels

	File f = new File(dataPath("levels/")); 
	ArrayList < String > filesInFolder = new ArrayList < String >(Arrays.asList(f.list()));

	// create a list holding images
	levelList = new ArrayList < PImage >();
	
	// step through each file in the levels folder
	for (int i=0;i<filesInFolder.size();i++) {

		String currentLevelFile = filesInFolder.get(i);
		
		// check if the file ends with .gif
		if (currentLevelFile.toLowerCase().contains(".gif")) {
			// put together a string twith the path and filename (foldername/levelname.gif)
			String fileName = f.getPath() + "/" + currentLevelFile;
			// load the image
			PImage level = loadImage(fileName);
			// add the image to the levels list
			levelList.add(level);
		}
	}	
}

void loadSounds() {
	//SOUNDS
	// initialise sound library
	minim = new Minim(this);
	bulletHit01 		= minim.loadSample("sounds/bulletHit01.wav",512);
	capture01 			= minim.loadSample("sounds/capture01.wav",512);
	die01 				= minim.loadSample("sounds/die01.wav",512);
	hurt01 				= minim.loadSample("sounds/hurt01.wav",512);
	shot01 				= minim.loadSample("sounds/shot01.wav",512);
	shot02 				= minim.loadSample("sounds/spawn01.wav",512);
	multiShot01 		= minim.loadSample("sounds/multiShot01.wav",512);
	spawn01 			= minim.loadSample("sounds/spawn01.wav",512);
	boost01 			= minim.loadSample("sounds/boost01.wav",512);
	powerUpSpawn01 		= minim.loadSample("sounds/powerUpSpawn01.wav",512);
	powerUpGet01 		= minim.loadSample("sounds/powerUpGet01.wav",512);
	lockDown01 			= minim.loadSample("sounds/lockDown01.wav",512);
	lockDownStopAlert01 = minim.loadSample("sounds/lockDownStopAlert01.wav",512);
	lockDownStop01 		= minim.loadSample("sounds/lockDownStop01.wav",512);
}

void loadTextures() {
	// load textures
	lg1 = loadImage("images/logo_zamSpielen.png");
}

void loadFonts() {
	//load the font files
	font = createFont("DS-DIGIB.TTF",128,false);
	debugFont = createFont("victor-pixel.ttf",32,false);
}
