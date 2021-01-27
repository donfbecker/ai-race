package drivers;

import cars.Car;

class DragDriver {
	private var car:Car;

	private var lastTick:Int = 0;
	private var thisTick:Int = 0;

	public function new(track:Track, car:Car) {
		this.car = car;
		lastTick = Math.round(haxe.Timer.stamp() * 1000);
	}

	public function tick():Void {
		car.tick(true, false, false, false, false);

		if (car.speed >= 60 && thisTick == 0) {
			thisTick = Math.round(haxe.Timer.stamp() * 1000);
			trace("0 to 60 in " + ((thisTick - lastTick) / 1000) + "sec");
		}
	}
}
