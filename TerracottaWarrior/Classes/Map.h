//
//  Map.h
//  ZYG006
//
//  Created by 林玄康 on 11-3-1.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapNode.h"
#import "cocos2d.h"


@class warrior;



#ifndef SCREEN_SIZE_MACRO
#define SCREEN_SIZE_MACRO

#define ADDED_WIDTH (6)
#define ADDED_HEIGHT (6)
#define SCREEN_WIDTH (15)
#define SCREEN_HEIGHT (10)

#endif

@interface Map : CCLayer <NSXMLParserDelegate> {
	int width;
	int height;

	NSMutableArray* nodeInfo;
	MapNode* nodesOnScreen[SCREEN_WIDTH+2*ADDED_WIDTH][SCREEN_HEIGHT+2*ADDED_HEIGHT];
	
	CCSpriteBatchNode* backgroundSheet;
	CCSpriteBatchNode* bombSheet;
}

@property (nonatomic, readwrite) int width;		//total width of the whole map
@property (nonatomic, readwrite) int height;	//      height

@property (nonatomic, readwrite) double lastFoldPointsDistance;	//used for counting the distance while touches moving to judge whether should fold

@property (nonatomic, readwrite) CGPoint foldPoint1;		//points to be folded
@property (nonatomic, readwrite) CGPoint foldPoint2;

@property (nonatomic, readwrite) BOOL shouldFold;
@property (nonatomic, readwrite) BOOL shouldWaitForAnimation;
@property (nonatomic, readwrite) BOOL justFolded;

@property (nonatomic, readwrite) CGPoint lastMoveScreenPoint;
@property (nonatomic, readwrite) BOOL shouldMoveScreen;
@property (nonatomic, readwrite) int screenMovingDirection;	//	int 
@property (nonatomic, readwrite,assign) warrior* warriorLayer;

@property (nonatomic, readwrite) int totalFoldCount;
@property (nonatomic, readwrite) int showFromX;
@property (nonatomic, readwrite) int showFromY;

-(id) initWithMission:(int)whichMission;

-(void) InitializeNodeInfo;
-(void) ReleaseNodeInfo;

-(void) InitializeMapForTheFirstTime;
-(BOOL) RemakePresentMapWith1stFoldPoint:(CGPoint*)point1 With2ndFoldPoint:(CGPoint*)point2;		//if return NO, means the warrior has died
-(void) ReleasePresentMap;

-(void) RecursivelyFillNodesOnScreenWithXPos:(int)xPos YPos:(int)yPos InitialXPos:(int)initialX InitialYPos:(int)initialY;
-(void) FillNodesOnScreenWithXPos:(int)xPos YPos:(int)yPos InitialXPos:(int)initialX InitialYPos:(int)initialY Angle:(int)angle;

-(void) ResetSelfChildrenToInitialized;
-(void) AddScreenSpritesToChilds;

-(BOOL) LoadFromFile:(int)whichMission;
-(BOOL) SaveIntoFile:(NSString*)fileName;

-(void) FoldFromPoint:(CGPoint*)point1 ToPoint:(CGPoint*)point2;
-(void) UnfoldFromPoint:(CGPoint*)point;

-(int) GetMapInfoAtPoint:(CGPoint)point;

-(int) GetXFromPoint:(CGPoint*)point;
-(int) GetYFromPoint:(CGPoint*)point;

-(void) Test;
-(void) TestFoldCount;
-(void) TestRefCount;

-(void) parseXMLFileAtURL:(NSURL*)URL parseError:(NSError**)error;

-(BOOL) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(BOOL) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

-(void) MapMoveUp;
-(void) MapMoveDown;
-(void) MapMoveLeft;
-(void) MapMoveRight;


@end
