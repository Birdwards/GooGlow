package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxBitmapText;

class EndState extends MyState {
	
	override public function create():Void
	{
		var titleText:FlxBitmapText = new FlxBitmapText(Fonts.defaultFont);
		titleText.autoSize = false;
		titleText.fieldWidth = FlxG.width;
		titleText.alignment = "center";
		titleText.text = "You have reached the end...\n...of the levels that I had time to make during Ludum Dare. :P\n\nI'm definitely thinking of doing a post-compo version of this.\n\nThat's all for now... thanks for playing!";
		titleText.y = FlxG.height * 0.25;
		titleText.color = 0x80ff00;
		add(titleText);
		
		var startText:FlxBitmapText = new FlxBitmapText(Fonts.defaultFont);
		startText.autoSize = false;
		startText.fieldWidth = FlxG.width;
		startText.alignment = "center";
		startText.text = "Press any key to quit";
		startText.y = FlxG.height * 0.75;
		add(startText);
		
		super.create();
	}
	
	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.pressed.ANY) {
			quit();
		}
		super.update(elapsed);
	}
}