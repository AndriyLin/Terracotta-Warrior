//
//  MainScene.h
//
//  Copyright 2011 qrc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "warrior.h"

@interface MainScene : CCScene {
	
	int currentbarrier;

}
@property (nonatomic,readwrite,assign) int currentbarrier;
// returns a Scene that contains the HelloWorld as the only child
+(id) ShowScene:(int) cur;
- (id) initwithpara:(int)cur;

@end
