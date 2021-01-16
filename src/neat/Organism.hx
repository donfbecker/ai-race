package neat;

class Organism {
    private var inputs:Int;
    private var outputs:Int;

    public var fitness:Float = 0;
    public var alive:Bool = true;
    public var genome:Genome;

    public function new(inputs:Int, outputs:Int) {
        this.inputs = inputs;
        this.outputs = outputs;

        genome = new Genome(inputs, outputs);
    }

    public function calculateFitness():Float {
        return fitness;
    }

    public function breed(mate:Organism) {
        var offspring:Organism = new Organism(inputs, outputs);
        offspring.genome = genome.breed(mate.genome);
        return offspring;
    }

    public function clone():Organism {
        var o:Organism = new Organism(inputs, outputs);
        o.genome = genome.clone();
        return o;
    }

    public function tick():Void {
    }

    public function reset():Void {
    }
}