//
//  LoseScene.m
// 
//  Copyright 2011 qrc. All rights reserved.
//

#import "LoseScene.h"
#import "SelectBarrier.h"


@implementation LoseScene

+(id) ShowScene
{
	LoseScene *stscene = [LoseScene node];
	return stscene;
}

-(id) init
{
	if( (self=[super init] )) 
	{
		CCSpriteBatchNode* sheetone;
		sheetone = [CCSpriteBatchNode spriteSheetWithFile:@"lose.png" capacity:24];
		[self addChild:sheetone];
		
		CCSprite * bgsprite = [CCSprite spriteWithTexture:sheetone.texture rect:CGRectMake(0,0,480,320)];
		bgsprite.position = ccp(240,160);
		[self addChild:bgsprite];
	
		CCMenuItemImage * menuItem1 = [CCMenuItemImage itemFromNormalImage:@"back_a.png"
															 selectedImage: @"back_b.png"
																	target:self
																  selector:@selector(select1:)];
		
		CCMenu * myMenu = [CCMenu menuWithItems:menuItem1,nil];
		//NSLog(@"gogo");
		[myMenu alignItemsVertically];
		menuItem1.position = ccp(0,-100);
		[self addChild:myMenu];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"lose.mp3"];
		[[SimpleAudioEngine sharedEngine] playEffect:@"lose.mp3"];
		
	}
	return self;
}

- (void) select1 :(id) sender
{
	
	CCScene *sc = [SelectBarrier ShowScene];	
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:1.2f scene:sc]];
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
