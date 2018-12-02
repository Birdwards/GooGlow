package;

import flixel.effects.particles.FlxParticle;
import flixel.math.FlxRandom;

class SplatParticle extends FlxParticle {
	
	static var rando:FlxRandom;
	
	public function new() {
		super();
		if (rando == null) {
			rando = new FlxRandom();
		}
		var randSize:Int = rando.int(2, 8);
		makeGraphic(randSize, randSize, 0xff80ff00);
	}
}