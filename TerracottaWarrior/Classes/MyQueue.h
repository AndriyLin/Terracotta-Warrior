//
//  MyQueue.h
//  TerracottaWarrior
//
//  Created by student on 11-3-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>


@interface MyQueue : NSObject {
	NSMutableArray* data;
}

-(void) AppendObject:(id)object;

-(id) ServeObject;

-(int) count;


@end






@interface FillNodes : NSObject{

}

@property (nonatomic, readwrite) int i;
@property (nonatomic, readwrite) int j;
@property (nonatomic, readwrite) int initialX;
@property (nonatomic, readwrite) int initialY;

@end