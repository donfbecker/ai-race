import flash.display.Shape;
import flash.events.Event;
import flash.geom.Point;

class Blip extends Shape {
	private var target:Dynamic;
	private var arena:Dynamic;
	private var scale:Float;

	public function new(target:Dynamic, arena:Dynamic, scale:Float = 1, color:Int = 0xff0000) {
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
		var tp:Point = target.localToGlobal(new Point(0, 0));
		var ap:Point = arena.localToGlobal(new Point(0, 0));
		x = (tp.x - ap.x) * scale;
		y = (tp.y - ap.y) * scale;
	}
}
