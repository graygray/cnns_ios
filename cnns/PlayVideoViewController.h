//
//  PlayVideoViewController.h
//  cnns
//
//  Created by GRAY_LIN on 2013/11/5.
//  Copyright (c) 2013年 graylin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "CNNSTableViewController.h"
#import "NoteViewController.h"
#import "GADInterstitial.h"
#import "GADInterstitialDelegate.h"

MPMoviePlayerController *mp;
BOOL isVideoPlaying;

@interface PlayVideoViewController : UIViewController <NSURLConnectionDataDelegate, GADInterstitialDelegate> {
    
//    MPMoviePlayerController *mp;
    UITextView *cnnScriptTextView;
    UIWebView *cnnScriptWebView;
    
    NSString *cnnVideoPath;
    NSString *cnnVideoName;
    NSString *cnnScriptName;
    NSString *cnnScriptPath;
    NSString *cnnScriptContentS;
    
    bool isPortrait;
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat mediaWidth;
    CGFloat mediaHeight;
    int scrollPosition;
    
    bool isPlayLocal;
    
    // for download
    UIProgressView *downloadProgress;
    NSMutableData *videoData;
    NSUInteger totalBytes;
    NSUInteger receivedBytes;
    NSFileHandle *handleFile;
    NSUInteger toastInteval;
    
    // for video operation
    NSTimeInterval totalVideoLength;
    NSTimeInterval currentVideoPosition;
    NSTimeInterval swipeTime;
    CGFloat previousX;
    CGFloat previousY;
    CGFloat currentX;
    CGFloat currentY;
    BOOL clickZoneRight;
    BOOL clickZoneCenter;
    BOOL clickZoneLeft;
    int videoThresholdX;
    BOOL isVideoTouchMove;
    
    GADInterstitial *interstitial_;
}

+ (MPMoviePlayerController*) getShareInstance;

@end
