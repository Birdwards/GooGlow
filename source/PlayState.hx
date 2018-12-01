package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxTilemap;

class PlayState extends FlxState
{
	var player:FlxSprite;
	var level:FlxTilemap;
	
	override public function create():Void
	{
		var levelData:TiledMap = new TiledMap("assets/data/testmap.tmx");
		var someLayer:TiledTileLayer = cast(levelData.getLayer("main"), TiledTileLayer);
		
		level = new FlxTilemap();
		level.loadMapFromCSV(someLayer.csvData, "assets/images/testsheet.png", 20, 20, 1, 1, 2);
		add(level);
		
		player = new FlxSprite(20, 320);
		player.makeGraphic(20, 20, 0xff0000ff);
		player.acceleration.y = 500;
		player.drag.x = 500;
		player.maxVelocity.x = 250;
		player.maxVelocity.y = 1000;
		add(player);
		
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		FlxG.collide(player,level);
		
		player.acceleration.x = 0;
		if (FlxG.keys.pressed.RIGHT) {
			player.acceleration.x = 500;
		}
		if (FlxG.keys.pressed.LEFT) {
			player.acceleration.x = -500;
		}
		if (FlxG.keys.justPressed.UP && player.isTouching(FlxObject.FLOOR)) {
			player.velocity.y = -250;
		}
		super.update(elapsed);
	}
}
