//
//  MyMPViewController.m
//
//  Copyright 2011 qrc. All rights reserved.
//

#import "MyMPViewController.h"
#import "StartScene.h"
#import "TerracottaWarriorAppDelegate.h"


@implementation MyMPViewController
@synthesize ifok;
//-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//	return YES;
//}
- (id)init
{
	if ((self = [super init])) {
		ifok = NO;
		MPMoviePlayerController *moviePlayer;
		moviePlayer = [[MPMoviePlayerController alloc]
					   initWithContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Movie" ofType:@"mp4"]]];
		//初始化视频播放器对象，并传入被播放文件的地址
		//moviePlayer.movieControlMode = MPMovieControlModeDefault;
		moviePlayer.scalingMode = MPMovieScalingModeNone;
		
		
		[[moviePlayer view] setFrame:[self.view bounds]];
		CGAffineTransform transform=CGAffineTransformMakeRotation(M_PI/2);
		[moviePlayer.view setTransform:transform];
		[self.view addSubview:[moviePlayer view]];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(myMovieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:moviePlayer];
		//[self.view addSubview:moviePlayer.view];
		[moviePlayer play];
	}
	return self;
}

- (void)myMovieFinishedCallback:(NSNotification*)aNotification
{
    MPMoviePlayerController* moviePlayer=[aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayer];
	ifok = YES;
    // Release the movie instance created in playMovieAtURL
	//[[[UIApplication sharedApplication] keyWindow] sendSubviewToBack:moviePlayer.view];
	//NSLog(@"MMPVC finish.");
    [moviePlayer release];
	[TerracottaWarriorAppDelegate ContinueLaun];
} 

- (void)dealloc
{
	[super dealloc];
}

@end
