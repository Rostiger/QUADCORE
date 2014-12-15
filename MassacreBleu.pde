
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

GameManager gManager = new GameManager();
ObjectManager oManager = new ObjectManager();
Colors colors = new Colors();
LevelParser levelParser = new LevelParser();
Debugger debugger;
Hud hud;
Collision collision;

PGraphics canvas;
PFont font;
PFont debugFont;

ArrayList < PImage > levelList;  

float WIN_WIDTH;			// stores the width of the display resolution
float WIN_HEIGHT;			// stores the height of the display resolution		
float WIN_SCALE = 0.8;		// window scale factor - set to 1 for non-windows fullscreen
float VIEW_WIDTH;			// width of the game area
float VIEW_HEIGHT;			// height of the game area
float CELL_SIZE;			// size of a single tile
float dt;					// this value is initialised and update in the GameManager() class
float dtInSeconds;
float FONT_SIZE;
float DEBUG_FONT_SIZE;
float ARENA_BORDER;
boolean TOP_VIEW = false;		// playing on the hansG?
PVector canvasPos;				// canvas position
color bgColor = #000000;

Shake screenShake = new Shake();

void setup() {

	// get the width of the current display and set the height so it's a 4:3 ratio
	WIN_HEIGHT = 768 * WIN_SCALE;	
	WIN_WIDTH = ceil(WIN_HEIGHT * 1.333);
	// WIN_WIDTH = WIN_HEIGHT;

	FONT_SIZE = ceil(WIN_WIDTH * 0.03);
	DEBUG_FONT_SIZE = ceil(WIN_WIDTH * 0.02);
	ARENA_BORDER = WIN_WIDTH * 0.04;
	println("WIN_WIDTH: "+WIN_WIDTH);
	println("WIN_HEIGHT: "+WIN_HEIGHT);

	// setup the window and renderer
	size((int)WIN_WIDTH,(int)WIN_HEIGHT,P2D);
	frameRate(30);

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

	//load the font files
	font = createFont("DS-DIGIB.TTF",128,false);
	debugFont = createFont("victor-pixel.ttf",32,false);

	// reset the game
	gManager.reset();

	// set up a canvas to draw onto
	canvas = createGraphics((int)VIEW_WIDTH,(int)VIEW_HEIGHT);
	canvasPos = new PVector(WIN_WIDTH / 2 - VIEW_WIDTH / 2, ARENA_BORDER);

	// initialise the debugger
	debugger = new Debugger();
}

void draw() {
	if (screenShake.isShaking) {
		screenShake.update();
		canvasPos.add(screenShake.offset);
	}
	noCursor();
	background(bgColor);
	textFont(font);
	canvas.beginDraw();
	canvas.background(colors.bg);
	canvas.textFont(font);
	image(canvas,canvasPos.x,canvasPos.y);
	gManager.update();
	canvas.endDraw();
	textFont(debugFont);
	debugger.update();
}

void keyPressed() {
	debugger.keyPressed();
	if (!gManager.debug) oManager.keyPressed();
	
}

void keyReleased() {
	debugger.keyReleased();
	if (!gManager.debug) oManager.keyReleased();
}

boolean sketchFullScreen() {
	// sets the sketch to true fullscreen
	if (WIN_SCALE == 1.0) return true;
	else return false;
}

float ease(float _currentValue, float _startValue, float _targetValue, float _easingFactor) {
	// this function eases a _startValue towards a _targetValue using an _easingFactor
	// if pulse is true, the function reverses back to the _startValue using the _easingFactor as well

	float normedValue = norm(_currentValue, _startValue, _targetValue);
	float easedValue = pow(normedValue, _easingFactor);
	return map(easedValue,0,1,_startValue,_targetValue);
}