import flash.display.Shape;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Point;

class Blip extends Shape {
	private var target:DisplayObject;
	private var arena:DisplayObject;
	private var scale:Float;

	public function new(target:DisplayObject, arena:DisplayObject, scale:Float = 1, color:Int = 0xff0000) {
		super();
		this.target = target;
		this.arena = arena;
		this.scale = scale;

		graphics.beginFill(color);
		graphics.drawRect(-2.5, -2.5, 5, 5);
		graphics.endFill();
		this.alpha = 5;

		// Setup redraw
		addEventListener(Event.ENTER_FRAME, handleEnterFrame);
	}

	private function handleEnterFrame(e:Event):Void {
		x = target.x * scale;
		y = target.y * scale;
	}
}
