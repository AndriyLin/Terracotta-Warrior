//
//  StartScene.m
//
//  Copyright 2011 qrc. All rights reserved.
//

#import "StartScene.h"
#import "SelectBarrier.h"
#import "HelpScene.h"

@implementation StartScene

+(id) ShowScene
{
	//NSLog(@"haha");
	
	StartScene *stscene = [StartScene node];
	//NSLog(@"haha");
	
	return stscene;
}

-(id) init
{
                                                             	if( (self=[super init] ))                                                               
                                                                                                                                                                                                                                                                                 	{
		//NSLog(@"hehe");
		CCSpriteBatchNode* sheetone;
		sheetone = [CCSpriteBatchNode spriteSheetWithFile:@"ui_bg.png" capacity:24];
		[self addChild:sheetone];

		CCSprite * bgsprite = [CCSprite spriteWithTexture:sheetone.texture rect:CGRectMake(0,0,480,320)];
		bgsprite.position = ccp(240,160);
		[self addChild:bgsprite];
		
		CCMenuItemImage * menuItem1 = [CCMenuItemImage itemFromNormalImage:@"play_a.png"
															 selectedImage: @"play_b.png"
																	target:self
																  selector:@selector(singlegame:)];
		//NSLog(@"hoho");
		CCMenuItemImage * menuItem2 = [CCMenuItemImage itemFromNormalImage:@"help_a.png"
															 selectedImage: @"help_b.png"
																	target:self
																  selector:@selector(gohelp:)];
		//NSLog(@"lala");
		CCMenu * myMenu = [CCMenu menuWithItems:menuItem1, menuItem2, nil];
		//NSLog(@"gogo");
		[myMenu alignItemsVertically];
		menuItem1.position = ccp(-100,-100);
		menuItem2.position = ccp(100,-100);
		[self addChild:myMenu];
		[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"title.mp3"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"button.mp3"];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"title.mp3"];
	}
	return self;
}

- (void) singlegame :(id) sender
{
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[[SimpleAudioEngine sharedEngine] playEffect:@"button.mp3"];
	CCScene *sc = [SelectBarrier ShowScene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:1.2f scene:sc]];
}

- (void) gohelp :(id) sender
{
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[[SimpleAudioEngine sharedEngine] playEffect:@"button.mp3"];
	CCScene *sc = [HelpScene ShowScene];
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
