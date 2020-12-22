import flash.errors.Error;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import format.SVG;
import openfl.Assets;

class TileBoundsSvg extends Sprite {
	public function new(tile:Int, color:Int = 0, scale:Float = 1) {
		super();

		try {
			var svg:SVG = new SVG(Assets.getText("assets/tiles/tile" + tile + ".svg"));
			var t:Sprite = new Sprite();
			svg.render(t.graphics);

			var ct:ColorTransform = t.transform.colorTransform;
			ct.color = color;
			t.transform.colorTransform = ct;
			t.scaleX = scale;
			t.scaleY = scale;

			addChild(t);
		} catch (error:Error) {
			trace(error);
		}
	}
}
