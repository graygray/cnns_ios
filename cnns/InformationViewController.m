//
//  InformationViewController.m
//  cnns
//
//  Created by GRAY_LIN on 2013/12/29.
//  Copyright (c) 2013年 graylin. All rights reserved.
//

#import "InformationViewController.h"

@interface InformationViewController ()

@end

@implementation InformationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // set title
    [self.navigationItem setTitle:@"Information"];
    [CNNSTableViewController setCurrentView:3];
    
    // check orientation
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        isPortrait = true;
    } else {
        isPortrait = false;
    }
    
    [self showInformationContent];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
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
                [self showInformationContent];
            }
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationPortraitUpsideDown", __FUNCTION__, __LINE__);
            }
            if (!isPortrait) {
                isPortrait = true;
                [self showInformationContent];
            }
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationLandscapeLeft", __FUNCTION__, __LINE__);
            }
            if (isPortrait) {
                isPortrait = false;
                [self showInformationContent];
            }
            break;
            
        case UIDeviceOrientationLandscapeRight:
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationLandscapeRight", __FUNCTION__, __LINE__);
            }
            if (isPortrait) {
                isPortrait = false;
                [self showInformationContent];
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

- (void) showInformationContent {
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    
    screenWidth = self.view.frame.size.width;
    screenHeight = self.view.frame.size.height;
    
    cnnsInformationWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [cnnsInformationWebView setFrame:CGRectMake(0.0, 0.0+64.0, screenWidth, screenHeight-[CNNSTableViewController getADHeight])];
//    if ([CNNSTableViewController isDeviceiPhone]) {
//        [cnnsInformationWebView setFrame:CGRectMake(0.0, 0.0+64.0, screenWidth, screenHeight-[CNNSTableViewController getADHeight])];
//    } else {
//        [cnnsInformationWebView setFrame:CGRectMake(0.0, 0.0+64.0, screenWidth, screenHeight-[CNNSTableViewController getADHeight])];
//    }
    
//    cnnsInformationWebView.editable = NO;
    
    // set script theme
    switch ([CNNSTableViewController getScriptTheme]) {
        case 0:     // Black  -  White
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            break;
            
        case 1:     // White  -  Black
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            break;
            
        case 2:     // Red - White
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:0.80 green:0.00 blue:0.00 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            break;
            
        case 3:     // White  -  Red
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:0.80 green:0.00 blue:0.00 alpha:1.0]];
            break;
            
        case 4:     // Orange  -  Black
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:1.00 green:0.60 blue:0.00 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            break;
            
        case 5:     // White  -  Orange
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:0.60 blue:0.00 alpha:1.0]];
            break;
            
        case 6:     // Black  -  Orange
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:0.60 blue:0.00 alpha:1.0]];
            break;
            
        case 7:     // Black  -  Yellow
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:0.85 blue:0.40 alpha:1.0]];
            break;
            
        case 8:     // Green - White
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:0.30 green:0.65 blue:0.15 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            break;
            
        case 9:     // Green - Black
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:0.30 green:0.65 blue:0.15 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            break;
            
        case 10:    // White - Green
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:0.30 green:0.65 blue:0.15 alpha:1.0]];
            break;
            
        case 11:    // Black - Green
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:0.30 green:0.65 blue:0.15 alpha:1.0]];
            break;
            
        case 12:    // LightBlue  -  White
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:0.44 green:0.66 blue:0.86 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            break;
            
        case 13:    // White - LightBlue
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:0.44 green:0.66 blue:0.86 alpha:1.0]];
            break;
            
        case 14:    // Black - LightBlue
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:0.44 green:0.66 blue:0.86 alpha:1.0]];
            break;
            
        case 15:    // White  -  Blue
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:0.00 green:0.00 blue:1.00 alpha:1.0]];
            break;
            
        case 16:    // Pink  -  White
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:0.91 green:0.43 blue:0.91 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            break;
            
        case 17:    // LightPurple - White
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:0.75 green:0.55 blue:0.89 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            break;
            
        case 18:    // White - LightPurple
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:0.75 green:0.55 blue:0.89 alpha:1.0]];
            break;
            
        case 19:    // White  -  Purple
//            [cnnsInformationWebView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:0.66 green:0.22 blue:0.95 alpha:1.0]];
            break;
            
        default:
            break;
    }
    
    // BackgroundColor always white
    [cnnsInformationWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
    
//    [cnnsInformationWebView setFont:[UIFont systemFontOfSize:[CNNSTableViewController getScriptTextSize]]];
    
    NSString* informationContent =
@"\
<center><b>Version Information (1.5) / What's new?</b></center>\
<br><br>\
Fix some error in iOS 8.<br>\
<br>\
<center><b>Usage & Features:</b></center>\
<br><br>\
<b>1. Quick translate : </b><br>\
Long press to select a word, then click \"Translate\" item.<br>\
Need network support.<br><br>\
<b>2. Quick Note :</b><br>\
After you look up a word and translate it which will be automatically saved to a file ( in your app's documents folder ); \
then you can check what you note at \"Quick Note\" page.<br><br>\
<b>3. Video operation :</b><br>\
a. Click video to pause/resume.<br>\
b. Rewind by click left area (1/6 zone) of video.<br>\
c. Fast forward by click right area(5/6 zone) of video.<br><br>\
<b>4. Script & video download :</b><br>\
The script will be downloaded automatically; \
but the video download need to be enabled first at \"setting\".<br>\
If the downloaded file exist in your app's documents folder, the icon will be different obviously.<br>\
You can perform offline jobs (without network) after downloading video & script files.<br><br>\
<b>5. Playing video at background :</b><br>\
<i><b><font color='red'>not available now!!</font></b></i><br>\
a. enabled when video ever played.<br>\
b. key play/pause to start/stop.<br>\
c. key previous/rewind to rewind.<br>\
d. key next/fast forward to stop.<br>\
<br>\
<b>6. Auto delete related file :</b><br>\
Auto delete if modified timestamp of compared file > your setting value; to enable this feature at \"settings\" page, \
default is disable.<br><br>\
<center><b>Q & A</b></center>\
<br><br>\
<b>1. No update for a long time?</b><br>\
It's depend on CNN Student News..<br>\
The show is suspended when student is on vacation.<br><br>\
Take a look at <a href='http://edition.cnn.com/studentnews/' target='_blank'>CNN Student News</a><br>\
and it's archive <a href='http://edition.cnn.com/US/studentnews/quick.guide/archive/'>here</a><br><br>\
<b>2. When will the list update?</b><br>\
We get video from <a href='http://rss.cnn.com/services/podcasting/studentnews/rss.xml'>here</a><br>\
When app start at first time, will auto update from CNNS website; but after that, you need to manual update by ckick \"refresh\" button.<br>\
<br>\
<b>3. Newest video or script not work?</b><br>\
Because the video or script of newest day may still not upload, you can take alook at website; If you see them at website but not work on your device, you can wait for a while & retry later, check your friends' device or report it to me.<br><br>\
<b>4. How translation work?</b><br>\
I just send a translated query to some website, and get the translate result to show, but I don't know if it's appropriate for your language ( or none for your language )<br>\
If you have better suggestion, just feel free to mail me.<br><br>\
<b>5. Any suggestion or bug:</b><br>\
mail to : <a href='mailto:llkkqq@gmail.com'>llkkqq@gmail.com (Gray Lin)</a><br><br>\
*********************<br>\
If you like this app or think it's useful, please help to rank it at Apple store, thanks~^^<br>\
*********************<br><br><br><br>\
</font>";
    
    NSString *jsString = [NSString stringWithFormat:@"<html> \n"
                          "<head> \n"
                          "<style type=\"text/css\"> \n"
                          "body {font-size: %f; color: %@;}\n"
                          "</style> \n"
                          "</head> \n"
                          "<body>%@</body> \n"
                          "</html>", 18.0, @"black", informationContent];
    
    [cnnsInformationWebView loadHTMLString:jsString baseURL:nil];
//    [UITextView setContentToHTMLString:];
    
    [self.view addSubview:cnnsInformationWebView];
    
    // add AD
    if ([CNNSTableViewController isDeviceiPhone]) {
        if (isDebug) {
            NSLog(@"%s-%d, iPhone", __FUNCTION__, __LINE__);
        }
        if (isPortrait) {
            admobView = [[GADBannerView alloc]
                         initWithFrame:CGRectMake(0.0,
                                                  screenHeight -
                                                  kGADAdSizeBanner.size.height,
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
        NSLog(@"%s-%d, self.view.frame.size.width:%f", __FUNCTION__, __LINE__, self.view.frame.size.width);
        NSLog(@"%s-%d, self.view.frame.size.height:%f", __FUNCTION__, __LINE__, self.view.frame.size.height);
        NSLog(@"%s-%d, screenWidth:%f", __FUNCTION__, __LINE__, screenWidth);
        NSLog(@"%s-%d, screenHeight:%f", __FUNCTION__, __LINE__, screenHeight);
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
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
