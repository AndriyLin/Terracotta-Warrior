//
//  SelectBarrier.m
//
//  Copyright 2011 qrc. All rights reserved.
//

#import "SelectBarrier.h"
#import "MainScene.h"

@implementation SelectBarrier

+(id) ShowScene
{
	//NSLog(@"haha");
	SelectBarrier *stscene = [SelectBarrier node];
	//NSLog(@"haha");
	return stscene;
}

-(id) init
{
	if( (self=[super init] )) 
	{
		//NSLog(@"hehe");
		CCSpriteBatchNode* sheetone;
		sheetone = [CCSpriteBatchNode spriteSheetWithFile:@"level select bg.png" capacity:24];
		[self addChild:sheetone];
		
		CCSprite * bgsprite = [CCSprite spriteWithTexture:sheetone.texture rect:CGRectMake(0,0,480,320)];
		bgsprite.position = ccp(240,160);
		[self addChild:bgsprite];
		
		CCMenuItemImage * menuItem1 = [CCMenuItemImage itemFromNormalImage:@"1.png"
															 selectedImage: @"1b.png"
																	target:self
																  selector:@selector(select1:)];
		//NSLog(@"hoho");
		CCMenuItemImage * menuItem2 = [CCMenuItemImage itemFromNormalImage:@"2.png"
															 selectedImage: @"2b.png"
																	target:self
																  selector:@selector(select2:)];
		CCMenuItemImage * menuItem3 = [CCMenuItemImage itemFromNormalImage:@"3.png"
															 selectedImage: @"3b.png"
																	target:self
																  selector:@selector(select3:)];
		CCMenuItemImage * menuItem4 = [CCMenuItemImage itemFromNormalImage:@"4.png"
															 selectedImage: @"4b.png"
																	target:self
																  selector:@selector(select4:)];
		
		//NSLog(@"lala");
		CCMenu * myMenu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, menuItem4,nil];
		//NSLog(@"gogo");
		[myMenu alignItemsVertically];
		menuItem1.position = ccp(-170,-20);
		menuItem2.position = ccp(-70,-20);
		menuItem3.position = ccp(30,-20);
		menuItem4.position = ccp(130,-20);
		
		[self addChild:myMenu];
		[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"levelselect.mp3"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"select.mp3"];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"levelselect.mp3"];
	}
	return self;
}

- (void) select1 :(id) sender
{
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[[SimpleAudioEngine sharedEngine] playEffect:@"select.mp3"];
	CCScene *sc = [MainScene ShowScene:1];
	
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:1.2f scene:sc]];
}

- (void) select2 :(id) sender
{
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[[SimpleAudioEngine sharedEngine] playEffect:@"select.mp3"];
	CCScene *sc = [MainScene ShowScene:2];
	
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:1.2f scene:sc]];
}

- (void) select3 :(id) sender
{
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[[SimpleAudioEngine sharedEngine] playEffect:@"select.mp3"];
	CCScene *sc = [MainScene ShowScene:3];
	
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:1.2f scene:sc]];
}

- (void) select4 :(id) sender
{
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[[SimpleAudioEngine sharedEngine] playEffect:@"select.mp3"];
	CCScene *sc = [MainScene ShowScene:4];
	
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