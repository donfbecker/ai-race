package neat;

class Genome {
    public var connections:Array<Connection>;
    public var nodes:Array<Node>;

    private var inputs:Int;
    private var outputs:Int;
    private var hidden:Int;

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

        // Connect all inputs to outputs
        for(i in 0...inputs) {
            for(o in inputs...(inputs+outputs)) {
                var c:Connection = new Connection(nodes[i], nodes[o], -1 + (Math.random() * 2), getInnovationId(nodes[i], nodes[o]));
                connections.push(c);
                nodes[i].connections.push(c);
            }
        }

        // Connect the bias node to outputs
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

        repairConnections();
    }

    private function addNewNode():Void {
        var r:Int = Std.int(Math.random() * connections.length);
        var c:Int = r;
        var found:Bool = false;
        do {
            if(connections[r].input != nodes[biasNodeId] && findNodeById(connections[r].innovationId) == null) {
                found = true;
                break;
            }

            if(++c >= connections.length) c = 0;
        } while(c != r);

        // If we didn't find a place to put a node, just bail
        if(!found) return;

        // Disable the old connection
        connections[r].active = false;

        // Set the node ID as the innovation ID of the connection
        // we are removing. This way, any node created by any genome
        // will have the same ID when spliced into a connection
        var node:Node = new Node(connections[r].innovationId);
        nodes.push(node);

        connections.push(new Connection(connections[r].input, node, 1, getInnovationId(connections[r].input, node)));
        connections.push(new Connection(node, connections[r].output, connections[r].weight, getInnovationId(node, connections[r].output)));
        node.layer = connections[r].input.layer + 1;
        while(connections[r].output.layer <= node.layer) {
            connections[r].output.layer++;
        }
    }

    private function addNewConnection():Void {
        // Choose two random starting nodes
        var s1:Int = Std.int(Math.random() * (nodes.length - 1));
        var s2:Int = Std.int(Math.random() * (nodes.length - 1));

        // If we happen to pick the same random starting nodes, just bail
        if(s1 == s2) return;

        // Start at the two random nodes, and loop around until we find
        // a suitable place to make a new connection
        var n1:Int = s1;
        var n2:Int = s2;
        var found:Bool = false;
        do {
            if(nodes[n1].layer != nodes[n2].layer && !nodes[n1].isConnectedTo(nodes[n2])) {
                found = true;
                break;
            }

            if(++n2 >= nodes.length) n2 = 0;
            if(n2 == s2) if(++n1 >= nodes.length) n1 = 0;
        } while(n1 != s1);

        // If we didn't find an available connection, just bail.
        if(!found) return;

        // Make sure n1 is in a lower layer than n2
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
                    offspring.connections.push(c.clone());
                } else {
                    offspring.connections.push(mate.connections[matesConnection].clone());
                }
            } else {
                offspring.connections.push(c.clone());
                active = c.active;
            }

            offspring.connections[offspring.connections.length-1].active = active;
        }

        for(n in nodes) offspring.nodes.push(n.clone());
        offspring.repairConnections();

        return offspring;
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
        for(n in nodes) n.connections = new Array<Connection>();

        for(c in connections) {
            var input:Node = findNodeById(c.input.id);
            var output:Node = findNodeById(c.output.id);

            c.input = input;
            c.output = output;

            input.connections.push(c);
        }

        // Repair layers
        for(n in nodes) n.layer = 0;
        for(i in 0...inputs) nodes[i].setLayer(0);
        nodes[biasNodeId].setLayer(0);

        // Make sure all output nodes are the same layer
        var layer:Int = 0;
        for(i in inputs...(inputs+outputs)) if(nodes[i].layer > layer) layer = nodes[i].layer;
        for(i in inputs...(inputs+outputs)) nodes[i].layer = layer;
        layers = layer+1;
    }

    public function findNodeById(id:Int):Node {
        for(n in nodes) {
            if(n.id == id) return n;
        }
        return null;
    }

    public function clone():Genome {
        var g:Genome = new Genome(inputs, outputs, true);
        g.layers = layers;
        g.biasNodeId = biasNodeId;

        for(n in nodes) g.nodes.push(n.clone());
        for(c in connections) g.connections.push(c.clone());

        g.repairConnections();

        return g;
    }

    public function asText():String {
        var text:String = "inputs " + inputs + "\n";
        text += "outputs " + outputs + "\n";
        text += "bias " + biasNodeId + "\n";

        for(n in nodes) text += "node " + n.id + " " + n.layer + "\n";
        for(c in connections) {
            text += "connection " + c.innovationId + " " + c.weight + " " + (c.active ? 1 : 0) + " " + c.input.id + " " + c.output.id + "\n";
        }

        return text;
    }
}
