//
//  ControlLayer.h
//  
//  Copyright 2011 qrc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameLayer.h"
#import "warrior.h"
#import "Map.h"
#import "SimpleAudioEngine.h"

@interface ControlLayer : CCLayer {
	
	GameLayer *gLayer;
	CCScene * mscene;

	// action button
//	CCSprite *item_u_n, *item_u_s, *item_l_n, *item_l_s, *item_r_n, *item_r_s, *item_d_n, *item_d_s;
	
	// action state
	
	CCAnimation *aniGoleft;
	CCAnimation *aniGoright;
	id acGoleft;
	id acGoright;
	
	
	double tottime,speedtime;
	bool speedtest;
	UITouch * curposi;
	double intervaltime;
	
	CGRect original_point;
	int texwidth,texhei;
	int gogogotime;
	int clactimes;
	//bool iftaste;
	
	CCLabelBMFont *lbScore;
	CCSpriteBatchNode *pausesheet;
	CCSprite *pausesprite;
	
	bool isover;
}

@property (nonatomic,readwrite,assign) GameLayer *gLayer;
@property (nonatomic,readwrite,assign) warrior *wlayer;
@property (nonatomic,readwrite,assign) Map* mapLayer;
@property (nonatomic,readwrite,assign) CCScene *mscene;
@property (nonatomic,readwrite,assign) CCLabelBMFont *lbScore;
@property (nonatomic,readwrite,assign) CCSpriteBatchNode *pausesheet;
@property (nonatomic,readwrite,assign) CCSprite *pausesprite;
@property (nonatomic,readwrite,assign) bool isover;

/*
- (void)KeepDoing;
- (void) MoveLeft:(CCLayer *)layer;
- (void) MoveRight:(CCLayer *)layer;
- (void) MoveUp:(CCLayer *)layer;
- (void) MoveDown:(CCLayer *)layer;
- (void) OnStay:(CCLayer *)layer;
*/

-(void) UpdateView;

@end
