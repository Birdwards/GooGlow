package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		
		FlxG.signals.preGameStart.add(Fonts.init);
		FlxG.signals.preGameStart.add(Reg.init);
		FlxG.signals.preGameStart.add(Sounds.init);
		addChild(new FlxGame(640, 360, PlayState, true, true));
		
		FlxG.autoPause = false;
		FlxG.mouse.useSystemCursor = true;
	}
}
