package neat;

class Population {
    private var species:Array<Species>;
    private var organisms:Array<Organism>;
    
    private var size:Int;
    private var generation:Int;

    public function new() {
        species = new Array<Species>();
        organisms = new Array<Organism>();
    }
}