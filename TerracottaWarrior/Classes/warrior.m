//
//  warrior.m
//
//  Copyright 2011 qrc. All rights reserved.
//

#import "warrior.h"
#import "LoseScene.h"
#import "WinScene.h"


@implementation warrior

@synthesize Vx;
@synthesize Vy;
@synthesize gLayer;
@synthesize ManSprite;
@synthesize kAct;
@synthesize befocused;
@synthesize runSpeed;
@synthesize moveStep;
@synthesize ifjump;
@synthesize gox;
@synthesize goy;
@synthesize godist;
@synthesize Manloca;
@synthesize mlayer;
@synthesize crash;
@synthesize iflose;
@synthesize tottime;

-(id) myinit: (int) curmission
{
	if( (self=[super init] )) {
		runSpeed = 10;
		moveStep = 4;
		orispeed = 100;
		kAct = kStay;
		SheetGo = [CCSpriteBatchNode batchNodeWithFile:@"go.png" capacity:24];
		[self addChild:SheetGo z:0 tag:10];
		ManSprite = [CCSprite spriteWithTexture:SheetGo.texture rect:CGRectMake(0,0,64,64)];
		[SheetGo addChild:ManSprite z:1 tag:2];
		ManSprite.position = ccp(240,64);
		befocused = NO;
		ifjump = NO;
		crash = NO;
		leftbound = -12;
		rightbound = 12;
		iflose = NO;
		ifwin = NO;
		[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"background.mp3"];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background.mp3"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"bump.mp3"];
		curbarrier = curmission;
		if (curbarrier == 1)
		{
			besttime = [[NSUserDefaults standardUserDefaults] integerForKey:@"TWTASK1"];
		}
		if (curbarrier == 2)
		{
			besttime = [[NSUserDefaults standardUserDefaults] integerForKey:@"TWTASK2"];
		}
		if (curbarrier == 3)
		{
			besttime = [[NSUserDefaults standardUserDefaults] integerForKey:@"TWTASK3"];
		}
		if (curbarrier == 4)
		{
			besttime = [[NSUserDefaults standardUserDefaults] integerForKey:@"TWTASK4"];
		}
	}
	return self;
}


- (void) settex:(int) index
{
	[ManSprite setTextureRect:CGRectMake(index * 64,0,64,64)];
}

- (void) setpos:(CGPoint)posi
{
	[ManSprite setPosition:posi];
}

-(CGRect)AtlasRect:(CCSprite *)atlSpr
{
	CGRect rc = [atlSpr textureRect];
	return CGRectMake( - rc.size.width / 2, -rc.size.height / 2, rc.size.width, rc.size.height);	
}

- (void) losegame
{
	if (iflose == YES) return;
	iflose = YES;
	//NSLog(@"haha!You Lose!");
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	CCScene *sc = [LoseScene ShowScene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5f scene:sc]];
}

- (void) wingame
{
	if (ifwin == YES) return;
	ifwin = YES;
	if (tottime < besttime || besttime == 0) 
	{
		if (curbarrier == 1) [[NSUserDefaults standardUserDefaults] setInteger:tottime forKey:@"TWTASK1"];
		if (curbarrier == 2) [[NSUserDefaults standardUserDefaults] setInteger:tottime forKey:@"TWTASK2"];
		if (curbarrier == 3) [[NSUserDefaults standardUserDefaults] setInteger:tottime forKey:@"TWTASK3"];
		if (curbarrier == 4) [[NSUserDefaults standardUserDefaults] setInteger:tottime forKey:@"TWTASK4"];
		besttime = tottime;
	}
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	CCScene *sc = [WinScene ShowScene:tottime besttime:besttime];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5f scene:sc]];
}


- (int) anothercheckbound
{
	int t1,t3,t4,t5,t6,t7,t11,t12,t31,t32,t41,t42,t51,t52,t61,t62,t71,t72;
	t1 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound,ManSprite.position.y + 32)];
	t11 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound,ManSprite.position.y + 27)];
	t12 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound + 5,ManSprite.position.y + 32)];
	t3 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound,ManSprite.position.y + 32)];
	t32 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound - 5,ManSprite.position.y + 32)];
	t31 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound,ManSprite.position.y + 27)];
	t4 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound,ManSprite.position.y)];
	t41 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound,ManSprite.position.y + 5)];
	t42 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound,ManSprite.position.y - 5)];
	t5 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound,ManSprite.position.y - 32)];
	t51 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound,ManSprite.position.y - 27)];
	t52 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound - 5,ManSprite.position.y - 32)];
	t6 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound,ManSprite.position.y)];
	t61 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound,ManSprite.position.y + 5)];
	t62 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound,ManSprite.position.y - 5)];
	t7 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound,ManSprite.position.y - 32)];
	t71 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound,ManSprite.position.y - 27)];
	t72 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound + 5,ManSprite.position.y - 32)];
	if (t11 == 17 || t12 == 17 || t31 == 17 || t32 == 17 || t41 == 17 || t42 == 17 || t51 == 17 || t52 == 17 || t61 == 17 || t62 == 17 || t71 == 17 || t72 == 17) 
	{
		[self wingame];
		return -1;
	}
	if (t11 == 13 || t11 == 14 || t11 == 15 || t11 == 16 || t12 == 13 || t12 == 14 || t12 == 15 || t12 == 16 || t32 == 13 || t32 == 14 || t32 == 15 || t32 == 16 || t31 == 13 || t31 == 14 || t31 == 15 || t31 == 16 || t41 == 13 || t41 == 14 || t41 == 15 || t41 == 16 
		|| t42 == 13 || t42 == 14 || t42 == 15 || t42 == 16 || t51 == 13 || t51 == 14 || t51 == 15 || t51 == 16 || t52 == 13 || t52 == 14 || t52 == 15 || t52 == 16 || t61 == 13 || t61 == 14 || t61 == 15 || t61 == 16 || t62 == 13 || t62 == 14 || t62 == 15 || t62 == 16 
		|| t71 == 13 || t71 == 14 || t71 == 15 || t71 == 16 || t72 == 13 || t72 == 14 || t72 == 15 || t72 == 16)
	{
		[self losegame];
		return -1;
	}
	
	if (t3 != 1 && t31 != 1 && t3 != 17 && t31 != 17)
	{
		return 3;
	}
	if (t4 != 1 && ((t41 != 1 && t41 != 17) || (t42 != 1 && t42 != 17)))
	{
		return 3;
	}
	if (t5 != 1 && t51 != 1 && t5 != 17 && t51 != 17)
	{
		return 3;
	}
	if (t1 != 1 && t11 != 1 && t1 != 17 && t11 != 17)
	{
		return 4;
	}
	if (t6 != 1 && ((t61 != 1 && t61 != 17) || (t62 != 1 && t62 != 17)))
	{
		return 4;
	}
	if (t7 != 1 && t71 != 1 && t7 != 17 && t71 != 17)
	{
		return 4;
	}
	if ((t52 == 1 || t52 == 17) && (t72 == 1 || t72 == 17) && (t5 == 1 || t5 == 17) && (t7 == 1 || t7 == 17) && (kAct == kRight || kAct == kLeft)) return 5;
	
	return 0;
}



- (void) dealwithsprite :(UITouch*) curposi
{
	CGPoint local;
	CGRect r;
	int itmp;
	itmp = [self anothercheckbound];
	if (itmp == 3 && kAct == kRight)
	{
		//NSLog(@"gotothebeach");
		kAct = kStay;
		return;
	}
	if (itmp == 4 && kAct == kLeft)
	{
		kAct = kStay;
		return;
	}
	if (itmp == 5)
	{
		//NSLog(@"for honor!");
		ifjump = YES;
		if (kAct == kRight) 
		{
			kAct = kRightUp;
			Vx = 500;
		}
		else 
		{
			kAct = kLeftUp;
			Vx = -500;
		}
		Vy = 0;
		return;
	}
	
	local = [ManSprite convertTouchToNodeSpaceAR:curposi];
	r = [self AtlasRect:ManSprite];	
	if( CGRectContainsPoint( r, local))
	{
		kAct = kStay;
	}
	if (kAct == kRight)
	{
		[ManSprite setPosition:ccp(ManSprite.position.x + moveStep, ManSprite.position.y)];
	}
	else if (kAct == kLeft)
	{
		[ManSprite setPosition:ccp(ManSprite.position.x - moveStep, ManSprite.position.y)];
	}	
}

- (void) runwithspeed:(float)grade
{
	nowspeed = grade * 570;
	Vx = nowspeed / godist * gox;
	Vy = nowspeed / godist * goy;
}


	

- (int) checkbound
{
	int t1,t3,t4,t5,t6,t7,t11,t12,t31,t32,t41,t42,t51,t52,t61,t62,t71,t72;
	t1 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound,ManSprite.position.y + 32)];
	t11 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound,ManSprite.position.y + 27)];
	t12 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound + 5,ManSprite.position.y + 32)];
	t3 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound,ManSprite.position.y + 32)];
	t32 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound - 5,ManSprite.position.y + 32)];
	t31 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound,ManSprite.position.y + 27)];
	t4 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound,ManSprite.position.y)];
	t41 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound,ManSprite.position.y + 5)];
	t42 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound,ManSprite.position.y - 5)];
	t5 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound,ManSprite.position.y - 32)];
	t51 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound,ManSprite.position.y - 27)];
	t52 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound - 5,ManSprite.position.y - 32)];
	t6 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound,ManSprite.position.y)];
	t61 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound,ManSprite.position.y + 5)];
	t62 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound,ManSprite.position.y - 5)];
	t7 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound,ManSprite.position.y - 32)];
	t71 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound,ManSprite.position.y - 27)];
	t72 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound + 5,ManSprite.position.y - 32)];
	if (t11 == 17 || t12 == 17 || t31 == 17 || t32 == 17 || t41 == 17 || t42 == 17 || t51 == 17 || t52 == 17 || t61 == 17 || t62 == 17 || t71 == 17 || t72 == 17) 
	{
		[self wingame];
		return -1;
	}
	if (t11 == 13 || t11 == 14 || t11 == 15 || t11 == 16 || t12 == 13 || t12 == 14 || t12 == 15 || t12 == 16 || t32 == 13 || t32 == 14 || t32 == 15 || t32 == 16 || t31 == 13 || t31 == 14 || t31 == 15 || t31 == 16 || t41 == 13 || t41 == 14 || t41 == 15 || t41 == 16 
	 || t42 == 13 || t42 == 14 || t42 == 15 || t42 == 16 || t51 == 13 || t51 == 14 || t51 == 15 || t51 == 16 || t52 == 13 || t52 == 14 || t52 == 15 || t52 == 16 || t61 == 13 || t61 == 14 || t61 == 15 || t61 == 16 || t62 == 13 || t62 == 14 || t62 == 15 || t62 == 16 
	 || t71 == 13 || t71 == 14 || t71 == 15 || t71 == 16 || t72 == 13 || t72 == 14 || t72 == 15 || t72 == 16)
	{
		[self losegame];
		return -1;
	}
	if (t1 != 1 && t12 != 1 && t1 != 17 && t12 != 17 && crash == NO)
	{
		return 1;
	}
	if (t3 != 1 && t32 != 1 && t3 != 17 && t32 != 17 && crash == NO)
	{
		return 1;
	}
	if (t5 != 1 && t52 != 1 && t5 != 17 && t52 != 17)
	{
		return 2;
	}
	if (t7 != 1 && t72 != 1 && t7 != 17 && t72 != 17)
	{
		return 2;
	}
	
	if (t3 != 1 && t31 != 1 && t3 != 17 && t31 != 17)
	{
		return 3;
	}
	if (t4 != 1 && t4 != 17 && ((t41 != 1 && t41 != 17) || (t42 != 1 && t42 != 17)))
	{
		return 3;
	}
	if (t5 != 1 && t51 != 1 && t5 != 17 && t51 != 17)
	{
		return 3;
	}
	if (t1 != 1 && t11 != 1 && t1 != 17 && t11 != 17)
	{
		return 4;
	}
	if (t6 != 1 && ((t61 != 1 && t61 != 17) || (t62 != 1 && t62 != 17)))
	{
		return 4;
	}
	if (t7 != 1 && t71 != 1 && t7 != 17 && t71 != 17)
	{
		return 4;
	}
	 
		return 0;
}

- (bool) gojump
{
	
	Vy = Vy - 15;
	[ManSprite setPosition:ccp(ManSprite.position.x + Vx * 0.005, ManSprite.position.y + Vy * 0.005)];
	
	Vy = Vy - 15;
	int itmp = [self checkbound];
	if (itmp == 1) 
	{
		Vy = 0;
		crash = YES;
		//return NO;
	}
	if (itmp == 2)
	{
		ifjump = NO;
		crash = NO;
		kAct = kStay;
		[ManSprite setPosition:ccp(ManSprite.position.x, ManSprite.position.y + 1)];
		while ([self checkbound] == 2) [ManSprite setPosition:ccp(ManSprite.position.x, ManSprite.position.y + 1)];
		[ManSprite setPosition:ccp(ManSprite.position.x, ManSprite.position.y - 1)];
		//NSLog(@"enheng");
		return NO;
	}
	if (itmp == 3 && kAct == kRightUp)
	{
		Vx = - speedrate * Vx;
		kAct = kLeftUp;
		[[SimpleAudioEngine sharedEngine] playEffect:@"bump.mp3"];
	}
	if (itmp == 4 && kAct == kLeftUp)
	{
		Vx = - speedrate * Vx;
		kAct = kRightUp;
		[[SimpleAudioEngine sharedEngine] playEffect:@"bump.mp3"];
	}
	
	if (Vy < 30 && Vy > -30)
	{
		if (kAct == kRightUp) [self settex:15];
		else if (kAct == kLeftUp) [self settex:20];
	}
	else
	if (Vy > 0)
	{
		if (kAct == kRightUp) [self settex:14];
		else if (kAct == kLeftUp) [self settex:19];
	}
	else 
	{
		if (kAct == kRightUp) [self settex:16];
		else if (kAct == kLeftUp) [self settex:21];
	}
	return YES;
}

- (void) ziyouluoti
{
	int t5,t52,t7,t72;
	t5 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound,ManSprite.position.y - 32)];
	t52 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound - 5,ManSprite.position.y - 32)];
	t7 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound,ManSprite.position.y - 32)];
	t72 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound + 5,ManSprite.position.y - 32)];	
	while ((t52 == 1 || t52 == 17) && (t72 == 1 || t72 == 17) && (t5 == 1 || t5 == 17) && (t7 == 1 || t7 == 17))
	{
		[ManSprite setPosition:ccp(ManSprite.position.x,ManSprite.position.y - 1)];
		t5 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound,ManSprite.position.y - 32)];
		t52 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + rightbound - 5,ManSprite.position.y - 32)];
		t7 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound,ManSprite.position.y - 32)];
		t72 = [mlayer GetMapInfoAtPoint:ccp(ManSprite.position.x + leftbound + 5,ManSprite.position.y - 32)];
	}
	if (t5 == 13 || t5 == 14 || t5 == 15 || t5 == 16 || t52 == 13 || t52 == 14 || t52 == 15 || t52 == 16 || t72 == 13 || t72 == 14 || t72 == 15 || t72 == 16 || t7 == 13 || t7 == 14 || t7 == 15 || t7 == 16)
	{
		[self losegame];
	}
}

@end
