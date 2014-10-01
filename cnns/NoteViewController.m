//
//  NoteViewController.m
//  cnns
//
//  Created by GRAY_LIN on 2013/12/14.
//  Copyright (c) 2013年 graylin. All rights reserved.
//

#import "NoteViewController.h"

@interface NoteViewController ()

@end

@implementation NoteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// remove HTML tags
-(NSString *) stringByStrippingHTML : (NSString*) rawString{
    NSRange r;
    while ((r = [rawString rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        rawString = [rawString stringByReplacingCharactersInRange:r withString:@""];
    return rawString;
}

- (void)shareNote:(id)sender
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    
    NSString* sharedSubject = [NSString stringWithFormat:@"%@ - %@", @"My 10min News Notes", [CNNSTableViewController getVideoDate]];
    
    NSString* sharedContent = [cnnsNoteContent stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    sharedContent = [self stringByStrippingHTML:sharedContent];
    NSArray* dataToShare = @[sharedContent];
    
    NSLog(@"%s-%d, ccccc", __FUNCTION__, __LINE__);
    
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
    activityViewController.popoverPresentationController.sourceView = self.view;
    [activityViewController setValue:sharedSubject forKey:@"subject"];
    
    [self presentViewController:activityViewController animated:YES completion:^{}];
}

- (void)viewDidLoad
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    [super viewDidLoad];
	
    // set title
    [self.navigationItem setTitle:@"Quick Note"];
    [CNNSTableViewController setCurrentView:2];
    
    UIBarButtonItem *shareNoteButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareNote:)];
    NSArray *buttonArray = [[NSArray alloc] initWithObjects:shareNoteButton, nil];
    self.navigationItem.rightBarButtonItems = buttonArray;
    
    // check orientation
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        isPortrait = true;
    } else {
        isPortrait = false;
    }
    
    // show note content
    NSString* cnnVideoName = [CNNSTableViewController getVideoFileName];
    NSString* noteFile =  [cnnVideoName stringByAppendingString:@".cnnsNote.txt"];
    cnnsNoteContent = @"";
    if ([self isFileExit:noteFile]) {
        // note file exit
        if (isDebug) {
            NSLog(@"%s-%d, note file exit", __FUNCTION__, __LINE__);
        }
        NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        filePath = [filePath stringByAppendingString:@"/"];
        filePath = [filePath stringByAppendingString:noteFile];
        
        if (filePath) {
            NSError *error;
            cnnsNoteContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error: &error];
        }
        
        [self showNoteContent];
        
    } else {
        // note file not exit
        if (isDebug) {
            NSLog(@"%s-%d, note file not exit", __FUNCTION__, __LINE__);
        }
        [CNNSTableViewController showAlertDialog:@"Information" warnMessage:@"You probably don't note anything yet."];
        // show the AD
        [self showNoteContent];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
    
    // register rotate event
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
}

- (void)applicationDidEnterBackground {
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
}

- (void)applicationWillEnterForeground {
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    [self showNoteContent];
}

- (void)orientationChanged:(NSNotification *) note {
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationPortrait", __FUNCTION__, __LINE__);
            }
            if (!isPortrait) {
                isPortrait = true;
                [self showNoteContent];
            }
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationPortraitUpsideDown", __FUNCTION__, __LINE__);
            }
            if (!isPortrait) {
                isPortrait = true;
                [self showNoteContent];
            }
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationLandscapeLeft", __FUNCTION__, __LINE__);
            }
            if (isPortrait) {
                isPortrait = false;
                [self showNoteContent];
            }
            break;
            
        case UIDeviceOrientationLandscapeRight:
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationLandscapeRight", __FUNCTION__, __LINE__);
            }
            if (isPortrait) {
                isPortrait = false;
                [self showNoteContent];
            }
            break;
            
        case UIDeviceOrientationFaceDown:
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationFaceDown", __FUNCTION__, __LINE__);
            }
            break;
            
        case UIDeviceOrientationFaceUp:
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationFaceUp", __FUNCTION__, __LINE__);
            }
            break;
            
        case UIDeviceOrientationUnknown:
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationUnknown", __FUNCTION__, __LINE__);
            }
            break;
            
        default:
            break;
    }
}

-(BOOL) isFileExit:(NSString*) s {
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileString = [documentsPath stringByAppendingPathComponent:s];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileString];
    
    return fileExists;
}

- (void) showNoteContent {
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    if (isPortrait) {
//        screenWidth = screenRect.size.width;
//        screenHeight = screenRect.size.height;
//    } else {
//        screenWidth = screenRect.size.height;
//        screenHeight = screenRect.size.width;
//    }
    
    screenWidth = self.view.frame.size.width;
    screenHeight = self.view.frame.size.height;
    
    // use UITextView
//    cnnsNoteTextView = [[UITextView alloc] initWithFrame:CGRectZero];
//    if ([CNNSTableViewController isDeviceiPhone]) {
//        [cnnsNoteTextView setFrame:CGRectMake(0.0, 0.0, screenWidth, screenHeight-[CNNSTableViewController getADHeight])];
//    } else {
//        [cnnsNoteTextView setFrame:CGRectMake(0.0, 0.0+64, screenWidth, screenHeight-[CNNSTableViewController getADHeight]-64)];
//    }
//    cnnsNoteTextView.editable = NO;

    // use UIWebView
    cnnsNoteWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    if ([CNNSTableViewController isDeviceiPhone]) {
        [cnnsNoteWebView setFrame:CGRectMake(0.0, 0.0+64.0, screenWidth, screenHeight-[CNNSTableViewController getADHeight])];
    } else {
        [cnnsNoteWebView setFrame:CGRectMake(0.0, 0.0+64.0, screenWidth, screenHeight-[CNNSTableViewController getADHeight]-64)];
    }
    
    // set note theme
    NSString *fontColor = @"";
    NSString *bgColor = @"";
    switch ([CNNSTableViewController getScriptTheme]) {
        case 0:     // Black  -  White
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            fontColor = @"#000000";
            bgColor = @"#FFFFFF";
            break;
            
        case 1:     // White  -  Black
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            fontColor = @"#FFFFFF";
            bgColor = @"#000000";
            break;
            
        case 2:     // Red - White
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:0.80 green:0.00 blue:0.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            fontColor = @"#CC0000";
            bgColor = @"#FFFFFF";
            break;
            
        case 3:     // White  -  Red
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:0.80 green:0.00 blue:0.00 alpha:1.0]];
            fontColor = @"#FFFFFF";
            bgColor = @"#CC0000";
            break;
            
        case 4:     // Orange  -  Black
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:1.00 green:0.60 blue:0.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            fontColor = @"#ff9900";
            bgColor = @"#000000";
            
            break;
            
        case 5:     // White  -  Orange
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:0.60 blue:0.00 alpha:1.0]];
            fontColor = @"#FFFFFF";
            bgColor = @"#ff9900";
            break;
            
        case 6:     // Black  -  Orange
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:0.98 green:0.63 blue:0.10 alpha:1.0]];
            fontColor = @"#000000";
            bgColor = @"#fba119";
            break;
            
        case 7:     // Black  -  Yellow
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:0.85 blue:0.28 alpha:1.0]];
            fontColor = @"#000000";
            bgColor = @"#FFDA47";
            break;
            
        case 8:     // Green - White
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:0.31 green:0.82 blue:0.18 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            fontColor = @"#50d22e";
            bgColor = @"#FFFFFF";
            break;
            
        case 9:     // Green - Black
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:0.31 green:0.82 blue:0.18 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            fontColor = @"#50d22e";
            bgColor = @"#000000";
            break;
            
        case 10:    // White - Green
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:0.31 green:0.82 blue:0.18 alpha:1.0]];
            fontColor = @"#FFFFFF";
            bgColor = @"#50d22e";
            break;
            
        case 11:    // Black - Green
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:0.31 green:0.82 blue:0.18 alpha:1.0]];
            fontColor = @"#000000";
            bgColor = @"#50d22e";
            break;
            
        case 12:    // LightBlue  -  White
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            fontColor = @"#3399FF";
            bgColor = @"#FFFFFF";
            break;
            
        case 13:    // White - LightBlue
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:1.0]];
            fontColor = @"#FFFFFF";
            bgColor = @"#3399FF";
            break;
            
        case 14:    // Black - LightBlue
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:1.0]];
            fontColor = @"#000000";
            bgColor = @"#3399FF";
            break;
            
        case 15:    // White  -  Blue
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:0.19 green:0.35 blue:0.83 alpha:1.0]];
            fontColor = @"#FFFFFF";
            bgColor = @"#3059D6";
            break;
            
        case 16:    // Pink  -  White
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:0.91 green:0.43 blue:0.91 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            fontColor = @"#FF66FF";
            bgColor = @"#FFFFFF";
            break;
            
        case 17:    // LightPurple - White
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:0.80 green:0.20 blue:1.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            fontColor = @"#CC33FF";
            bgColor = @"#FFFFFF";
            break;
            
        case 18:    // White - LightPurple
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:0.80 green:0.20 blue:1.00 alpha:1.0]];
            fontColor = @"#FFFFFF";
            bgColor = @"#CC33FF";
            break;
            
        case 19:    // White  -  Purple
//            [cnnsNoteWebView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnsNoteWebView setBackgroundColor:[UIColor colorWithRed:0.61 green:0.00 blue:0.81 alpha:1.0]];
            fontColor = @"#FFFFFF";
            bgColor = @"#9900CC";
            break;
            
        default:
            break;
    }
    
//    [cnnsNoteTextView setFont:[UIFont systemFontOfSize:[CNNSTableViewController getScriptTextSize]]];
//    [cnnsNoteTextView setText:cnnsNoteContent];
    
    NSString *jsString = [NSString stringWithFormat:@"<html> \n"
                          "<head> \n"
                          "<style type=\"text/css\"> \n"
                          "body {font-size: %f; color: %@; background-color: %@;}\n"
                          "</style> \n"
                          "</head> \n"
                          "<body>%@</body> \n"
                          "</html>", (float)[CNNSTableViewController getScriptTextSize], fontColor, bgColor, cnnsNoteContent];
    
    [cnnsNoteWebView loadHTMLString:jsString baseURL:nil];
//    [UITextView setContentToHTMLString:];
    
    [self.view addSubview:cnnsNoteWebView];

//    [self.view addSubview:cnnsNoteTextView];
    
    // add AD
    if ([CNNSTableViewController isDeviceiPhone]) {
        if (isDebug) {
            NSLog(@"%s-%d, iPhone", __FUNCTION__, __LINE__);
        }
        
        if (isPortrait) {
            admobView = [[GADBannerView alloc]
                         initWithFrame:CGRectMake(0.0,
                                                  screenHeight -
                                                  kGADAdSizeBanner.size.height ,
                                                  kGADAdSizeBanner.size.width,
                                                  kGADAdSizeBanner.size.height)];
        } else {
            admobView = [[GADBannerView alloc]
                         initWithFrame:CGRectMake(0.0,
                                                  screenHeight -
                                                  kGADAdSizeBanner.size.height,
                                                  kGADAdSizeBanner.size.width,
                                                  kGADAdSizeBanner.size.height)];
        }
    } else {
        if (isDebug) {
            NSLog(@"%s-%d, iPad", __FUNCTION__, __LINE__);
        }
        if (isPortrait) {
            admobView = [[GADBannerView alloc]
                         initWithFrame:CGRectMake(0.0,
                                                  screenHeight -
                                                  kGADAdSizeLeaderboard.size.height,
                                                  kGADAdSizeLeaderboard.size.width,
                                                  kGADAdSizeLeaderboard.size.height)];
        } else {
            admobView = [[GADBannerView alloc]
                         initWithFrame:CGRectMake(0.0,
                                                  screenHeight -
                                                  kGADAdSizeLeaderboard.size.height,
                                                  kGADAdSizeLeaderboard.size.width,
                                                  kGADAdSizeLeaderboard.size.height)];
        }
    }
    
    if (isDebug) {
        NSLog(@"%s-%d, kGADAdSizeBanner.size.width:%f", __FUNCTION__, __LINE__, kGADAdSizeBanner.size.width);
        NSLog(@"%s-%d, kGADAdSizeBanner.size.height:%f", __FUNCTION__, __LINE__, kGADAdSizeBanner.size.height);
        NSLog(@"%s-%d, self.view.frame.size.height:%f", __FUNCTION__, __LINE__, self.view.frame.size.height);
        NSLog(@"%s-%d, self.view.frame.size.width:%f", __FUNCTION__, __LINE__, self.view.frame.size.width);
    }
    
    // Specify the ad unit ID.
    admobView.adUnitID = @"ca-app-pub-5561117272957358/2609425204";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    admobView.rootViewController = self;
    [self.view addSubview:admobView];
    
    // Initiate a generic request to load it with an AD
    [admobView loadRequest:[GADRequest request]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
