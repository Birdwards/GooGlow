package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
using flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import openfl.display.BitmapDataChannel;
//import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class PlayState extends FlxState
{
	static var GRAVITY:Float = 500;
	static var SPLAT_VEL:Float = 250;
	static var NUM_LIVES:Int = 20;
	static var TUT_WIDTH:Int = 200;
	
	var maskRect:Rectangle;
	var startPoint:FlxPoint;
	var respawnTimer:FlxTimer;
	var livesLeft:Int;
	
	var player:FlxSprite;
	var splatEmitter:FlxEmitter;
	
	var levelData:TiledMap;
	var level:FlxTilemap;
	var levelMask:FlxSprite;
	var nullSprite:FlxSprite;
	
	var nullObs:FlxSprite;
	var obstacles:FlxTypedGroup<FlxSprite>;
	
	var nullPlat:FlxSprite;
	var platforms:FlxTypedGroup<FlxSprite>;
	var curPlatform:FlxSprite;
	
	var exit:FlxSprite;
	
	var tutText:FlxTypedGroup<FlxBitmapText>;
	var tutBox:FlxSprite;
	var tutCollision4:FlxSprite;
	var tutCollision6:FlxSprite;
	var curTut:Int;
	
	override public function create():Void
	{		
		respawnTimer = new FlxTimer();
		livesLeft = NUM_LIVES;
		
		levelData = new TiledMap("assets/data/level1.tmx");
		var someLayer:TiledTileLayer = cast(levelData.getLayer("main"), TiledTileLayer);
		
		level = new FlxTilemap();
		level.loadMapFromCSV(someLayer.csvData, "assets/images/tilesheet.png", 20, 20, FlxTilemapAutoTiling.FULL, 1, 1, 1);
		add(level);
		
		levelMask = new FlxSprite();
		levelMask.makeGraphic(Math.round(level.width), Math.round(level.height), 0xff000000);
		add(levelMask);
		maskRect = new Rectangle(0,0,levelMask.width, levelMask.height);
		
		nullSprite = new FlxSprite();
		nullSprite.makeGraphic(Math.round(level.width), Math.round(level.height), 0);
		
		var exitLayer:TiledObjectLayer = getObjectLayer("exit");
		exit = new FlxSprite(exitLayer.objects[0].x, exitLayer.objects[0].y);
		exit.makeGraphic(20, 20, 0xffffffff);
		add(exit);
		
		nullObs = new FlxSprite().makeGraphic(20, 20, 0xffff0000);
		
		obstacles = new FlxTypedGroup();
		var obstacleLayer:TiledObjectLayer = getObjectLayer("obstacles");
		var obstaclePathLayer:TiledObjectLayer = getObjectLayer("obstaclePaths");
		if (obstaclePathLayer != null) {
			for (op in obstaclePathLayer.objects) {
				for (p in op.points) {
					p.x += op.x;
					p.y += op.y;
				}
			}
		}
		if (obstacleLayer != null) {
			for (o in obstacleLayer.objects) {
				var newObs:FlxSprite = new FlxSprite(o.x, o.y);
				newObs.makeGraphic(20, 20, 0xff000000, true);
				newObs.immovable = true;
				if (obstaclePathLayer != null) {
					for (op in obstaclePathLayer.objects) {
						if (op.name == o.name) {
							FlxTween.linearPath(newObs, op.points, 100, false, {ease:FlxEase.sineInOut, type:FlxTweenType.PINGPONG});
							break;
						}
					}
				}
				obstacles.add(newObs);
			}
		}		
		add(obstacles);
		
		nullPlat = new FlxSprite().makeGraphic(20, 20, 0xff0000ff);
		
		platforms = new FlxTypedGroup();
		var platformLayer:TiledObjectLayer = getObjectLayer("platforms");
		var platformPathLayer:TiledObjectLayer = getObjectLayer("platformPaths");
		if (platformPathLayer != null) {
			for (pp in platformPathLayer.objects) {
				for (p in pp.points) {
					p.x += pp.x;
					p.y += pp.y;
				}
			}
		}
		if (platformLayer != null) {
			for (p in platformLayer.objects) {
				var newPlat:FlxSprite = new FlxSprite(p.x, p.y);
				newPlat.makeGraphic(60, 10, 0xff000000, true);
				newPlat.immovable = true;
				if (platformPathLayer != null) {
					for (pp in platformPathLayer.objects) {
						if (pp.name == p.name) {
							FlxTween.linearPath(newPlat, pp.points, 50, false, {ease:FlxEase.sineInOut, type:FlxTweenType.PINGPONG});
							break;
						}
					}
				}			
				platforms.add(newPlat);
			}
		}		
		add(platforms);
		
		curPlatform = null;
		
		var tutLayer:TiledObjectLayer = getObjectLayer("tutText");
		tutText = new FlxTypedGroup();
		if (tutLayer != null) {
			tutLayer.objects.sort( function(a:TiledObject, b:TiledObject):Int {
				return Std.parseInt(a.name) - Std.parseInt(b.name);
			});
			for (t in tutLayer.objects) {
				var tempText:FlxBitmapText = new FlxBitmapText(Fonts.defaultFont);
				tempText.autoSize = false;
				tempText.fieldWidth = TUT_WIDTH;
				tempText.alignment = "center";
				tempText.text = t.properties.get("caption");
				tempText.x = t.x + (t.width-TUT_WIDTH)*0.5;
				tempText.y = t.y - tempText.height - 20;
				tempText.visible = false;
				tutText.add(tempText);
			}
			add(tutText);
			curTut = 0;
			tutText.members[curTut].visible = true;
			
			tutBox = new FlxSprite(tutLayer.objects[1].x, tutLayer.objects[1].y, "assets/images/tutBox.png");
			tutBox.visible = false;
			add(tutBox);
			
			tutCollision4 = new FlxSprite(tutLayer.objects[4].x, tutLayer.objects[4].y);
			tutCollision4.makeGraphic(tutLayer.objects[4].width, tutLayer.objects[4].height, 0);
			add(tutCollision4);
			
			tutCollision6 = new FlxSprite(tutLayer.objects[6].x, tutLayer.objects[6].y);
			tutCollision6.makeGraphic(tutLayer.objects[6].width, tutLayer.objects[6].height, 0);
			add(tutCollision6);
		} else {
			tutBox = new FlxSprite();
			tutCollision4 = new FlxSprite();
			tutCollision6 = new FlxSprite();
			curTut = -1;
		}
		
		var playerLayer:TiledObjectLayer = getObjectLayer("player");
		startPoint = new FlxPoint(playerLayer.objects[0].x, playerLayer.objects[0].y);
		
		player = new FlxSprite(startPoint.x, startPoint.y);
		player.makeGraphic(20, 20, 0xff0080ff);
		player.width = 16;
		player.height = 16;
		player.offset.x = 2;
		player.offset.y = 4;
		player.acceleration.y = GRAVITY;
		player.drag.x = 500;
		player.maxVelocity.x = 250;
		player.maxVelocity.y = 1000;
		add(player);
		
		splatEmitter = new FlxEmitter(player.x, player.y);
		splatEmitter.setSize(player.width, player.height);
		//splatEmitter.makeParticles(4, 4, 0xff00ff00, 30);
		for (i in 0...30) {
		  splatEmitter.add(new SplatParticle());
		}
		splatEmitter.launchMode = FlxEmitterMode.SQUARE;
		splatEmitter.acceleration.set(0,GRAVITY);
		splatEmitter.solid = true;
		add(splatEmitter);
		
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		splatEmitter.x = player.x;
		splatEmitter.y = player.y;
		
		if (curPlatform != null && curPlatform.last.y < curPlatform.y) {
			player.y += curPlatform.y - curPlatform.last.y;
		}
		curPlatform = null;
		
		FlxG.collide(player, level);
		FlxG.collide(player, platforms, function(a:FlxSprite, b:FlxSprite){if (b.isTouching(FlxObject.UP)) {curPlatform = b;}});
		FlxG.collide(player, obstacles, playerHitSpike);
		FlxG.overlap(player, exit, exitLevel);
		FlxG.collide(splatEmitter, level, drawSplatOnLevel);
		FlxG.collide(splatEmitter, platforms, drawSplatOnSprite(nullPlat));
		FlxG.collide(splatEmitter, obstacles, drawSplatOnSprite(nullObs));
		
		if (curTut == 1 && FlxG.overlap(player, tutBox)) {
			nextTut();
		}
		
		if (curTut == 3 && FlxG.overlap(player, tutCollision4)) {
			nextTut();
		}
		
		if (curTut == 5 && FlxG.overlap(player, tutCollision6)) {
			nextTut();
		}
		
		player.acceleration.x = 0;
		if (FlxG.keys.pressed.RIGHT) {
			player.acceleration.x = 500;
		}
		if (FlxG.keys.pressed.LEFT) {
			player.acceleration.x = -500;
		}
		if (FlxG.keys.justPressed.UP &&
			((player.isTouching(FlxObject.FLOOR) && (curTut == -1 || curTut >= 3))
			|| ((curTut == -1 || curTut >= 5) && (player.isTouching(FlxObject.LEFT) || player.isTouching(FlxObject.RIGHT))))) {
			player.velocity.y = -250;
		}
		if (FlxG.keys.justPressed.DOWN && player.alive && (curTut == -1 || curTut >= 2)) {	
			if (curTut == 2) {
				nextTut();
				tutBox.visible = false;
			}
			if (curTut == 4) {
				nextTut();
			}
					
			splatEmitter.velocity.set(
				-SPLAT_VEL+player.velocity.x,
				-SPLAT_VEL+player.velocity.y,
				SPLAT_VEL+player.velocity.x,
				player.velocity.y); //SPLAT_VEL+player.velocity.y); //this needs to be called before killPlayer, so velocity isn't reset yet yet
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
		livesLeft -= 1;
		if (livesLeft > 0) {
			respawnTimer.start(1, function(t:FlxTimer) {
				player.x = startPoint.x;
				player.y = startPoint.y;
				player.revive();
			});
		} else {
			respawnTimer.start(1, function(t:FlxTimer) {
				FlxG.resetState();
			});
		}
	}
	
	function drawSplatOnLevel(a:FlxSprite, b:FlxTilemap):Void {
		//what a weird way to create an alpha mask! Thank you FlxShapeDonut for the inspiration!
		levelMask.pixels.copyChannel(levelMask.pixels, maskRect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.BLUE);
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
		levelMask.drawRect(Math.round(a.x), Math.round(a.y), a.width, a.height, 0xff000000);
		
		levelMask.pixels.copyChannel(levelMask.pixels, maskRect, new Point(), BitmapDataChannel.BLUE, BitmapDataChannel.ALPHA);
		levelMask.pixels.copyChannel(nullSprite.pixels, maskRect, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.BLUE);
		a.kill();
	}
	
	
	
	function drawSplatOnSprite(template:FlxSprite):FlxSprite->FlxSprite->Void {
		return function (a:FlxSprite, b:FlxSprite):Void {
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
				b.pixels.copyPixels(template.pixels, intersect.copyToFlash(), new Point(intersect.x,intersect.y));
			}
			a.kill();
		}
	}
	
	function getObjectLayer(name:String):TiledObjectLayer {
		var layer:TiledLayer = levelData.getLayer(name);
		if (layer == null) {
			return null;
		}
		return cast(layer, TiledObjectLayer);
	}
	
	function exitLevel(a:FlxSprite, b:FlxSprite):Void {
		if (a.x >= b.x && a.x + a.width <= b.x + b.width && a.y >= b.y && a.y + a.height <= b.y + b.height) {
			a.kill();
			//todo: increment level
			respawnTimer.start(1, function(t:FlxTimer) {
				FlxG.resetState();
			});
		}		
	}
	
	function playerHitSpike(a:FlxSprite, b:FlxSprite):Void {
		if (curTut == 0) {
			nextTut();			
			tutBox.visible = true;
		}
		killPlayer();
	}
	
	function nextTut():Void {
		tutText.members[curTut].visible = false;
		curTut += 1;
		tutText.members[curTut].visible = true;
	}
}
