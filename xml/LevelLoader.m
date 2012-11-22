//
//  LevelLoader.m
//  ANYTHING
//
//  Created by eyexing on 11-2-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LevelLoader.h"
#import "BTToolUnit.h"


@implementation LevelLoader

@synthesize levelTools;
@synthesize bgSize;
@synthesize playerPosition;


#pragma mark - 类方法


+ (NSMutableArray *)getAllToolsForLevel:(NSInteger)levelIndex {
	// 在这里加入获取所有道具的代码。
	NSBundle*	bundle = [NSBundle mainBundle];
	NSError *error = nil;
	
	NSString *level = [[NSString alloc] initWithFormat:@"level%d",levelIndex];
	
	[self parseXMLFileAtURL:[NSURL fileURLWithPath: [bundle pathForResource:level ofType:@"xml"]] parseError:error];
	
	//return self.levelTools;
	return nil;
}


+ (NSInteger)getBGMaxNumberForLevel:(NSInteger)levelIndex {
	// 在这里加入获取背景最大图片切片数的代码。
	NSBundle*	bundle = [NSBundle mainBundle];
	NSError *error = nil;
	
	NSString *level = [[NSString alloc] initWithFormat:@"level%d",levelIndex];
	
	[self parseXMLFileAtURL:[NSURL fileURLWithPath: [bundle pathForResource:level ofType:@"xml"]] parseError:error];
	
	//return self.bgSize;
	return 0;
}



#pragma mark - 原生


- (void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error {	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
	[parser setDelegate:self];
	
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	
	[parser parse];
	
	NSError *parseError = [parser parserError];
	if (parseError && error) {
		*error = parseError;
	}
	[parser release];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if (qName) {
		elementName = qName;
	}
	
	if ([elementName isEqualToString:@"background"]) {
		self.bgSize = [[attributeDict valueForKey:@"size"] intValue];
	}
	/*
	else if([elementName isEqualToString:@"player"]){
  //		[self.playerPosition.x [[attributeDict valueForKey:@"x"] floatValue] ]
		//self.playerPosition.y = [[attributeDict valueForKey:@"y"] floatValue];
		float xx = [[attributeDict valueForKey:@"x"] floatValue];
		float yy = [[attributeDict valueForKey:@"y"] floatValue];
		xx = 1;
		yy = 1;
	
	}
	 */
	else if([elementName isEqualToString:@"tool"]){
		BTToolUnit *newTool = [[BTToolUnit alloc] init];
		newTool.toolType = [[attributeDict valueForKey:@"type"] intValue];
		newTool.x = [[attributeDict valueForKey:@"x"] floatValue];
		newTool.y = [[attributeDict valueForKey:@"y"] floatValue];
		newTool.widthInControl = [[attributeDict valueForKey:@"widthInControl"] floatValue];
		newTool.heightInControl =[[attributeDict valueForKey:@"heightInControl"] floatValue];
		[levelTools addObject:newTool];
		[newTool release];
	}
	
}


//error
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
	NSLog(@"Error on XML Parse: %@", [parseError localizedDescription] );
}


-(void)dealloc
{

	[super dealloc];
}


@end
