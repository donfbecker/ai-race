package neat;

class Connection {
    public var input:Node;
    public var output:Node;
    public var weight:Float;
    public var innovation:Int;

    public var active:Bool = true;

    public function new(input:Node, output:Node, weight:Float, innovation:Int) {
        this.input = input;
        this.output = output;
        this.weight = weight;
        this.innovation = innovation;
    }

    public function mutate() {
        var rand:Float = Math.random();

        if(rand < 0.1) {
            // 10% of the time, completely change the weight
            weight = -1 + (Math.random() * 2);
        } else {
            // Otherwise, just change it a little
            weight += randomGaussian() / 50;
            if(weight > 1) weight = 1;
            else if(weight < -1) weight = -1;
        }
    }

    private function randomGaussian(mean:Float = 0, deviation:Float = 1):Float {
        var x:Float = Math.random();
        var y:Float = Math.random();

        return Math.sqrt(-2 * Math.log(x)) * Math.cos(2 * Math.PI * y) * deviation + mean;
    }

    public function clone():Connection {
        return new Connection(input, output, weight, innovation);
    }
}