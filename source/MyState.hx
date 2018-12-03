package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxTimer;

class MyState extends FlxState {
	override public function create():Void
	{
		FlxG.camera.fade(0xff000000, 0.5, true);
	}
	
	function switchState(other:FlxState):Void
	{
		FlxG.camera.fade(0xff000000, 0.5, function() {
			FlxG.switchState(other);
		});
	}
	
	function reset(?t:FlxTimer):Void
	{
		FlxG.camera.fade(0xff000000, 0.5, function() {
			FlxG.resetState();
		});
	}
}