package neat;

class Node {
    public var id:Int;
    public var connections:Array<Connection> = new Array<Connection>();
    public var layer:Int;

    public var inputSum:Float = 0;
    public var outputValue:Float = 0;

    public function new(id:Int) {
        this.id = id;
    }

    public function engage() {
        if(layer != 0) {
            outputValue = sigmoid(inputSum);
        }

        for(c in connections) {
            if(c.active) {
                c.output.inputSum += c.weight * outputValue;
            }
        }
    }

    private function sigmoid(f:Float):Float {
        return 1 / (1 + Math.pow(2.718281828459045, -4.9 * f));
    }

    public function isConnectedTo(node:Node):Bool {
        // Nodes in the same layer can't be connected
        if(node.layer == layer) return false;

        if(node.layer < layer) {
            // If the target node's layer is less, then it's output
            // is connected to our input
            for(c in connections) {
                if(c.output == this) return true;
            }
        } else {
            // If the target node's layer is more, then it's input
            // is connected to our output
            for(c in connections) {
                if(c.input == this) return true;
            }
        }

        return false;
    }

    public function clone():Node {
        var n:Node = new Node(id);
        n.layer = layer;
        return n;
    }
}