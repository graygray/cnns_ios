//
//  PlayVideoViewController.m
//  cnns
//
//  Created by GRAY_LIN on 2013/11/5.
//  Copyright (c) 2013年 graylin. All rights reserved.
//

#import "PlayVideoViewController.h"
#import "TFHpple.h"
#import "Tutorial.h"
#import "Contributor.h"

static int reTranslateCount = 0;
static bool isRotate = false;

@interface PlayVideoViewController ()

@end

@implementation PlayVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL) isHttpFileExists : (NSString*) videoPath {
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:videoPath] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    [request setHTTPMethod:@"HEAD"];
    
    NSHTTPURLResponse* response = nil;
    NSError* error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    if (isDebug) {
        NSLog(@"%s-%d, videoPath:%@, [response statusCode]:%ld", __FUNCTION__, __LINE__, videoPath, (long)[response statusCode]);
    }
    
    if ([response statusCode] == 404) {
        return NO;
    } else if ([response statusCode] == 200) {
        return YES;
    } else {
        return NO;
    }
}

-(NSString *)getDownloadLink {
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    NSString *resultS = @"";
    
    NSURL *tutorialsUrl = [NSURL URLWithString:@"http://rss.cnn.com/services/podcasting/studentnews/rss.xml"];
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
    
    // Parser object
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    
    // stored array
    NSMutableArray *newTutorials = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Query XPath
    NSString *tutorialsXpathQueryString = @"//guid";
    NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    
    // process data if found any
    if (tutorialsNodes) {
        
        for (TFHppleElement *element in tutorialsNodes) {
            
            Tutorial *tutorial = [[Tutorial alloc] init];
            [newTutorials addObject:tutorial];
            
            resultS = [[element firstChild] content];
            
            if ([resultS rangeOfString:[CNNSTableViewController getVideoDate]].location == NSNotFound) {
                NSLog(@"string does not contain date:%@", [CNNSTableViewController getVideoDate]);
            } else {
                NSLog(@"string contain date:%@", [CNNSTableViewController getVideoDate]);
                return resultS;
            }
        }
    }
    return resultS;
}

- (void)viewDidLoad
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    [super viewDidLoad];
    
    // init variable
    cnnScriptContentS = @"";
    isRotate = false;
    isVideoPlaying = false;
    [CNNSTableViewController setCurrentView:1];
    
    cnnScriptPath = [CNNSTableViewController getScriptAddress];
    
    videoThresholdX = 10;
    swipeTime = [CNNSTableViewController getSwipeTime];
    
    // get video file name
    cnnVideoName = [CNNSTableViewController getVideoFileName];
    cnnScriptName = [cnnVideoName stringByAppendingString:@".txt"];
    
    if (isDebug) {
        NSLog(@"%s-%d, cnnVideoName:%@", __FUNCTION__, __LINE__, cnnVideoName);
        NSLog(@"%s-%d, cnnScriptName:%@", __FUNCTION__, __LINE__, cnnScriptName);
    }
    
    // set title
    [self.navigationItem setTitle:@"Video & Script"];
    
    // check orientation
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        isPortrait = true;
    } else {
        isPortrait = false;
    }

    UIBarButtonItem *gotoNoteButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(gotoNote:)];
//    self.navigationItem.rightBarButtonItem = gotoNoteButton;
//    navigationButton2.enabled=TRUE;
    
    // map marker button
    UIImage *mmImage = [UIImage imageNamed:@"Icon_mapMarker.png"];
    UIButton* mmButton = [UIButton buttonWithType:UIButtonTypeCustom];

    CGRect buttonFrame = mmButton.frame;
    buttonFrame.size = mmImage.size;
    mmButton.frame = buttonFrame;

    [mmButton setImage:mmImage forState:UIControlStateNormal];
    [mmButton addTarget:self action:@selector(gotoRoughPosition:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *mmBarButton = [[UIBarButtonItem alloc] initWithCustomView:mmButton];
    
    NSArray *buttonArray = [[NSArray alloc] initWithObjects:gotoNoteButton, mmBarButton, nil];
    self.navigationItem.rightBarButtonItems = buttonArray;

    // play video
    // check if video file already download
    if ([self isFileExit:cnnVideoName]) {
        // file exist, play video from local disk
        // reset video path to local path
        isPlayLocal = true;
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        cnnVideoPath = [documentsPath stringByAppendingPathComponent:cnnVideoName];
        if (isDebug) {
            NSLog(@"%s-%d, video file exist, play video from local disk, cnnVideoPath:%@", __FUNCTION__, __LINE__, cnnVideoPath);
        }
        [self playVideo];
        
    } else {
        isPlayLocal = false;
        // file not exist
        if (isDebug) {
            NSLog(@"%s-%d, video file not exist", __FUNCTION__, __LINE__);
        }
        
        if ([CNNSTableViewController isNetworkAvailable]) {
            
            // check video path
            if ([self isHttpFileExists:[CNNSTableViewController getVideoAddress]]) {
                cnnVideoPath = [CNNSTableViewController getVideoAddress];
            } else if ([self isHttpFileExists:[CNNSTableViewController getVideoAddress2]]) {
                cnnVideoPath = [CNNSTableViewController getVideoAddress2];
            } else if ([self isHttpFileExists:[CNNSTableViewController getVideoAddress3]]) {
                cnnVideoPath = [CNNSTableViewController getVideoAddress3];
            } else if ([self isHttpFileExists:[CNNSTableViewController getVideoAddress4]]) {
                cnnVideoPath = [CNNSTableViewController getVideoAddress4];
            } else {
                if (isDebug) {
                    NSLog(@"All expected video Path fail!, call \"getDownloadLink\"");
                }
                cnnVideoPath = [self getDownloadLink];
            }
            
            if (isDebug) {
                NSLog(@"%s-%d, finalcnnVideoPath:%@", __FUNCTION__, __LINE__, cnnVideoPath);
            }
            
            // network is available, play stream video
            if (isDebug) {
                NSLog(@"%s-%d, network is available, play stream video", __FUNCTION__, __LINE__);
            }
            [self playVideo];
            
            if ([CNNSTableViewController isEnableDownload]) {
                
                if (isDebug) {
                    NSLog(@"%s-%d, Start to Download Video!", __FUNCTION__, __LINE__);
                }
                [self toast:@"Start to Download Video!"];
                
                // download video
                NSURL *url = [NSURL URLWithString:cnnVideoPath];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, cnnVideoName];
                if (connection) {
                    
                    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
                    }
                    
                    handleFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
                }

                // enable download at setting, download it
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    NSString *urlToDownload = cnnVideoPath;
//                    NSURL *url = [NSURL URLWithString:urlToDownload];
//                    NSData *urlData = [NSData dataWithContentsOfURL:url];
//                    if (urlData)
//                    {
//                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//                        NSString *documentsDirectory = [paths objectAtIndex:0];
//                        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, cnnVideoName];
//                        
//                        //saving is done on main thread
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [urlData writeToFile:filePath atomically:YES];
//                            if (isDebug) {
//                                NSLog(@"video file saved!");
//                            }
//                        });
//                    }
//                });
            }
            
        } else {
            // network is not available, show warning message
            if (isDebug) {
                NSLog(@"%s-%d, network is not available", __FUNCTION__, __LINE__);
            }
            [CNNSTableViewController showAlertDialog:@"Warning" warnMessage:@"No network"];
            
            // for script content
            mediaHeight = 0.0;
            mediaWidth = 0.0;
            
            screenWidth = self.view.frame.size.width;
            screenHeight = self.view.frame.size.height;
            
//            CGRect screenRect = [[UIScreen mainScreen] bounds];
//            if (isPortrait) {
//                screenWidth = screenRect.size.width;
//                screenHeight = screenRect.size.height;
//            } else {
//                screenWidth = screenRect.size.height;
//                screenHeight = screenRect.size.width;
//            }
        }
    }
    
    // show script
    if ([self isFileExit:cnnScriptName]) {
        // file exist, load from saved script file
        if (isDebug) {
            NSLog(@"%s-%d, script file exist", __FUNCTION__, __LINE__);
        }
        
        // load script from file
        NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        filePath = [filePath stringByAppendingString:@"/"];
        filePath = [filePath stringByAppendingString:cnnScriptName];

        if (isDebug) {
            NSLog(@"%s-%d, filePath:%@", __FUNCTION__, __LINE__, filePath);
        }
        if (filePath) {
            NSError *error;
            cnnScriptContentS = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error: &error];
            if (cnnScriptContentS) {
                // show script text
                [self showScriptContent];
            }  
        }
        
    } else {
        if (isDebug) {
            NSLog(@"%s-%d, script file not exist", __FUNCTION__, __LINE__);
        }
        // file not exist, load from network
        if ([CNNSTableViewController isNetworkAvailable]) {
            if (isDebug) {
                NSLog(@"%s-%d, network OK, load script from network", __FUNCTION__, __LINE__);
            }
            [self getScriptContent];
            // show script text
            [self showScriptContent];
        } else {
            // error, show user warning message
            if (isDebug) {
                NSLog(@"error, show user warning message");
            }
        }
    }
    
    // add customize mune
    NSArray *buttons = [NSArray arrayWithObjects:@"Tranlate", nil];
    NSMutableArray *menuItems = [NSMutableArray array];
    for (NSString *buttonText in buttons) {
        NSString *sel = [NSString stringWithFormat:@"magic_%@", buttonText];
        [menuItems addObject:[[UIMenuItem alloc]
                              initWithTitle:buttonText
                              action:NSSelectorFromString(sel)]];
    }
    [UIMenuController sharedMenuController].menuItems = menuItems;
    
    
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
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    tapGestureRecognizer.delegate = self;
    [mp.view addGestureRecognizer:tapGestureRecognizer];
    
    // interstitial ADs
    int seeVideoCounter = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"pref_seeVideoCounter"];
    if (isDebug) {
        NSLog(@"%s-%d, seeVideoCounter:%d", __FUNCTION__, __LINE__, seeVideoCounter);
    }
    if (seeVideoCounter >= 3) {
        if ([CNNSTableViewController isNetworkAvailable]) {
            interstitial_ = [[GADInterstitial alloc] init];
            interstitial_.adUnitID = @"ca-app-pub-5561117272957358/2609425204";
            interstitial_.delegate = self;
            [interstitial_ loadRequest:[GADRequest request]];
            
            seeVideoCounter = 0;
            [[NSUserDefaults standardUserDefaults] setInteger:seeVideoCounter forKey:@"pref_seeVideoCounter"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            seeVideoCounter++;
            [[NSUserDefaults standardUserDefaults] setInteger:seeVideoCounter forKey:@"pref_seeVideoCounter"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } else {
        seeVideoCounter++;
        [[NSUserDefaults standardUserDefaults] setInteger:seeVideoCounter forKey:@"pref_seeVideoCounter"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    [interstitial presentFromRootViewController:self];
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)interstitial{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)interstitial{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
}

- (GADRequest *)request {
    GADRequest *request = [GADRequest request];
    return request;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint currentLocation = [touch locationInView:touch.view];
    
    previousX = currentLocation.x;
    previousY = currentLocation.y;
    
    if (isDebug) {
        NSLog(@"%s-%d, x:%f, y:%f", __FUNCTION__, __LINE__, previousX, previousY);
    }
    
    if (previousX <= (screenWidth/6)) {
        if (isDebug) {
            NSLog(@"%s-%d, left", __FUNCTION__, __LINE__);
        }
        clickZoneRight = false;
        clickZoneCenter = false;
        clickZoneLeft = true;
    } else if (previousX > (screenWidth/6) && previousX < (screenWidth*5/6) ) {
        if (isDebug) {
            NSLog(@"%s-%d, center", __FUNCTION__, __LINE__);
        }
        clickZoneRight = false;
        clickZoneCenter = true;
        clickZoneLeft = false;
    } else {
        if (isDebug) {
            NSLog(@"%s-%d, right", __FUNCTION__, __LINE__);
        }
        clickZoneRight = true;
        clickZoneCenter = false;
        clickZoneLeft = false;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint currentLocation = [touch locationInView:touch.view];
    
    currentX = currentLocation.x;
    currentY = currentLocation.y;
    
    if (currentX - previousX > videoThresholdX) {
        if (isDebug) {
            NSLog(@"%s-%d, move to right", __FUNCTION__, __LINE__);
        }
        currentVideoPosition = [mp currentPlaybackTime];
        [mp setCurrentPlaybackTime:currentVideoPosition + swipeTime];
        [mp play];
        previousX = currentX;
        isVideoTouchMove = true;
        isVideoPlaying = true;
        
    } else if (currentX - previousX < -videoThresholdX ) {
        if (isDebug) {
            NSLog(@"%s-%d, move to left", __FUNCTION__, __LINE__);
        }
        currentVideoPosition = [mp currentPlaybackTime];
        [mp setCurrentPlaybackTime:currentVideoPosition - swipeTime];
        [mp play];
        previousX = currentX;
        isVideoTouchMove = true;
        isVideoPlaying = true;
        
    } else {
        if (isDebug) {
            NSLog(@"%s-%d, X not over the threshold", __FUNCTION__, __LINE__);
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    UITouch *touch = [[event allTouches] anyObject];
//    CGPoint currentLocation = [touch locationInView:touch.view];
    
    // reset variable
    currentX = 0;
    currentY = 0;
    previousX = 0;
    previousY = 0;
    
    if (!isVideoTouchMove) {
        if (clickZoneLeft) {
            // click at video left
            currentVideoPosition = [mp currentPlaybackTime];
            if (isDebug) {
                NSLog(@"%s-%d, currentVideoPosition:%f", __FUNCTION__, __LINE__, currentVideoPosition);
            }
            [mp setCurrentPlaybackTime:currentVideoPosition - swipeTime];
            [mp play];
            isVideoPlaying = true;
            if (!isPortrait) {
                [[self navigationController] setNavigationBarHidden:YES animated:YES];
            }
        } else if (clickZoneCenter) {
            // click at video center
            if ([mp playbackState] == MPMoviePlaybackStatePlaying) {
                [mp pause];
                isVideoPlaying = false;
                if (!isPortrait) {
                    [[self navigationController] setNavigationBarHidden:NO animated:YES];
                }
            } else if([mp playbackState] == MPMoviePlaybackStatePaused) {
                [mp play];
                isVideoPlaying = true;
                if (!isPortrait) {
                    [[self navigationController] setNavigationBarHidden:YES animated:YES];
                }
            }
        } else {
            // click at video left
            currentVideoPosition = [mp currentPlaybackTime];
            [mp setCurrentPlaybackTime:currentVideoPosition + swipeTime];
            [mp play];
            isVideoPlaying = true;
            if (!isPortrait) {
                [[self navigationController] setNavigationBarHidden:YES animated:YES];
            }
        }
    } else {
        // touch move
    }
    
    isVideoTouchMove = false;
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *) response {
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSDictionary *dict = httpResponse.allHeaderFields;
    NSString *lengthString = [dict valueForKey:@"Content-Length"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *length = [formatter numberFromString:lengthString];
    totalBytes = length.unsignedIntegerValue;
    
    if (isDebug) {
        NSLog(@"%s-%d, totalBytes:%lu", __FUNCTION__, __LINE__, (unsigned long)totalBytes);
    }
    videoData = [[NSMutableData alloc] initWithLength:0] ;
 }
     
 - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *) data {
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    [videoData appendData:data];
    receivedBytes += data.length;
     
     if ( (videoData.length > 22000000)) {
         if (isDebug) {
             NSLog(@"%s-%d, videoData.length:%lu, write to disk", __FUNCTION__, __LINE__, (unsigned long)videoData.length);
         }
         if (isDebug) {
             NSLog(@"%s-%d, write file", __FUNCTION__, __LINE__);
         }
         [handleFile writeData:videoData];
         videoData =[[NSMutableData alloc] initWithLength:0];
     }
     
     toastInteval++;
     if (toastInteval > 500) {
         NSString *dlProgressMsg = [NSString stringWithFormat:@"Download Progress %d %%", (int)((float)receivedBytes/totalBytes*100)];
         [self toast:dlProgressMsg];
         toastInteval = 0;
     }
     if (isDebug) {
         NSLog(@"%s-%d, DL progress:%f", __FUNCTION__, __LINE__, (float)receivedBytes/totalBytes);
     }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
     
    [handleFile writeData:videoData];

    if (isDebug) {
     NSLog(@"%s-%d, Download Video Complete", __FUNCTION__, __LINE__);
    }
    [self toast:@"Download Video Complete"];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (isDebug) {
        NSLog(@"%s-%d, download video error:%@", __FUNCTION__, __LINE__, error);
    }
}

- (void)orientationChanged:(NSNotification *) note {
    if (isDebug) {
        NSLog(@"%s-%d, currentView:%d", __FUNCTION__, __LINE__, [CNNSTableViewController getCurrentView]);
    }
    
    if ([CNNSTableViewController getCurrentView] != 1) {
        return;
    }
    
    double delayInSeconds = 1.0;
    
    UIDevice * device = note.object;
    switch(device.orientation) {
            
        case UIDeviceOrientationPortrait:
        {
            
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationPortrait", __FUNCTION__, __LINE__);
            }
            
            // show NavigationBar any way
            [[self navigationController] setNavigationBarHidden:NO animated:YES];
            
            scrollPosition = [[cnnScriptWebView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
            if (isDebug) {
                NSLog(@"%s-%d, scrollPosition:%d", __FUNCTION__, __LINE__, scrollPosition);
            }
            if (!isPortrait) {
                
                isPortrait = true;
                isRotate = true;
                if ([CNNSTableViewController isNetworkAvailable] || [self isFileExit:cnnVideoName]) {
                    currentVideoPosition = [mp currentPlaybackTime];
                    [self playVideo];
                } else {
                    // for script content
                    mediaHeight = 0.0;
                    mediaWidth = 0.0;
                    
                    screenWidth = self.view.frame.size.width;
                    screenHeight = self.view.frame.size.height;
                    
//                    CGRect screenRect = [[UIScreen mainScreen] bounds];
//                    if (isPortrait) {
//                        screenWidth = screenRect.size.width;
//                        screenHeight = screenRect.size.height;
//                    } else {
//                        screenWidth = screenRect.size.height;
//                        screenHeight = screenRect.size.width;
//                    }
                }
                if (isDebug) {
                    NSLog(@"%s-%d, screenWidth:%f", __FUNCTION__, __LINE__, screenWidth);
                    NSLog(@"%s-%d, screenWidth:%f", __FUNCTION__, __LINE__, screenHeight);
                }
                [self showScriptContent];
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    //code to be executed on the main queue after delay
                    NSString *scrollString = [NSString stringWithFormat:@"window.scrollBy(0,%d);", scrollPosition];
                    [cnnScriptWebView stringByEvaluatingJavaScriptFromString:scrollString];
                });
            }
        }
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
        {
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationPortraitUpsideDown", __FUNCTION__, __LINE__);
            }
            
            // show NavigationBar any way
            [[self navigationController] setNavigationBarHidden:NO animated:YES];
            
            scrollPosition = [[cnnScriptWebView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
            if (isDebug) {
                NSLog(@"%s-%d, scrollPosition:%d", __FUNCTION__, __LINE__, scrollPosition);
            }
            if (!isPortrait) {
                
                isPortrait = true;
                isRotate = true;
                if ([CNNSTableViewController isNetworkAvailable] || [self isFileExit:cnnVideoName]) {
                    currentVideoPosition = [mp currentPlaybackTime];
                    [self playVideo];
                } else {
                    // for script content
                    mediaHeight = 0.0;
                    mediaWidth = 0.0;
                    
                    screenWidth = self.view.frame.size.width;
                    screenHeight = self.view.frame.size.height;
                    
                }
                if (isDebug) {
                    NSLog(@"%s-%d, screenWidth:%f", __FUNCTION__, __LINE__, screenWidth);
                    NSLog(@"%s-%d, screenWidth:%f", __FUNCTION__, __LINE__, screenHeight);
                }
                [self showScriptContent];
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    //code to be executed on the main queue after delay
                    NSString *scrollString = [NSString stringWithFormat:@"window.scrollBy(0,%d);", scrollPosition];
                    [cnnScriptWebView stringByEvaluatingJavaScriptFromString:scrollString];
                });
            }
        }

            break;
            
        case UIDeviceOrientationLandscapeLeft:
        {
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationLandscapeLeft", __FUNCTION__, __LINE__);
            }
            scrollPosition = [[cnnScriptWebView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
            if (isDebug) {
                NSLog(@"%s-%d, scrollPosition:%d", __FUNCTION__, __LINE__, scrollPosition);
            }
            if (isPortrait) {
                
                isPortrait = false;
                isRotate = true;
                if ([CNNSTableViewController isNetworkAvailable] || [self isFileExit:cnnVideoName]) {
                    currentVideoPosition = [mp currentPlaybackTime];
                    [self playVideo];
                } else {
                    // for script content
                    mediaHeight = 0.0;
                    mediaWidth = 0.0;
                    
                    screenWidth = self.view.frame.size.width;
                    screenHeight = self.view.frame.size.height;
                    
//                    CGRect screenRect = [[UIScreen mainScreen] bounds];
//                    if (isPortrait) {
//                        screenWidth = screenRect.size.width;
//                        screenHeight = screenRect.size.height;
//                    } else {
//                        screenWidth = screenRect.size.height;
//                        screenHeight = screenRect.size.width;
//                    }
                }
                if (isDebug) {
                    NSLog(@"%s-%d, screenWidth:%f", __FUNCTION__, __LINE__, screenWidth);
                    NSLog(@"%s-%d, screenWidth:%f", __FUNCTION__, __LINE__, screenHeight);
                }
                [self showScriptContent];
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    //code to be executed on the main queue after delay
                    NSString *scrollString = [NSString stringWithFormat:@"window.scrollBy(0,%d);", scrollPosition];
                    [cnnScriptWebView stringByEvaluatingJavaScriptFromString:scrollString];
                });
            }
        }

            break;
            
        case UIDeviceOrientationLandscapeRight:
        {
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationLandscapeRight", __FUNCTION__, __LINE__);
            }
            scrollPosition = [[cnnScriptWebView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
            if (isDebug) {
                NSLog(@"%s-%d, scrollPosition:%d", __FUNCTION__, __LINE__, scrollPosition);
            }
            if (isPortrait) {
                
                isPortrait = false;
                isRotate = true;
                if ([CNNSTableViewController isNetworkAvailable] || [self isFileExit:cnnVideoName]) {
                    currentVideoPosition = [mp currentPlaybackTime];
                    [self playVideo];
                } else {
                    // for script content
                    mediaHeight = 0.0;
                    mediaWidth = 0.0;
                    
                    screenWidth = self.view.frame.size.width;
                    screenHeight = self.view.frame.size.height;
                    
//                    CGRect screenRect = [[UIScreen mainScreen] bounds];
//                    if (isPortrait) {
//                        screenWidth = screenRect.size.width;
//                        screenHeight = screenRect.size.height;
//                    } else {
//                        screenWidth = screenRect.size.height;
//                        screenHeight = screenRect.size.width;
//                    }
                }
                if (isDebug) {
                    NSLog(@"%s-%d, screenWidth:%f", __FUNCTION__, __LINE__, screenWidth);
                    NSLog(@"%s-%d, screenWidth:%f", __FUNCTION__, __LINE__, screenHeight);
                }
                [self showScriptContent];
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    //code to be executed on the main queue after delay
                    NSString *scrollString = [NSString stringWithFormat:@"window.scrollBy(0,%d);", scrollPosition];
                    [cnnScriptWebView stringByEvaluatingJavaScriptFromString:scrollString];
                });
            }

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

- (void) showScriptContent {
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    
//    cnnScriptTextView = [[UITextView alloc] initWithFrame:CGRectZero];
//    if ([CNNSTableViewController isDeviceiPhone]) {
//        [cnnScriptTextView setFrame:CGRectMake(0, mediaHeight, screenWidth, screenHeight-mediaHeight)];
//    } else {
//        [cnnScriptTextView setFrame:CGRectMake(0, mediaHeight+64, screenWidth, screenHeight-mediaHeight-64)];
//    }
//    cnnScriptTextView.editable = NO;
    
    cnnScriptWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    if ([CNNSTableViewController isDeviceiPhone]) {
        [cnnScriptWebView setFrame:CGRectMake(0, mediaHeight+64, screenWidth, screenHeight-mediaHeight)];
    } else {
        [cnnScriptWebView setFrame:CGRectMake(0, mediaHeight+64, screenWidth, screenHeight-mediaHeight-64)];
    }
    
    // set script theme
    NSString *fontColor = @"";
    NSString *bgColor = @"";
    switch ([CNNSTableViewController getScriptTheme]) {
        case 0:     // Black  -  White
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            fontColor = @"#000000";
            bgColor = @"#FFFFFF";
            break;
            
        case 1:     // White  -  Black
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            fontColor = @"#FFFFFF";
            bgColor = @"#000000";
            break;
            
        case 2:     // Red - White
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:0.80 green:0.00 blue:0.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            fontColor = @"#CC0000";
            bgColor = @"#FFFFFF";
            break;
            
        case 3:     // White  -  Red
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:0.80 green:0.00 blue:0.00 alpha:1.0]];
            fontColor = @"#FFFFFF";
            bgColor = @"#CC0000";
            break;
            
        case 4:     // Orange  -  Black
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:1.00 green:0.60 blue:0.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            fontColor = @"#ff9900";
            bgColor = @"#000000";

            break;
            
        case 5:     // White  -  Orange
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:1.00 green:0.60 blue:0.00 alpha:1.0]];
            fontColor = @"#FFFFFF";
            bgColor = @"#ff9900";
            break;
            
        case 6:     // Black  -  Orange
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:0.98 green:0.63 blue:0.10 alpha:1.0]];
            fontColor = @"#000000";
            bgColor = @"#fba119";
            break;
            
        case 7:     // Black  -  Yellow
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:1.00 green:0.85 blue:0.28 alpha:1.0]];
            fontColor = @"#000000";
            bgColor = @"#FFDA47";
            break;
            
        case 8:     // Green - White
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:0.31 green:0.82 blue:0.18 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            fontColor = @"#50d22e";
            bgColor = @"#FFFFFF";
            break;
            
        case 9:     // Green - Black
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:0.31 green:0.82 blue:0.18 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            fontColor = @"#50d22e";
            bgColor = @"#000000";
            break;
            
        case 10:    // White - Green
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:0.31 green:0.82 blue:0.18 alpha:1.0]];
            fontColor = @"#FFFFFF";
            bgColor = @"#50d22e";
            break;
            
        case 11:    // Black - Green
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:0.31 green:0.82 blue:0.18 alpha:1.0]];
            fontColor = @"#000000";
            bgColor = @"#50d22e";
            break;
            
        case 12:    // LightBlue  -  White
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            fontColor = @"#3399FF";
            bgColor = @"#FFFFFF";
            break;
            
        case 13:    // White - LightBlue
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:1.0]];
            fontColor = @"#FFFFFF";
            bgColor = @"#3399FF";
            break;
            
        case 14:    // Black - LightBlue
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:1.0]];
            fontColor = @"#000000";
            bgColor = @"#3399FF";
            break;
            
        case 15:    // White  -  Blue
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:0.19 green:0.35 blue:0.83 alpha:1.0]];
            fontColor = @"#FFFFFF";
            bgColor = @"#3059D6";
            break;
            
        case 16:    // Pink  -  White
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:0.91 green:0.43 blue:0.91 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            fontColor = @"#FF66FF";
            bgColor = @"#FFFFFF";
            break;
            
        case 17:    // LightPurple - White
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:0.80 green:0.20 blue:1.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            fontColor = @"#CC33FF";
            bgColor = @"#FFFFFF";
            break;
            
        case 18:    // White - LightPurple
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:0.80 green:0.20 blue:1.00 alpha:1.0]];
            fontColor = @"#FFFFFF";
            bgColor = @"#CC33FF";
            break;
            
        case 19:    // White  -  Purple
            [cnnScriptTextView setTextColor:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];
            [cnnScriptTextView setBackgroundColor:[UIColor colorWithRed:0.61 green:0.00 blue:0.81 alpha:1.0]];
            fontColor = @"#FFFFFF";
            bgColor = @"#9900CC";
            break;
            
        default:
            break;
    }
    
//    [cnnScriptTextView setFont:[UIFont systemFontOfSize:[CNNSTableViewController getScriptTextSize]]];
//    [cnnScriptTextView setText:cnnScriptContentS];
    
    NSString *jsString = [NSString stringWithFormat:@"<html> \n"
                          "<head> \n"
                          "<style type=\"text/css\"> \n"
                          "body {font-size: %f; color: %@; background-color: %@;}\n"
                          "</style> \n"
                          "</head> \n"
                          "<body>%@</body> \n"
                          "</html>", (float)[CNNSTableViewController getScriptTextSize], fontColor, bgColor, cnnScriptContentS];
    
    [cnnScriptWebView loadHTMLString:jsString baseURL:nil];
//    [UITextView setContentToHTMLString:];
    
    [self.view addSubview:cnnScriptWebView];
//    [self.view addSubview:cnnScriptTextView];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    [super viewWillAppear:animated];
    if ([CNNSTableViewController isNetworkAvailable]) {
        if (mp != nil) {
            [mp play];
            isVideoPlaying = true;
        }
    }
    [CNNSTableViewController setCurrentView:1];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    [super viewWillDisappear:animated];
    if (mp != nil) {
        [mp pause];
        isVideoPlaying = false;
    }
}

- (BOOL)isPlaying {
    if (isDebug) {
        NSLog(@"%s-%d, [mp playbackState]:%d", __FUNCTION__, __LINE__, [mp playbackState]);
    }
    if ([mp playbackState] == MPMoviePlaybackStatePlaying) {
        return  true;
    } else {
        return false;
    }
}

- (void)applicationDidEnterBackground {
    if (isDebug) {
        NSLog(@"%s-%d, isVideoPlaying:%d", __FUNCTION__, __LINE__, isVideoPlaying);
    }
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if (isVideoPlaying) {
            [mp play];
        }

    });
    
}

- (void)applicationWillEnterForeground {
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    [self showScriptContent];
    
}

- (void)didReceiveMemoryWarning
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) playVideo {
    
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    
    screenWidth = self.view.frame.size.width;
    screenHeight = self.view.frame.size.height;
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    if (isPortrait) {
//        screenWidth = screenRect.size.width;
//        screenHeight = screenRect.size.height;
//    } else {
//        screenWidth = screenRect.size.height;
//        screenHeight = screenRect.size.width;
//    }
    
    float mediaAspectRatio = 1.785;
    
    mediaWidth = screenWidth;
    mediaHeight = screenWidth / mediaAspectRatio;
    
    if (isDebug) {
        NSLog(@"%s-%d, screenWidth:%f", __FUNCTION__, __LINE__, screenWidth);
        NSLog(@"%s-%d, screenHeight:%f", __FUNCTION__, __LINE__, screenHeight);
        NSLog(@"%s-%d, mediaWidth:%f", __FUNCTION__, __LINE__, mediaWidth);
        NSLog(@"%s-%d, mediaHeight:%f", __FUNCTION__, __LINE__, mediaHeight);
    }

    NSURL *cnnsVideoURL;
    if (mp == nil) {
        
        if (isPlayLocal) {
            // play from loacl
            cnnsVideoURL = [NSURL fileURLWithPath:cnnVideoPath];
        } else {
            // play from internet
            cnnsVideoURL = [NSURL URLWithString:cnnVideoPath];
        }

        mp = [[MPMoviePlayerController alloc] initWithContentURL:cnnsVideoURL];
    }
    
    if (!isRotate) {
        isRotate = false;
        if (isPlayLocal) {
            // play from loacl
            cnnsVideoURL = [NSURL fileURLWithPath:cnnVideoPath];
        } else {
            // play from internet
            cnnsVideoURL = [NSURL URLWithString:cnnVideoPath];
        }
        mp.contentURL = cnnsVideoURL;
    }
    mp.scalingMode = MPMovieScalingModeFill;
    if ([CNNSTableViewController isDeviceiPhone]) {
        if (isPortrait) {
            mp.view.frame = CGRectMake(0.0, 0.0+64, mediaWidth, mediaHeight);
            // show navigation bar
            [[self navigationController] setNavigationBarHidden:NO animated:YES];
        } else {
            mp.view.frame = CGRectMake(0.0, 0.0, mediaWidth, mediaHeight);
            // hide navigation bar
            [[self navigationController] setNavigationBarHidden:YES animated:YES];
        }
    } else {
        mp.view.frame = CGRectMake(0.0, 0.0+64, mediaWidth, mediaHeight);
    }
    [self.view addSubview:mp.view];
    if (isDebug) {
        NSLog(@"%s-%d, currentVideoPosition:%f", __FUNCTION__, __LINE__, currentVideoPosition);
    }
    
    [mp setCurrentPlaybackTime:currentVideoPosition];
    [mp play];
    
    isVideoPlaying = true;
}

-(void)getScriptContent {
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    NSString *resultS = @"";
//    NSString *replaceS1 = @"<p class=\"cnnBodyText\">";
//    NSString *replaceS2 = @"</p>";
//    NSString *replaceS3 = @"<br/>";
    
    NSURL *tutorialsUrl = [NSURL URLWithString:cnnScriptPath];
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
    
    // Parser object
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    
    // stored array
    NSMutableArray *newTutorials = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Query XPath
    NSString *tutorialsXpathQueryString = @"//p[@class='cnnTransSubHead']";
    NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    
    // process data if found any
    if (tutorialsNodes) {
        
        for (TFHppleElement *element in tutorialsNodes) {
            
            Tutorial *tutorial = [[Tutorial alloc] init];
            [newTutorials addObject:tutorial];
            
            resultS = [[element firstChild] content];
            if (resultS != nil) {
                cnnScriptContentS = [cnnScriptContentS stringByAppendingString:resultS];
            }
        }
    }
    
    // Query XPath
    tutorialsXpathQueryString = @"//p[@class='cnnBodyText']";
    tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    
    // process data if found any
    if (tutorialsNodes) {
        
        for (TFHppleElement *element in tutorialsNodes) {

            Tutorial *tutorial = [[Tutorial alloc] init];
            [newTutorials addObject:tutorial];
            
//            resultS = [[element firstChild] content];
            resultS = [element raw];
            if (resultS != nil) {
                cnnScriptContentS = [cnnScriptContentS stringByAppendingString:resultS];
            }
        }
//        cnnScriptContentS = [cnnScriptContentS stringByReplacingOccurrencesOfString:replaceS1 withString:@"\n"];
//        cnnScriptContentS = [cnnScriptContentS stringByReplacingOccurrencesOfString:replaceS2 withString:@"\n"];
//        cnnScriptContentS = [cnnScriptContentS stringByReplacingOccurrencesOfString:replaceS3 withString:@"\n"];
//        cnnScriptContentS = [self stringByStrippingHTML:cnnScriptContentS];
    }

    cnnScriptContentS = [cnnScriptContentS stringByReplacingOccurrencesOfString:@"<br/> <br/>" withString:@"<br/><br/>"];
    cnnScriptContentS = [cnnScriptContentS stringByReplacingOccurrencesOfString:@"  " withString:@"<br/><br/>"];
    cnnScriptContentS = [cnnScriptContentS stringByReplacingOccurrencesOfString:@"<br/><br/><br/><br/><br/>" withString:@"<br/><br/>"];
    cnnScriptContentS = [cnnScriptContentS stringByReplacingOccurrencesOfString:@"<br/><br/><br/><br/>" withString:@"<br/><br/>"];
//    cnnScriptContentS = [cnnScriptContentS stringByReplacingOccurrencesOfString:@"<br><br><br>" withString:@"<br><br>"];
    
    if (isDebug) {
        NSLog(@"%s-%d, cnnVideoName:%@", __FUNCTION__, __LINE__, cnnVideoName);
        NSLog(@"%s-%d, cnnScriptName:%@", __FUNCTION__, __LINE__, cnnScriptName);
    }

    // save script to file
    if ((cnnScriptContentS != nil && [cnnScriptContentS length] > 0)) {
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSError *error;
        bool succeed = [cnnScriptContentS writeToFile:[documentsPath stringByAppendingPathComponent:cnnScriptName]
                                           atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!succeed){
            if (isDebug) {
                NSLog(@"%s-%d, save script error!", __FUNCTION__, __LINE__);
            }
        }
    }
    
}

-(BOOL) isFileExit:(NSString*) s {
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileString = [documentsPath stringByAppendingPathComponent:s];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileString];
    
    return fileExists;
}

- (void)tappedMenuItem:(NSString *)buttonText {
    
    // translate function
    if ([CNNSTableViewController isNetworkAvailable]) {
    
        scrollPosition = [[cnnScriptWebView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
        if (isDebug) {
            NSLog(@"%s-%d, scrollPosition:%d", __FUNCTION__, __LINE__, scrollPosition);
        }
        NSString *selectedText = [cnnScriptWebView stringByEvaluatingJavaScriptFromString: @"window.getSelection().toString()"];
//        NSString *selectedText = [cnnScriptTextView textInRange:cnnScriptTextView.selectedTextRange];
        
        // highlight
        NSString *replaceString = [NSString stringWithFormat:@"<b><big>%@</big></b>", selectedText];
        cnnScriptContentS = [cnnScriptContentS stringByReplacingOccurrencesOfString:selectedText withString:replaceString];
        // save script to file
        if ((cnnScriptContentS != nil && [cnnScriptContentS length] > 0)) {
            NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSError *error;
            bool succeed = [cnnScriptContentS writeToFile:[documentsPath stringByAppendingPathComponent:cnnScriptName]
                                               atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (!succeed){
                if (isDebug) {
                    NSLog(@"%s-%d, save script error!", __FUNCTION__, __LINE__);
                }
            }
        }
        
        [self showScriptContent];
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            NSString *scrollString = [NSString stringWithFormat:@"window.scrollBy(0,%d);", scrollPosition];
            [cnnScriptWebView stringByEvaluatingJavaScriptFromString:scrollString];
        });
        
        if (isDebug) {
            NSLog(@"%s-%d, srcString:%@, selectedText:%@", __FUNCTION__, __LINE__, buttonText, selectedText);
        }
    
        reTranslateCount = 0;
        [self getTranslateString:selectedText];
        
    } else {
        [CNNSTableViewController showAlertDialog:@"Warning" warnMessage:@"No network"];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    NSString *sel = NSStringFromSelector(action);
    NSRange match = [sel rangeOfString:@"magic_"];
    if (match.location == 0) {
        return YES;
    }
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if ([super methodSignatureForSelector:sel]) {
        return [super methodSignatureForSelector:sel];
    }
    return [super methodSignatureForSelector:@selector(tappedMenuItem:)];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *sel = NSStringFromSelector([invocation selector]);
    NSRange match = [sel rangeOfString:@"magic_"];
    if (match.location == 0) {
        [self tappedMenuItem:[sel substringFromIndex:6]];
    } else {
        [super forwardInvocation:invocation];
    }
}

- (void) getTranslateString:(NSString*)srcString {
    
    if (isDebug) {
        NSLog(@"getTranslateString");
    }
    
    NSString *originString = srcString;
    bool isSentance = false;
    if ([srcString rangeOfString:@" "].location == NSNotFound) {
        if (isDebug) {
            NSLog(@"string does not contain ' '");
        }
    } else {
        if (isDebug) {
            NSLog(@"string contains ' '");
        }
        isSentance = true;
        srcString = [srcString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    }
    
    NSString* resultS = @"";
    NSString* translatedText = @"";
    NSString* translateLanguage = [CNNSTableViewController getTranslateLanguage];
    
    NSString* queryURL = @"";
    
    // stored array
    NSMutableArray *newTutorials = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Query XPath
    NSString *tutorialsXpathQueryString;
    if ([translateLanguage caseInsensitiveCompare:@"es"] == NSOrderedSame) {
        queryURL = @"http://spanish.dictionary.com/translation/";
        queryURL = [NSString stringWithFormat: @"%@%@?src=en", queryURL, srcString];
        tutorialsXpathQueryString = @"//div[@id='tabr1']";
    } else if ([translateLanguage caseInsensitiveCompare:@"eng"] == NSOrderedSame) {
        queryURL = @"http://www.merriam-webster.com/dictionary/";
        queryURL = [NSString stringWithFormat: @"%@%@", queryURL, srcString];
        tutorialsXpathQueryString = @"//div[@class='ld_on_collegiate']//p";
        translatedText = @"\n";
    } else if ([translateLanguage caseInsensitiveCompare:@"zh-TW"] == NSOrderedSame) {
        queryURL = @"http://dict.dreye.com/ews/dict.php?w=";
        queryURL = [NSString stringWithFormat: @"%@%@", queryURL, srcString];
        tutorialsXpathQueryString = @"//div[@class='dict_cont']//div";
        translatedText = @"\n";
    } else {
        queryURL = @"http://translate.reference.com/translate?query=";
        queryURL = [NSString stringWithFormat: @"%@%@&src=en&dst=%@", queryURL, srcString, translateLanguage];
        tutorialsXpathQueryString = @"//div[@class='translateTxt']";
    }

    if (isDebug) {
        NSLog(@"%s-%d, queryURL:%@", __FUNCTION__, __LINE__, queryURL);
        NSLog(@"%s-%d, XPATH:%@", __FUNCTION__, __LINE__, tutorialsXpathQueryString);
    }
    
    NSURL *tutorialsUrl = [NSURL URLWithString:queryURL];
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
    // Parser object
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    
    // process data if found any
    if (tutorialsNodes) {
        
        for (TFHppleElement *element in tutorialsNodes) {
            
            Tutorial *tutorial = [[Tutorial alloc] init];
            [newTutorials addObject:tutorial];
            resultS = [element raw];
//            resultS = [element content];
//            resultS = [element text];
//            if (isDebug) {
//                NSLog(@"resultS:%@", resultS);
//            }
            if (resultS != nil) {
                translatedText = [translatedText stringByAppendingString:resultS];
                translatedText = [translatedText stringByAppendingString:@"\n"];
            }
        }
    }
    translatedText = [self stringByStrippingHTML:translatedText];
    
    if (isDebug) {
        NSLog(@"translatedText:%@, result string length:%lu", translatedText, (unsigned long)[translatedText length]);
    }
    
    if ( ([translatedText length]<2) && (reTranslateCount <3) ) {
        // not find translate result
        
        if (reTranslateCount == 0) {
            // try to use lower case to re-query
            srcString = [srcString lowercaseString];
        } else {
            srcString = [srcString substringToIndex:[srcString length]-1];
        }
        
        // search again
        reTranslateCount++;
        [self getTranslateString:srcString];
        
    } else {
        // find translate result
        // show translate result in dialog
        [CNNSTableViewController showAlertDialog:originString warnMessage:translatedText];
        
        // save translate result to file
        NSString* addContent = [NSString stringWithFormat:@"<b><big>%@</big></b>", originString];
        translatedText = [translatedText stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        addContent = [addContent stringByAppendingString:translatedText];
        addContent = [addContent stringByAppendingString:@"<br>"];
        
        NSString* noteFile =  [cnnVideoName stringByAppendingString:@".cnnsNote.txt"];
        NSString *contents = @"";
        NSError *error;
        
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
                contents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error: &error];
            }
            
            contents = [contents stringByAppendingString:addContent];
            NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            bool succeed = [contents writeToFile:[documentsPath stringByAppendingPathComponent:noteFile]
                                      atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (!succeed){
                if (isDebug) {
                    NSLog(@"%s-%d, save note error!", __FUNCTION__, __LINE__);
                }
            }
            
        } else {
            // note file not exit
            if (isDebug) {
                NSLog(@"%s-%d, note file not exit", __FUNCTION__, __LINE__);
            }
            
            contents = [contents stringByAppendingString:addContent];
            
            NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            bool succeed = [contents writeToFile:[documentsPath stringByAppendingPathComponent:noteFile]
                                      atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (!succeed){
                if (isDebug) {
                    NSLog(@"%s-%d, save note error!", __FUNCTION__, __LINE__);
                }
            }
        }

    }

}

// remove HTML tags
-(NSString *) stringByStrippingHTML : (NSString*) rawString{
    NSRange r;
    while ((r = [rawString rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        rawString = [rawString stringByReplacingCharactersInRange:r withString:@""];
    return rawString;
}

- (void) toast : (NSString*) msg{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject] animated:YES];

    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;

    [hud hide:YES afterDelay:1];
}

- (void)gotoNote:(id)sender
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    NoteViewController* noteViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NoteViewController"];
    [self.navigationController pushViewController:noteViewController animated:YES];
}

- (void)gotoRoughPosition:(id)sender
{
    totalVideoLength = mp.duration;
    currentVideoPosition = [mp currentPlaybackTime];
    
    NSInteger height = [[cnnScriptWebView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
    NSInteger roughPosition = (int)(currentVideoPosition * height /totalVideoLength);
    
    if (isDebug) {
        NSLog(@"%s-%d, totalVideoLength:%f", __FUNCTION__, __LINE__, totalVideoLength);
        NSLog(@"%s-%d, currentVideoPosition:%f", __FUNCTION__, __LINE__, currentVideoPosition);
        NSLog(@"%s-%d, height:%ld", __FUNCTION__, __LINE__, (long)height);
        NSLog(@"%s-%d, roughPosition:%ld", __FUNCTION__, __LINE__, (long)roughPosition);
    }
    
    scrollPosition = [[cnnScriptWebView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
    NSString *scrollString = [NSString stringWithFormat:@"window.scrollBy(0,%d);", roughPosition - scrollPosition];
    [cnnScriptWebView stringByEvaluatingJavaScriptFromString:scrollString];

}

+ (MPMoviePlayerController*) getShareInstance {
    return mp;
}

@end
