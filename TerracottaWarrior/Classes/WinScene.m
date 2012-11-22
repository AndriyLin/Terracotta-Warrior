//
//  WinScene.m
//
//  Copyright 2011 qrc. All rights reserved.
//

#import "WinScene.h"
#import "SelectBarrier.h"


@implementation WinScene

@synthesize tot;
@synthesize besttime;

+(id) ShowScene:(int) tottime besttime:(int)best
{
	WinScene *stscene = [WinScene node];
	stscene.tot = tottime; 
	stscene.besttime = best;
	//NSLog(@"diffent output: %d %d",stscene.tot,tottime);
	CCLabelTTF* label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Total Time: %d",stscene.tot] fontName:@"LIGHTMORNING.TTF" fontSize:25];
	CCLabelTTF* label2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Best Time: %d",stscene.besttime] fontName:@"LIGHTMORNING.TTF" fontSize:25];
	//NSLog(@"YES YES GOGOGO diffent output: %d",tot);
	ccColor3B myred = {255,0,0};
	[stscene.self addChild:label];
	[stscene.self addChild:label2];
	label.position = ccp(240,160); 
	label2.position = ccp(240,130);
	[label setColor:myred];
	[label2 setColor:ccBLUE];
	return stscene;
}

-(id) init
{
	if( (self=[super init] )) 
	{
		//NSLog(@"yehaha!!! I Win!!!!!!");
		CCSpriteBatchNode* sheetone;
		sheetone = [CCSpriteBatchNode batchNodeWithFile:@"congratulations.png" capacity:24];
		[self addChild:sheetone];
		
		CCSprite * bgsprite = [CCSprite spriteWithTexture:sheetone.texture rect:CGRectMake(0,0,480,320)];
		bgsprite.position = ccp(240,160);
		[self addChild:bgsprite];
		
		CCMenuItemImage * menuItem1 = [CCMenuItemImage itemFromNormalImage:@"back_a.png"
															 selectedImage: @"back_b.png"
																	target:self
																  selector:@selector(select1:)];
		
		CCMenu * myMenu = [CCMenu menuWithItems:menuItem1,nil];
		
		//CCLabelTTF*
		
		
		//NSLog(@"gogo");
		[myMenu alignItemsVertically];
		menuItem1.position = ccp(0,-75);
		[self addChild:myMenu];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"win.mp3"];
		[[SimpleAudioEngine sharedEngine] playEffect:@"win.mp3"];
		
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
