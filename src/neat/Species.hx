package neat;

class Species {
    public var genome:Genome;
    public var organisms:Array<Organism> = new Array<Organism>();

    private var champion:Organism;
    private var topFitness:Float = 0;
    public var averageFitness:Float = 0;
    public var staleness:Int = 0;

    private var excessCoeff:Float = 1.5;
    private var weightDiffCoeff:Float = 0.8;
    private var compatibilityThreshold:Float = 1;

    public function new(organism:Organism = null) {
        if(organism != null) {
            organisms.push(organism);
            topFitness = organism.fitness;
            genome = organism.genome.clone();
            champion = organism.clone();

        }
    }

    public function addOrganism(o:Organism) {
        organisms.push(o);
    }

    public function isSameSpecies(o:Organism):Bool {
        var excessAndDisjoint:Float = getExcessDisjoint(o.genome, this.genome);
        var averageWeightDiff:Float = averageWeightDiff(o.genome, this.genome);

        var largeGenomeNormalize:Float = o.genome.connections.length - 20;
        if(largeGenomeNormalize < 1) largeGenomeNormalize = 1;

        var compatibility:Float = (excessCoeff * excessAndDisjoint / largeGenomeNormalize) + (weightDiffCoeff * averageWeightDiff);
        return (compatibilityThreshold > compatibility);
    }

    private function getExcessDisjoint(g1:Genome, g2:Genome):Float {
        var matching:Float = 0;

        for(i in 0...g1.connections.length) {
            for(j in 0...g2.connections.length) {
                if(g1.connections[i].innovationId == g2.connections[j].innovationId) {
                    matching++;
                    break;
                }
            }
        }

        return (g1.connections.length + g2.connections.length) - (2 * matching);
    }

    private function averageWeightDiff(g1:Genome, g2:Genome):Float {
        var matching:Float = 0;
        var totalDiff:Float = 0;

        for(i in 0...g1.connections.length) {
            for(j in 0...g2.connections.length) {
                if(g1.connections[i].innovationId == g2.connections[j].innovationId) {
                    matching++;
                    totalDiff += Math.abs(g1.connections[i].weight - g2.connections[j].weight);
                    break;
                }
            }
        }

        if(matching == 0) return 100;
        return totalDiff / matching;
    }

    public function sort():Void {
        if(organisms.length < 1) return;

        organisms.sort(function (a, b) {
            if(a.fitness > b.fitness) return -1;
            if(a.fitness < b.fitness) return 1;
            else return 0;
        });

        if(organisms[0].fitness > topFitness) {
            staleness = 0;
            topFitness = organisms[0].fitness;
            genome = organisms[0].genome.clone();
            champion = organisms[0].clone();
        } else {
            staleness++;
        }
    }

    public function calculateAverageFitness():Float {
        if(organisms.length < 1) return 0;

        var sum:Float = 0;
        for(o in organisms) sum += o.fitness;
        averageFitness = sum / organisms.length;
        return averageFitness;
    }

    public function cull():Void {
        if(organisms.length > 2) {
            organisms.resize(Std.int(organisms.length / 2));
        }
    }

    public function fitnessSharing():Void {
        for(o in organisms) o.fitness /= organisms.length;
    }

    public function breed():Genome {
        var offspring:Genome;

        var mother:Organism = selectParent();
        var father:Organism = selectParent();

        if(mother.fitness > father.fitness) {
            offspring = mother.genome.breed(father.genome);
        } else {
            offspring = father.genome.breed(mother.genome);
        }

        offspring.mutate();
        return offspring;
    }

    private function selectParent():Organism {
        var fitnessSum:Float = 0;
        for(o in organisms) fitnessSum += o.fitness;

        var random:Float = fitnessSum * Math.random();
        var runningSum:Float = 0;
        for(o in organisms) {
            runningSum += o.fitness;
            if(runningSum > random) {
                return o;
           }
        }

        return organisms[0];
    }
}
