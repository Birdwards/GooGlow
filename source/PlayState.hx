package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tile.FlxTilemap;
using flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import openfl.display.BitmapDataChannel;
//import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class PlayState extends FlxState
{
	static var GRAVITY:Float = 500;
	
	var maskRect:Rectangle;
	var startPoint:FlxPoint;
	var respawnTimer:FlxTimer;
	
	var player:FlxSprite;
	var splatEmitter:FlxEmitter;
	
	var level:FlxTilemap;
	var levelMask:FlxSprite;
	var nullSprite:FlxSprite;
	
	var nullObs:FlxSprite;
	var obstacles:FlxTypedGroup<FlxSprite>;
	
	override public function create():Void
	{		
		respawnTimer = new FlxTimer();
		
		var levelData:TiledMap = new TiledMap("assets/data/testmap.tmx");
		var someLayer:TiledTileLayer = cast(levelData.getLayer("main"), TiledTileLayer);
		
		level = new FlxTilemap();
		level.loadMapFromCSV(someLayer.csvData, "assets/images/testsheet.png", 20, 20, 1, 1, 1);
		add(level);
		
		levelMask = new FlxSprite();
		levelMask.makeGraphic(Math.round(level.width), Math.round(level.height), 0xff000000);
		add(levelMask);
		maskRect = new Rectangle(0,0,levelMask.width, levelMask.height);
		
		nullSprite = new FlxSprite();
		nullSprite.makeGraphic(Math.round(level.width), Math.round(level.height), 0);
		
		nullObs = new FlxSprite().makeGraphic(20, 20, 0xffff0000);
		
		obstacles = new FlxTypedGroup();
		var obstacleLayer:TiledObjectLayer = cast(levelData.getLayer("obstacles"), TiledObjectLayer);
		for (o in obstacleLayer.objects) {
			var newObs:FlxSprite = new FlxSprite(o.x, o.y);
			newObs.makeGraphic(20, 20, 0xff000000);
			//newObs.alpha = 0.5;
			//newObs.pixels.copyPixels(nullObs.pixels, new Rectangle(-10,-5,20,20), new Point(-10,-5));
			newObs.immovable = true;
			obstacles.add(newObs);
		}
		add(obstacles);	
		
		startPoint = new FlxPoint(20, 320);
		
		player = new FlxSprite(startPoint.x, startPoint.y);
		player.makeGraphic(20, 20, 0xff0080ff);
		player.acceleration.y = GRAVITY;
		player.drag.x = 500;
		player.maxVelocity.x = 250;
		player.maxVelocity.y = 1000;
		add(player);
		
		splatEmitter = new FlxEmitter(player.x, player.y);
		splatEmitter.setSize(player.width, player.height);
		splatEmitter.makeParticles(4, 4, 0xff00ff00, 30);
		splatEmitter.launchMode = FlxEmitterMode.SQUARE;
		splatEmitter.velocity.set(-250,-250,250,250);
		splatEmitter.acceleration.set(0,GRAVITY);
		splatEmitter.solid = true;
		add(splatEmitter);
		
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		splatEmitter.x = player.x;
		splatEmitter.y = player.y;
		
		FlxG.collide(player, level);
		FlxG.collide(player, obstacles, function(a:FlxSprite, b:FlxSprite){killPlayer();});
		FlxG.collide(splatEmitter, level, drawSplatOnLevel);
		FlxG.collide(splatEmitter, obstacles, drawSplatOnSprite);
		
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
		if (FlxG.keys.justPressed.DOWN) {
			killPlayer();
			
			splatEmitter.start();
			
			for (o in obstacles.members) {
				var testRect:FlxRect = new FlxRect(player.x - player.width, player.y -player.height, player.width*3, player.height*3);
				var intersect:FlxRect = testRect.intersection(o.getHitbox());
				if (!intersect.isEmpty) {
					intersect.x -= o.x;
					intersect.y -= o.y;
					o.pixels.copyPixels(nullObs.pixels, intersect.copyToFlash(), new Point(intersect.x,intersect.y));
				}
			}
		}
		super.update(elapsed);
	}
	
	function killPlayer():Void {
		player.kill();
		player.acceleration.x = 0;
		player.velocity.x = 0;
		player.velocity.y = 0;
		respawnTimer.start(1, function(t:FlxTimer) {
			player.x = startPoint.x;
			player.y = startPoint.y;
			player.revive();
		});
	}
	
	function drawSplatOnLevel(a:FlxSprite, b:FlxTilemap):Void {
		//what a weird way to create an alpha mask! Thank you FlxShapeDonut for the inspiration!
		levelMask.pixels.copyChannel(levelMask.pixels, maskRect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.BLUE);
		if (a.isTouching(FlxObject.RIGHT)) {
			levelMask.drawRect(Math.round(a.x+a.width), Math.round(a.y), a.width, a.height, 0xff000000);
		} else if (a.isTouching(FlxObject.LEFT)) {
			levelMask.drawRect(Math.round(a.x-a.width), Math.round(a.y), a.width, a.height, 0xff000000);
		} else if (a.isTouching(FlxObject.DOWN)) {
			levelMask.drawRect(Math.round(a.x), Math.round(a.y+a.height), a.width, a.height, 0xff000000);
		} else if (a.isTouching(FlxObject.UP)) {
			levelMask.drawRect(Math.round(a.x), Math.round(a.y-a.height), a.width, a.height, 0xff000000);
		}
		
		levelMask.pixels.copyChannel(levelMask.pixels, maskRect, new Point(), BitmapDataChannel.BLUE, BitmapDataChannel.ALPHA);
		levelMask.pixels.copyChannel(nullSprite.pixels, maskRect, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.BLUE);
		a.kill();
	}
	
	function drawSplatOnSprite(a:FlxSprite, b:FlxSprite):Void {
		if (a.isTouching(FlxObject.RIGHT)) {
			a.x += a.width;
		} else if (a.isTouching(FlxObject.LEFT)) {
			a.x -= a.width;
		}
		if (a.isTouching(FlxObject.DOWN)) {
			a.y += a.height;
		} else if (a.isTouching(FlxObject.UP)) {
			a.y -= a.height;
		}
		var intersect:FlxRect = a.getHitbox().intersection(b.getHitbox());
		if (!intersect.isEmpty) {
			intersect.x -= b.x;
			intersect.y -= b.y;
			b.pixels.copyPixels(nullObs.pixels, intersect.copyToFlash(), new Point(intersect.x,intersect.y));
		}
		a.kill();
	}
}
