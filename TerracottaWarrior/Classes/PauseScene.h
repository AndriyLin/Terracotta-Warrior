//
//  PauseScene.h
//
//  Copyright 2011 qrc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ControlLayer.h"

@interface PauseScene : CCScene {
	
	ControlLayer *layer;
	
}

@property (nonatomic,readwrite,assign) ControlLayer *layer;

+(id) ShowScene:(ControlLayer *) clayer;

@end
