//
//  PauseScene.m
//
//  Copyright 2011 qrc. All rights reserved.
//

#import "PauseScene.h"
#import "ControlLayer.h"


@implementation PauseScene

@synthesize layer;

+(id) ShowScene:(ControlLayer *) clayer
{
	PauseScene *stscene = [PauseScene node];
	stscene.layer = clayer;
	return stscene;
}

-(id) init
{
	if( (self=[super init] )) 
	{
		CCSpriteBatchNode* sheetone;
		sheetone = [CCSpriteBatchNode spriteSheetWithFile:@"pause.png" capacity:24];
		[self addChild:sheetone];
		
		CCSprite * bgsprite = [CCSprite spriteWithTexture:sheetone.texture rect:CGRectMake(0,0,480,320)];
		bgsprite.position = ccp(240,160);
		[self addChild:bgsprite];
		
		CCMenuItemImage * menuItem1 = [CCMenuItemImage itemFromNormalImage:@"resume_a.png"
															 selectedImage: @"resume_b.png"
																	target:self
																  selector:@selector(select1:)];
		CCMenuItemImage * menuItem2 = [CCMenuItemImage itemFromNormalImage:@"back_a.png"
															 selectedImage: @"back_b.png"
																	target:self
																  selector:@selector(select2:)];
		
		CCMenu * myMenu = [CCMenu menuWithItems:menuItem1,menuItem2,nil];
		//NSLog(@"gogo");
		[myMenu alignItemsVertically];
		menuItem1.position = ccp(0,50);
		menuItem2.position = ccp(0,-50);
		[self addChild:myMenu];
	}
	return self;
}

- (void) select1 :(id) sender
{
	
	//[clayer addChild:clayer.lbScore z:1 tag:3];
	//[clayer addChild:clayer.pausesheet z:1 tag: 456];
	//[clayer.pausesheet addChild:clayer.pausesprite z:1 tag: 123];
	[[CCDirector sharedDirector] popScene];
	//NSLog(@"go to at last for the finally you can do it~!  %d",sender);
	
}

- (void) select2 :(id) sender
{
	layer.isover = YES;
	
	[[CCDirector sharedDirector] popScene];
	
	
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
