package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxBitmapText;

class MenuState extends FlxState {
	
	override public function create():Void
	{
		var titleText:FlxBitmapText = new FlxBitmapText(Fonts.defaultFont);
		titleText.autoSize = false;
		titleText.fieldWidth = FlxG.width;
		titleText.alignment = "center";
		titleText.text = "GOO GLOW";
		titleText.y = FlxG.height * 0.25;
		titleText.scale.set(5, 5);
		titleText.color = 0x80ff00;
		add(titleText);
		
		var startText:FlxBitmapText = new FlxBitmapText(Fonts.defaultFont);
		startText.autoSize = false;
		startText.fieldWidth = FlxG.width;
		startText.alignment = "center";
		startText.text = "Press any key to begin";
		startText.y = FlxG.height * 0.75;
		add(startText);
		
		super.create();
	}
	
	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.pressed.ANY) {
			FlxG.switchState(new PlayState());
		}
		super.update(elapsed);
	}
}