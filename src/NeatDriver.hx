import neat.Organism;

import flash.geom.Point;

class NeatDriver extends Organism {
    private var car:Car;
    private var fx:Int = 225;
    private var fy:Int = 160;
    private var lead:Float = 0;

    private var startingPosition:Point;

    public function new(car:Car, lead:Float = 7) {
        // Organism's genome should have 3 inputs and 5 outputs
        super(3, 5);

        this.car = car;
        this.lead = lead;
        this.startingPosition = new Point(car.x, car.y);
    }

    public override function tick():Void {
        if(!alive) return;

        var inputs:Array<Float> = [0, 0, 0];
        var p:Point = new Point(100, 0);

        for(i in 0...20) {
            var percent:Float = (i / 20);
            if(inputs[0] == 0) {
                p.x = Std.int(fx + (car.speedP * lead) * percent);
                p.y = 0;
                p = car.localToGlobal(p);
                if(!car.track.hitTestPoint(p.x, p.y, true)) inputs[0] = percent;
            }

            if(inputs[1] == 0) {
                p.x = Std.int(fx * percent);
                p.y = Std.int(-fy * percent);
                p = car.localToGlobal(p);
                if(!car.track.hitTestPoint(p.x, p.y, true)) inputs[1] = percent;
            }

            if(inputs[2] == 0) {
                p.x = Std.int(fx * percent);
                p.y = Std.int(fy * percent);
                p = car.localToGlobal(p);
                if(!car.track.hitTestPoint(p.x, p.y, true)) inputs[2] = percent;
            }
        }
        for(i in 0...3) if(inputs[i] == 0) inputs[i] = 1;
        
        // Process the network
        var outputs:Array<Float> = genome.feedForward(inputs);

        // Translate outputs to keys
        var up:Bool = (outputs[0] >= 0.5);
		var down:Bool = (outputs[1] >= 0.5);
		var left:Bool = (outputs[2] >= 0.5);
		var right:Bool = (outputs[3] >= 0.5);
        var space:Bool = (outputs[4] >= 0.5);

        car.tick(up, down, left, right, space);

        if(car.hitWall) alive = false;
    }

    public override function reset():Void {
        car.x = startingPosition.x;
        car.y = startingPosition.y;
        car.velocity.x = 0;
        car.velocity.y = 0;
        car.rotation = 0;
        car.hitWall = false;
        car.distanceTraveled = 0;
        alive = true;
    }

    public override function calculateFitness():Float {
        fitness = car.distanceTraveled;
        return fitness;
    }
}
