package drivers;

import flash.geom.Point;

import neat.Organism;
import cars.Car;

class NeatDriver extends Organism {
    private var track:Track;
    private var car:Car;

    private var fx:Int = 225;
    private var fy:Int = 200;

    // Variables for fitness
	private var distanceTraveled:Float = 0;
    private var checkpoints:Int = 0;
    private var ticksSinceCheckpoint:Int = 0;

    public function new(track:Track, car:Car) {
        // Organism's genome should have 3 inputs and 5 outputs
        super(3, 5);

        this.track = track;
        this.car = car;
    }

    public override function tick():Void {
        if(!alive) return;

        var inputs:Array<Float> = [-1, -1, -1];
        var p:Point = new Point(100, 0);

        for(i in 0...20) {
            var percent:Float = (i / 20);
            if(inputs[0] == -1) {
                //p.x = Std.int((fx + car.speedP) * percent);
                p.x = Std.int(fx * percent);
                p.y = 0;
                p = car.localToGlobal(p);
                if(!track.hitTestPoint(p.x, p.y, true)) inputs[0] = percent;
            }

            if(inputs[1] == -1) {
                p.x = Std.int(fx * percent);
                p.y = Std.int(-fy * percent);
                p = car.localToGlobal(p);
                if(!track.hitTestPoint(p.x, p.y, true)) inputs[1] = percent;
            }

            if(inputs[2] == -1) {
                p.x = Std.int(fx * percent);
                p.y = Std.int(fy * percent);
                p = car.localToGlobal(p);
                if(!track.hitTestPoint(p.x, p.y, true)) inputs[2] = percent;
            }
        }
        for(i in 0...3) if(inputs[i] == -1) inputs[i] = 1;

        //car.graphics.clear();
		//car.graphics.beginFill(0xFF0000);
		//car.graphics.drawCircle((fx + car.speedP) * inputs[0], 0, 3);
		//car.graphics.drawCircle(fx * inputs[1], -fy * inputs[1], 3);
		//car.graphics.drawCircle(fx * inputs[2], fy * inputs[2], 3);
		//car.graphics.endFill();        
        
        // Process the network
        var outputs:Array<Float> = genome.feedForward(inputs);

        // Translate outputs to keys
        var up:Bool = (outputs[0] >= 0.5);
		var down:Bool = (outputs[1] >= 0.5);
		var left:Bool = (outputs[2] >= 0.5);
		var right:Bool = (outputs[3] >= 0.5);
        var space:Bool = (outputs[4] >= 0.5);

        car.tick(up, down, left, right, space);

        // Keep track of distance traveled
        distanceTraveled += car.speedP;

        // Check if we reached a checkpoint
		var t:Array<Int> = track.getTileXY(car.x, car.y);
		var cp:Array<Int> = track.checkpoints[this.checkpoints % track.checkpoints.length];
        if(cp[0] == t[0] && cp[1] == t[1]) {
            this.checkpoints++;
            ticksSinceCheckpoint = 0;
        } else {
            ticksSinceCheckpoint++;
        }
        
        // See if we are still alive
        if(car.collisions > 0) alive = false;
        if(ticksSinceCheckpoint > 100) alive = false;

        car.visible = alive;
    }

    public override function reset():Void {
        var i:Int = track.getChildIndex(car);
        car.x = ((track.startX) * track.tileWidth) + (track.tileWidth / 2);
        car.y = ((track.startY) * track.tileHeight) + (track.tileHeight / 2) - 75 + ((i % 4) * 50);
        car.velocity.x = 0;
        car.velocity.y = 0;
        car.rotation = 0;
        car.collisions = 0;
        car.visible = true;

        distanceTraveled = 0;
        checkpoints = 0;
        ticksSinceCheckpoint = 0;
        
        alive = true;
        track.addChild(car);
    }

    public override function calculateFitness():Float {
        //fitness = (checkpoints * 300) + distanceTraveled;
        fitness = checkpoints;
        return fitness;
    }
}
