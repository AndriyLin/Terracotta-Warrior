//
//  warrior.h
//
//  Copyright 2011 qrc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameLayer.h"
#import "Map.h"

typedef enum {
	kRightUp = 2,
	kLeft = 1,
	kRight = 0,
	kLeftUp = 3,
	//	kFire = 5,
	kStay = 6,
} ManAction;

#define speedrate 0.8


@interface warrior : CCSprite {
	float Vx,Vy;
	float orispeed;
	ManAction kAct;
	CCSprite * ManSprite;
	float runSpeed,moveStep;
	bool befocused;
	bool ifjump;
	bool crash;
	float gox,goy,nowspeed,godist,height;
	CGPoint Manloca;
	Map* mlayer;
	int leftbound,rightbound;
	bool iflose,ifwin;
	int tottime;
	int besttime;
	int curbarrier;
	
	CCSprite * spriteGo;
	CCSpriteBatchNode *SheetGo;

}
@property (nonatomic,readwrite,assign) float Vx;
@property (nonatomic,readwrite,assign) float Vy;
@property (nonatomic,readwrite,assign) GameLayer *gLayer;
@property (nonatomic,readwrite,assign) CCSprite *ManSprite;
@property (nonatomic,readwrite,assign) ManAction kAct;
@property (nonatomic,readwrite,assign) bool befocused;
@property (nonatomic,readwrite,assign) float runSpeed;
@property (nonatomic,readwrite,assign) float moveStep;
@property (nonatomic,readwrite,assign) bool ifjump;
@property (nonatomic,readwrite,assign) bool crash;
@property (nonatomic,readwrite,assign) float gox;
@property (nonatomic,readwrite,assign) float goy;
@property (nonatomic,readwrite,assign) float godist;
@property (nonatomic,readwrite,assign) CGPoint Manloca;
@property (nonatomic,readwrite,assign) Map* mlayer;
@property (nonatomic,readwrite,assign) bool iflose;
@property (nonatomic,readwrite,assign) int tottime;

- (id) myinit: (int) curmission;
- (void) settex:(int) index;
- (void) setpos:(CGPoint) posi;
- (void) dealwithsprite:(UITouch*) curposi;
- (void) runwithspeed: (float) grade;
- (bool) gojump;
- (int) checkbound;
- (void) losegame;
- (void) wingame;
- (void) ziyouluoti;

@end
