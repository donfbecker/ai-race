package neat;

class Organism {
    public var fitness:Float;
    public var genome:Genome;

    public function new(inputs:Int, outputs:Int) {
        genome = new Genome(inputs, outputs);
    }

    public function clone():Organism {
        return new Organism(3, 5);
    }
}