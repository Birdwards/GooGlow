package;

import flixel.FlxG;
import flixel.system.FlxSound;

class Sounds {
	public static var jump:FlxSound;
	public static var die:FlxSound;
	public static var explode:FlxSound;
	public static var exit:FlxSound;
	
	public static function init():Void {
		jump = FlxG.sound.load("assets/sounds/jump.wav", 0.5);
		jump.persist = true;
		die = FlxG.sound.load("assets/sounds/die.wav");
		die.persist = true;
		explode = FlxG.sound.load("assets/sounds/explode2.wav");
		explode.persist = true;
		exit = FlxG.sound.load("assets/sounds/exit.wav");
		exit.persist = true;
	}
}