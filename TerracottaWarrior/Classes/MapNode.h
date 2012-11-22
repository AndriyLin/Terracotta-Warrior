//
//  MapNode.h
//
//  Copyright 2011 林玄康. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//const int MAP_NODE_WALL = 1;

@interface MapNode : CCLayer {

}

@property (nonatomic, readwrite) short nodeBackType;
@property (nonatomic, readwrite) short nodeForeType;
@property (nonatomic, readonly) int foldCount;
@property (nonatomic, readwrite) int initialX;
@property (nonatomic, readwrite) int initialY;
@property (nonatomic, readwrite, retain) NSMutableArray* otherFoldNodes;
@property (nonatomic, readwrite, retain) CCSprite* backSprite;
@property (nonatomic, readwrite, retain) CCSprite* foreSprite;
@property (nonatomic, readwrite) BOOL isAdditional;

-(void) Fold;
-(void) Unfold;

-(void) PushAnotherFoldNode: (MapNode*)anotherNode;
-(MapNode*) PopAnotherFoldNode;

-(void) ReleaseSprites;

@end
