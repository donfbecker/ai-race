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

        var inputs:Array<Float> = new Array<Float>();
        var p:Point = new Point(100, 0);

		p.x = fx + (car.speedP * lead);
		p.y = 0;
		p = car.localToGlobal(p);
		inputs.push(car.track.hitTestPoint(p.x, p.y, true) ? 1 : 0);

		p.x = fx;
		p.y = -fy;
		p = car.localToGlobal(p);
		inputs.push(car.track.hitTestPoint(p.x, p.y, true) ? 1 : 0);

		p.x = fx;
		p.y = fy;
		p = car.localToGlobal(p);
        inputs.push(car.track.hitTestPoint(p.x, p.y, true) ? 1 : 0);
        
        // Process the network
        var outputs:Array<Float> = genome.feedForward(inputs);

        // Translate outputs to keys
        var up:Bool = (outputs[0] >= 0.9);
		var down:Bool = (outputs[1] >= 0.9);
		var left:Bool = (outputs[2] >= 0.9);
		var right:Bool = (outputs[3] >= 0.9);
        var space:Bool = (outputs[4] >= 0.9);

        car.tick(up, down, left, right, space);

        if(car.hitWall) alive = false;
    }

    public override function reset():Void {
        car.x = startingPosition.x;
        car.y = startingPosition.y;
        car.hitWall = false;
        car.distanceTraveled = 0;
        alive = true;
    }

    public override function calculateFitness():Float {
        fitness = car.distanceTraveled;
        return fitness;
    }
}