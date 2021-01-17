import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Point;
import openfl.Assets;

class Car extends Sprite {
	// Sprite
	public var CarSprite:Bitmap = new Bitmap(Assets.getBitmapData('assets/car.png'));

	// track and movement variables
	public var track:Sprite;
	public var onTrack:Bool;
	public var halfX:Float;
	public var halfY:Float;
	public var opponent:Array<Car>;

	// Constants
	public var ToRad:Float = (Math.PI / 180);
	public var ToDeg:Float = (180 / Math.PI);
	public var IPP:Float = 160 / 62;
	public var FPP:Float = (160 / 62) / 12;
	public var MPP:Float = (((160 / 62) / 12) / 5280);

	// Public vars
	public var speed:Float = 0;
	public var speedP:Float = 0;
	public var velocity:GeometryVector = new GeometryVector(0, 0);

	// Private vars
	private var speedR:Float = 0;
	private var stick:Float = 1.3;
	private var gear:Int = 0;
	private var gearAr:Array<Int> = [0, 20, 40, 60, 80, 100, 9999];
	private var pickupAr:Array<Float> = [.6, .5, .4, .3, .2, .1, 0];
	private var idle:Float = 0.00;
	private var wheelRot:Float = 1 * (Math.PI / 180);
	private var collisionPoint:Array<Int> = [0, -12, 12];

	// Variables for AI
	public var distanceTraveled:Float = 0;
	public var hitWall:Bool = false;

	public function new(track:Sprite, opponent:Array<Car> = null, spriteBitmap:Bitmap = null) {
		super();

		// Save parameters
		this.track = track;
		this.opponent = opponent;

		// Draw the sprite
		if (spriteBitmap == null) {
			spriteBitmap = CarSprite;
		}

		halfX = spriteBitmap.width / 2;
		halfY = spriteBitmap.height / 2;
		spriteBitmap.x = -halfX;
		spriteBitmap.y = -halfY;
		addChild(spriteBitmap);
	}

	public function tick(up:Bool = false, down:Bool = false, left:Bool = false, right:Bool = false, space:Bool = false):Void {
		// find gear
		while (speed < this.gearAr[gear] && gear > 0) {
			gear--;
		}

		while (speed > this.gearAr[gear + 1]) {
			gear++;
		}

		// acceleration
		var accel:Int = 0;
		if (up) {
			accel = 1;
		} else if (down) {
			accel = -1;
		}
		velocity.x += (accel + idle) * pickupAr[gear] * Math.cos(rotation * ToRad);
		velocity.y += (accel + idle) * pickupAr[gear] * Math.sin(rotation * ToRad);

		// Which way are we going?
		var carDir:GeometryVector = new GeometryVector(Math.cos(rotation * ToRad), Math.sin(rotation * ToRad));
		var velInCarDir:GeometryVector = velocity.projection(carDir);

		// steering
		var r:Float = 0;
		var d:Float = carDir.dot(velocity);
		if (left) {
			r = ((d >= 0) ? -1 : 1);
		}
		if (right) {
			r = ((d >= 0) ? 1 : -1);
		}
		if (r == 0 && speedR != 0) {
			r = (speedR > 0) ? -1 : 1;
		}
		speedR = ((r > 0) ? Math.min(Math.min((space) ? 7 : 5, speedR + r), speedP) : Math.max(Math.max((space) ? -7 : -5, speedR + r), -speedP));
		rotation += speedR;

		// subtract stiction
		var stickVec:GeometryVector;
		if (!space) {
			var stickDir:GeometryVector = new GeometryVector(Math.cos((rotation + 90) * ToRad), Math.sin((rotation + 90) * ToRad));
			stickVec = velocity.neg().projection(stickDir);
		} else {
			stickVec = velocity.neg();
		}
		var maxStickMag:Float = stickVec.getMag();
		if ((stickVec.x != 0 || stickVec.y != 0) && stickVec.getMag() > stick) {
			stickVec.setMag(stick);
		}
		if (stickVec.getMag() > maxStickMag) {
			stickVec.setMag(maxStickMag);
		}

		// Move it
		velocity.addVec(stickVec);
		x += velocity.x;
		y += velocity.y;

		velocity.x *= 0.995;
		velocity.y *= 0.995;

		speedP = velocity.getMag();
		distanceTraveled += speedP * (d >= 0 ? 1 : -1);
		speed = Math.floor(((speedP / 0.033) * 3600) * MPP);

		// Don't idle forward
		if (!up && !down && speedP <= 0.5) {
			velocity = new GeometryVector(0, 0);
		}

		// Check for collisions with wall and opponents
		var p:Point = new Point();
		for (c in 0...3) {
			p.x = ((d < 0) ? -halfX : halfX);
			p.y = collisionPoint[c];
			p = this.localToGlobal(p);
			if (!track.hitTestPoint(p.x, p.y, true)) {
				hitWall = true;
				x -= velocity.x;
				y -= velocity.y;
				if (c == 0) {
					velocity = velocity.neg();
					velocity.x *= 0.5;
					velocity.y *= 0.5;
				} else {
					if (c == 1) {
						rotation += 5;
					}
					if (c == 2) {
						rotation -= 5;
					}
					velocity.setRot(rotation * ToRad);
				}
				velocity.x *= 0.85;
				velocity.y *= 0.85;
				break;
			}
		}
	}
}
