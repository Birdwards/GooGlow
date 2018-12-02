package;

import flixel.graphics.frames.FlxBitmapFont;

class Fonts {
	public static var defaultFont:FlxBitmapFont;
	
	public static function init():Void {
		defaultFont = FlxBitmapFont.fromXNA("assets/images/good_neighbors_xna_0.png", " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ ");
	}
}