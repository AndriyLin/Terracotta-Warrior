//
//  Map.m
//  ZYG006
//
//  Created by 林玄康 on 11-3-1.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Map.h"
#import "warrior.h"
#import "MyQueue.h"
#import "SimpleAudioEngine.h"

@implementation Map


@synthesize width;
@synthesize height;

@synthesize lastFoldPointsDistance;

@synthesize foldPoint1;
@synthesize foldPoint2;

@synthesize shouldFold;
@synthesize shouldWaitForAnimation;
@synthesize justFolded;

@synthesize shouldMoveScreen;
@synthesize screenMovingDirection;
@synthesize lastMoveScreenPoint;

@synthesize warriorLayer;
@synthesize totalFoldCount;

@synthesize showFromX;
@synthesize showFromY;



const int AutoDoneOneSideX = 15;	//auto fill this width to the total width, filled with BLOCK
const int AutoDoneOneSideY = 10;	//               height             height


//all types of MAP_NODEs
const int MAP_NODE_TYPE_BLOCK		=	0;
const int MAP_NODE_TYPE_BACKGROUND	=	1;
const int MAP_NODE_TYPE_RING		=	2;
const int MAP_NODE_TYPE_LUO			=	3;
const int MAP_NODE_TYPE_BOW			=	4;
const int MAP_NODE_TYPE_CANDLE		=	5;
const int MAP_NODE_TYPE_TRICK_DOWN	=	6;
const int MAP_NODE_TYPE_TRICK_UP	=	7;
const int MAP_NODE_TYPE_TRICK_RIGHT	=	8;
const int MAP_NODE_TYPE_TRICK_LEFT	=	9;
const int MAP_NODE_TYPE_TRICK_VERT	=	10;
const int MAP_NODE_TYPE_TRICK_HORI	=	11;
const int MAP_NODE_TYPE_BUDDY		=	12;
const int MAP_NODE_TYPE_SPEAR_DOWN	=	13;
const int MAP_NODE_TYPE_SPEAR_RIGHT	=	14;
const int MAP_NODE_TYPE_SPEAR_UP	=	15;
const int MAP_NODE_TYPE_SPEAR_LEFT	=	16;
const int MAP_NODE_TYPTE_DOOR		=	17;

//numbers of the pictures in bomb animation
const int BOMB_ANIMATION_PICTURES = 11;

//several state of screen scrolling
const int MOVING_STAY = 0;
const int MOVING_UP = 1;
const int MOVING_DOWN = 2;
const int MOVING_LEFT = 3;
const int MOVING_RIGHT = 4;


CGPoint nullPoint;	//ccp(0,0) for comparing



-(id) initWithMission:(int)whichMission
{
	if ((self=[super init])) {
		
		//although obj-c seems to initialize the parameters automatically, I explicitly do that here
		nodeInfo = nil;
		warriorLayer = nil;

		shouldFold = NO;
		shouldWaitForAnimation = NO;
		justFolded = NO;
		shouldMoveScreen = NO;

		screenMovingDirection = MOVING_STAY;
		
		totalFoldCount = 0;
		
		showFromX = ADDED_WIDTH;
		showFromY = ADDED_HEIGHT;
		
		nullPoint = ccp(0,0);	//assuming ccp(0,0) to be a nullPoint

		
		//initialize the nodesOnScreen array, set nil to each one of it
		for (int i=0; i<SCREEN_WIDTH+2*ADDED_WIDTH; i++) {
			for (int j=0; j<SCREEN_HEIGHT+2*ADDED_HEIGHT; j++) {
				nodesOnScreen[i][j] = nil;
			}
		}
		
		foldPoint1 = nullPoint;
		foldPoint2 = nullPoint;

		//initialize the sprite sheet that is to be used later
		backgroundSheet = [[CCSpriteBatchNode alloc] initWithFile:@"tileSet.png" capacity:18];
		[self addChild:backgroundSheet z:0];
		
		bombSheet = [[CCSpriteBatchNode alloc] initWithFile:@"exploBig.png" capacity:BOMB_ANIMATION_PICTURES];
		[self addChild:bombSheet z:1];
		
		
		//load map from file
		[self LoadFromFile:whichMission];
//		[self LoadFromFile:2];
		
		//then make the presentMap information for the 1st time
		[self InitializeMapForTheFirstTime];

		//enable this to receive events to fold map or unfold
		[self setIsTouchEnabled:YES];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"trick.mp3"];
	}
	
	return self;
}


-(void) dealloc
{
	//release the info of present map
	[self ReleasePresentMap];
	
	//release the info of all mapnodes
	[self ReleaseNodeInfo];

	
	//release the saved sprite sheets
	[backgroundSheet release];
	[bombSheet release];
	
	[super dealloc];
}


//the following 3 methods are all for loading map information from file
-(BOOL) LoadFromFile:(int)whichMission
{
	NSBundle* bundle = [NSBundle mainBundle];
	NSError* error = nil;
	
	//load from which file
	NSString *mission = [[NSString alloc] initWithFormat:@"mission%d",whichMission];
	[self parseXMLFileAtURL:[NSURL fileURLWithPath: 
				[bundle pathForResource:mission ofType:@"xml"]] parseError:&error];
	
	if (error) {
		return NO;
	}
	return YES;
}


-(void) parseXMLFileAtURL:(NSURL*)URL parseError:(NSError**)error 
{	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
	[parser setDelegate:self];
	
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	
	[parser	parse];
	
	NSError* parseError = [parser parserError];
	if (parseError && error) {
		*error = parseError;
	}
	[parser release];
}


-(void) parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName
	attributes:(NSDictionary *)attributeDict
{
	if (qName) {
		elementName = qName;
	}
	
	//get total size (added by autoDone parts)
	if ([elementName isEqualToString:@"size"]) {
		self.width = [[attributeDict valueForKey:@"width"] intValue];
		self.height = [[attributeDict valueForKey:@"height"] intValue];
		
		//ensure that the size of the total map is bigger than the screen
		NSAssert(width >= 15, @"width is too small");
		NSAssert(height >= 10, @"height is too small");
		
		self.width += AutoDoneOneSideX * 2;
		self.height += AutoDoneOneSideY * 2;
		
		//initially set BACKGROUND & BLOCK to the back and fore types, they'll be replaced later if needed
		for (int i=0; i<width; i++) {
			NSMutableArray* line = [nodeInfo objectAtIndex:i];
			for (int j=0; j<height; j++) {
				MapNode* node = [line objectAtIndex:j];
				node.nodeBackType = MAP_NODE_TYPE_BACKGROUND;
				node.nodeForeType = MAP_NODE_TYPE_BLOCK;
			}
		}
		
		//according the nodeType, attach sprites to it
		[self InitializeNodeInfo];
		
	}
	
	//get detail information for each point in the map
	else if ([elementName isEqualToString:@"detail"]){
		int i = [[attributeDict valueForKey:@"x"] intValue];
		int j = [[attributeDict valueForKey:@"y"] intValue];
		int backType = [[attributeDict valueForKey:@"back"] intValue];
		int foreType = [[attributeDict valueForKey:@"type"] intValue];

		NSMutableArray* line = [nodeInfo objectAtIndex:i+AutoDoneOneSideX];
		MapNode* node = [line objectAtIndex:j+AutoDoneOneSideY];
		node.nodeBackType = backType;
		node.nodeForeType = foreType;

		//replace the former sprite if it doesn't meet the latest type
		if (node.nodeBackType != MAP_NODE_TYPE_BACKGROUND) {
			[node.backSprite release];
			node.backSprite = [[CCSprite alloc] initWithTexture:backgroundSheet.texture
														   rect:CGRectMake(node.nodeBackType*32, 0, 32, 32)];
		}
		if (node.nodeForeType != MAP_NODE_TYPE_BLOCK) {
			[node.foreSprite release];
			node.foreSprite = [[CCSprite alloc] initWithTexture:backgroundSheet.texture
													   rect:CGRectMake(node.nodeForeType*32, 0, 32, 32)];
		}
	}
//	这里读取人物的初始位置?
//	else if ()
//	{}
}
	

//this method is for saving information into file
//NOT USED currently;
-(BOOL) SaveIntoFile:(NSString *)fileName
{
	return YES;
}


//initialize the nodeInfo, often called only when program starts
//according to the width & height get from file, information saved in the class
-(void) InitializeNodeInfo
{
	//usually, nodeInfo is always nil at this moment
	if (nodeInfo != nil) {
		[self ReleaseNodeInfo];
	}
	
	nodeInfo = [[NSMutableArray alloc] initWithCapacity:width];

	for (int i=0; i<width; i++) {
		NSMutableArray* line = [[NSMutableArray alloc] initWithCapacity:height];
		for (int j=0; j<height; j++) {
			MapNode* node = [[MapNode alloc]init];
			node.initialX = i;
			node.initialY = j;
			
			node.backSprite = [[CCSprite alloc] initWithTexture:backgroundSheet.texture
														   rect:CGRectMake(node.nodeBackType*32, 0, 32, 32)];
			node.foreSprite = [[CCSprite alloc] initWithTexture:backgroundSheet.texture
														   rect:CGRectMake(node.nodeForeType*32, 0, 32, 32)];
			[line addObject:node];
			[node release];
		}
		[nodeInfo addObject:line];
		[line release];
	}
}


//release the nodeInfo, called only when program leaves
//Add once，ref count＋＋，remove once, ref count－－，so it's enough to do REMOVEALL
-(void) ReleaseNodeInfo
{
	if (nodeInfo == nil) {
		return;
	}
	
	for (int i=0; i<width; i++) {
		NSMutableArray* line = [nodeInfo objectAtIndex:i];
		for (int j=0; j<height; j++) {
			MapNode* node = [line objectAtIndex:j];
			[node ReleaseSprites];
		}
		[line removeAllObjects];
	}
	[nodeInfo removeAllObjects];
	[nodeInfo release];
	nodeInfo = nil;
}




-(void) FillNodesOnScreenWithXPos:(int)xPos YPos:(int)yPos InitialXPos:(int)initialX InitialYPos:(int)initialY Angle:(int)angle
{
	BOOL hasFilled[SCREEN_WIDTH+2*ADDED_WIDTH][SCREEN_HEIGHT+2*ADDED_HEIGHT];
	for (int i=0; i<SCREEN_WIDTH+2*ADDED_WIDTH; i++) {
		for (int j=0; j<SCREEN_HEIGHT+2*ADDED_HEIGHT; j++) {
			hasFilled[i][j] = NO;
		}
	}
	
	FillNodes* firstFillNode = [[[FillNodes alloc] init] autorelease];
	firstFillNode.i = xPos;
	firstFillNode.j = yPos;
	firstFillNode.initialX = initialX;
	firstFillNode.initialY = initialY;
	
	MyQueue* queue = [[MyQueue alloc] init];
	[queue AppendObject:firstFillNode];
	
	while ([queue count] != 0) {
		FillNodes* fill = [queue ServeObject];
		
		if (fill.i < 0 || fill.i >= SCREEN_WIDTH+2*ADDED_WIDTH) {
			continue;
		}
		if (fill.j < 0 || fill.j >= SCREEN_HEIGHT+2*ADDED_HEIGHT) {
			continue;
		}
		
		if (hasFilled[fill.i][fill.j] == NO) {
			hasFilled[fill.i][fill.j] = YES;
			MapNode* node = [(NSMutableArray*)[nodeInfo objectAtIndex:fill.initialX] objectAtIndex:fill.initialY];
			nodesOnScreen[fill.i][fill.j] = node;
			
			//left side
			if (fill.initialX >= 1) {
				MapNode* leftNode = [(NSMutableArray*)[nodeInfo objectAtIndex:fill.initialX-1] objectAtIndex:fill.initialY];

				if ([leftNode foldCount] == 0) {
					FillNodes* newFill = [[[FillNodes alloc] init] autorelease];
					newFill.initialX = fill.initialX-1;
					newFill.initialY = fill.initialY;
					newFill.i = fill.i-1;
					newFill.j = fill.j;
					[queue AppendObject:newFill];
				}
				else {
//					NSLog(@"Fill info: i=%d,j=%d,initialX=%d,initialY=%d",fill.i,fill.j,fill.initialX,fill.initialY);
					if (angle == 45) {
						int tempX = fill.initialX-1;
						int tempY = fill.initialY+1;
						while (YES) {
							if (tempX < 0 || tempY >= height) {
								break;
							}
							
							MapNode* newNode = [(NSMutableArray*)[nodeInfo objectAtIndex:tempX] objectAtIndex:tempY];

							if ([newNode foldCount] == 0) {
								FillNodes* newFill = [[[FillNodes alloc] init] autorelease];
								newFill.initialX = tempX;
								newFill.initialY = tempY;
								newFill.i = fill.i-1;
								newFill.j = fill.j;
								[queue AppendObject:newFill];
								break;
							}
							
							tempX--;
							tempY++;
						}
					}
					else if (angle == -45) {
						int tempX = fill.initialX-1;
						int tempY = fill.initialY-1;
						while (YES) {
							if (tempX < 0 || tempY < 0) {
								break;
							}
							
							MapNode* newNode = [(NSMutableArray*)[nodeInfo objectAtIndex:tempX] objectAtIndex:tempY];
							
							if ([newNode foldCount] == 0) {
								FillNodes* newFill = [[[FillNodes alloc] init] autorelease];
								newFill.initialX = tempX;
								newFill.initialY = tempY;
								newFill.i = fill.i-1;
								newFill.j = fill.j;
								[queue AppendObject:newFill];
								break;
							}
							
							tempX--;
							tempY--;
						}
					}
					else {
						int tempX = fill.initialX-1;
						int tempY = fill.initialY;
						while (YES) {
							if (tempX < 0) {
								break;
							}
							MapNode* newNode = [(NSMutableArray*)[nodeInfo objectAtIndex:tempX] objectAtIndex:tempY];
							
							if ([newNode foldCount] == 0) {
								FillNodes* newFill = [[[FillNodes alloc] init] autorelease];
								newFill.initialX = tempX;
								newFill.initialY = tempY;
								newFill.i = fill.i-1;
								newFill.j = fill.j;
								[queue AppendObject:newFill];
								break;
							}
							
							tempX--;
						}
					}


				}
				
			}
			
			//right side
			if (fill.initialX < width-1) {
				MapNode* rightNode = [(NSMutableArray*)[nodeInfo objectAtIndex:fill.initialX+1] objectAtIndex:fill.initialY];
				if ([rightNode foldCount] == 0) {
					FillNodes* newFill = [[[FillNodes alloc] init] autorelease];
					newFill.initialX = fill.initialX+1;
					newFill.initialY = fill.initialY;
					newFill.i = fill.i+1;
					newFill.j = fill.j;
					[queue AppendObject:newFill];
				}
				else {
//					NSLog(@"Fill info: i=%d,j=%d,initialX=%d,initialY=%d",fill.i,fill.j,fill.initialX,fill.initialY);

					if (angle == 45) {
						int tempX = fill.initialX+1;
						int tempY = fill.initialY-1;
						while (YES) {
							if (tempX >= width || tempY < 0) {
								break;
							}
							
							MapNode* newNode = [(NSMutableArray*)[nodeInfo objectAtIndex:tempX] objectAtIndex:tempY];
							
							if ([newNode foldCount] == 0) {
								FillNodes* newFill = [[[FillNodes alloc] init] autorelease];
								newFill.initialX = tempX;
								newFill.initialY = tempY;
								newFill.i = fill.i+1;
								newFill.j = fill.j;
								[queue AppendObject:newFill];
								break;
							}
							
							tempX++;
							tempY--;
						}
					}
					else if (angle == -45) {
						int tempX = fill.initialX+1;
						int tempY = fill.initialY+1;
						while (YES) {
							if (tempX >= width || tempY >= height) {
								break;
							}
							
							MapNode* newNode = [(NSMutableArray*)[nodeInfo objectAtIndex:tempX] objectAtIndex:tempY];
							
							if ([newNode foldCount] == 0) {
								FillNodes* newFill = [[[FillNodes alloc] init] autorelease];
								newFill.initialX = tempX;
								newFill.initialY = tempY;
								newFill.i = fill.i+1;
								newFill.j = fill.j;
								[queue AppendObject:newFill];
								break;
							}
							
							tempX++;
							tempY++;
						}
					}
					else {
						int tempX = fill.initialX+1;
						int tempY = fill.initialY;
						while (YES) {
							if (tempX >= width) {
								break;
							}
							MapNode* newNode = [(NSMutableArray*)[nodeInfo objectAtIndex:tempX] objectAtIndex:tempY];
							
							if ([newNode foldCount] == 0) {
								FillNodes* newFill = [[[FillNodes alloc] init] autorelease];
								newFill.initialX = tempX;
								newFill.initialY = tempY;
								newFill.i = fill.i+1;
								newFill.j = fill.j;
								[queue AppendObject:newFill];
								break;
							}
							
							tempX++;
						}
					}
					
				}

			}
			
			//down side
			if (fill.initialY >= 1) {
				MapNode* downNode = [(NSMutableArray*)[nodeInfo objectAtIndex:fill.initialX] objectAtIndex:fill.initialY-1];
				if ([downNode foldCount] == 0) {
					FillNodes* newFill = [[[FillNodes alloc] init] autorelease];
					newFill.initialX = fill.initialX;
					newFill.initialY = fill.initialY-1;
					newFill.i = fill.i;
					newFill.j = fill.j-1;
					[queue AppendObject:newFill];
				}
				else {
//					NSLog(@"Fill info: i=%d,j=%d,initialX=%d,initialY=%d",fill.i,fill.j,fill.initialX,fill.initialY);

					if (angle == 45) {
						int tempX = fill.initialX+1;
						int tempY = fill.initialY-1;
						while (YES) {
							if (tempX >= width || tempY < 0) {
								break;
							}
							
							MapNode* newNode = [(NSMutableArray*)[nodeInfo objectAtIndex:tempX] objectAtIndex:tempY];
							
							if ([newNode foldCount] == 0) {
								FillNodes* newFill = [[[FillNodes alloc] init] autorelease];
								newFill.initialX = tempX;
								newFill.initialY = tempY;
								newFill.i = fill.i;
								newFill.j = fill.j+1;
								[queue AppendObject:newFill];
								break;
							}
							
							tempX++;
							tempY--;
						}
					}
					else if (angle == -45) {
						int tempX = fill.initialX-1;
						int tempY = fill.initialY-1;
						while (YES) {
							if (tempX < 0 || tempY < 0) {
								break;
							}
							
							MapNode* newNode = [(NSMutableArray*)[nodeInfo objectAtIndex:tempX] objectAtIndex:tempY];
							
							if ([newNode foldCount] == 0) {
								FillNodes* newFill = [[[FillNodes alloc] init] autorelease];
								newFill.initialX = tempX;
								newFill.initialY = tempY;
								newFill.i = fill.i;
								newFill.j = fill.j-1;
								[queue AppendObject:newFill];
								break;
							}
							
							tempX--;
							tempY--;
						}
					}
					else {
						int tempX = fill.initialX;
						int tempY = fill.initialY-1;
						while (YES) {
							if (tempY < 0) {
								break;
							}
							MapNode* newNode = [(NSMutableArray*)[nodeInfo objectAtIndex:tempX] objectAtIndex:tempY];
							
							if ([newNode foldCount] == 0) {
								FillNodes* newFill = [[[FillNodes alloc] init] autorelease];
								newFill.initialX = tempX;
								newFill.initialY = tempY;
								newFill.i = fill.i;
								newFill.j = fill.j-1;
								[queue AppendObject:newFill];
								break;
							}
							
							tempY--;
						}
					}
					
				}

			}
			
			//up side
			if (fill.initialY < height-1) {
				MapNode* upNode = [(NSMutableArray*)[nodeInfo objectAtIndex:fill.initialX] objectAtIndex:fill.initialY+1];
				if ([upNode foldCount] == 0) {
					FillNodes* newFill = [[[FillNodes alloc] init] autorelease];
					newFill.initialX = fill.initialX;
					newFill.initialY = fill.initialY+1;
					newFill.i = fill.i;
					newFill.j = fill.j+1;
					[queue AppendObject:newFill];
				}
				else {
//					NSLog(@"Fill info: i=%d,j=%d,initialX=%d,initialY=%d",fill.i,fill.j,fill.initialX,fill.initialY);

					if (angle == 45) {
						int tempX = fill.initialX-1;
						int tempY = fill.initialY+1;
						while (YES) {
							if (tempX < 0 || tempY >= height) {
								break;
							}
							
							MapNode* newNode = [(NSMutableArray*)[nodeInfo objectAtIndex:tempX] objectAtIndex:tempY];
							
							if ([newNode foldCount] == 0) {
								FillNodes* newFill = [[[FillNodes alloc] init] autorelease];
								newFill.initialX = tempX;
								newFill.initialY = tempY;
								newFill.i = fill.i;
								newFill.j = fill.j+1;
								[queue AppendObject:newFill];
								break;
							}
							
							tempX--;
							tempY++;
						}
					}
					else if (angle == -45) {
						int tempX = fill.initialX+1;
						int tempY = fill.initialY+1;
						while (YES) {
							if (tempX >= width || tempY >= height) {
								break;
							}
							
							MapNode* newNode = [(NSMutableArray*)[nodeInfo objectAtIndex:tempX] objectAtIndex:tempY];
							
							if ([newNode foldCount] == 0) {
								FillNodes* newFill = [[[FillNodes alloc] init] autorelease];
								newFill.initialX = tempX;
								newFill.initialY = tempY;
								newFill.i = fill.i;
								newFill.j = fill.j+1;
								[queue AppendObject:newFill];
								break;
							}
							
							tempX++;
							tempY++;
						}
					}
					else {
						int tempX = fill.initialX;
						int tempY = fill.initialY+1;
						while (YES) {
							if (tempY >= height) {
								break;
							}
							MapNode* newNode = [(NSMutableArray*)[nodeInfo objectAtIndex:tempX] objectAtIndex:tempY];
							
							if ([newNode foldCount] == 0) {
								FillNodes* newFill = [[[FillNodes alloc] init] autorelease];
								newFill.initialX = tempX;
								newFill.initialY = tempY;
								newFill.i = fill.i;
								newFill.j = fill.j+1;
								[queue AppendObject:newFill];
								break;
							}
							
							tempY++;
						}
					}
					
				}

			}
			
		}
		else {
//			NSLog(@"has filled before, next one");
		}

	}
	
	[queue release];
}



//as the name suggests, this method is used to fill the nodesOnScreen array recursively
-(void) RecursivelyFillNodesOnScreenWithXPos:(int)xPos YPos:(int)yPos InitialXPos:(int)initialX InitialYPos:(int)initialY
{	
	if (xPos < 0 || xPos >= SCREEN_WIDTH+2*ADDED_WIDTH) {
		return;
	}
	if (yPos < 0 || yPos >= SCREEN_HEIGHT+2*ADDED_HEIGHT) {
		return;
	}
	
	nodesOnScreen[xPos][yPos] = [(NSMutableArray*)[nodeInfo objectAtIndex:initialX] objectAtIndex:initialY];

	//this two params will be used below
	int tempX = initialX;
	int tempY = initialY;

	//CLOCKWISE
	
	//if the one above is still nil，it needs fill
	if (yPos+1 < SCREEN_HEIGHT+2*ADDED_HEIGHT && nodesOnScreen[xPos][yPos+1] == nil) {
		tempX = initialX;
		tempY = initialY + 1;
		while (YES)
		{
			if (tempY >= height) {
				break;
			}
			
			MapNode* node = [(NSMutableArray*)[nodeInfo objectAtIndex:tempX] objectAtIndex:tempY];
			if (node == nil) {
				break;
			}
			if (node.foldCount == 0) {
				[self RecursivelyFillNodesOnScreenWithXPos:xPos YPos:yPos+1 InitialXPos:tempX InitialYPos:tempY];
				break;
			}
			tempY++;
		}		
	}
	
	//if the one on the right is still nil，it needs fill
	if (xPos+1 < SCREEN_WIDTH+2*ADDED_WIDTH && nodesOnScreen[xPos+1][yPos] == nil) {
		tempX = initialX + 1;
		tempY = initialY;
		while (YES)
		{
			if (tempX >= width) {
				break;
			}
			MapNode* node = [(NSMutableArray*)[nodeInfo objectAtIndex:tempX] objectAtIndex:tempY];
			if (node == nil) {
				break;
			}
			if (node.foldCount == 0) {
				[self RecursivelyFillNodesOnScreenWithXPos:xPos+1 YPos:yPos InitialXPos:tempX InitialYPos:tempY];
				break;
			}
			tempX++;
		}
	}
	
	//if the one below is still nil，it needs fill
	if (yPos-1 >= 0 && nodesOnScreen[xPos][yPos-1] == nil) {
		tempX = initialX;
		tempY = initialY - 1;
		while (YES)
		{
			if (tempY < 0) {
				break;
			}
			MapNode* node = [(NSMutableArray*)[nodeInfo objectAtIndex:tempX] objectAtIndex:tempY];
			if (node == nil) {
				break;
			}
			if (node.foldCount == 0) {
				[self RecursivelyFillNodesOnScreenWithXPos:xPos YPos:yPos-1 InitialXPos:tempX InitialYPos:tempY];
				break;
			}
			tempY--;
		}
	}
	
	//if the one ont the left is still nil，it needs fill
	if (xPos-1 >= 0 && nodesOnScreen[xPos-1][yPos] == nil) {
		tempX = initialX - 1;
		tempY = initialY;
		while (YES)
		{
			if (tempX < 0) {
				break;
			}
			MapNode* node = [(NSMutableArray*)[nodeInfo objectAtIndex:tempX] objectAtIndex:tempY];
			if (node == nil) {
				break;
			}
			if (node.foldCount == 0) {
				[self RecursivelyFillNodesOnScreenWithXPos:xPos-1 YPos:yPos InitialXPos:tempX InitialYPos:tempY];
				break;
			}
			tempX--;
		}
	}
}



//to show which part of the whole map at the first time
-(void) InitializeMapForTheFirstTime
{
	//the initialization should be correct, so there needn't too much IF
	for (int i=0,x=AutoDoneOneSideX-showFromX; i<SCREEN_WIDTH+2*ADDED_WIDTH; i++,x++) {
		NSMutableArray* original = [nodeInfo objectAtIndex:x];
		for (int j=0,y=AutoDoneOneSideY-showFromY; j<SCREEN_HEIGHT+2*ADDED_HEIGHT; j++,y++) {
			MapNode* node = [original objectAtIndex:y];
			nodesOnScreen[i][j] = node;
		}
	}
	
	//attaching sprites
	[self AddScreenSpritesToChilds];
}



//remake the present map with the information of nodeInfo
//only called after the fold/unfold operation happens
-(BOOL) RemakePresentMapWith1stFoldPoint:(CGPoint*)point1 With2ndFoldPoint:(CGPoint*)point2
{
	//PS: Here! It needs the cooperation of the map's data, assuming that the map is boundless
	CGPoint warriorPoint = warriorLayer.ManSprite.position;
	
	int warriorLeftUpX = (warriorPoint.x - 8 + 1e-4) / 32;
	int warriorLeftUpY = (warriorPoint.y + 9 + 1e-4) / 32;
	
	int warriorRightUpX = (warriorPoint.x + 8 + 1e-4) / 32;
	int warriorRightUpY = (warriorPoint.y + 9 + 1e-4) / 32;
	
	int warriorLeftDownX = (warriorPoint.x - 8 + 1e-4) / 32;
	int warriorLeftDownY = (warriorPoint.y - 9 + 1e-4) / 32;
	
	int warriorRightDownX = (warriorPoint.x + 8 + 1e-4) / 32;
	int warriorRightDownY = (warriorPoint.y - 9 + 1e-4) / 32;

	MapNode* leftUpNode = nodesOnScreen[warriorLeftUpX+showFromX][warriorLeftUpY+showFromY];
	MapNode* leftDownNode = nodesOnScreen[warriorLeftDownX+showFromX][warriorLeftDownY+showFromY];
	MapNode* rightUpNode = nodesOnScreen[warriorRightUpX+showFromX][warriorRightUpY+showFromY];
	MapNode* rightDownNode = nodesOnScreen[warriorRightDownX+showFromX][warriorRightDownY+showFromY];

	if (leftUpNode.foldCount != 0 || leftDownNode.foldCount != 0
		|| rightUpNode.foldCount != 0 || rightDownNode.foldCount != 0) {
		NSLog(@"the warrior has been folded to death!!!!!");
		NSLog(@"foldpoint1: %f,%f",foldPoint1.x, foldPoint1.y);
		NSLog(@"foldpoint2: %f,%f",foldPoint2.x, foldPoint2.y);
		NSLog(@"leftup: %d,  %d,%d",leftUpNode.foldCount,warriorLeftUpX,warriorLeftUpY);
		NSLog(@"leftdown: %d,  %d,%d",leftDownNode.foldCount,warriorLeftDownX,warriorLeftDownY);
		NSLog(@"rightup: %d,  %d,%d",rightUpNode.foldCount,warriorRightUpX,warriorRightUpY);
		NSLog(@"rightdown: %d,  %d,%d",rightDownNode.foldCount,warriorRightDownX,warriorRightDownY);
		////////////////////
		//做一些什么吧这里！
		////////////////////
		[warriorLayer losegame];
		
		//[NSThread sleepForTimeInterval:0.5];
		
		return NO;
	}

	if (shouldWaitForAnimation) {
//		NSLog(@"make animation here");
		shouldWaitForAnimation = NO;
		
//		for (int i=0; i<10; i++) {
//			CCSprite* bombSprite = [CCSprite spriteWithTexture:bombSheet.texture
//														  rect:CGRectMake(0, 0, 32, 32)];
//			[bombSheet addChild:bombSprite z:1];		
//			CCAnimation *bombAnimation = [CCAnimation animationWithName:@"bomb" delay:0.1f];
//			for (int k=0; k<BOMB_ANIMATION_PICTURES; k++) {
//				CCSpriteFrame* frame = [CCSpriteFrame frameWithTexture:bombSheet.texture
//																  rect:CGRectMake(k*32, 0, 32, 32)
//																offset:ccp(32*i+16,32*i+16)];
//				[bombAnimation addFrame:frame];
//			}
//			
//			CCAnimate* bombAction = [CCAnimate actionWithAnimation:bombAnimation];
//			//[bombSprite runAction:bombAction];		
//			id waitSomeTime = [CCSpawn actions:[CCDelayTime actionWithDuration:0.5],bombAction,nil];
//			[bombSprite runAction:waitSomeTime];
//			//[bombSprite runAction:[CCSequence actions:waitSomeTime,
//			//					   [CCCallFunc actionWithTarget:self selector:@selector(AddNodesOnScreenToSelfChildren)],nil]];
//		}
//		CCSprite* bombSprite = [CCSprite spriteWithTexture:bombSheet.texture
//													  rect:CGRectMake(0, 0, 32, 32)];
//		[bombSprite runAction:[CCDelayTime actionWithDuration:0.5]];
	}
	
	[self ReleasePresentMap];
	
	int x1 = [self GetXFromPoint:&foldPoint1];
	int y1 = [self GetYFromPoint:&foldPoint1];
	int x2 = [self GetXFromPoint:&foldPoint2];
	int y2 = [self GetYFromPoint:&foldPoint2];
	if (x1 != x2 && y1 != y2) {
		double k = (x1-x2) / (y2-y1);
		if (k > 0.25 && k < 4) {
			[self FillNodesOnScreenWithXPos:warriorLeftDownX+showFromX YPos:warriorLeftDownY+showFromY 
								InitialXPos:leftDownNode.initialX InitialYPos:leftDownNode.initialY Angle:45];
		}
		else if (k < -0.25 && k > -4)
		{
			[self FillNodesOnScreenWithXPos:warriorLeftDownX+showFromX YPos:warriorLeftDownY+showFromY 
								InitialXPos:leftDownNode.initialX InitialYPos:leftDownNode.initialY Angle:-45];
		}
		else {
//			NSLog(@"x1=%d,y1=%d,x2=%d,y2=%d,k=%f",x1,y1,x2,y2,k);
//			NSLog(@"foldpoint1: %f,%f",foldPoint1.x,foldPoint1.y);
//			NSLog(@"foldpoint2: %f,%f",foldPoint2.x,foldPoint2.y);
//			NSAssert(NO,@"why here! it should never come to here!!!");
			[self FillNodesOnScreenWithXPos:warriorLeftDownX+showFromX YPos:warriorLeftDownY+showFromY 
								InitialXPos:leftDownNode.initialX InitialYPos:leftDownNode.initialY Angle:0];	//angle is useless here;
		}

	}
	else {
		[self FillNodesOnScreenWithXPos:warriorLeftDownX+showFromX YPos:warriorLeftDownY+showFromY 
							InitialXPos:leftDownNode.initialX InitialYPos:leftDownNode.initialY Angle:0];	//angle is useless here
	}

	
//	[self RecursivelyFillNodesOnScreenWithXPos:warriorLeftDownX+showFromX YPos:warriorLeftDownY+showFromY
//								   InitialXPos:leftDownNode.initialX	InitialYPos:leftDownNode.initialY];


	//attach sprites
	[self AddScreenSpritesToChilds];
	
	return YES;
}


//remove all the children that is to be shown on the screen except the two spritesheets
//for readd the sprites later
-(void) ResetSelfChildrenToInitialized
{
	[self removeAllChildrenWithCleanup:NO];
	[self addChild:backgroundSheet z:1];
	[self addChild:bombSheet z:1];
}


//attach the sprites that should be on the screen
//add them to [self children]
-(void) AddScreenSpritesToChilds
{
	for (int x=showFromX,i=0; i<SCREEN_WIDTH; i++,x++) {
		for (int y=showFromY,j=0; j<SCREEN_HEIGHT; j++,y++) {
			MapNode* node = nodesOnScreen[x][y];

			if (node == nil) {
				CCSprite* defaultSprite = [CCSprite spriteWithTexture:backgroundSheet.texture
																 rect:CGRectMake(5*32, 0, 32, 32)];
				defaultSprite.position = ccp(i*32+16,j*32+16);
				[self addChild:defaultSprite];
			}
			else {
				node.backSprite.position = ccp(i*32+16,j*32+16);
				node.foreSprite.position = ccp(i*32+16,j*32+16);
				
				if (![[self children] containsObject:nodesOnScreen[x][y].foreSprite]) {
					if (nodesOnScreen[x][y].backSprite != nil) {
						[self addChild:nodesOnScreen[x][y].backSprite];
					}
					if (nodesOnScreen[x][y].foreSprite != nil) {
						[self addChild:nodesOnScreen[x][y].foreSprite];
					}
				}
				else {
					//if on some conditions, one particular sprite has been added, add a default sprite
					CCSprite* backSprite = [CCSprite spriteWithTexture:backgroundSheet.texture
																  rect:CGRectMake(node.nodeBackType*32, 0, 32, 32)];
					CCSprite* foreSprite = [CCSprite spriteWithTexture:backgroundSheet.texture
																  rect:CGRectMake(node.nodeForeType*32, 0, 32, 32)];
					backSprite.position = ccp(i*32+16,j*32+16);
					foreSprite.position = ccp(i*32+16,j*32+16);
					[self addChild:backSprite];
					[self addChild:foreSprite];
				}
			}
			
		}
	}
}




//set the nodesOnScreen array to nil everywhere for future filling
-(void) ReleasePresentMap
{	
	for (int i=0; i<SCREEN_WIDTH+2*ADDED_WIDTH; i++) {
		for (int j=0; j<SCREEN_HEIGHT+2*ADDED_HEIGHT; j++) {
			nodesOnScreen[i][j] = nil;
		}
	}
	[self ResetSelfChildrenToInitialized];
}



//when FOLD happens, update the information in nodeInfo
//assuming that point1 != point2
-(void) FoldFromPoint:(CGPoint*)point1 ToPoint:(CGPoint*)point2
{
	//testing whether the warrior is within the screen+buffer, if not, fold isn't permitted
	CGPoint warriorPoint = warriorLayer.ManSprite.position;
	
	int warriorLeftUpX = (warriorPoint.x - 12 + 1e-4) / 32;
	int warriorLeftUpY = (warriorPoint.y + 16 + 1e-4) / 32;
	
	int warriorRightUpX = (warriorPoint.x + 12 + 1e-4) / 32;
	int warriorRightUpY = (warriorPoint.y + 16 + 1e-4) / 32;

	int warriorLeftDownX = (warriorPoint.x - 12 + 1e-4) / 32;
	int warriorLeftDownY = (warriorPoint.y - 16 + 1e-4) / 32;	
	
	int warriorRightDownX = (warriorPoint.x + 12 + 1e-4) / 32;
	int warriorRightDownY = (warriorPoint.y - 16 + 1e-4) / 32;

	BOOL leftUpInvalid = warriorLeftUpX+showFromX < 0 || warriorLeftUpX+showFromX > SCREEN_WIDTH+2*ADDED_WIDTH
	|| warriorLeftUpY+showFromY < 0 || warriorLeftUpY+showFromY > SCREEN_HEIGHT+2*ADDED_HEIGHT;
	
	BOOL leftDownInvalid = warriorLeftDownX+showFromX < 0 || warriorLeftDownX+showFromX > SCREEN_WIDTH+2*ADDED_WIDTH
	|| warriorLeftDownY+showFromY < 0 || warriorLeftDownY+showFromY > SCREEN_HEIGHT+2*ADDED_HEIGHT;
	
	BOOL rightUpInvalid = warriorRightUpX+showFromX < 0 || warriorRightUpX+showFromX > SCREEN_WIDTH+2*ADDED_WIDTH
	|| warriorRightUpY+showFromY < 0 || warriorRightUpY+showFromY > SCREEN_HEIGHT+2*ADDED_HEIGHT;
	
	BOOL rightDownInvalid = warriorRightDownX+showFromX < 0 || warriorRightDownX+showFromX > SCREEN_WIDTH+2*ADDED_WIDTH
	|| warriorRightDownY+showFromY < 0 || warriorRightDownY+showFromY > SCREEN_HEIGHT+2*ADDED_HEIGHT;
	
	if (leftUpInvalid || leftDownInvalid || rightUpInvalid || rightDownInvalid) {
		NSLog(@"warrior is out of screen, could not fold!");
		return;
	}
	
	

	//folding starts
	
	int i1 = [self GetXFromPoint:point1];
	int j1 = [self GetYFromPoint:point1];
	int i2 = [self GetXFromPoint:point2];
	int j2 = [self GetYFromPoint:point2];
	
	if (i1 != i2 && j1 != j2) {
		return;
	}
	

	
	MapNode* node1 = nodesOnScreen[i1+showFromX][j1+showFromY];
	int x1 = node1.initialX;
	int y1 = node1.initialY;
	
	MapNode* node2 = nodesOnScreen[i2+showFromX][j2+showFromY];
	int x2 = node2.initialX;
	int y2 = node2.initialY;

	
	int length = (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2);
	if (length >= 64) {
		//fold the points that is too far away, BANNED
		return;
	}
	
	
	self.totalFoldCount++;

	//save the info of which two points fold together
	[node1 PushAnotherFoldNode:node2];
	[node2 PushAnotherFoldNode:node1];
	
	if (y1 == y2) {
		int xSmall = (x1 < x2)?x1:x2;
		int xLarge = (x1 > x2)?x1:x2;
	
		for (int i=xSmall+1; i<=xLarge; i++) {
			NSMutableArray* line = [nodeInfo objectAtIndex:i];
			for (int j=0; j<height; j++) {
				MapNode* node = [line objectAtIndex:j];
				[node Fold];
//这里一大段代码是用来在屏幕要消失的地方放一点动画，但是由于无法让主线程暂停，在动画完毕后再缩进来，因此先注释掉把				
//				CGPoint point = [self GetCGPointFromMapByX:i Y:j];
//				CGPoint nullPoint = ccp(0,0);
//				if (point.x == nullPoint.x && point.y == nullPoint.y) {
//					continue;
//				}
//
//				CCSprite* bombSprite = [CCSprite spriteWithTexture:bombSheet.texture
//															  rect:CGRectMake(0, 0, 32, 32)];
//				[bombSheet addChild:bombSprite z:1];		
//				CCAnimation *bombAnimation = [CCAnimation animationWithName:@"bomb" delay:0.1f];
//				for (int k=0; k<BOMB_ANIMATION_PICTURES; k++) {
//					CCSpriteFrame* frame = [CCSpriteFrame frameWithTexture:bombSheet.texture
//																	  rect:CGRectMake(k*32, 0, 32, 32)
//																	offset:point];
//					[bombAnimation addFrame:frame];
//				}
//				
//				CCAnimate* bombAction = [CCAnimate actionWithAnimation:bombAnimation];
//				[bombSprite runAction:bombAction];
			}
		}
		shouldWaitForAnimation = YES;
		[self RemakePresentMapWith1stFoldPoint:&foldPoint1 With2ndFoldPoint:&foldPoint2];
	}
	else {
		double k = (double)(x1-x2) / (double)(y2-y1);	//垂直平分线的斜率k
		int b1 = y1 - k * x1 + 1e-4;
		int b2 = y2 - k * x2 + 1e-4;
		int bSmall = (b1 < b2)?b1:b2;
		int bLarge = (b1 > b2)?b1:b2;
		
		if (k > 0) {
			for (int i=0; i<width; i++) {
				NSMutableArray* line = [nodeInfo objectAtIndex:i];
				for (int j=0; j<height; j++) {
					MapNode* node = [line objectAtIndex:j];
					int b3 = j - k * i + 1e-4;
					if (b3 >= bSmall && b3 < bLarge) {
						[node Fold];
					}
				}
			}
		}
		else {
			for (int i=0; i<width; i++) {
				NSMutableArray* line = [nodeInfo objectAtIndex:i];
				for (int j=0; j<height; j++) {
					MapNode* node = [line objectAtIndex:j];
					int b3 = j - k * i + 1e-4;
					if (b3 > bSmall && b3 <= bLarge) {
						[node Fold];
					}
				}
			}
		}
		
		[self RemakePresentMapWith1stFoldPoint:&foldPoint1 With2ndFoldPoint:&foldPoint2];
	}

	[warriorLayer ziyouluoti];
	[[SimpleAudioEngine sharedEngine] playEffect:@"trick.mp3"];

	//似乎还是又autorelease的问题，这次好像是spritesheet
	//set the node's texture to folded
//	[node1.sprite release];
//	if (node1.nodeType == MAP_NODE_TYPE_TRICK_UP || node1.nodeType == MAP_NODE_TYPE_TRICK_DOWN) {
//		node1.nodeType = MAP_NODE_TYPE_TRICK_VERT;
//	}
//	else if (node1.nodeType == MAP_NODE_TYPE_TRICK_LEFT || node1.nodeType == MAP_NODE_TYPE_TRICK_RIGHT)
//	{
//		node1.nodeType = MAP_NODE_TYPE_TRICK_HORI;
//	}
//	NSLog(@"%d",node1.nodeType);
//	node1.sprite = [[CCSprite alloc] initWithTexture:backgroundSheet.texture
//											   rect:CGRectMake(node1.nodeType, 0, 32, 32)];
//	
//	[node2.sprite release];
//	if (node2.nodeType == MAP_NODE_TYPE_TRICK_UP || node2.nodeType == MAP_NODE_TYPE_TRICK_DOWN) {
//		node2.nodeType = MAP_NODE_TYPE_TRICK_VERT;
//	}
//	else if (node2.nodeType == MAP_NODE_TYPE_TRICK_LEFT || node2.nodeType == MAP_NODE_TYPE_TRICK_RIGHT)
//	{
//		node2.nodeType = MAP_NODE_TYPE_TRICK_HORI;
//	}
//	node2.sprite = [[CCSprite alloc] initWithTexture:backgroundSheet.texture
//												rect:CGRectMake(node2.nodeType, 0, 32, 32)];
	
}

					 
//when UNFOLD happens, update the information in nodeInfo
-(void) UnfoldFromPoint:(CGPoint *)point
{
	//similarly, when warrior isn't within screen+buffer, unfold isn't permitted
	CGPoint warriorPoint = warriorLayer.ManSprite.position;
	
	int warriorLeftUpX = (warriorPoint.x - 12 + 1e-4) / 32;
	int warriorLeftUpY = (warriorPoint.y + 16 + 1e-4) / 32;
	
	int warriorRightUpX = (warriorPoint.x + 12 + 1e-4) / 32;
	int warriorRightUpY = (warriorPoint.y + 16 + 1e-4) / 32;
	
	int warriorLeftDownX = (warriorPoint.x - 12 + 1e-4) / 32;
	int warriorLeftDownY = (warriorPoint.y - 16 + 1e-4) / 32;	
	
	int warriorRightDownX = (warriorPoint.x + 12 + 1e-4) / 32;
	int warriorRightDownY = (warriorPoint.y - 16 + 1e-4) / 32;
	
	BOOL leftUpInvalid = warriorLeftUpX+showFromX < 0 || warriorLeftUpX+showFromX > SCREEN_WIDTH+2*ADDED_WIDTH
	|| warriorLeftUpY+showFromY < 0 || warriorLeftUpY+showFromY > SCREEN_HEIGHT+2*ADDED_HEIGHT;
	
	BOOL leftDownInvalid = warriorLeftDownX+showFromX < 0 || warriorLeftDownX+showFromX > SCREEN_WIDTH+2*ADDED_WIDTH
	|| warriorLeftDownY+showFromY < 0 || warriorLeftDownY+showFromY > SCREEN_HEIGHT+2*ADDED_HEIGHT;
	
	BOOL rightUpInvalid = warriorRightUpX+showFromX < 0 || warriorRightUpX+showFromX > SCREEN_WIDTH+2*ADDED_WIDTH
	|| warriorRightUpY+showFromY < 0 || warriorRightUpY+showFromY > SCREEN_HEIGHT+2*ADDED_HEIGHT;
	
	BOOL rightDownInvalid = warriorRightDownX+showFromX < 0 || warriorRightDownX+showFromX > SCREEN_WIDTH+2*ADDED_WIDTH
	|| warriorRightDownY+showFromY < 0 || warriorRightDownY+showFromY > SCREEN_HEIGHT+2*ADDED_HEIGHT;
	
	if (leftUpInvalid || leftDownInvalid || rightUpInvalid || rightDownInvalid) {
		NSLog(@"warrior is out of screen, could not unfold!");
		return;
	}
	
	
	//unfold starts
	self.totalFoldCount--;

	int i = [self GetXFromPoint:point];
	int j = [self GetYFromPoint:point];
	
	MapNode* node1 = nodesOnScreen[i+showFromX][j+showFromY];
	
	MapNode* node2 = [node1 PopAnotherFoldNode];
	NSAssert(node2 != nil, @"point hasn't saved another point to unfold");

	
	int x1 = node1.initialX;
	int y1 = node1.initialY;
	int x2 = node2.initialX;
	int y2 = node2.initialY;
	
	[node2 PopAnotherFoldNode];

	if (y1 == y2) {
		int xSmall = (x1 < x2)?x1:x2;
		int xLarge = (x1 > x2)?x1:x2;
		
		for (int i=xSmall+1; i<=xLarge; i++) {
			NSMutableArray* line = [nodeInfo objectAtIndex:i];
			for (int j=0; j<height; j++) {
				MapNode* node = [line objectAtIndex:j];
				[node Unfold];
			}
		}
		[self RemakePresentMapWith1stFoldPoint:&foldPoint1 With2ndFoldPoint:&foldPoint2];
	} 
	else {
		double k = (double)(x1-x2) / (double)(y2-y1);	//垂直平分线的斜率k
		int b1 = y1 - k * x1 + 1e-4;
		int b2 = y2 - k * x2 + 1e-4;
		int bSmall = (b1 < b2)?b1:b2;
		int bLarge = (b1 > b2)?b1:b2;
		
		
		if (k > 0) {
			for (int i=0; i<width; i++) {
				NSMutableArray* line = [nodeInfo objectAtIndex:i];
				for (int j=0; j<height; j++) {
					MapNode* node = [line objectAtIndex:j];
					int b3 = j - k * i + 1e-4;					
					if (b3 >= bSmall && b3 < bLarge) {
						[node Unfold];
					}
				}
			}
			//同理，可能没有必要分成两个函数了
			
			//这里调用with1stFoldPoint With2ndFoldPoint是有问题的！！！因为此时的foldPoint1和foldPoint2已经不是fold时候的那两个了！！！
			[self RemakePresentMapWith1stFoldPoint:&foldPoint1 With2ndFoldPoint:&foldPoint2];
		}
		else {
			for (int i=0; i<width; i++) {
				NSMutableArray* line = [nodeInfo objectAtIndex:i];
				for (int j=0; j<height; j++) {
					MapNode* node = [line objectAtIndex:j];
					int b3 = j - k * i + 1e-4;
					if (b3 > bSmall && b3 <= bLarge) {
						[node Unfold];
					}
				}
			}		
			//这里调用with1stFoldPoint With2ndFoldPoint是有问题的！！！因为此时的foldPoint1和foldPoint2已经不是fold时候的那两个了！！！
			[self RemakePresentMapWith1stFoldPoint:&foldPoint1 With2ndFoldPoint:&foldPoint2];
		}
	}
	
	[warriorLayer ziyouluoti];
	[[SimpleAudioEngine sharedEngine] playEffect:@"trick.mp3"];
	
	//reset the texture of the node to normal (not fold)

//	[node1.sprite release];
//	if (node1.nodeType == MAP_NODE_TYPE_TRICK_VERT) {
//		if (x1*x1+y1*y1 > x2*x2+y2*y2) {
//			node1.nodeType = MAP_NODE_TYPE_TRICK_UP;
//		}
//		else {
//			node1.nodeType = MAP_NODE_TYPE_TRICK_DOWN;
//		}
//		node1.sprite = [[CCSprite alloc] initWithTexture:backgroundSheet.texture
//													rect:CGRectMake(node1.nodeType, 0, 32, 32)];
//	}
//	else if (node1.nodeType == MAP_NODE_TYPE_TRICK_HORI)
//	{
//		if (x1*x1+y1*y1 > x2*x2+y2*y2) {
//			node1.nodeType = MAP_NODE_TYPE_TRICK_LEFT;
//		}
//		else {
//			node1.nodeType = MAP_NODE_TYPE_TRICK_RIGHT;
//		}
//		node1.sprite = [[CCSprite alloc] initWithTexture:backgroundSheet.texture
//													rect:CGRectMake(node1.nodeType, 0, 32, 32)];
//	}
	
	
	//似乎又有autorelease的问题！这次好像是spritesheet
//	[node2.sprite release];
//	if (node2.nodeType == MAP_NODE_TYPE_TRICK_VERT) {
//		if (x1*x1+y1*y1 > x2*x2+y2*y2) {
//			node2.nodeType = MAP_NODE_TYPE_TRICK_UP;
//		}
//		else {
//			node2.nodeType = MAP_NODE_TYPE_TRICK_DOWN;
//		}
//		node2.sprite = [[CCSprite alloc] initWithTexture:backgroundSheet.texture
//													rect:CGRectMake(node2.nodeType, 0, 32, 32)];
//	}
//	else if (node2.nodeType == MAP_NODE_TYPE_TRICK_HORI)
//	{
//		if (x1*x1+y1*y1 > x2*x2+y2*y2) {
//			node2.nodeType = MAP_NODE_TYPE_TRICK_LEFT;
//		}
//		else {
//			node2.nodeType = MAP_NODE_TYPE_TRICK_RIGHT;
//		}
//		node2.sprite = [[CCSprite alloc] initWithTexture:backgroundSheet.texture
//													rect:CGRectMake(node2.nodeType, 0, 32, 32)];
//	}
}



					 
//get the type of the point
-(int) GetMapInfoAtPoint:(CGPoint)point
{
	int i = [self GetXFromPoint:&point];
	int j = [self GetYFromPoint:&point];
	
//	if (i < 0-ADDED_WIDTH || i >= SCREEN_WIDTH+ADDED_WIDTH || j < 0-ADDED_HEIGHT || j >= SCREEN_HEIGHT+ADDED_HEIGHT) {
//		//越界了怎么办！！！这里是先返回一个0，那么将会被弹回来或者停住。
//		NSAssert(NO,@"out of range in GetMapInfoAtPoint");
//		return 0;
//	}
	
	MapNode* node = nodesOnScreen[i+showFromX][j+showFromY];
	
	return node.nodeForeType;
}

					 
//convert from CGPoint's xy into Array's xy
-(int) GetXFromPoint:(CGPoint *)point
{
	//adding 1e-4 is because it used float(the precise problem, we'v suffered a lot in ACM)
	int x = point->x + 1e-4;
	
	if (x > 0) {
		return x / 32;
	}
	else {
		return x / 32 - 1;
	}
}

					 
//convert from CGPoint's xy into Array's xy
-(int) GetYFromPoint:(CGPoint *)point
{
	//adding 1e-4 is because it used float(the precise problem, we'v suffered a lot in ACM)
	int y = point->y + 1e-4;

	if (y > 0) {
		return y / 32;
	}
	else {
		return y / 32 - 1;
	}
}





//screen scrolling up
-(void) MapMoveUp
{
	int totalWidth = SCREEN_WIDTH + 2*ADDED_WIDTH;
	int totalHeight = SCREEN_HEIGHT + 2*ADDED_HEIGHT;
	for (int i=0; i<totalWidth; i++) {
		MapNode* node = nodesOnScreen[i][totalHeight-1];
		if (node.initialY == height-1) {
			return;
		}
	}
	
	for (int i=0; i<totalWidth; i++) {
		for (int j=0; j<totalHeight-1; j++) {
			nodesOnScreen[i][j] = nodesOnScreen[i][j+1];
		}
	}
	for (int i=0; i<totalWidth; i++) {
		MapNode* node = nodesOnScreen[i][totalHeight-1];
		int x = node.initialX;
		int y = node.initialY;
		while (YES) {
			y++;
			if (y >= height) {
				return;
			}
			MapNode* nextNode = [(NSMutableArray*)[nodeInfo objectAtIndex:x] objectAtIndex:y];
			if (nextNode.foldCount == 0) {
				nodesOnScreen[i][totalHeight-1] = nextNode;
				break;
			}
		}
	}
	
	[self ResetSelfChildrenToInitialized];
	[self AddScreenSpritesToChilds];
	CGPoint warriorPoint = warriorLayer.ManSprite.position;
	warriorPoint.y -= 32;
	warriorLayer.ManSprite.position = warriorPoint;
}


//screen scrolling down
-(void) MapMoveDown
{
	int totalWidth = SCREEN_WIDTH + 2*ADDED_WIDTH;
	int totalHeight = SCREEN_HEIGHT + 2*ADDED_HEIGHT;
	for (int i=0; i<totalWidth; i++) {
		MapNode* node = nodesOnScreen[i][0];
		if (node.initialY == 0) {
			return;
		}
	}
	
	for (int i=0; i<totalWidth; i++) {
		for (int j=totalHeight-1; j>0; j--) {
			nodesOnScreen[i][j] = nodesOnScreen[i][j-1];
		}
	}
	for (int i=0; i<totalWidth; i++) {
		MapNode* node = nodesOnScreen[i][0];
		int x = node.initialX;
		int y = node.initialY;
		while (YES) {
			y--;
			if (y < 0) {
				return;
			}
			MapNode* nextNode = [(NSMutableArray*)[nodeInfo objectAtIndex:x] objectAtIndex:y];
			if (nextNode.foldCount == 0) {
				nodesOnScreen[i][0] = nextNode;
				break;
			}
		}
	}
	
	[self ResetSelfChildrenToInitialized];
	[self AddScreenSpritesToChilds];
	CGPoint warriorPoint = warriorLayer.ManSprite.position;
	warriorPoint.y += 32;
	warriorLayer.ManSprite.position = warriorPoint;
}


//screen scrolling left
-(void) MapMoveLeft
{
	int totalWidth = SCREEN_WIDTH + 2*ADDED_WIDTH;
	int totalHeight = SCREEN_HEIGHT + 2*ADDED_HEIGHT;
	for (int i=0; i<totalHeight; i++) {
		MapNode* node = nodesOnScreen[0][i];
		if (node.initialX == 0) {
			return;
		}
	}
	
	for (int i=totalWidth-1; i>0; i--) {
		for (int j=0; j<totalHeight; j++) {
			nodesOnScreen[i][j] = nodesOnScreen[i-1][j];
		}
	}
	for (int i=0; i<totalHeight; i++) {
		MapNode* node = nodesOnScreen[0][i];
		int x = node.initialX;
		int y = node.initialY;
		while (YES) {
			x--;
			if (x < 0) {
				return;
			}
			MapNode* nextNode = [(NSMutableArray*)[nodeInfo objectAtIndex:x] objectAtIndex:y];
			if (nextNode.foldCount == 0) {
				nodesOnScreen[0][i] = nextNode;
				break;
			}
		}
	}
	
	[self ResetSelfChildrenToInitialized];
	[self AddScreenSpritesToChilds];
	CGPoint warriorPoint = warriorLayer.ManSprite.position;
	warriorPoint.x += 32;
	warriorLayer.ManSprite.position = warriorPoint;
}


//screen scrolling right
-(void) MapMoveRight
{
	int totalWidth = SCREEN_WIDTH + 2*ADDED_WIDTH;
	int totalHeight = SCREEN_HEIGHT + 2*ADDED_HEIGHT;
	for (int i=0; i<totalHeight; i++) {
		MapNode* node = nodesOnScreen[totalWidth-1][i];
		if (node.initialX == width-1) {
			return;
		}
	}
	
	for (int i=0; i<totalWidth-1; i++) {
		for (int j=0; j<totalHeight; j++) {
			nodesOnScreen[i][j] = nodesOnScreen[i+1][j];
		}
	}
	for (int i=0; i<totalHeight; i++) {
		MapNode* node = nodesOnScreen[totalWidth-1][i];
		int x = node.initialX;
		int y = node.initialY;
		while (YES) {
			x++;
			if (x >= width) {
				return;
			}
			MapNode* nextNode = [(NSMutableArray*)[nodeInfo objectAtIndex:x] objectAtIndex:y];
			if (nextNode.foldCount == 0) {
				nodesOnScreen[totalWidth-1][i] = nextNode;
				break;
			}
		}
	}
	
	[self ResetSelfChildrenToInitialized];
	[self AddScreenSpritesToChilds];
	CGPoint warriorPoint = warriorLayer.ManSprite.position;
	warriorPoint.x -= 32;
	warriorLayer.ManSprite.position = warriorPoint;
}




-(BOOL) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{	
	self.justFolded = NO;

	if (!self.shouldFold) {

		//only one point tested at a time
		if ([touches count] == 1) {
			UITouch* touch = [touches anyObject];
			CGPoint location = [touch locationInView: [touch view]];
			CGPoint point = [[CCDirector sharedDirector] convertToGL:location];
			
			int x = [self GetXFromPoint:&point];
			int y = [self GetYFromPoint:&point];
			
			for (int i=x-2; i<=x+2; i++) {
				for (int j=y-2; j<=y+2; j++) {
					MapNode* node = nodesOnScreen[i+showFromX][j+showFromY];
					BOOL nodeCanFold = node.nodeForeType == MAP_NODE_TYPE_TRICK_DOWN || 
										node.nodeForeType == MAP_NODE_TYPE_TRICK_UP	|| 
										node.nodeForeType == MAP_NODE_TYPE_TRICK_LEFT ||
										node.nodeForeType == MAP_NODE_TYPE_TRICK_RIGHT;
					
					if (nodeCanFold) {
						CGPoint thePoint = ccp(i*32+16,j*32+16);

						//fill foldPoint1
						if (foldPoint1.x == nullPoint.x && foldPoint1.y == nullPoint.y) {
							foldPoint1 = thePoint;
//							NSLog(@"touch once, foldPoint 1 has been saved %f,%f",foldPoint1.x,foldPoint1.y);
						}
						
						//fill foldPoint2
						else if (foldPoint2.x == nullPoint.x && foldPoint2.y == nullPoint.y)
						{
							if (thePoint.x != foldPoint1.x || thePoint.y != foldPoint1.y) {
								foldPoint2 = thePoint;
//								NSLog(@"touch once, foldPoint 2 has been saved %f,%f",foldPoint2.x,foldPoint2.y);
								lastFoldPointsDistance = (foldPoint1.x-foldPoint2.x)*(foldPoint1.x-foldPoint2.x) 
														+ (foldPoint1.y-foldPoint2.y)*(foldPoint1.y-foldPoint2.y);
							}
						}
						
						//if there's any foldPoint filling, enough, return
						return YES;
					}
				}
			}			
		}

		//two points tested at a time
		else if ([touches count] == 2)
		{
			NSEnumerator* enu = [touches objectEnumerator];
			UITouch* touch1 = [enu nextObject];
			UITouch* touch2 = [enu nextObject];
			CGPoint location1 = [touch1 locationInView:[touch1 view]];
			CGPoint location2 = [touch2 locationInView:[touch2 view]];
			CGPoint point1 = [[CCDirector sharedDirector] convertToGL:location1];
			CGPoint point2 = [[CCDirector sharedDirector] convertToGL:location2];
			
			int x1 = [self GetXFromPoint:&point1];
			int y1 = [self GetYFromPoint:&point1];
			int x2 = [self GetXFromPoint:&point2];
			int y2 = [self GetYFromPoint:&point2];
			
			if (x1 != x2 || y1 != y2) {
				
				//try point1
				for (int i=x1-1; i<=x1+1; i++) {
					for (int j=y1-1; j<=y1+1; j++) {
						MapNode* node = nodesOnScreen[i+showFromX][j+showFromY];
						BOOL nodeCanFold = node.nodeForeType == MAP_NODE_TYPE_TRICK_DOWN ||
											node.nodeForeType == MAP_NODE_TYPE_TRICK_UP	|| 
											node.nodeForeType == MAP_NODE_TYPE_TRICK_LEFT || 
											node.nodeForeType == MAP_NODE_TYPE_TRICK_RIGHT;
						
						if (nodeCanFold) {
							CGPoint thePoint = ccp(i*32+16,j*32+16);
							
							if (foldPoint1.x == nullPoint.x && foldPoint1.y == nullPoint.y) {
								foldPoint1 = thePoint;
//								NSLog(@"touch twice, 1st, foldpoint1 has been saved %f,%f",foldPoint1.x,foldPoint1.y);
							}
							else if (foldPoint2.x == nullPoint.x && foldPoint2.y == nullPoint.y)
							{
								if (thePoint.x != foldPoint1.x || thePoint.y != foldPoint1.y) {
									foldPoint2 = thePoint;
//									NSLog(@"touch twice, 1st, foldpoint2 has been saved %f,%f",foldPoint2.x,foldPoint2.y);
									lastFoldPointsDistance = (foldPoint1.x-foldPoint2.x)*(foldPoint1.x-foldPoint2.x)
															+ (foldPoint1.y-foldPoint2.y)*(foldPoint1.y-foldPoint2.y);
								}
							}
						}
					}
				}
				
				//try point2
				for (int i=x2-1; i<=x2+1; i++) {
					for (int j=y2-1; j<=y2+1; j++) {
						MapNode* node = nodesOnScreen[i+showFromX][j+showFromY];
						BOOL nodeCanFold = node.nodeForeType == MAP_NODE_TYPE_TRICK_DOWN || 
											node.nodeForeType == MAP_NODE_TYPE_TRICK_UP	|| 
											node.nodeForeType == MAP_NODE_TYPE_TRICK_LEFT || 
											node.nodeForeType == MAP_NODE_TYPE_TRICK_RIGHT;
						
						if (nodeCanFold) {
							CGPoint thePoint = ccp(i*32+16,j*32+16);
							if (foldPoint1.x == nullPoint.x && foldPoint1.y == nullPoint.y) {
								foldPoint1 = thePoint;
//								NSLog(@"touch twice, 2nd, foldpoint1 has been saved %f,%f",foldPoint1.x,foldPoint1.y);
							}
							else if (foldPoint2.x == nullPoint.x && foldPoint2.y == nullPoint.y)
							{
								if (thePoint.x != foldPoint1.x || thePoint.y != foldPoint1.y) {
									foldPoint2 = thePoint;
//									NSLog(@"touch twice, 2nd, foldpoint2 has been saved %f,%f",foldPoint2.x,foldPoint2.y);
									lastFoldPointsDistance = (foldPoint1.x-foldPoint2.x)*(foldPoint1.x-foldPoint2.x) 
															+ (foldPoint1.y-foldPoint2.y)*(foldPoint1.y-foldPoint2.y);
								}
							}
						}
					}
				}
			}
			return YES;
		}
		
		

		//touching screen to scroll it
		if ([touches count] == 1 && !shouldMoveScreen) {
			shouldMoveScreen = YES;
			screenMovingDirection = MOVING_STAY;

			UITouch* touch = [touches anyObject];
			CGPoint location = [touch locationInView: [touch view]];
			CGPoint point = [[CCDirector sharedDirector] convertToGL:location];
			lastMoveScreenPoint = point;

			return YES;
		}		
	}
	return NO;
}


-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//test FOLDing conditions
	if ([touches count] == 2
		&& foldPoint1.x != nullPoint.x && foldPoint1.y != nullPoint.y
		&& foldPoint2.x != nullPoint.x && foldPoint2.y != nullPoint.y) 
	{
		NSEnumerator* enu = [touches objectEnumerator];
		UITouch* touch1 = [enu nextObject];
		UITouch* touch2 = [enu nextObject];
		CGPoint location1 = [touch1 locationInView:[touch1 view]];
		CGPoint location2 = [touch2 locationInView:[touch2 view]];
		
		double distance = (location1.x-location2.x) * (location1.x-location2.x) + (location1.y-location2.y) * (location1.y-location2.y);
		if (distance <= lastFoldPointsDistance) {
			lastFoldPointsDistance = distance;
			shouldFold = YES;
		}
		else {
			//assign a big number so that most distance is < it
			lastFoldPointsDistance = 9999999;	
			shouldFold = NO;
		}
		return;
	}
	
	//test screen scrolling
	if ([touches count] == 1 && shouldMoveScreen) {
		UITouch* touch = [touches anyObject];
		CGPoint location = [touch locationInView: [touch view]];
		CGPoint point = [[CCDirector sharedDirector] convertToGL:location];
		
		float xDistance = point.x - lastMoveScreenPoint.x;
		float yDistance = point.y - lastMoveScreenPoint.y;

		float distance = xDistance * xDistance + yDistance * yDistance;
		
		//from MOVING_STAY to any direction
		if (screenMovingDirection == MOVING_STAY) {
			if (distance > 100) {
				if (xDistance*xDistance > yDistance*yDistance) {
					if (xDistance < 0) {
						screenMovingDirection = MOVING_RIGHT;
					}
					else {
						screenMovingDirection = MOVING_LEFT;
					}
				}
				else if (xDistance*xDistance < yDistance*yDistance)
				{
					if (yDistance < 0) {
						screenMovingDirection = MOVING_UP;
					}
					else {
						screenMovingDirection = MOVING_DOWN;
					}
				}
				lastMoveScreenPoint = point;
			}
		}
		
		else {
			float k = yDistance / xDistance;

			//from 30 degree to 60 degree -> skew
			if (k*k > 0.25 && k*k < 4) {
				if (distance < 500) {
					return;
				}
				
				if (xDistance > 0 && yDistance > 0) {
					[self MapMoveLeft];
					[self MapMoveDown];
				}
				else if (xDistance > 0 && yDistance < 0)
				{
					[self MapMoveLeft];
					[self MapMoveUp];
				}
				else if (xDistance < 0 && yDistance > 0)
				{
					[self MapMoveRight];
					[self MapMoveDown];
				}
				else if (xDistance < 0 && yDistance < 0)
				{
					[self MapMoveRight];
					[self MapMoveUp];
				}
			}
			
			//MOVING_UP
			if (screenMovingDirection == MOVING_UP) {
				if (yDistance < 0 && xDistance < 50 && xDistance > -50) {
					if (distance > 250) {
						[self MapMoveUp];
						lastMoveScreenPoint = point;
					}
				}
				else {
					screenMovingDirection = MOVING_STAY;
					shouldMoveScreen = NO;
				}
			}
			//MOVING_DOWN
			else if (screenMovingDirection == MOVING_DOWN)
			{
				if (yDistance > 0 && xDistance < 50 && xDistance > -50) {
					if (distance > 250) {
						[self MapMoveDown];
						lastMoveScreenPoint = point;
					}
				}
				else {
					screenMovingDirection = MOVING_STAY;
					shouldMoveScreen = NO;
				}
			}
			//MOVING_LEFT
			else if (screenMovingDirection == MOVING_LEFT)
			{
				if (xDistance > 0 && yDistance < 50 && yDistance > -50) {
					if (distance > 250) {
						[self MapMoveLeft];
						lastMoveScreenPoint = point;
					}
				}
				else {
					screenMovingDirection = MOVING_STAY;
					shouldMoveScreen = NO;
				}
			}
			//MOVING_RIGHT
			else if (screenMovingDirection == MOVING_RIGHT)
			{
				if (xDistance < 0 && yDistance < 50 && yDistance > -50) {
					if (distance > 250) {
						[self MapMoveRight];
						lastMoveScreenPoint = point;
					}
				}
				else {
					screenMovingDirection = MOVING_STAY;
					shouldMoveScreen = NO;
				}
			}
		}
	}
}


-(BOOL) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//fold
	if (self.shouldFold) {
		self.shouldFold = NO;
		//similarly, assign a big number
		lastFoldPointsDistance = 9999999;	
		
		NSAssert(foldPoint1.x != foldPoint2.x || foldPoint1.y != foldPoint2.y,@"can not fold the same point");
		
		[self FoldFromPoint:&foldPoint1 ToPoint:&foldPoint2];

		justFolded = YES;
		foldPoint1 = nullPoint;
		foldPoint2 = nullPoint;
//		NSLog(@"foldPoints have been set to nullPoint");
		return YES;
	}
	
	
	//screen scrolling
	if (self.shouldMoveScreen && [touches count] == 1) {
		screenMovingDirection = MOVING_STAY;
		shouldMoveScreen = NO;
		//return YES;	//这里不要return了？！
	}
	
	//unfold
	if (!justFolded) {
		if ([touches count] == 1 /*&& !self.shouldMoveScreen*/ && self.totalFoldCount > 0)
		{
			UITouch* touch = [touches anyObject];
			CGPoint location = [touch locationInView:[touch view]];
			CGPoint point = [[CCDirector sharedDirector] convertToGL:location];
			
			int x = [self GetXFromPoint:&point];
			int y = [self GetYFromPoint:&point];
			
			for (int i=x-1; i<=x+1; i++) {
				for (int j=y-1; j<=y+1; j++) {
					MapNode* node = nodesOnScreen[i+showFromX][j+showFromY];
					if ([node.otherFoldNodes count] != 0) {
						CGPoint point = ccp(i*32+16,j*32+16);
						
						foldPoint1 = nullPoint;
						foldPoint2 = nullPoint;
						
						[self UnfoldFromPoint:&point]; 
						return YES;
					}
				}
			}
			return YES;
		}
	}

	

	//clean the varibles since they should be refreshed when next touch began
	shouldMoveScreen = NO;
	foldPoint1 = nullPoint;
	foldPoint2 = nullPoint;
	lastFoldPointsDistance = 9999999;
//	NSLog(@"foldPoints have been set to nullPoint");
	
	return NO;
}

-(void) ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	;
}



-(void) Test
{
	//打印所有的nodes
	//	NSLog(@"node info:");
	//	for (int i=0; i<width; i++) {
	//		NSMutableArray* line = [nodeInfo objectAtIndex:i];
	//		for (int j=0; j<height; j++) {
	//			MapNode* node = [line objectAtIndex:j];
	//			printf("(%d,%d)_%d\t",i,j,node.nodeType);
	//		}
	//		printf("\n");
	//	}
	
	//打印存在当前地图缓存里的nodes
//	NSLog(@"current screen's nodes");
//	for (int i=0,x=showFromX; i<SCREEN_WIDTH; i++,x++) {
//		for (int j=0,y=showFromY; j<SCREEN_HEIGHT; j++,y++) {
//			MapNode* node = nodesOnScreen[x][y];
//			printf("(%d,%d)-(%d,%d)\t",i,j,node.initialX,node.initialY);
//		}
//		printf("\n");
//	}
//	
//	for (int i=0,y=showFromY; i<SCREEN_HEIGHT; i++,y++) {
//		MapNode* node = nodesOnScreen[8][y];
////		CGPoint back = node.backSprite.position;
////		CGPoint fore = node.foreSprite.position;
//		NSLog(@"node[8][%d] at %d-%d, back %d, fore %d",y,node.initialX,node.initialY, node.nodeBackType, node.nodeForeType);
//	}
	
	//测试一个爆炸的小动画效果
	//	for (int i=0; i<10; i++) {
	//		CCSprite* bombSprite = [CCSprite spriteWithTexture:bombSheet.texture
	//													  rect:CGRectMake(0, 0, 32, 32)];
	//		[bombSheet addChild:bombSprite z:1];		
	//		CCAnimation *bombAnimation = [CCAnimation animationWithName:@"bomb" delay:0.1f];
	//		for (int k=0; k<BOMB_ANIMATION_PICTURES; k++) {
	//			CCSpriteFrame* frame = [CCSpriteFrame frameWithTexture:bombSheet.texture
	//															  rect:CGRectMake(k*32, 0, 32, 32)
	//															offset:ccp(32*i+16,32*i+16)];
	//			[bombAnimation addFrame:frame];
	//		}
	//		
	//		CCAnimate* bombAction = [CCAnimate actionWithAnimation:bombAnimation];
	//		[bombSprite runAction:bombAction];		
	//	}
	//	//[bombSheet removeChild:bombSprite cleanup:NO];
}



-(void) TestRefCount
{
	NSLog(@"nodes'");
	for (int i=0; i<width; i++) {
		NSMutableArray* line = [nodeInfo objectAtIndex:i];
		for (int j=0; j<height; j++) {
			MapNode* node = [line objectAtIndex:j];
			printf("(%d,%d)-%d    ",i,j,node.retainCount);
		}
		printf("\n");
	}
	
	NSLog(@"sprites'");
	for (int i=0; i<width; i++) {
		NSMutableArray* line = [nodeInfo objectAtIndex:i];
		for (int j=0; j<height; j++) {
			MapNode* node = [line objectAtIndex:j];
			printf("(%d,%d)-%d-%d    ",i,j,node.backSprite.retainCount,node.foreSprite.retainCount);
		}
		printf("\n");
	}
}



-(void) TestFoldCount
{
	NSLog(@"fold count:");
	for (int i=0; i<SCREEN_WIDTH+2*ADDED_WIDTH; i++) {
		for (int j=0; j<SCREEN_HEIGHT+2*ADDED_HEIGHT; j++) {
			MapNode* node = nodesOnScreen[i][j];
			printf("(%d,%d)%d ",node.initialX,node.initialY,node.foldCount);
		}
		printf("\n");
	}
	
	NSLog(@"total");
	for (int i=0; i<width; i++) {
		NSMutableArray* line = [nodeInfo objectAtIndex:i];
		for (int j=0; j<height; j++) {
			MapNode* node = [line objectAtIndex:j];
			printf("(%d,%d)%d",node.initialX,node.initialY,node.foldCount);
		}
		printf("\n");
	}
}

@end
