import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

class Track extends Sprite {
	// Track layers
	public var layerSkin:Sprite = new Sprite();

	// Where to start
	public var startX:Int = 0;
	public var startY:Int = 0;
	
	// Path checkpoints
	public var checkpoints:Array<Array<Int>>;

	// Radar
	public var radar:Sprite = new Sprite();

	// Tiles
	private var skin:Skin;
	private var tiles:Array<Array<Int>>;
	private var tileWidth:Int;
	private var tileHeight:Int;
	private var tilesX:Int;
	private var tilesY:Int;

	public function new(tiles:Array<Array<Int>>, skin:Skin) {
		super();
		this.tiles      = tiles;
		this.skin       = skin;
		this.tileWidth  = skin.tileWidth;
		this.tileHeight = skin.tileHeight;

		// Figure out the track width and height
		tilesY = this.tiles.length;
		tilesX = this.tiles[0].length;

		// Put a black background on the radar
		radar.graphics.beginFill(0x000000);
		radar.graphics.drawRect(0, 0, tilesX * 10, tilesY * 10);
		radar.graphics.endFill();

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
				var t:SvgTile = new SvgTile(tiles[ty][tx], 0xffffff, 1 / 30);
				t.x = tx * 10;
				t.y = ty * 10;
				radar.addChild(t);

				// Check for where we should start the car
				if (!foundStart && tiles[ty][tx] == 7) {
					foundStart = true;
					startX = tx;
					startY = ty;
				}
			}
		}

		// Add the layers
		addChild(layerSkin);

		checkpoints = findPath();
	}

	override public function hitTestPoint(x:Float, y:Float, shapeFlag:Bool = false):Bool {
		var p:Point = new Point(x, y);
		p = this.globalToLocal(p);

		var tx:Int = Std.int(p.x / this.tileWidth);
		var ty:Int = Std.int(p.y / this.tileHeight);

		if(tx < 0) return false;
		if(ty < 0) return false;
		if(ty >= this.tiles.length) return false;
		if(tx >= this.tiles[ty].length) return false;

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

	public function getTileXY(x:Float, y:Float):Array<Int> {
		return [Std.int(x / tileWidth), Std.int(y / tileHeight)];
	}

	public function findPath():Array<Array<Int>> {
		var neighbors:Array<Array<Array<Int>>> = [
			[], // Tile 0 (unused)
			[], // Tile 1
			[], // Tile 2
			[], // Tile 3
			[], // Tile 4
			[[-1, 1], [1, 0]], // Tile 5
			[[-1, 0], [1, 1]], // Tile 6
			[[-1, 0], [1, 0]], // Tile 7
			[[0, -1], [0, 1]], // Tile 8
			[[-1, 1], [1, -1]], // Tile 9
			[[-1, -1], [1, 1]], // Tile 10
			[[-1, -1], [1, 0]], // Tile 11
			[[-1, 0], [1, -1]], // Tile 12
			[[0, 1], [1, 0]], // Tile 13
			[[-1, 0], [0, 1]], // Tile 14
			[], // Tile 15
			[], // Tile 16
			[[0, 1], [1, -1]], // Tile 17
			[[-1, -1], [0, 1]], // Tile 18
			[[0, -1], [1, 0]], // Tile 19
			[[-1, 0], [0, -1]], // Tile 20
			[], // Tile 21
			[], // Tile 22
			[[0, -1], [1, 1]], // Tile 23
			[[-1, 1], [0, -1]] // Tile 24
		];

		var path:Array<Array<Int>> = new Array<Array<Int>>();

		// The first tile will always be the starting tile
		var lastX:Int = startX;
		var lastY:Int = startY;
		var currX:Int = startX + 1;
		var currY:Int = startY;

		do {
			path.push([currX, currY]);
			var dX:Int = lastX - currX;
			var dY:Int = lastY - currY;
			var tile:Int = this.tiles[currY][currX];

			var next:Array<Int> = (dX == neighbors[tile][0][0] && dY == neighbors[tile][0][1]) ? neighbors[tile][1] : neighbors[tile][0];

			lastX = currX;
			lastY = currY;
			currX = currX + next[0];
			currY = currY + next[1];
		} while(lastX != startX || lastY != startY);

		return path;
	}
}
