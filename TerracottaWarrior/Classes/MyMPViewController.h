//
//  MyMPViewController.h
//
//  Copyright 2011 qrc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPMoviePlayerController.h>

@interface MyMPViewController : UIViewController {
	bool ifok;
}

@property (nonatomic,readwrite,assign) bool ifok;

- (void)myMovieFinishedCallback:(NSNotification*)aNotification;

@end
