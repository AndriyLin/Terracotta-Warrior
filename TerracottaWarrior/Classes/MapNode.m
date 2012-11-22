//
//  MapNode.m
//
//  Copyright 2011 林玄康. All rights reserved.
//

#import "MapNode.h"


@implementation MapNode

@synthesize nodeBackType;
@synthesize nodeForeType;
@synthesize foldCount;
@synthesize initialX;
@synthesize initialY;
@synthesize otherFoldNodes;
@synthesize backSprite;
@synthesize foreSprite;
@synthesize isAdditional;

-(id) init
{
	if ((self = [super init])) {
		nodeBackType = 1;
		nodeForeType = 0;
		//nodeType = MAP_NODE_WALL;
		foldCount = 0;
		
		backSprite = nil;
		foreSprite = nil;
		
		isAdditional = NO;
		
		otherFoldNodes = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) dealloc
{
	[self ReleaseSprites];
	[otherFoldNodes release];
	[super dealloc];
}

-(void) Fold
{
	foldCount++;
}

-(void) Unfold
{
	foldCount--;
}

-(void) ReleaseSprites
{
	if (backSprite != nil) {
		[backSprite release];
	}
	if (foreSprite != nil) {
		[foreSprite release];
	}
}


-(void) PushAnotherFoldNode:(MapNode *)anotherNode
{
	if (anotherNode != nil) {
		[otherFoldNodes addObject:anotherNode];
	}
}

-(MapNode*) PopAnotherFoldNode
{
	if ([otherFoldNodes count] != 0) {
		MapNode* lastNode = [otherFoldNodes objectAtIndex:[otherFoldNodes count]-1];
		[otherFoldNodes removeObject:lastNode];
		return lastNode;
	}
	return nil;
}


@end
