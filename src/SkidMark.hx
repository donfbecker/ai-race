import flash.display.Shape;
import flash.events.Event;

class SkidMark extends Shape {
	private var life(default, never):Int = 30;
	private var age:Int = 0;

	private var x1:Int = 0;
	private var x2:Int = 0;
	private var y1:Int = 0;
	private var y2:Int = 0;

	public function new(x1:Int, y1:Int, x2:Int, y2:Int) {
		super();
		this.x1 = x1;
		this.x2 = x2;
		this.y1 = y1;
		this.y2 = y2;

		// Draw first frame
		handleEnterFrame(null);

		// Setup redraw
		addEventListener(Event.ENTER_FRAME, handleEnterFrame);
	}

	private function handleEnterFrame(evt:Event):Void {
		graphics.clear();
		graphics.lineStyle(4, 0x000000, (life - age) / life);
		graphics.moveTo(x1, y1);
		graphics.lineTo(x2, y2);

		if (age++ >= life) {
			if (parent != null) {
				parent.removeChild(this);
			}
			removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
	}
}
