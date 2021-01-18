package neat;

import openfl.geom.Point;

#if cpp
import sys.io.File;
import sys.io.FileOutput;
#end

class Population {
    private var species:Array<Species> = new Array<Species>();
    private var organisms:Array<Organism> = new Array<Organism>();

    private var size:Int;
    public var generation:Int = 1;
    private var averageFitnessSum:Float;
    private var averageFitness:Float;
    private var champion:Organism;

    private var ticks:Int = 0;

    private var startingPositions:Array<Point> = new Array<Point>();

    public function new() {
    }

    public function addOrganism(o:Organism):Void {
        organisms.push(o);
    }

    public function tick():Void {
        ticks++;
        if(ticks > 300 + generation) {
            breed();
            ticks = 0;
        } else {
            for(o in organisms) o.tick();
        }
    }

    private function breed():Void {
        size = organisms.length;

        speciate();
        calculateFitness();
        sortSpecies();
        cullSpecies();
        killStaleSpecies();
        killBadSpecies();

        // if we don't have any species left, just mutate everything
        if(species.length > 0) {
            reincarnate();
        } else {
            for (o in organisms) {
                o.genome.mutate();
            }
        }


        for(o in organisms) {
            o.reset();
        }

        #if cpp
            // If we are using CPP, then dump best genome to file
            var champion:Organism = organisms[0];
            for(o in organisms) if(o.fitness > champion.fitness) champion = o;

            var out:FileOutput = File.write("generation" + generation + ".txt");
            out.writeString(champion.genome.asText());
            out.close();
        #end

        generation++;
    }

    private function speciate():Void {
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

    private function calculateFitness():Void {
        champion = organisms[0];
        for(o in organisms) {
            o.calculateFitness();
            if(o.fitness > champion.fitness) champion = o;
        }
    }

    private function sortSpecies():Void {
        for(s in species) s.sort();
    }

    private function cullSpecies():Void {
        averageFitnessSum = 0;
        for(s in species) {
            s.cull();
            s.fitnessSharing();
            averageFitnessSum += s.calculateAverageFitness();
        }
    }

    private function killStaleSpecies():Void {
        for(s in species) {
            if(s.staleness >= 15) {
                species.remove(s);
            }
        }

    }

    private function killBadSpecies():Void {
        for(s in species) {
            if(s.averageFitness / averageFitnessSum * organisms.length < 1) {
                species.remove(s);
            }
        }
    }

    private function reincarnate():Void {
        var newGenomes:Array<Genome> = new Array<Genome>();

        // Sometimes the average fitness is 0, which breaks things
        if(averageFitnessSum > 0) {
            for(s in species) {
                if(s.organisms.length > 0) {
                    newGenomes.push(s.organisms[0].genome.clone());

                    var size:Int = Math.floor(s.averageFitness / averageFitnessSum * organisms.length) - 1;
                    for(i in 0...size) newGenomes.push(s.breed());
                }
            }
        }

        while(newGenomes.length < organisms.length) {
            newGenomes.push(species[0].breed());
        }

        for(i in 0...organisms.length) {
            organisms[i].genome = newGenomes[i];
        }
    }
}
