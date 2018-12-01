package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		
		addChild(new FlxGame(640, 360, PlayState, true, true));
		
		FlxG.autoPause = false;
		FlxG.mouse.useSystemCursor = true;
	}
}
