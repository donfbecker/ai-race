package neat;

class Genome {
    public var connections:Array<Connection>;
    public var nodes:Array<Node>;
    
    private var inputs:Int;
    private var outputs:Int;

    private var layers:Int = 2;
    private var biasNodeId:Int = 0;

    public function new(inputs:Int, outputs:Int, breeding:Bool = false) {
        this.inputs = inputs;
        this.outputs = outputs;
        
        connections = new Array<Connection>();
        nodes = new Array<Node>();

        if(breeding) return;

        // Create input nodes
        for(i in 0...inputs) {
            nodes.push(new Node(i));
            nodes[i].layer = 0;
        }

        // Create output nodes
        for(i in inputs...(inputs+outputs)) {
            nodes.push(new Node(i));
            nodes[i].layer = 1;
        }

        // Create a bias node
        biasNodeId = inputs + outputs;
        nodes.push(new Node(biasNodeId));
        nodes[biasNodeId].layer = 0;

        // Connect all inputs and outputs
        for(i in 0...inputs) {
            for(o in inputs...(inputs+outputs)) {
                var c:Connection = new Connection(nodes[i], nodes[o], -1 + (Math.random() * 2), getInnovationId(nodes[i], nodes[o]));
                connections.push(c);
                nodes[i].connections.push(c);
            }
        }

        // Connect the bias node
        for(o in inputs...(inputs+outputs)) {
            var c:Connection = new Connection(nodes[biasNodeId], nodes[o], -1 + (Math.random() * 2), getInnovationId(nodes[biasNodeId], nodes[o]));
            connections.push(c);
            nodes[biasNodeId].connections.push(c);
        }
    }

    private function getInnovationId(input:Node, output:Node) {
        // Inputs and Outputs will have IDs starting from 0.  Using a pairing
        // function to generate a unique ID for the connection, and add the number
        // of inputs and outputs so they don't overlap.
        return this.inputs + this.outputs + Std.int((0.5 * (input.id + output.id) * (input.id + output.id + 1)) + output.id);
    }

    public function feedForward(input:Array<Float>):Array<Float> {
            // Connect the inputs to the output values
            for(i in 0...inputs) {
                nodes[i].outputValue = input[i];
            }

            // Output of bias is 1
            nodes[biasNodeId].outputValue = 1;

            // Engage all the nodes, in order by layer
            // Other implementations cache the order of these to avoid doing a pass for each layer
            // I will do that later
            for(l in 0...layers) {
                for(i in 0...nodes.length) {
                    if(nodes[i].layer == l) {
                        nodes[i].engage();
                    }
                }
            }

            // Get the output values
            var output:Array<Float> = new Array<Float>();
            for(i in 0...outputs) {
                output[i] = nodes[inputs + i].outputValue;
            }

            // Reset all the nodes
            for(i in 0...nodes.length) {
                nodes[i].inputSum = 0;
            }

            return output;
    }

    public function mutate():Void {
        // Mutate weights 80% of the time
        var r:Float = Math.random();
        if(r < 0.8) {
            for(c in connections) c.mutate();
        }

        // Add a new connection 5% of the time
        if(r < 0.05) {
            addNewConnection();
        }

        // Add a new node 3% of the time
        if(r < 0.03) {
            addNewNode();
        }
    }

    private function addNewNode():Void {
        var r:Int;
        do {
            r = Std.int(Math.random() * connections.length);
        } while(connections[r].input == nodes[biasNodeId]);

        connections[r].active = false;

        // Set the node ID as the innovation ID of the connection
        // we are removing. This way, any node created by any genome
        // will have the same ID when spliced into a connection
        var node:Node = new Node(connections[r].innovationId);
        nodes.push(node);

        connections.push(new Connection(connections[r].input, node, 1, getInnovationId(connections[r].input, node)));
        connections.push(new Connection(node, connections[r].output, connections[r].weight, getInnovationId(node, connections[r].output)));
        node.layer = connections[r].input.layer + 1;
        if(connections[r].output.layer <= node.layer) {
            connections[r].output.layer = node.layer + 1;
        }
    }

    private function addNewConnection():Void {
        if(fullyConnected()) return;

        // Choose two random nodes
        var n1:Int;
        var n2:Int;
        do {
            n1 = Std.int(Math.random() * nodes.length - 1);
            n2 = Std.int(Math.random() * nodes.length - 1);
        } while(nodes[n1].layer == nodes[n2].layer || nodes[n1].isConnectedTo(nodes[n2]));

        if(nodes[n1].layer > nodes[n2].layer) {
            var temp:Int = n1;
            n1 = n2;
            n2 = temp;
        }

        var c:Connection = new Connection(nodes[n1], nodes[n2], -1 + (Math.random() * 2), getInnovationId(nodes[n1], nodes[n2]));
        connections.push(c);
    }

    public function breed(mate:Genome):Genome {
        var offspring:Genome = new Genome(inputs, outputs, true);

        offspring.layers = layers;
        offspring.biasNodeId = biasNodeId;

        for(c in connections) {
            var active:Bool = true;
            var matesConnection:Int = mate.findMatchingConnection(c.innovationId);
            if(matesConnection != -1 ){
                if(!c.active || !mate.connections[matesConnection].active) {
                    if(Math.random() < 0.75) {
                        active = false;
                    }
                }

                if(Math.random() < 0.5) {
                    offspring.connections.push(c);
                } else {
                    offspring.connections.push(mate.connections[matesConnection]);
                }
            } else {
                offspring.connections.push(c);
                active = c.active;
            }

            offspring.connections[offspring.connections.length-1].active = active;
        }

        for(n in nodes) offspring.nodes.push(n.clone());
        offspring.repairConnections();

        return offspring;
    }

    public function fullyConnected():Bool {
        var total:Int = 0;
        var npl:Map<Int, Int> = new Map<Int, Int>();
        for(n in nodes) {
            if(npl[n.layer] == null) {
                npl[n.layer] = 1;
            } else {
                npl[n.layer]++;
            }
        }

        for(i in 0...layers) {
            for(j in (i+1)...layers) {
                total += npl[i] * npl[j];
            }
        }

        return total == connections.length;
    }

    private function findMatchingConnection(innovationId:Int):Int {
        for(i in 0...connections.length) {
            if(connections[i].innovationId == innovationId) {
                return i;
            }
        }

        return -1;
    }

    public function repairConnections():Void {
        for(c in connections) {
            var input:Node = findNodeById(c.input.id);
            var output:Node = findNodeById(c.output.id);

            c.input = input;
            c.output = output;
        }

    }

    public function findNodeById(id:Int):Node {
        for(n in nodes) {
            if(n.id == id) return n;
        }
        return null;
    }

    public function clone():Genome {
        var g:Genome = new Genome(inputs, outputs);
        for(n in nodes) g.nodes.push(n.clone());
        for(c in connections) g.connections.push(c.clone());
        g.repairConnections();

        return g;
    }
}