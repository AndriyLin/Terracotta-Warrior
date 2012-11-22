//
//  MyQueue.m
//  TerracottaWarrior
//
//  Created by student on 11-3-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyQueue.h"


@implementation MyQueue

-(id) init
{
	if ((self = [super init])) {
		data = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) dealloc
{
	[data removeAllObjects];
	[data release];
	
	[super dealloc];
}

-(int) count
{
	return [data count];
}

-(void) AppendObject:(id)object
{
	[data addObject:object];
}

-(id) ServeObject
{
	if ([data count] >= 0) {
		id object = [data objectAtIndex:0];
		[data removeObjectAtIndex:0];
		return object;
	}
	return nil;
}

@end







@implementation FillNodes

@synthesize i;
@synthesize j;
@synthesize initialX;
@synthesize initialY;

-(id) init
{
	if ((self = [super init])) {
		;
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

@end