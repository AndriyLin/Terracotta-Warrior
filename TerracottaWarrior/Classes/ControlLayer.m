//
//  ControlLayer.m
//
//  Copyright 2011 qrc. All rights reserved.
//

#import "ControlLayer.h"
#import "PauseScene.h"
#import "SelectBarrier.h"


@implementation ControlLayer

@synthesize gLayer;
@synthesize wlayer;
@synthesize mapLayer;
@synthesize mscene;
@synthesize lbScore;
@synthesize pausesprite;
@synthesize pausesheet;
@synthesize isover;



-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		//original_point = CGRect(0,0,32,32);
		[self setIsTouchEnabled:YES];
		tottime = 0;
		texwidth = 64;
		texhei = 64;
		intervaltime = 0.0025;
		clactimes = 0;
		gogogotime = 0;
		[self schedule:@selector(KeepDoing) interval: intervaltime];
		//[music init];
		//[self addChild:music];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"jump.mp3"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"unjump.mp3"];
		
		lbScore = [CCLabelBMFont labelWithString:@"Time: 0" fntFile:@"font09.fnt"];
		lbScore.anchorPoint = ccp(1.0, 1.0);
		lbScore.scale = 0.6;
		[self addChild:lbScore z:1 tag:3];
		lbScore.position = ccp(480, 320);	
		
		//CCSpriteBatchNode *mgr = [CCSpriteBatchNode spriteSheetWithFile:@"tileSet.png" capacity:5];
		//[self addChild:mgr z:1 tag:4];
		
		//CCSprite *sprite = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake(12 * 32,0,32,32) ];
		//[mgr addChild:sprite z:1 tag:5];
		
		pausesheet = [CCSpriteBatchNode batchNodeWithFile:@"pausesprite.png" capacity:5];
		[self addChild:pausesheet z:1 tag: 456];
		
		pausesprite = [CCSprite spriteWithTexture:pausesheet.texture rect:CGRectMake(0,0,96,32) ];
		pausesprite.anchorPoint = ccp(0,1);
		pausesprite.position = ccp(0,320);
		[pausesheet addChild:pausesprite z:1 tag: 123];
		
		isover = NO;
		
		//iftaste = NO;
		//sprite.scale = 1.1;
		//sprite.anchorPoint = ccp(0, 1);
		//sprite.position = ccp(0, 320);
		
		//CCBitmapFontAtlas *lbLife = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"3" fntFile:@"font09.fnt"];
		//lbLife.anchorPoint = ccp(0.0, 1.0);
		//lbLife.scale = 0.6;
		//[self addChild:lbLife z:1 tag:6];
		//lbLife.position = ccp(40, 312);
		
		//[self schedule:@selector(step) interval: 1];
		
		//[self schedule:@selector(UpdateView) interval: 0.05];
	}
	return self;
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
}


- (void) KeepDoing;
{	
	//if (iftaste == YES) [[CCDirector sharedDirector] popScene];
	//if (wlayer.iflose == YES) [[CCDirector sharedDirector] popScene];
	if (isover == YES)
	{
		CCScene *sc = [SelectBarrier ShowScene];	
		[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.2f scene:sc]];
	}
	++ clactimes;
	if (clactimes == 80)
	{
		NSLog(@"who can defend me!");
		clactimes = 0;
		++ gogogotime;
		wlayer.tottime = gogogotime;
		NSString *string = [NSString stringWithFormat:@"Time: %d", gogogotime];
		
		CCLabelBMFont *label1 = (CCLabelBMFont*) [self getChildByTag:3];
		[label1 setString:string];
	}
	if (wlayer.kAct == kStay)
	{
		tottime = 0;
		[wlayer settex:0];
		return;
	}
	
	tottime += intervaltime;
	if (wlayer.ifjump && speedtest) 
	{
		speedtime += intervaltime;
		return;
	}
	if (wlayer.kAct == kRightUp)
	{
		if ([wlayer gojump] == NO) 
		{
			tottime = 0;
			[[SimpleAudioEngine sharedEngine] playEffect:@"unjump.mp3"];
		}
		return;
	}
	if (wlayer.kAct == kLeftUp)
	{
		if ([wlayer gojump] == NO)
		{
			tottime = 0;
			[[SimpleAudioEngine sharedEngine] playEffect:@"unjump.mp3"];
		}	
		return;
	}
	if (tottime >= 0.125) tottime -= 0.125;
	if (tottime <= 0.02075) [wlayer settex:(wlayer.kAct * 6 + 1)];
	if (tottime > 0.02075 && tottime <= 0.04) [wlayer settex:(wlayer.kAct * 6 + 2)];
	if (tottime > 0.04 && tottime <= 0.061) [wlayer settex:(wlayer.kAct * 6 + 3)];
	if (tottime > 0.061 && tottime <= 0.083) [wlayer settex:(wlayer.kAct * 6 + 4)];
	if (tottime > 0.083 && tottime <= 0.104) [wlayer settex:(wlayer.kAct * 6 + 5)];
	if (tottime > 0.104 && tottime <= 0.125) [wlayer settex:(wlayer.kAct * 6 + 6)];
	
	[wlayer dealwithsprite:curposi];
	
	
}

-(CGRect)AtlasRect:(CCSprite *)atlSpr
{
	CGRect rc = [atlSpr textureRect];
	return CGRectMake( - rc.size.width / 2, -rc.size.height / 2, rc.size.width, rc.size.height);	
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint local;
	CGRect r;
	CGPoint location1 = [touch locationInView:[touch view]];
	CGPoint point1 = [[CCDirector sharedDirector] convertToGL:location1];
	if (point1.x < 96 && point1.y > 320 - 32)
	{
		CCScene *sc = [PauseScene ShowScene:self];
		[[CCDirector sharedDirector] pushScene:sc];
		//iftaste = YES;
		
		return NO;
		
	}
	if (wlayer.ifjump) return NO;
	local = [wlayer.ManSprite convertTouchToNodeSpaceAR:touch];
	r = [self AtlasRect:wlayer.ManSprite];	
	if( CGRectContainsPoint( r, local))
	{
		wlayer.befocused = YES;
		NSLog(@"it shall be done! to battle! fine!");
		return YES;
	}
	return NO;
}


-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint local;
	//CGRect r;
	if (wlayer.ifjump) return;
	if (wlayer.befocused)
	{
		curposi = touch;
		local = [wlayer.ManSprite convertTouchToNodeSpaceAR:touch];
		if (local.y > local.x / 2 && local.x > wlayer.ManSprite.textureRect.size.width / 2)
		{
			wlayer.ifjump = YES;
			wlayer.Manloca = wlayer.ManSprite.position;
			tottime = 0;
			speedtime = 0;
			speedtest = YES;
			wlayer.kAct = kRightUp;
			
			NSLog(@"Right");
			return;
		}
		if (local.y > -local.x / 2 && local.x < -wlayer.ManSprite.textureRect.size.width / 2)
		{
			wlayer.ifjump = YES;
			wlayer.Manloca = wlayer.ManSprite.position;
			tottime = 0;
			speedtime = 0;
			speedtest = YES;
			wlayer.kAct = kLeftUp;
			NSLog(@"Left");
			return;
		}
		if (local.x > wlayer.ManSprite.textureRect.size.width / 2) 
		{
			if (wlayer.kAct == kLeft)
			{
				tottime = 0;
			}
			wlayer.kAct = kRight;
		}
		else 
		if (local.x < -wlayer.ManSprite.textureRect.size.width / 2)
		{
			if (wlayer.kAct == kRight)
			{
				tottime = 0;
			}
			NSLog(@"%d",wlayer.kAct);
			wlayer.kAct = kLeft;
		}
		//else kAct = kStay;
	}
}

-(void) givespeed: (UITouch *) posi
{
	CGPoint tmp;
	tmp = [posi locationInView:nil];
	NSLog(@"%f %f",tmp.x,tmp.y);
	float ttt;
	ttt = tmp.x;
	tmp.x = tmp.y;
	tmp.y = ttt;
	float grade;
	wlayer.godist = (float)sqrt((tmp.x - wlayer.Manloca.x) * (tmp.x - wlayer.Manloca.x) + (tmp.y - wlayer.Manloca.y) * (tmp.y - wlayer.Manloca.y));
	grade = wlayer.godist / (float)speedtime;
	NSLog(@"%f %f %f",wlayer.godist,speedtime,grade);
	wlayer.gox = tmp.x - wlayer.Manloca.x;
	wlayer.goy = tmp.y - wlayer.Manloca.y;
	if (grade > 3000) [wlayer runwithspeed: 2];
	else if (grade < 400) [wlayer runwithspeed: 1];
	else [wlayer runwithspeed:(float) grade / (float)2600 + (float) 11.0 / (float)13.0];
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (wlayer.ifjump && speedtest == YES) 
	{
		speedtest = NO;
		[self givespeed: touch];
		[[SimpleAudioEngine sharedEngine] playEffect:@"jump.mp3"];
		int itmp = [wlayer checkbound];
		if (itmp == 1 || (itmp == 3 && wlayer.kAct == kRightUp) || (itmp == 4 && wlayer.kAct == kLeftUp))
		{
			wlayer.ifjump = NO;
			wlayer.crash = NO;
			wlayer.kAct = kStay;
			NSLog(@"gotothefinal!");
		}
			
		return;
	}
	if (wlayer.ifjump) return;
	wlayer.kAct = kStay;
	wlayer.befocused = NO;
	
}

- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}


-(void) UpdateView
{
	//if (wlayer.Vx == 0 && wlayer.Vy == 0) {
	//	return;
	//}
	if (wlayer.befocused) {
		//[mapLayer MakePresentMap];
	}
	//[mapLayer MakePresentMap];
}
		 

@end
