package neat;

import openfl.geom.Point;

class Population {
    private var species:Array<Species>;
    private var organisms:Array<Organism>;
    
    private var size:Int;
    private var generation:Int;
    private var averageFitness:Float;

    private var ticks:Int = 0;

    private var startingPositions:Array<Point> = new Array<Point>();

    public function new() {
        species = new Array<Species>();
        organisms = new Array<Organism>();
    }

    public function addOrganism(o:Organism):Void {
        organisms.push(o);
    }

    public function speciate():Void {
        for(s in species) {
            s.organisms = new Array<Organism>();
        }

        for(o in organisms) {
            var found:Bool = false;
            for(s in species) {
                if(s.isSameSpecies(o)) {
                    s.addOrganism(o);
                    found = true;
                    break;
                }
            }

            if(!found) {
                species.push(new Species(o));
            }
        }
    }

    public function calculateFitness():Void {
        for(o in organisms) {
            o.calculateFitness();
        }
    }

    public function tick():Void {
        ticks++;
        if(ticks > 300) {
            for(o in organisms) {
                o.genome.mutate();
                o.reset();
            }
            ticks = 0;
        } else {
            for(o in organisms) o.tick();
        }
    }
}