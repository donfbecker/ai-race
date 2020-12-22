import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.system.System;
import flash.text.TextField;
import flash.ui.Keyboard;

import flash.events.TimerEvent;
import flash.utils.Timer;

class Main extends Sprite {
	// Tile info
	private var tileWidth(default, never):Int = 300;
	private var tileHeight(default, never):Int = 300;

	// Setup an object for keyboard states
	private var key:Dynamic = {};

	// Sprite objects
	private var track:Track;
	private var speedometer:TextField;
	private var output:TextField;
	private var camera:Camera;
	private var car:Array<Car> = new Array<Car>();
	private var driver:Array<Driver> = new Array<Driver>();

	public function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	private function onAddedToStage(e:Event) {
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

		/*
			var trackTiles:Array = [
				[1, 2, 3, 4, 5, 6],
				[7, 8, 9, 10, 11, 12],
				[13, 14, 15, 16, 17, 18],
				[19, 20, 21, 22, 23, 24]
			];
		 */
		/*
			var trackTiles:Array<Array<Int>> = [
				[1, 1, 1, 1, 1, 1,1],
				[1,13, 7, 6, 4, 1,1],
				[1,23, 4,21,10, 4,1],
				[1,21,10, 4,21,18,1],
				[1, 1,21,11, 7,20,1],
				[1, 1, 1, 1, 1, 1,1],
			];
		*/
		/*
			var trackTiles:Array =  [
				[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
				[1,13,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,14,1],
				[1,19,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,20,1],
				[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
			];
		 */
		
		var trackTiles:Array<Array<Int>> = [
			[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
			[1, 1, 1, 1, 3, 5, 7, 7, 6, 4, 1, 1],
			[1, 1, 1, 1, 17, 22, 1, 1, 21, 11, 14, 1],
			[1, 1, 1, 1, 8, 1, 1, 1, 1, 1, 8, 1],
			[1, 13, 7, 7, 20, 1, 3, 5, 7, 7, 20, 1],
			[1, 23, 4, 1, 1, 3, 9, 22, 1, 1, 1, 1],
			[1, 21, 11, 7, 7, 12, 22, 1, 1, 1, 1, 1],
			[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
		];
		
		/*
			var trackTiles:Array<Array<Int>> =  [
				[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
				[1,13,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,14,1],
				[1,19,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,14,8,1],
				[1,13,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,20,8,1],
				[1,19,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,14,8,1],
				[1,13,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,20,8,1],
				[1,19,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,14,8,1],
				[1,13,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,20,8,1],
				[1,19,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,14,8,1],
				[1,13,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,20,8,1],
				[1,19,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,14,8,1],
				[1,13,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,20,8,1],
				[1,19,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,20,1],
				[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
			];
		*/
		/*
			var trackTiles:Array<Array<Int>> =  [
				[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
				[1,13,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,14,1],
				[1,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,1],
				[1,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,1],
				[1,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,1],
				[1,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,1],
				[1,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,1],
				[1,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,1],
				[1,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,1],
				[1,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,1],
				[1,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,1],
				[1,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,1],
				[1,19,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,20,1],
				[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
			];
		 */

		// Create a Sprite for the track
		track = new Track(trackTiles, tileWidth, tileHeight);
		track.x = -((track.startx - 1) * tileWidth) - ((stage.stageWidth - tileWidth) / 2);
		track.y = -(track.starty * tileHeight) + ((stage.stageHeight - tileHeight) / 2);
		addChild(track);

		// Add the mini radar
		track.radar.x = stage.stageWidth - track.radar.width;
		track.radar.y = 0;
		track.radar.alpha = 0.25;
		addChild(track.radar);

		// speedometer
		speedometer = new TextField();
		speedometer.textColor = 0xFFFFFF;
		speedometer.autoSize = "left";
		speedometer.text = "0 mph";
		addChild(speedometer);

		// Debug output
		output = new TextField();
		output.y = 20;
		output.textColor = 0xFFFFFF;
		output.autoSize = "left";
		addChild(output);

		// Add cars to the track
		for (i in 0...4) {
			car[i] = new Car(track, car);
			car[i].x = ((track.startx) * tileWidth) + (tileWidth / 2);
			car[i].y = ((track.starty) * tileHeight) + (tileHeight / 2) - 75 + (i * 50);
			if (i > 0) {
				driver[i] = new Driver(car[i], 2 + i);
			}
			track.addChild(car[i]);
			track.radar.addChild(new Blip(car[i], track, 1 / 30, (i > 0) ? 0xff0000 : 0x00ff00));
		}

		// Set camera to watch main car
		camera = new Camera(stage, track, car[0]);

		// Setup event handling
		//addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);

		var timer:Timer = new Timer(1000 / 30);
		timer.addEventListener(TimerEvent.TIMER, handleEnterFrame);
		timer.start();
	}

	// Setup keyboard listener
	private function handleEnterFrame(e:Event):Void {
		// Let the car handle its movement
		for (i in 0...4) {
			if (driver[i] != null) {
				driver[i].tick();
			} else {
				car[0].tick(key[Keyboard.UP], key[Keyboard.DOWN], key[Keyboard.LEFT], key[Keyboard.RIGHT], key[Keyboard.SPACE]);
			}
		}
		camera.tick();
		speedometer.text = cast(camera.target, Car).speed + "mph";
	}

	private function handleKeyDown(e:KeyboardEvent):Void {
		switch (e.keyCode) {
			case Keyboard.UP, Keyboard.DOWN, Keyboard.LEFT, Keyboard.RIGHT, Keyboard.SPACE:
				key[e.keyCode] = true;

			case Keyboard.NUMBER_1:
				camera.setTarget(car[0]);

			case Keyboard.NUMBER_2:
				camera.setTarget(car[1]);

			case Keyboard.NUMBER_3:
				camera.setTarget(car[2]);

			case Keyboard.NUMBER_4:
				camera.setTarget(car[3]);
		}
	}

	private function handleKeyUp(e:KeyboardEvent):Void {
		switch (e.keyCode) {
			case Keyboard.UP, Keyboard.DOWN, Keyboard.LEFT, Keyboard.RIGHT, Keyboard.SPACE:
				key[e.keyCode] = false;
		}
	}
}
