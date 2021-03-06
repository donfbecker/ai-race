package cars;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Point;

import openfl.Assets;

class SimpleCar extends Sprite {
	// Sprite
	private var carSprite:Bitmap = new Bitmap(Assets.getBitmapData('assets/car.png'));

	// track and movement variables
	public var track:Sprite;

	private var ontrack:Bool;
	private var target:Sprite;

	// Constants
	private var ToRad(default, never):Float = (Math.PI / 180);
	private var IPP:Float = 160 / 62;
	private var FPP:Float;
	private var MPP:Float;

	// Car constants
	private var acceleration(default, never):Float = 0.4;
	private var deceleration(default, never):Float = 0.96;
	private var maxspeed(default, never):Int = 20;
	private var revspeed(default, never):Int = 5;

	// Variables
	public var speed:Float = 0;
	public var speedP:Float = 0;

	public function new(track:Sprite, ontrack:Bool = true, target:Sprite = null) {
		super();
		FPP = IPP / 12;
		MPP = FPP / 5280;

		// Save parameters
		this.track = track;
		this.ontrack = ontrack;
		this.target = target;

		// Draw the sprite
		carSprite.x = -10;
		carSprite.y = -15;
		addChild(carSprite);
	}

	public function tick(up:Bool = false, down:Bool = false, left:Bool = false, right:Bool = false, space:Bool = false):Void {
		if (up) {
			speedP += acceleration;
			if (speedP > maxspeed) {
				speedP = maxspeed;
			}
		} else if (down) {
			speedP -= revspeed;
			if (speedP < -revspeed) {
				speedP = -revspeed;
			}
		} else if (speedP > 0.3) {
			speedP *= deceleration;
		} else {
			speedP = 0;
		}

		// Steering wheel
		if (left) {
			rotation -= 5 * (speedP / maxspeed);
			speedP *= 0.97;
		}
		if (right) {
			rotation += 5 * (speedP / maxspeed);
			speedP *= 0.97;
		}

		if (speedP != 0) {
			var collision:Bool = false;
			var p:Point = new Point();

			var xspeed:Float = Math.cos(rotation * (Math.PI / 180)) * speedP;
			var yspeed:Float = Math.sin(rotation * (Math.PI / 180)) * speedP;

			var j:Int = -12;
			while (j <= 12) {
				p.x = ((speedP > 0) ? 28 : -28);
				p.y = j;
				p = localToGlobal(p);
				if (track.hitTestPoint(p.x + xspeed, p.y + yspeed, true) != ontrack) {
					if (j < 0) {
						rotation += 5 * (speedP / maxspeed);
					}
					if (j > 0) {
						rotation -= 5 * (speedP / maxspeed);
					}
					speedP *= 0.75;
					collision = true;
				}
				j += 12;
			}

			// Collision?
			if (!collision) {
				// Move

				x += xspeed;
				y += yspeed;
			}
		}

		// Save MPH
		speed = Math.floor((speedP * 3600) / 0.033 * MPP);
	}
}
