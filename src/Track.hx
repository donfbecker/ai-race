import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

class Track extends Sprite {
	// Track layers
	public var layerSkin(default, never):Sprite = new Sprite();

	// Where to start
	public var startx:Int = 0;
	public var starty:Int = 0;

	// Radar
	public var radar(default, never):Sprite = new Sprite();

	// Tiles
	private var skin:Skin;
	private var tiles:Array<Array<Int>>;
	private var tileWidth:Int;
	private var tileHeight:Int;
	private var tilesX:Int;
	private var tilesY:Int;

	public function new(tiles:Array<Array<Int>>, tileWidth:Int, tileHeight:Int) {
		super();
		this.tiles = tiles;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;

		// Figure out the track width and height
		tilesY = this.tiles.length;
		tilesX = this.tiles[0].length;

		// Put a black background on the radar
		radar.graphics.beginFill(0x000000);
		radar.graphics.drawRect(0, 0, tilesX * 10, tilesY * 10);
		radar.graphics.endFill();

		// Create the skin
		skin = new Skin(tileWidth, tileHeight);

		// Mask layer for debugging
		/*
			var mx:int = tileWidth * this.tilesX;
			var my:int = tileHeight * this.tilesY;
			trace(mx + 'x' + my);
			for (var y:int = 0; y < my; y++) {
				//trace('Checking ' + y);
				for (var x:int = 0; x < mx; x++) {
					if (this.hitTestPoint(x, y, false)) {
						var dtx:int = int(x / 300);
						var dty:int = int(y / 300);
						BitmapData(skin.tile[this.tiles[dty][dtx] - 1]).setPixel(x % 300, y % 300, 0);
					}
				}
			}
		 */

		// Generate the map and radar
		var foundStart:Bool = false;
		for (ty in 0...tilesY) {
			for (tx in 0...tilesX) {
				// Skinned tile
				var b:Bitmap = new Bitmap(skin.tile[tiles[ty][tx] - 1]);
				b.x = tx * tileWidth;
				b.y = ty * tileHeight;
				layerSkin.addChild(b);

				// Radar
				var t:TileBoundsSvg = new TileBoundsSvg(tiles[ty][tx], 0xffffff, 1 / 30);
				t.x = tx * 10;
				t.y = ty * 10;
				radar.addChild(t);

				// Check for where we should start the car
				if (!foundStart && tiles[ty][tx] == 7) {
					foundStart = true;
					startx = tx;
					starty = ty;
				}
			}
		}

		// Add the layers
		addChild(layerSkin);
	}

	override public function hitTestPoint(x:Float, y:Float, shapeFlag:Bool = false):Bool {
		var p:Point = new Point(x, y);
		p = this.globalToLocal(p);

		var tx:Int = Std.int(p.x / this.tileWidth);
		var ty:Int = Std.int(p.y / this.tileHeight);
		if (this.tiles[ty] == null || this.tiles[ty][tx] == null) {
			return false;
		}

		x = p.x % this.tileWidth;
		y = p.y % this.tileHeight;

		var r:Int;

		switch (this.tiles[ty][tx]) {
			case 1: // blank tile
			case 2: // blank tile
				return false;

			case 3: // Lower right corner
				if (x > 390 - y)
					return true;
				return false;

			case 4: // Lower left corner
				if (x < y - 90)
					return true;
				return false;

			case 5: // Partial curve from lower left corner to right
				if (x <= 200 && y >= 100)
					return true;
				if (x >= 200 && y >= 10 && y <= 290)
					return true;
				if (x >= 200 && y >= 280 && x < 510 - y)
					return true;

				r = Std.int(Math.sqrt(((195 - x) * (195 - x)) + ((290 - y) * (290 - y))));
				if (x <= 200 && r > 10 && r < 280)
					return true;
				return false;

			case 6: // Partial curve from left to lower right corner
				if (x >= 90 && y >= 100)
					return true;
				if (x <= 100 && y >= 10 && y <= 290)
					return true;
				if (x <= 100 && y >= 280 && x > y - 210)
					return true;
				r = Std.int(Math.sqrt(((x - 105) * (x - 105)) + ((290 - y) * (290 - y))));
				if (x >= 100 && r >= 10 && r <= 280)
					return true;
				return false;

			case 7: // Horizontal strait away
				if (y >= 10 && y <= 290)
					return true;
				return false;

			case 8: // Vertical strait away
				if (x >= 10 && x <= 290)
					return true;
				return false;

			case 9: // Slant from lower left to upper right
				if (x >= 90 - y && x <= 510 - y)
					return true;
				return false;

			case 10: // Slant from left to lower rigth
				if (x < 210 + y && x > y - 210)
					return true;
				return false;

			case 11: // Partial curve from right to upper left corner
				if (x <= 200 && y <= 200)
					return true;
				if (x >= 200 && y >= 10 && y <= 290)
					return true;
				if (x >= 200 && y <= 20 && x < y + 210)
					return true;
				r = Std.int(Math.sqrt(((195 - x) * (195 - x)) + ((y - 10) * (y - 10))));
				if (x <= 200 && r >= 10 && r <= 280)
					return true;
				return false;

			case 12: // Partial curve from upper right corner to left
				if (x >= 100 && y <= 200)
					return true;
				if (x <= 100 && y >= 10 && y <= 290)
					return true;
				if (x <= 100 && y <= 10 && x > 90 - y)
					return true;
				r = Std.int(Math.sqrt(((x - 105) * (x - 105)) + ((y - 10) * (y - 10))));
				if (x >= 100 && r >= 10 && r <= 280)
					return true;
				return false;

			case 13: // Curve from bottom to right
				r = Std.int(Math.sqrt(((300 - x) * (300 - x)) + ((300 - y) * (300 - y))));
				if (r >= 10 && r <= 290)
					return true;
				return false;

			case 14: // Curve from left to bottom
				r = Std.int(Math.sqrt((x * x) + ((300 - y) * (300 - y))));
				if (r > 10 && r < 290)
					return true;
				return false;

			case 15: // Upper left and lower right corner
				if (x <= 210 - y)
					return true; // Upper left
				if (x >= 390 - y)
					return true; // Lower right
				return false;

			case 16: // Upper right and lower left corner
				if (x > 90 + y)
					return true; // Upper right
				if (x < y - 90)
					return true; // Lower left
				return false;

			case 17: // Partial curve from bottom to upper right corner
				if (x >= 100 && y <= 200)
					return true;
				if (x >= 10 && x <= 290 && y >= 200)
					return true;
				if (x >= 280 && y >= 200 && x < 510 - y)
					return true;
				r = Std.int(Math.sqrt(((290 - x) * (290 - x)) + ((195 - y) * (195 - y))));
				if (y <= 200 && r >= 10 && r <= 280)
					return true;
				return false;

			case 18: // Partial curve from upper left corner to bottom
				if (x <= 200 && y <= 200)
					return true;
				if (x >= 10 && x <= 290 && y >= 200)
					return true;
				if (x <= 20 && y >= 200 && x > y - 210)
					return true;
				r = Std.int(Math.sqrt(((x - 10) * (x - 10)) + ((195 - y) * (195 - y))));
				if (y <= 200 && r >= 10 && r <= 280)
					return true;
				return false;

			case 19: // Curve from right to top
				r = Std.int(Math.sqrt(((300 - x) * (300 - x)) + (y * y)));
				if (r > 10 && r < 290)
					return true;
				return false;

			case 20: // Curve from top to left
				r = Std.int(Math.sqrt((x * x) + (y * y)));
				if (r >= 10 && r <= 290)
					return true;
				return false;

			case 21: // Upper right corner
				if (x >= 90 + y)
					return true;
				return false;

			case 22: // Upper left corner
				if (x <= 210 - y)
					return true;
				return false;

			case 23: // Partial curve from lower right corner to top
				if (x >= 100 && y >= 100)
					return true;
				if (x >= 10 && x <= 290 && y <= 100)
					return true;
				if (x >= 280 && y <= 100 && x < y + 210)
					return true;
				r = Std.int(Math.sqrt(((290 - x) * (290 - x)) + ((y - 100) * (y - 100))));
				if (y >= 100 && r >= 10 && r <= 280)
					return true;
				return false;

			case 24: // Partial curve from top to lower left corner
				if (x <= 200 && y >= 100)
					return true;
				if (x >= 10 && x <= 290 && y <= 100)
					return true;
				if (x <= 20 && y <= 100 && x > 90 - y)
					return true;
				r = Std.int(Math.sqrt(((x - 10) * (x - 10)) + ((y - 100) * (y - 100))));
				if (y >= 100 && r >= 10 && r <= 280)
					return true;
				return false;
		}

		return false;
	}
}
