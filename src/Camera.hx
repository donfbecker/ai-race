import openfl.display.DisplayObject;
import flash.display.Stage;
import flash.geom.Point;

class Camera {
	private var stage:Stage;
	private var arena:DisplayObject;
	public var target(default, null):DisplayObject;

	public function new(stage:Stage, arena:DisplayObject, target:DisplayObject = null) {
		this.stage = stage;
		this.arena = arena;
		this.target = target;
	}

	public function setTarget(target:DisplayObject):Void {
		this.target = target;
	}

	public function tick():Void {
		var x:Float;
		var y:Float;
		var p:Point = target.localToGlobal(new Point(0, 0));

		if(arena.width > stage.stageWidth) {
			x = arena.x - (p.x - (stage.stageWidth / 2));
			if (x > 0) x = 0;
			if (x < -(arena.width - stage.stageWidth)) {
				x = -(arena.width - stage.stageWidth);
			}
		} else {
			x = (stage.stageWidth - arena.width) / 2;
		}

		if(arena.height > stage.stageHeight) {
			y = arena.y - (p.y - (stage.stageHeight / 2));
			if (y > 0) y = 0;
			if (y < -(arena.height - stage.stageHeight)) {
				y = -(arena.height - stage.stageHeight);
			}
		} else {
			y = (stage.stageHeight - arena.height) / 2;
		}

		arena.x = x;
		arena.y = y;
	}

	public function zoomIn():Void {
		arena.scaleX *= 1.5;
		arena.scaleY *= 1.5;
	}

	public function zoomOut():Void {
		arena.scaleX /= 1.5;
		arena.scaleY /= 1.5;
	}
}
