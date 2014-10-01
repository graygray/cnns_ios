//
//  AppDelegate.m
//  cnns
//
//  Created by GRAY_LIN on 2013/10/29.
//  Copyright (c) 2013年 graylin. All rights reserved.
//

#import "AppDelegate.h"
#import "CNNSTableViewController.h"
#import "PlayVideoViewController.h"

@implementation AppDelegate {

}

@synthesize window = window_;


-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            if (isDebug) {
                NSLog(@"%s-%d, UIEventSubtypeRemoteControlPlay", __FUNCTION__, __LINE__);
            }
            [mp play];
            isVideoPlaying = true;

        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            if (isDebug) {
                NSLog(@"%s-%d, UIEventSubtypeRemoteControlPause", __FUNCTION__, __LINE__);
            }
            [mp pause];
            isVideoPlaying = false;

        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            if (isDebug) {
                NSLog(@"%s-%d, UIEventSubtypeRemoteControlTogglePlayPause", __FUNCTION__, __LINE__);
            }
            if ([mp playbackState] == MPMoviePlaybackStatePlaying) {
                [mp pause];
                isVideoPlaying = false;
            } else if([mp playbackState] == MPMoviePlaybackStatePaused) {
                [mp play];
                isVideoPlaying = true;
            }
        } else if (event.subtype == UIEventSubtypeNone) {
            if (isDebug) {
                NSLog(@"%s-%d, UIEventSubtypeNone", __FUNCTION__, __LINE__);
            }

        } else if (event.subtype == UIEventSubtypeMotionShake) {
            if (isDebug) {
                NSLog(@"%s-%d, UIEventSubtypeMotionShake", __FUNCTION__, __LINE__);
            }
        } else if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
            if (isDebug) {
                NSLog(@"%s-%d, UIEventSubtypeRemoteControlNextTrack", __FUNCTION__, __LINE__);
            }
            [mp setCurrentPlaybackTime:[mp currentPlaybackTime] + [CNNSTableViewController getSwipeTime]];
            [mp play];
            isVideoPlaying = true;
        } else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
            if (isDebug) {
                NSLog(@"%s-%d, UIEventSubtypeRemoteControlPreviousTrack", __FUNCTION__, __LINE__);
            }
            [mp setCurrentPlaybackTime:[mp currentPlaybackTime] - [CNNSTableViewController getSwipeTime]];
            [mp play];
            isVideoPlaying = true;
        } else if (event.subtype == UIEventSubtypeRemoteControlBeginSeekingBackward) {
            if (isDebug) {
                NSLog(@"%s-%d, UIEventSubtypeRemoteControlBeginSeekingBackward", __FUNCTION__, __LINE__);
            }
        } else if (event.subtype == UIEventSubtypeRemoteControlEndSeekingBackward) {
            if (isDebug) {
                NSLog(@"%s-%d, UIEventSubtypeRemoteControlEndSeekingBackward", __FUNCTION__, __LINE__);
            }
        } else if (event.subtype == UIEventSubtypeRemoteControlBeginSeekingForward) {
            if (isDebug) {
                NSLog(@"%s-%d, UIEventSubtypeRemoteControlBeginSeekingForward", __FUNCTION__, __LINE__);
            }
        } else if (event.subtype == UIEventSubtypeRemoteControlEndSeekingForward) {
            if (isDebug) {
                NSLog(@"%s-%d, UIEventSubtypeRemoteControlEndSeekingForward", __FUNCTION__, __LINE__);
            }
        } else {
                NSLog(@"%s-%d, not a case", __FUNCTION__, __LINE__);
        }
    }

}

- (void) handleChangeInUserSettings{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    [CNNSTableViewController updateSettingValue];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    // Override point for customization after application launch.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChangeInUserSettings) name:NSUserDefaultsDidChangeNotification object:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
