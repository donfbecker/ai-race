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

    public function setLayer(layer:Int):Void {
        this.layer = layer;
        for(c in connections) {
            if(c.output.layer <= layer) c.output.setLayer(layer+1);
        }
    }

    private function sigmoid(f:Float):Float {
        return 1 / (1 + Math.pow(2.718281828459045, -4.9 * f));
    }

    public function isConnectedTo(node:Node):Bool {
        // Check all the connections for this node
        for(c in connections) {
            if(c.output == node) return true;
        }

        // Check all the connections on the other node
        for(c in node.connections) {
            if(c.output == this) return true;
        }

        return false;
    }

    public function clone():Node {
        var n:Node = new Node(id);
        n.layer = layer;
        return n;
    }
}
