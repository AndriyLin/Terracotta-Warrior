//
//  MainScene.m
//
//  Copyright 2011 qrc. All rights reserved.
//

#import "MainScene.h"
#import "GameLayer.h"
#import "ControlLayer.h"
#import "warrior.h"
#import "Map.h"

@implementation MainScene

@synthesize currentbarrier;

+(id) ShowScene:(int) cur
{
	// 'scene' is an autorelease object.
	MainScene *scene = [[[MainScene alloc] initwithpara:cur] autorelease];
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) initwithpara:(int) cur
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) 
	{

		// Make all animantion frames for all layer
		/*
//		CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"enemy.png"];
		
		// manually add frames to the frame cache
		CCSpriteFrame *frame0 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(40*0, 40*0, 40, 40) offset:CGPointZero];
		CCSpriteFrame *frame1 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(40*1, 40*0, 40, 40) offset:CGPointZero];
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:frame0 name:@"e01"];
//		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:frame1 name:@"e02"];
		*/
		
		// 'layer' is an autorelease object.
		// ControlLayer *layer = [ControlLayer node];
		currentbarrier = cur;
		GameLayer *glayer = [GameLayer node];
		ControlLayer *clayer = [ControlLayer node];
		warrior * wlayer = [[[warrior alloc] myinit:self.currentbarrier] autorelease];
		Map* mapLayer = [[[Map alloc] initWithMission:self.currentbarrier]  autorelease];
		
		
		clayer.gLayer = glayer;
		clayer.wlayer = wlayer;
		clayer.mapLayer = mapLayer;
		clayer.mscene = self;
		wlayer.gLayer = glayer;
		wlayer.mlayer = mapLayer;
		mapLayer.warriorLayer = wlayer;
		
		// add layer as a child to scene
		[self addChild: glayer z:0];
		
		[self addChild:mapLayer z:0.3];
		//[self addChild: wlayer z:0.6];
		//[self addChild: clayer z:1];
		[self addChild:clayer z:0.6];
		[self addChild:wlayer z:1];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
