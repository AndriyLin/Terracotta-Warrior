//
//  ZYG006AppDelegate.h
//
//  Copyright 2011 qrc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyMPViewController.h"


@interface TerracottaWarriorAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	MyMPViewController *mpViewController;
}
+ (void) ContinueLaun;

@property (nonatomic, retain) UIWindow *window;

@end
