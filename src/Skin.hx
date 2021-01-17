import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Assets;

class Skin {
	// Tile array
	public var tile:Array<BitmapData> = new Array<BitmapData>();

	public function new(tileWidth:Int, tileHeight:Int) {
		// Load the embedded skin
		var skinBitmap:Bitmap = new Bitmap(Assets.getBitmapData('assets/worn_track.jpg'));

		// Find the number of tiles
		var tilesX:Int = Std.int(skinBitmap.width / tileWidth);
		var tilesY:Int = Std.int(skinBitmap.height / tileHeight);

		// Chop it up
		for (y in 0...tilesY) {
			for (x in 0...tilesX) {
				var i:Int = Std.int((tilesX * y) + x);
				tile[i] = new BitmapData(tileWidth, tileHeight);
				tile[i].copyPixels(skinBitmap.bitmapData, new Rectangle(x * tileWidth, y * tileHeight, tileWidth, tileHeight), new Point(0, 0));
			}
		}
	}
}
