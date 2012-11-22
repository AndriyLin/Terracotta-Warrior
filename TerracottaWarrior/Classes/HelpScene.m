//
//  HelpScene.m
//
//  Copyright 2011 qrc. All rights reserved.
//

#import "HelpScene.h"
#import "StartScene.h"
#import "HelpSceneNext.h"


@implementation HelpScene

+(id) ShowScene
{
	//NSLog(@"haha");
	
	HelpScene *stscene = [HelpScene node];
	//NSLog(@"haha");
	
	return stscene;
}

-(id) init
{
	if( (self=[super init] )) 
	{
		NSLog(@"hehe");
		CCSpriteBatchNode* sheetone;
		sheetone = [CCSpriteBatchNode spriteSheetWithFile:@"helpbg1.png" capacity:24];
		[self addChild:sheetone];
		
		CCSprite * bgsprite = [CCSprite spriteWithTexture:sheetone.texture rect:CGRectMake(0,0,480,320)];
		bgsprite.position = ccp(240,160);
		[self addChild:bgsprite];
		
		CCMenuItemImage * menuItem1 = [CCMenuItemImage itemFromNormalImage:@"helpback_a.png"
															 selectedImage: @"helpback_b.png"
																	target:self
																  selector:@selector(goback:)];
		CCMenuItemImage * menuItem2 = [CCMenuItemImage itemFromNormalImage:@"next_a.png"
															 selectedImage: @"next_b.png"
																	target:self
																  selector:@selector(gonext:)];
		
		CCMenu * myMenu = [CCMenu menuWithItems:menuItem1,menuItem2,nil];
		[myMenu alignItemsVertically];
		menuItem1.position = ccp(100,-130);
		menuItem2.position = ccp(150,-130);
		[self addChild:myMenu];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"button.mp3"];
	}
	return self;
}

- (void) goback :(id) sender
{
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[[SimpleAudioEngine sharedEngine] playEffect:@"button.mp3"];
	CCScene *sc = [StartScene ShowScene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:1.2f scene:sc]];
}

- (void) gonext :(id) sender
{
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[[SimpleAudioEngine sharedEngine] playEffect:@"button.mp3"];
	CCScene *sc = [HelpSceneNext ShowScene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:1.2f scene:sc]];
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
