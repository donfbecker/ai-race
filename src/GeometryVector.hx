class GeometryVector {
	public var x:Float;
	public var y:Float;

	public function new(x:Float, y:Float) {
		this.x = x;
		this.y = y;
	}

	public function perp():GeometryVector {
		return new GeometryVector(-this.y, this.x);
	}

	public function projection(vec:GeometryVector):GeometryVector {
		if (vec.getMag() == 0) {
			return new GeometryVector(0, 0);
		}
		var newVec:GeometryVector = new GeometryVector(vec.x, vec.y);
		var newMag:Float = newVec.getMag();
		newVec.setMag(newMag * ((newVec.x * this.x + newVec.y * this.y) / (vec.x * vec.x + vec.y * vec.y)));
		return newVec;
	}

	public function angleReal():Float {
		var testVec:GeometryVector = this.unitVector();
		var asin:Float = Math.asin(testVec.y);
		var acos:Float = Math.acos(testVec.x);
		if (Math.sin(asin) > 0 && Math.sin(acos) > 0) {
			return asin;
		} else if (Math.cos(asin) < 0) {
			return -acos;
		} else {
			return acos;
		}
	}

	public function getMag():Float {
		return Math.sqrt((this.x * this.x) + (this.y * this.y));
	}

	public function unitVector():GeometryVector {
		var mag:Float = this.getMag();
		return new GeometryVector(this.x / mag, this.y / mag);
	}

	public function setMag(mag:Float):Bool {
		if (this.getMag() == 0) {
			return false;
		}
		var unit:GeometryVector = this.unitVector();
		this.x = unit.x * mag;
		this.y = unit.y * mag;
		return true;
	}

	public function setRot(rad:Float):Void {
		var mag:Float = this.getMag();
		this.x = mag * Math.cos(rad);
		this.y = mag * Math.sin(rad);
	}

	public function addVec(vec:GeometryVector):Void {
		this.x += vec.x;
		this.y += vec.y;
	}

	public function zero():Void {
		this.x = 0;
		this.y = 0;
	}

	public function neg():GeometryVector {
		return new GeometryVector(-this.x, -this.y);
	}

	public function rotate(theta:Float):GeometryVector {
		var x:Float = this.x * Math.cos(theta) - this.y * Math.sin(theta);
		var y:Float = this.x * Math.sin(theta) - this.y * Math.cos(theta);
		return new GeometryVector(x, y);
	}

	public function dot(vec:GeometryVector):Float {
		var l1:Float = getMag();
		var l2:Float = vec.getMag();
		if (l1 == 0 || l2 == 0) {
			return 0;
		}
		return (this.x * vec.x + this.y * vec.y) / (l1 * l2);
	}

	public function angleBetween(vec:GeometryVector):Float {
		var l1:Float = getMag();
		var l2:Float = vec.getMag();
		if (l1 == 0 || l2 == 0) {
			return 0;
		}
		return Math.acos((this.x * vec.x + this.y * vec.y) / (l1 * l2));
	}
}
