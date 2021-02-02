import haxe.display.Display.SignatureHelpParams;

class RandomTrack {
    private var nineties:Int = 100;
    private var width:Int = 20;
    private var height:Int = 15;
    private var tiles:Array<Array<Int>>;

    private var neighbors:Map<String, Array<Int>> = [
        'NW' => [-1, -1],
		'N'  => [ 0, -1],
		'NE' => [ 1, -1],
		'E'  => [ 1,  0],
		'SE' => [ 1,  1],
		'S'  => [ 0,  1],
		'SW' => [-1,  1],
		'W'  => [-1,  0]
    ];

    private var invert:Map<String, String> = [
        'NW' => 'SE',
		'N'  => 'S',
		'NE' => 'SW',
		'E'  => 'W',
		'SE' => 'NW',
		'S'  => 'N',
		'SW' => 'NE',
		'W'  => 'E'
    ];

    private var exits:Map<String, Array<String>> = [
        'NW' => ['E', 'SE', 'S'],
		'N'  => ['E', 'SE', 'S', 'SW', 'W'],
		'NE' => ['S', 'SW', 'W'],
		'E'  => ['S', 'SW', 'W', 'NW', 'N'],
		'SE' => ['W', 'NW', 'N'],
		'S'  => ['W', 'NW', 'N', 'NE', 'E'],
		'SW' => ['N', 'NE', 'E'],
		'W'  => ['N', 'NE', 'E', 'SE', 'S']
    ];

    private var exits_no_nineties:Map<String, Array<String>> = [
        'NW' => ['E', 'SE', 'S'],
		'N'  => ['SE', 'S', 'SW'],
		'NE' => ['S', 'SW', 'W'],
		'E'  => ['SW', 'W', 'NW'],
		'SE' => ['W', 'NW', 'N'],
		'S'  => ['NW', 'N', 'NE'],
		'SW' => ['N', 'NE', 'E'],
		'W'  => ['NE', 'E', 'SE']
    ];

    public function new(width:Int, height:Int, nineties:Int=100) {
        this.width = width;
        this.height = height;
        this.nineties = nineties;

        while(!generatePath()) {};
    }

    private function generatePath():Bool {
        // Create an empty tile array
        this.tiles = [];
        for(y in 0...this.height) {
            this.tiles[y] = [];
            for(x in 0...this.width) this.tiles[y][x] = 0;
        }

        // Pick a random place to start
        var start_x:Int = Math.round(Math.random() * (this.width - 1));
        var start_y:Int = Math.round(Math.random() * (this.height - 1));

        var x:Int = start_x;
        var y:Int = start_y;
        var last:String = null;
        var first:String = null;
        var step:Int = 1;

        do {
            var exits:Array<String> = getValidExits(x, y, last != null ? this.invert[last] : null);
			if(exits.length < 1) {
				return false;
			}
			var exit:String = exits[Math.round(Math.random() * (exits.length - 1))];

			this.tiles[y][x] = (last == null ? 0 : getTileIdForDirection(this.invert[last], exit));

            var v:Array<Int> = this.neighbors[exit];
			x += v[0];
            y += v[1];

			this.tiles[y][x] = 1;
			if(exit.length == 2) {
				// If we are moving on a diagonol, then block the corners
				this.tiles[y - v[1]][x] = -1;
				this.tiles[y][x - v[0]] = -1;
			}

			// Store the first move so we can resolve the starting tile later
			if(first == null) first = exit;

			// Store the most recent move
			last = exit;

			// Keep track of the length so we know if the path is long enough
			step++;
        } while(x != start_x || y != start_y);

        // The starting tile is set to 0, find the actual ID
		this.tiles[start_y][start_x] = getTileIdForDirection(this.invert[last], first);

		// Make sure path isn't too short
        if(step < (this.width * this.height * 0.35)) return false;
        
        // We need to resolve the corners that are set to -1;
        // Also look for a starting tile (ID: 7)
        var startFound:Bool = false;
		for(y in 0...this.height) {
			for(x in 0...this.width) {
                if(this.tiles[y][x] == -1) this.tiles[y][x] = getCornerTileId(x, y);
                if(this.tiles[y][x] == 7) startFound = true;
			}
        }
        if(!startFound) return false;

		 // Find the bounds
		var minX:Int = this.width;
		var maxX:Int = 0;
		var minY:Int = this.height;
		var maxY:Int = 0;
		for(y in 0...this.height) {
			for(x in 0...this.width) {
				if(this.tiles[y][x] > 0) {
					minX = Std.int(Math.min(minX, x));
					maxX = Std.int(Math.max(maxX, x));
					minY = Std.int(Math.min(minY, y));
                    maxY = Std.int(Math.max(maxY, y));
				}
			}
        }
        
        // Crop it and pad it
        this.width = (maxX - minX) + 3;
		this.height = (maxY - minY) + 3;
        var cropped:Array<Array<Int>> = [[]];
        var row:Array<Int>;
		for(x in 0...this.width) cropped[0][x] = 1;
		for(y in minY...maxY+1) {
			row = [1];
			for(x in minX...maxX+1) {
				row.push(this.tiles[y][x]);
			}
			row.push(1);
			cropped.push(row);
        }
        row = [];
        for(x in 0...this.width) row.push(1);
        cropped.push(row);
		
        this.tiles = cropped;

        return true;
    }

    private function getValidExits(x:Int, y:Int, entrance:String=null):Array<String> {
        var exits:Array<String> = entrance == null ? ['N', 'S', 'E', 'W'] : (Math.random() * 100 < this.nineties ? this.exits[entrance] : this.exits_no_nineties[entrance]);
        var p:Array<String> = [];

        for(exit in exits) {
            var v:Array<Int> = this.neighbors[exit];

            var valid:Bool = true;

            if(x + v[0] < 0) valid = false;
			if(y + v[1] < 0) valid = false;
			if(x + v[0] >= this.width)  valid = false;
			if(y + v[1] >= this.height) valid = false;

			if(valid) {
				if(this.tiles[y + v[1]][x + v[0]] != 0) valid = false;
				if(exit.length == 2) {
					if(this.tiles[y][x + v[0]] > 0) valid = false;
					if(this.tiles[y + v[1]][x] > 0) valid = false;
				}
			}

            //if(!valid) exits.remove(exit);
            if(valid) p.push(exit);
        }

        return p;
    }

    private function getTileIdForDirection(enter:String, exit:String):Int {
        if(exit < enter) {
            var temp:String = enter;
            enter = exit;
            exit = temp;
        }

        var pair:String = enter + '-' + exit;
        switch(pair) {
            case 'E-N':   return 19;
			case 'E-NW':  return 11;
			case 'E-W':   return 7;
			case 'E-SW':  return 5;
			case 'E-S':   return 13;

			case 'N-SE':  return 23;
			case 'N-S':   return 8;
			case 'N-SW':  return 24;
			case 'N-W':   return 20;

			case 'NE-S':  return 17;
			case 'NE-SW': return 9;
			case 'NE-W':  return 12;

			case 'NW-SE': return 10;
			case 'NW-S':  return 18;

			case 'S-W':   return 14;

            case 'SE-W':  return 6;
            
            default:
                trace("Tile for " + pair + " not found.");
                return 1;
        }
        return 1;
    }

    private function getCornerTileId(x:Int, y:Int):Int {
        var N:Int = (y > 0) ? this.tiles[y - 1][x] : 0;
        var E:Int = (x < this.width - 1) ? this.tiles[y][x + 1] : 0;
        var S:Int = (y < this.height - 1) ? this.tiles[y + 1][x] : 0;
        var W:Int = (x > 0) ? this.tiles[y][x - 1] : 0;

        // Don't count diagonals that are pointing away
        if(![5,  6,  9, 10, 23, 24].contains(N)) N = 0;
        if(![5,  9, 10, 11, 18, 24].contains(E)) E = 0;
        if(![9, 10, 11, 12, 17, 18].contains(S)) S = 0;
        if(![6,  9, 10, 12, 17, 23].contains(W)) W = 0;

        var set:String = (N > 0 ? '1' : '0') + (E > 0 ? '1' : '0') + (S > 0 ? '1' : '0') + (W > 0 ? '1' : '0');
        switch(set) {
            case "1100": return 21;
            case "0110": return 3;
            case "0011": return 4;
            case "1001": return 22;

            case "1111":
                if([6, 10, 23].contains(N)) return 16;
                else return 15;
    
            default:
                trace("No diagonal found for " + N + E + S + W);
                return -1;
        }
        return 1;
    }

    public function getTiles():Array<Array<Int>> {
        return this.tiles;
    }
}