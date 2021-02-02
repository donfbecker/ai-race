package drivers;

import flash.geom.Point;

import cars.Car;

class QLDriver {
    private var track:Track;
    private var car:Car;

    private var fx:Int = 225;
    private var fy:Int = 200;

    private var startingPosition:Point;

    // Variables for fitness
	private var distanceTraveled:Float = 0;
    private var checkpoints:Int = 0;
    private var ticksSinceCheckpoint:Int = 0;

    // QLearning
    private var learningRate:Float = 0.1;
    private var learningDiscount:Float = 0.8;
    private var qTable:Array<Array<Array<Array<Array<Float>>>>>;
    private var lastAction:Int = -1;

    // Store some variables for rewards
    private var distanceToCheckpoint:Float = -1;
    private var collisionCount:Int = 0;

    public function new(track:Track, car:Car) {
        this.track = track;
        this.car = car;

        this.startingPosition = new Point(car.x, car.y);

        // Initialize QTable
        qTable = new Array<Array<Array<Array<Array<Float>>>>>();
        for(i in 0...21) {
            qTable[i] = new Array<Array<Array<Array<Float>>>>();
            for(j in 0...21) {
                qTable[i][j] = new Array<Array<Array<Float>>>();
                for(k in 0...21) {
                    qTable[i][j][k] = new Array<Array<Float>>();
                    for(l in 0...25) {
                        qTable[i][j][k][l] = new Array<Float>();
                        for(m in 0...32) {
                            qTable[i][j][k][l].push(0);
                        }
                    }
                }
            }
        }
    }

    public function tick():Void {
        // Check the state
        var state:Array<Int> = getState();

        // Make a decision
        var action:Int = makeDecision(state);
        //trace(action);

        // Translate action to keys
        var up:Bool = (action & 1 > 0);
		var down:Bool = (action & 2 > 0);
		var left:Bool = (action & 4 > 0);
		var right:Bool = (action & 8 > 0);
        var space:Bool = (action & 16 > 0);

        // Update the car
        car.tick(up, down, left, right, space);

        //trace(state);
        //trace(action);
        //trace(car.speedP);

        // Observe and learn
        observe(state, action);
    }

    private function getState():Array<Int> {
        var p:Point = new Point(100, 0);
        var state:Array<Int> = [-1, -1, -1];
        for(i in 0...20) {
            var percent:Float = (i / 20);

            // Check left side first
            if(state[0] == -1) {
                p.x = Std.int(fx * percent);
                p.y = Std.int(-fy * percent);
                p = car.localToGlobal(p);
                if(!track.hitTestPoint(p.x, p.y, true)) state[0] = 1;
            }

            // Check front
            if(state[1] == -1) {
                //p.x = Std.int((fx + car.speedP) * percent);
                p.x = Std.int(fx * percent);
                p.y = 0;
                p = car.localToGlobal(p);
                if(!track.hitTestPoint(p.x, p.y, true)) state[1] = 1;
            }

            // Check right side
            if(state[2] == -1) {
                p.x = Std.int(fx * percent);
                p.y = Std.int(fy * percent);
                p = car.localToGlobal(p);
                if(!track.hitTestPoint(p.x, p.y, true)) state[2] = 1;
            }
        }
        for(i in 0...3) if(state[i] == -1) state[i] = 0;

        // Pass the tile ID
        state[3] = track.getTileIdAt(car.x, car.y);

        car.graphics.clear();
        car.graphics.beginFill(0xFF0000);
        car.graphics.drawCircle(fx * (state[0] / 20), -fy * (state[0] / 20), 3);
		car.graphics.drawCircle(fx * (state[1] / 20), 0, 3);
		car.graphics.drawCircle(fx * (state[2] / 20), fy * (state[2] / 20), 3);
        car.graphics.endFill();
        
        return state;
    }

    private function makeDecision(state:Array<Int>):Int {
        // First find the max value for the state
        var actions:Array<Float> = qTable[state[0]][state[1]][state[2]][state[3]];
        var max:Float = actions[0];
        for(c in actions) max = Math.max(c, max);

        // Now find all the actions that have that value
        var possible:Array<Int> = new Array<Int>();
        for(i in 0...actions.length) if(actions[i] == max) possible.push(i);

        // Choose an action
        var action:Int = 0;
        if(possible.length > 1) {
            if(lastAction != -1 && possible.contains(lastAction)) {
                action = lastAction;
            } else {
                var r:Int = Math.round(Math.random() * possible.length);
                action = possible[r];
            }
        } else {
            action = possible[0];
        }

        lastAction = action;
        return action;
    }

    private function observe(state:Array<Int>, action:Int):Void {
        var reward:Float = 0;
        var new_state:Array<Int> = getState();

        distanceTraveled += car.speedP;

        // Give a small reward for moving
        //if(car.speedP > 0) reward = distanceTraveled;
        //else reward -= 100;
        if(car.speedP <= 0) reward = -100;

        // Check if we reached a checkpoint and give a reward
		var t:Array<Int> = track.getTileXY(car.x, car.y);
		var cp:Array<Int> = track.checkpoints[this.checkpoints % track.checkpoints.length];
        if(cp[0] == t[0] && cp[1] == t[1]) {
            reward += 100;
            this.checkpoints++;
            ticksSinceCheckpoint = 0;
            distanceToCheckpoint = -1;
        } else {
            ticksSinceCheckpoint++;

            var cpX:Float = (t[0] * track.tileWidth) + (track.tileWidth / 2);
            var cpY:Float = (t[1] * track.tileHeight) + (track.tileHeight / 2);
            var d:Float = Math.sqrt(Math.pow(car.x - cpX, 2) + Math.pow(car.y - cpY, 2));
            if(distanceToCheckpoint > -1) reward += (distanceToCheckpoint - d) * Math.abs(car.speedP);
            distanceToCheckpoint = d;
        }

        if(collisionCount - car.collisions > 0) {
            reward = -100;
        }
        collisionCount = car.collisions;

        var oldQ:Float = qTable[state[0]][state[1]][state[2]][state[3]][action];
            
        var maxQ:Float = 0;
        var actions:Array<Float> = qTable[new_state[0]][new_state[1]][new_state[2]][new_state[3]];
        for(a in actions) maxQ = Math.max(a, maxQ);
            
        var newQ:Float = (1 - learningRate) * oldQ + learningRate * (reward + learningDiscount * maxQ);
        qTable[state[0]][state[1]][state[2]][state[3]][action] = newQ;

        //trace('reward=' + reward);
        //trace('oldQ=' + oldQ);
        //trace('maxQ=' + maxQ);
        //trace('newQ=' + newQ);

        if(car.collisions > 100) reset();
        //if(ticksSinceCheckpoint > 150) reset();
    }

    public function reset():Void {
        car.x = startingPosition.x;
        car.y = startingPosition.y;
        car.velocity.x = 0;
        car.velocity.y = 0;
        car.rotation = 0;
        car.collisions = 0;
        car.visible = true;

        distanceTraveled = 0;
        checkpoints = 0;
        ticksSinceCheckpoint = 0;
        lastAction = -1;
    }
}
