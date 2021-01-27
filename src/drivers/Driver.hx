package drivers;

import flash.geom.Point;

import cars.Car;

class Driver {
	private var track:Track;
	private var car:Car;

	private var fx:Int = 225;
	private var fy:Int = 160;
	private var lead:Float = 0;

	public function new(track:Track, car:Car) {
		this.car = car;
		this.lead = Math.random() * 10;
	}

	public function tick():Void {
		var up:Bool = true;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;
		var space:Bool = false;

		var p:Point = new Point(100, 0);

		p.x = fx + (car.speedP * lead);
		p.y = 0;
		p = car.localToGlobal(p);
		if (!car.track.hitTestPoint(p.x, p.y, true)) {
			up = false;
		}

		p.x = fx;
		p.y = -fy;
		p = car.localToGlobal(p);
		if (car.track.hitTestPoint(p.x, p.y, true)) {
			left = true;
		}

		p.x = fx;
		p.y = fy;
		p = car.localToGlobal(p);
		if (car.track.hitTestPoint(p.x, p.y, true)) {
			right = true;
		}

		//car.graphics.clear();
		//car.graphics.beginFill(0xFF0000);
		//car.graphics.drawCircle(fx + (car.speedP * lead), 0, 3);
		//car.graphics.drawCircle(fx, -fy, 3);
		//car.graphics.drawCircle(fx, fy, 3);
		//car.graphics.endFill();

		car.tick(up, down, left, right, space);
	}
}
