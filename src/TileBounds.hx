import flash.display.MovieClip;
import flash.geom.ColorTransform;

class TileBounds extends MovieClip {
	public function new(tile:Int, color:Int = 0, scale:Float = 1) {
		super();
		gotoAndStop(tile);
		var ct:ColorTransform = transform.colorTransform;
		ct.color = color;
		transform.colorTransform = ct;
		scaleX = scale;
		scaleY = scale;
	}
}
