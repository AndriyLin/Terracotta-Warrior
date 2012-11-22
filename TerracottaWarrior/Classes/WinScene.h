//
//  WinScene.h
//
//  Copyright 2011 qrc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

@interface WinScene : CCScene {
	int tot,besttime;
}

@property (nonatomic,readwrite,assign) int tot;
@property (nonatomic,readwrite,assign) int besttime;

+(id) ShowScene:(int) tottime besttime:(int)best;

@end
