//
//  LevelLoader.h
//  ANYTHING
//
//  Created by eyexing on 11-2-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTToolUnit;

@interface LevelLoader : NSObject<NSXMLParserDelegate> {

}

@property (nonatomic, assign) NSMutableArray *levelTools;
@property (nonatomic, assign) NSInteger bgSize;
@property (nonatomic, assign) CGPoint playerPosition;

-(void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error;

+ (NSMutableArray *)getAllToolsForLevel:(NSInteger)levelIndex;
+ (NSInteger)getBGMaxNumberForLevel:(NSInteger)levelIndex;

@end
