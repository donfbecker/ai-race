package neat;

import js.html.HeadingElement;
import openfl.sensors.Accelerometer;
import js.html.HitRegionOptions;
import js.html.HtmlElement;

class Genome {
    public var connections:Array<Connection>;
    public var nodes:Array<Node>;
    
    private var inputs:Int;
    private var outputs:Int;

    private var layers:Int = 2;
    private var nextNodeId:Int = 0;
    private var biasNodeId:Int = 0;
    private var nextInnovationId:Int = 0;

    public function new(inputs:Int, outputs:Int) {
        this.inputs = inputs;
        this.outputs = outputs;

        connections = new Array<Connection>();
        nodes = new Array<Node>();

        // Create input nodes
        for(i in 0...inputs) {
            nodes.push(new Node(nextNodeId));
            nodes[nextNodeId].layer = 0;
            nextNodeId++;
        }

        // Create output nodes
        for(i in 0...outputs) {
            nodes.push(new Node(nextNodeId));
            nodes[nextNodeId].layer = 1;
            nextNodeId++;
        }

        // Create a bias node
        biasNodeId = nextNodeId;
        nodes.push(new Node(nextNodeId));
        nodes[nextNodeId].layer = 0;
        nextNodeId++;

        // Connect all inputs and outputs
        for(i in 0...inputs) {
            for(o in inputs...outputs) {
                var c:Connection = new Connection(nodes[i], nodes[o], -1 + (Math.random() * 2), nextInnovationId++);
                connections.push(c);
                nodes[i].connections.push(c);
            }
        }

        // Connect the bias node
        for(o in inputs...outputs) {
            var c:Connection = new Connection(nodes[biasNodeId], nodes[o], -1 + (Math.random() * 2), nextInnovationId++);
            connections.push(c);
            nodes[biasNodeId].connections.push(c);
        }
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

    public function clone():Genome {
        return new Genome(inputs, outputs);
    }
}