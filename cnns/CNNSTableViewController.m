//
//  CNNSTableViewController.m
//  cnns
//
//  Created by GRAY_LIN on 2013/10/29.
//  Copyright (c) 2013年 graylin. All rights reserved.
//

// settings variable
static BOOL isEnableDownloadVar;
static int scriptTextSize;
static NSTimeInterval swipeTime;
static int scriptTheme;
static int autoDelete;
static CGFloat screenWidth;
static CGFloat screenHeight;
static CGFloat ADHeight;
static NSString *translateLanguage;

static NSString *scriptAddressString;
static NSString *videoAddressString;
static NSString *videoAddressString2;
static NSString *videoAddressString3;
static NSString *videoAddressString4;
static NSString *cnnVideoName;
static NSString *cnnVideoDate;

#import "CNNSTableViewController.h"
#import "TFHpple.h"
#import "Tutorial.h"
#import "Contributor.h"
#import "Reachability.h"
#import "ViewController.h"


@interface CNNSTableViewController ()

@end

@implementation CNNSTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    NSLog(@"initWithStyle");
    self = [super initWithStyle:style];
    
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
  
    // initial variable
    isNeedUpdate = false;
    waitFlag = false;
    isEverLoaded = false;
    currentView = 0;
    
    cnnListStringArray = [[NSMutableArray alloc] init];
    cnnScriptAddrStringArray = [[NSMutableArray alloc] init];
    CNNSListData = [[NSMutableArray alloc] init];
    imagesArray = [[NSMutableArray alloc] init];
    
    scriptAddressStringPrefix = @"http://transcripts.cnn.com/TRANSCRIPTS/";
    scriptAddressStringPostfix = @"/sn.01.html";
    scriptAddressString = @"";
    videoAddressStringPrefix = @"http://podcasts.cnn.net/cnn/big/podcasts/studentnews/video/";
    videoAddressStringPostfix = @".cnn.m4v";
    videoAddressString = @"";
    videoAddressString2 = @"";
    videoAddressString3 = @"";
    videoAddressString4 = @"";
    CNNS_URL = @"http://edition.cnn.com/US/studentnews/quick.guide/archive/";
    
    [self initPlist];
    [self writePlist];
    
    // initial from settings
    [CNNSTableViewController updateSettingValue];
    
    // set title
    [self.navigationItem setTitle:@"10min News"];
    
    // check orientation
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        isPortrait = true;
    } else {
        isPortrait = false;
    }
    
    // build up navigation bar button array
    if (isDebug) {
        UIBarButtonItem *navigationButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(navigationButtonPressed:)];
        self.navigationItem.leftBarButtonItem = navigationButton;
    }

    // refresh button
    UIBarButtonItem* refleshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshList:)];
    
    // info button
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(gotoInfoPage:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    // Q & A button
//    UIImage *qaImage = [UIImage imageNamed:@"icon_qa.png"];
//    UIButton* qaButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    
//    CGRect buttonFrame = qaButton.frame;
//    buttonFrame.size = qaImage.size;
//    qaButton.frame = buttonFrame;
//    
//    [qaButton setImage:qaImage forState:UIControlStateNormal];
//    [qaButton addTarget:self action:@selector(gotoInfoPage:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *qaBarButton = [[UIBarButtonItem alloc] initWithCustomView:qaButton];
    
    NSArray *buttonArray = [[NSArray alloc] initWithObjects:infoBarButton, refleshButton, nil];
//    NSArray *buttonArray = [[NSArray alloc] initWithObjects:qaBarButton, infoBarButton, refleshButton, nil];
    
    self.navigationItem.rightBarButtonItems = buttonArray;
    
    // start a thread to get list from cnns website
    if ([self showListView] == -1) {
        // no list data before
        if ([CNNSTableViewController isNetworkAvailable]) {
            
            [NSThread detachNewThreadSelector:@selector(getCNNSTitle) toTarget:self withObject:nil];
            
        } else {
            
            [CNNSTableViewController showAlertDialog:@"Warning" warnMessage:@"No network"];
        }
    }
    
//    if ([CNNSTableViewController isNetworkAvailable]) {
//        
//        if (true) {
//            // check if need update list
//            [NSThread detachNewThreadSelector:@selector(getCNNSTitle) toTarget:self withObject:nil];
//        }
//        
//    } else {
//        // offline jobs
//        if (isDebug) {
//            NSLog(@"%s-%d, no network, just show list", __FUNCTION__, __LINE__);
//        }
//        [self showListView];
//    }
    
    if (isDebug) {
        NSLog(@"%s-%d, model:%@", __FUNCTION__, __LINE__, [UIDevice currentDevice].model);
        NSLog(@"%s-%d, description:%@", __FUNCTION__, __LINE__, [UIDevice currentDevice].description);
        NSLog(@"%s-%d, localizedModel:%@", __FUNCTION__, __LINE__, [UIDevice currentDevice].localizedModel);
        NSLog(@"%s-%d, name:%@", __FUNCTION__, __LINE__, [UIDevice currentDevice].name);
        NSLog(@"%s-%d, systemVersion:%@", __FUNCTION__, __LINE__, [UIDevice currentDevice].systemVersion);
        NSLog(@"%s-%d, systemName:%@", __FUNCTION__, __LINE__, [UIDevice currentDevice].systemName);
    }
    
    if ([CNNSTableViewController isDeviceiPhone]) {
        if (isDebug) {
            NSLog(@"%s-%d, iPhone", __FUNCTION__, __LINE__);
        }
        ADHeight = 50.0;
    } else {
        if (isDebug) {
            NSLog(@"%s-%d, iPad", __FUNCTION__, __LINE__);
        }
        ADHeight = 90.0;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    // back ground service
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryErr];
    [[AVAudioSession sharedInstance] setActive: YES error: &activationErr];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

//    // load AD
//    // Create a view of the standard size at the top of the screen.
//    // Available AdSize constants are explained in GADAdSize.h.
//    admobView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
//    
//    // Specify the ad unit ID.
//    admobView.adUnitID = @"a1526f2eb4a1fe3";
//    
//    // Let the runtime know which UIViewController to restore after taking
//    // the user wherever the ad goes and add it to the view hierarchy.
//    admobView.rootViewController = self;

    // load AD
    admobView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    admobView.adUnitID = @"ca-app-pub-5561117272957358/2609425204";
    [admobView setRootViewController:self];
    [admobView loadRequest:[GADRequest request]];
    
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
            }
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationPortraitUpsideDown", __FUNCTION__, __LINE__);
            }
            if (!isPortrait) {
                isPortrait = true;
            }
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationLandscapeLeft", __FUNCTION__, __LINE__);
            }
            if (isPortrait) {
                isPortrait = false;
            }
            break;
            
        case UIDeviceOrientationLandscapeRight:
            if (isDebug) {
                NSLog(@"%s-%d, UIDeviceOrientationLandscapeRight", __FUNCTION__, __LINE__);
            }
            if (isPortrait) {
                isPortrait = false;
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
            isPortrait = false;
            break;
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation {
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    for (int i=0; i<imagesArray.count; i++) {
        [[imagesArray objectAtIndex:i] removeFromSuperview];
    }
    [self.tableView reloadData];
}

- (CGFloat) tableView :(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = ADHeight; // this should be the height of your admob view
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *headerView = admobView; // init your view or reference your admob view
    [admobView loadRequest:[GADRequest request]];
    return headerView;
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
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self.tableView reloadData];
    });
}

+ (void) updateSettingValue {
    
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    // load user preference settings
    NSUserDefaults* userDefaults  = [NSUserDefaults standardUserDefaults];
    isEnableDownloadVar = [userDefaults boolForKey:@"pref_enable_download"];
    scriptTheme = (int)[userDefaults integerForKey:@"pref_script_theme"];
    scriptTextSize = (int)[userDefaults integerForKey:@"pref_script_text_size"];
    if (scriptTextSize == 0) {
        scriptTextSize = 18;
    }
    swipeTime = (NSTimeInterval)[userDefaults integerForKey:@"pref_swipe_time"];
    if (swipeTime == 0.0) {
        swipeTime = 3.0;
    }
    translateLanguage = [userDefaults stringForKey:@"pref_translate_language"];
    if (translateLanguage == nil) {
        translateLanguage = @"zh-TW";
    }
    autoDelete = (int)[userDefaults integerForKey:@"pref_auto_delete_related_files"];
    if (isDebug) {
        NSLog(@"%s-%d, isEnableDownload:%d", __FUNCTION__, __LINE__, isEnableDownloadVar);
        NSLog(@"%s-%d, scriptTheme:%d", __FUNCTION__, __LINE__, scriptTheme);
        NSLog(@"%s-%d, scriptTextSize:%d", __FUNCTION__, __LINE__, scriptTextSize);
        NSLog(@"%s-%d, swipeTime:%f", __FUNCTION__, __LINE__, swipeTime);
        NSLog(@"%s-%d, translateLanguage:%@", __FUNCTION__, __LINE__, translateLanguage);
        NSLog(@"%s-%d, autoDelete:%d", __FUNCTION__, __LINE__, autoDelete);
    }
    
    // delete old related files
    if (autoDelete != 0) {
        [CNNSTableViewController deleteOlderFile];
    }
    
}

+ (Boolean) isDeviceiPhone {
    
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        return true;
    } else if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        return false;
    } else {
        return false;
    }
}

- (void)didReceiveMemoryWarning
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isDebug) {
        NSLog(@"%s-%d, number:%ld, [CNNSListData count]:%lu", __FUNCTION__, __LINE__, (long)section, (unsigned long)[CNNSListData count]);
    }
    return [CNNSListData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (isDebug) {
//        NSLog(@"%s-%d, row:%d", __FUNCTION__, __LINE__, indexPath.row);
//    }
    static NSString *CellIdentifier = @"CNNSCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Tutorial *thisTutorial = [CNNSListData objectAtIndex:indexPath.row];
    cell.textLabel.text = thisTutorial.title;
//        cell.detailTextLabel.text = thisTutorial.url;
//        cell.imageView.image = [UIImage imageNamed:@"img_newspaper_o.jpg"];
    
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

    
    NSArray *tempSA = [cnnScriptAddrStringArray[indexPath.row] componentsSeparatedByString:@"/"];
    
//    if (isDebug) {
//        NSLog(@"tempSA:%@", tempSA);
//    }
    
    if (tempSA != nil && [tempSA[0] isEqualToString:@"initial value"]) {
        return cell;
    }
    
    // format the date
    NSInteger archiveYear = 0, archiveMonth, archiveDay, realYear = 0, realMonth = 0, realDay = 0;
    
    NSString *dateString = [NSString stringWithFormat:@"%@-%@-%@", tempSA[1], tempSA[2], tempSA[3]];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    archiveYear = [components year];
    archiveMonth = [components month];
    archiveDay = [components day];
//    if (isDebug) {
//        NSLog(@"date:%@", date);
//        NSLog(@"archive day:%ld-%ld-%ld", (long)archiveYear, (long)archiveMonth, (long)archiveDay);
//    }
    
    // add one day
    NSDateComponents* deltaComps = [[NSDateComponents alloc] init];
    [deltaComps setDay:1];
    NSDate* tomorrow = [[NSCalendar currentCalendar] dateByAddingComponents:deltaComps toDate:date options:0];
    
    components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:tomorrow];
    realYear = [components year];
    realMonth = [components month];
    realDay = [components day];
    
//    if (isDebug) {
//        NSLog(@"real day:%ld-%ld-%ld", (long)realYear, (long)realMonth, (long)realDay);
//    }
    
    // get video file name
    cnnVideoName = [NSString stringWithFormat:@"sn-%02ld%02ld%02d%@", (long)realMonth, (long)realDay, (realYear-2000), videoAddressStringPostfix];
    cnnScriptName = [cnnVideoName stringByAppendingString:@".txt"];
    
    UIImageView *imageView1;
    UIImageView *imageView2;
    
    if (imagesArray.count <= (indexPath.row+1)*2) {
        
        if ([self isFileExit:cnnVideoName]) {
            imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-70, 5, 30, 30)];
            [imageView1 setImage:[UIImage imageNamed:@"img_video_o.jpg"]];
            [cell.contentView addSubview:imageView1];
        } else {
            imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-70, 5, 30, 30)];
            [imageView1 setImage:[UIImage imageNamed:@"img_video_x.jpg"]];
            [cell.contentView addSubview:imageView1];
        }
        if ([self isFileExit:cnnScriptName]) {
            imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-35, 5, 30, 30)];
            [imageView2 setImage:[UIImage imageNamed:@"img_newspaper_o.jpg"]];
            [cell.contentView addSubview:imageView2];
        } else {
            imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-35, 5, 30, 30)];
            [imageView2 setImage:[UIImage imageNamed:@"img_newspaper_x.jpg"]];
            [cell.contentView addSubview:imageView2];
        }
        
        [imagesArray addObject:imageView1];
        [imagesArray addObject:imageView2];
    } else {
        
        [[imagesArray objectAtIndex:indexPath.row*2] removeFromSuperview];
        [[imagesArray objectAtIndex:indexPath.row*2+1] removeFromSuperview];
        
        if ([self isFileExit:cnnVideoName]) {
            imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-70, 5, 30, 30)];
            [imageView1 setImage:[UIImage imageNamed:@"img_video_o.jpg"]];
            [cell.contentView addSubview:imageView1];
        } else {
            imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-70, 5, 30, 30)];
            [imageView1 setImage:[UIImage imageNamed:@"img_video_x.jpg"]];
            [cell.contentView addSubview:imageView1];
        }
        if ([self isFileExit:cnnScriptName]) {
            imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-35, 5, 30, 30)];
            [imageView2 setImage:[UIImage imageNamed:@"img_newspaper_o.jpg"]];
            [cell.contentView addSubview:imageView2];
        } else {
            imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-35, 5, 30, 30)];
            [imageView2 setImage:[UIImage imageNamed:@"img_newspaper_x.jpg"]];
            [cell.contentView addSubview:imageView2];
        }
        
        [imagesArray replaceObjectAtIndex:indexPath.row*2 withObject:imageView1];
        [imagesArray replaceObjectAtIndex:indexPath.row*2+1 withObject:imageView2];
    }
    
    // Configure the cell...
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isDebug) {
        NSLog(@"%s-%d, press index:%ld", __FUNCTION__, __LINE__, (long)indexPath.row);
        NSLog(@"%s-%d, cnnListStringArray:%@", __FUNCTION__, __LINE__, cnnListStringArray[indexPath.row]);
        NSLog(@"%s-%d, cnnScriptAddrStringArray:%@", __FUNCTION__, __LINE__, cnnScriptAddrStringArray[indexPath.row]);
    }

    NSArray *tempSA = [cnnScriptAddrStringArray[indexPath.row] componentsSeparatedByString:@"/"];
    
    // format the date
    NSInteger archiveYear = 0, archiveMonth, archiveDay, realYear = 0, realMonth = 0, realDay = 0;
    
    NSString *dateString = [NSString stringWithFormat:@"%@-%@-%@", tempSA[1], tempSA[2], tempSA[3]];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    archiveYear = [components year];
    archiveMonth = [components month];
    archiveDay = [components day];
    
    // add one day
    NSDateComponents* deltaComps = [[NSDateComponents alloc] init];
    [deltaComps setDay:1];
    NSDate* tomorrow = [[NSCalendar currentCalendar] dateByAddingComponents:deltaComps toDate:date options:0];
    
    components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:tomorrow];
    realYear = [components year];
    realMonth = [components month];
    realDay = [components day];
    
    scriptAddressString = [NSString stringWithFormat:@"%@%d%02ld/%02ld%@", scriptAddressStringPrefix, (realYear-2000), (long)realMonth, (long)realDay, scriptAddressStringPostfix];
    
    // origin path
    videoAddressString2 = [NSString stringWithFormat:@"%@%ld/%02ld/%02ld/sn-%02ld%02ld%02d%@", videoAddressStringPrefix, (long)archiveYear, (long)archiveMonth, (long)archiveDay, (long)realMonth, (long)realDay, (realYear-2000), videoAddressStringPostfix];
    videoAddressString3 = [NSString stringWithFormat:@"%@%ld/%02ld/%02ld/sn-%02ld%02ld%02d%@", videoAddressStringPrefix, (long)realYear, (long)realMonth, (long)realDay, (long)realMonth, (long)realDay, (realYear-2000), videoAddressStringPostfix];
    videoAddressString4 = [NSString stringWithFormat:@"%@%ld/%02ld/%02ld/orig-sn-%02ld%02ld%02d%@", videoAddressStringPrefix, (long)realYear, (long)realMonth, (long)realDay, (long)realMonth, (long)realDay, (realYear-2000), videoAddressStringPostfix];
    // recent use path
    videoAddressString = [NSString stringWithFormat:@"%@%ld/%02ld/%02ld/orig-sn-%02ld%02ld%02d%@", videoAddressStringPrefix, (long)archiveYear, (long)archiveMonth, (long)archiveDay, (long)realMonth, (long)realDay, (realYear-2000), videoAddressStringPostfix];
    
    cnnVideoName = [NSString stringWithFormat:@"sn-%02ld%02ld%02d%@", (long)realMonth, (long)realDay, (realYear-2000), videoAddressStringPostfix];
    cnnScriptName = [cnnVideoName stringByAppendingString:@".txt"];
    cnnVideoDate = [NSString stringWithFormat:@"%02ld%02ld", (long)realMonth, (long)realDay];
    
    if (isDebug) {
        NSLog(@"scriptAddressString:%@", scriptAddressString);
        NSLog(@"videoAddressString:%@", videoAddressString);
        NSLog(@"videoAddressString2:%@", videoAddressString2);
        NSLog(@"videoAddressString3:%@", videoAddressString3);
        NSLog(@"videoAddressString4:%@", videoAddressString4);
        NSLog(@"cnnVideoName:%@", cnnVideoName);
        NSLog(@"cnnVideoDate:%@", cnnVideoDate);
    }
    
    PlayVideoViewController* playVideoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayVideoViewController"];
    [self.navigationController pushViewController:playVideoViewController animated:YES];
}

- (int) showListView {
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }

    // stored array
    NSMutableArray *newTutorials = [[NSMutableArray alloc] initWithCapacity:0];
    
    // read stored data
    [self readWritePlist:0];
    
    if ([cnnListStringArray count] == 0) {
        return -1;
    }
    
    for (int i = 0; i < MAX_LIST_ARRAY_SIZE; i++) {
        if (isDebug) {
            NSLog(@"cnnListStringArray:%d:%@", i, cnnListStringArray[i]);
            NSLog(@"cnnScriptAddrStringArray:%d:%@", i, cnnScriptAddrStringArray[i]);
        }
        Tutorial *tutorial = [[Tutorial alloc] init];
        tutorial.title = cnnListStringArray[i];
        tutorial.url = cnnScriptAddrStringArray[i];
        
        [newTutorials addObject:tutorial];
    }
    
    // return result
    CNNSListData = newTutorials;
    [self.tableView reloadData];
    return 0;
}

-(void)getCNNSTitle {
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    int arrayIndex = 0;
    NSString *resultS = @"";
//    NSString *matchString = @"CNN Student News";
    NSString *dummyString = @"CNN Student News - ";

    // CNNS URL
    if (isDebug) {
        NSLog(@"%s-%d, CNNS_URL:%@", __FUNCTION__, __LINE__, CNNS_URL);
    }
    NSURL *tutorialsUrl = [NSURL URLWithString:CNNS_URL];
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
    
    // Parser object
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    
    // stored array
    NSMutableArray *newTutorials = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Query XPath
    NSString *tutorialsXpathQueryString = @"//div[@class='cnn_spccovt1cllnk cnn_spccovt1cll2']//h2//a";
    NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    
    // process data if found any
    if (tutorialsNodes) {
        
        for (TFHppleElement *element in tutorialsNodes) {
            
            if (arrayIndex < MAX_LIST_ARRAY_SIZE) {
                
                Tutorial *tutorial = [[Tutorial alloc] init];
                [newTutorials addObject:tutorial];
                
                resultS = [[element firstChild] content];
                tutorial.title = [resultS stringByReplacingOccurrencesOfString:dummyString withString:@""];
                cnnListStringArray[arrayIndex] = tutorial.title;
                
                tutorial.url = [element objectForKey:@"href"];
                cnnScriptAddrStringArray[arrayIndex] = tutorial.url;
                
//                if (isDebug) {
//                    NSLog(@"title: %@", tutorial.title);
//                    NSLog(@"url: %@", tutorial.url);
//                }
                
                arrayIndex++;
            } else {
                break;
            }
        }
    }
    
    // Query XPath
    tutorialsXpathQueryString = @"//div[@class='cnn_mtt1imghtitle']//span//a";
    tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    
    // process data if found any
    if (tutorialsNodes) {
        
        for (TFHppleElement *element in tutorialsNodes) {
            
            if (arrayIndex < MAX_LIST_ARRAY_SIZE) {
                
                Tutorial *tutorial = [[Tutorial alloc] init];
                [newTutorials addObject:tutorial];
                
                resultS = [[element firstChild] content];
                tutorial.title = [resultS stringByReplacingOccurrencesOfString:dummyString withString:@""];
                cnnListStringArray[arrayIndex] = tutorial.title;
                
                tutorial.url = [element objectForKey:@"href"];
                cnnScriptAddrStringArray[arrayIndex] = tutorial.url;
                
//                if (isDebug) {
//                    NSLog(@"title: %@", tutorial.title);
//                    NSLog(@"url: %@", tutorial.url);
//                }
                
                arrayIndex++;
            } else {
                break;
            }
        }
    }

    // Query XPath
    tutorialsXpathQueryString = @"//div[@class='archive-item story cnn_skn_spccovstrylst']//h2//a";
    tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    
    // process data if found any
    if (tutorialsNodes) {
        
        for (TFHppleElement *element in tutorialsNodes) {
            
            if (arrayIndex < MAX_LIST_ARRAY_SIZE) {
                
                Tutorial *tutorial = [[Tutorial alloc] init];
                [newTutorials addObject:tutorial];
                
                resultS = [[element firstChild] content];
                tutorial.title = [resultS stringByReplacingOccurrencesOfString:dummyString withString:@""];
                cnnListStringArray[arrayIndex] = tutorial.title;
                
                tutorial.url = [element objectForKey:@"href"];
                cnnScriptAddrStringArray[arrayIndex] = tutorial.url;
                
//                if (isDebug) {
//                    NSLog(@"title: %@", tutorial.title);
//                    NSLog(@"url: %@", tutorial.url);
//                }
                
                arrayIndex++;
            } else {
                break;
            }
        }
    }
    
    // write to plist
    [self readWritePlist:1];
    
    // return result
    CNNSListData = newTutorials;
    if (isDebug) {
        NSLog(@"%s-%d, [CNNSListData count]:%lu", __FUNCTION__, __LINE__, (unsigned long)[CNNSListData count]);
    }
    [self.tableView reloadData];
}

+ (Boolean) isNetworkAvailable {
    // check if we've got network connectivity
    Reachability *myNetwork = [Reachability reachabilityWithHostname:@"google.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    switch (myStatus) {
        case NotReachable:
            if (isDebug) {
                NSLog(@"%s-%d, There's no internet connection at all. Display error message now.", __FUNCTION__, __LINE__);
            }
            return false;
            break;
            
        case ReachableViaWWAN:
            if (isDebug) {
                NSLog(@"%s-%d, We have a 3G connection", __FUNCTION__, __LINE__);
            }
            return true;
            break;
            
        case ReachableViaWiFi:
            if (isDebug) {
                NSLog(@"%s-%d, We have WiFi", __FUNCTION__, __LINE__);
            }
            return true;
            break;
            
        default:
            return false;
            break;
    }
}

-(BOOL) isFileExit:(NSString*) s {
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileString = [documentsPath stringByAppendingPathComponent:s];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileString];
    
    return fileExists;
}

- (void) toast : (NSString*) msg{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
}


// class methods
+ (NSString*) getVideoAddress {
    return videoAddressString;
}
+ (NSString*) getVideoAddress2 {
    return videoAddressString2;
}
+ (NSString*) getVideoAddress3 {
    return videoAddressString3;
}
+ (NSString*) getVideoAddress4 {
    return videoAddressString4;
}
+ (NSString*) getVideoDate {
    return cnnVideoDate;
}

+ (NSString*) getScriptAddress {
    return scriptAddressString;
}

+ (NSString*) getVideoFileName {
    return cnnVideoName;
}

+ (Boolean) isEnableDownload {
    return isEnableDownloadVar;
}

+ (int) getScriptTheme {
    return scriptTheme;
}

+ (int) getScriptTextSize {
    return scriptTextSize;
}

+ (NSTimeInterval) getSwipeTime {
    return swipeTime;
}

+ (NSString*) getTranslateLanguage {
    return translateLanguage;
}

+ (CGFloat) getScreenWidth {
    return screenWidth;
}

+ (CGFloat) getScreenHeight {
    return screenHeight;
}

+ (CGFloat) getADHeight {
    return ADHeight;
}

- (void)navigationButtonPressed:(id)sender
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    
}

+ (void)deleteOlderFile{
    
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"];
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    NSDirectoryEnumerator *dirEnum =
    [localFileManager enumeratorAtPath:docsDir];
    
    NSString *file;
    NSDictionary *attributes;
    NSDate* timeNow = [NSDate date];
    NSDate *date;
    NSError *error;
    int survivalDay = 0;
    
    switch (autoDelete) {
        case 1:
            survivalDay = 5;
            break;
        case 2:
            survivalDay = 10;
            break;
        case 3:
            survivalDay = 15;
            break;
        case 4:
            survivalDay = 20;
            break;
            
        default:
            break;
    }
    
    while ((file = [dirEnum nextObject])) {
        if (isDebug) {
            NSLog(@"%s-%d, file:%@", __FUNCTION__, __LINE__, file);
        }
        
        if ([file rangeOfString:@".cnn.m4v"].location == NSNotFound) {

        } else {

            file = [docsDir stringByAppendingPathComponent:file];
            attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil];
            date = [attributes fileModificationDate];

            // If file is older than settings' >> delete
            if (isDebug) {
                NSLog(@"%s-%d, %f", __FUNCTION__, __LINE__, [timeNow timeIntervalSinceDate:date]);
            }
//            if ([timeNow timeIntervalSinceDate:date] > 30.0f)
            if ([timeNow timeIntervalSinceDate:date] > survivalDay*24*60*60.0f)
            {
                // delete file
                if ([localFileManager removeItemAtPath:file error:&error] != YES)
                    NSLog(@"delete file error:%@", [error localizedDescription]);
            }
        }
    }
}

- (void)gotoInfoPage:(id)sender
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    NoteViewController* informationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InformationViewController"];
    [self.navigationController pushViewController:informationViewController animated:YES];
}

- (void)refreshList:(id)sender
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    
    if ([CNNSTableViewController isNetworkAvailable]) {
        [self getCNNSTitle];
    } else {
        [CNNSTableViewController showAlertDialog:@"Warning" warnMessage:@"Networknot exist!"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    [self.tableView reloadData];
    [super viewWillAppear:animated];
    [CNNSTableViewController setCurrentView:0];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    // reload settings
    [super viewWillDisappear:animated];
}

+ (void) showAlertDialog : (NSString*) title warnMessage:(NSString*) message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                message:message
                                                delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    [alert show];
}

// read or write to plist file
- (void)readWritePlist : (int) rw
{
    // rw == 0 for read, rw == 1 for write
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    // get file path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/cnnListStringArray.plist"];
    NSString *filePath2 = [documentsDirectory stringByAppendingString:@"/cnnScriptAddrStringArray.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (rw == 0) {
        if (isDebug) {
            NSLog(@"%s-%d, read plist", __FUNCTION__, __LINE__);
        }
        if ([fileManager fileExistsAtPath:filePath] || [fileManager fileExistsAtPath:filePath2]) {
            if (isDebug) {
                NSLog(@"%s-%d, plist exist", __FUNCTION__, __LINE__);
            }
            // read stored info
            cnnListStringArray = [NSMutableArray arrayWithContentsOfFile:filePath];
            cnnScriptAddrStringArray = [NSMutableArray arrayWithContentsOfFile:filePath2];
//            if (isDebug) {
//                for (int i =0; i<MAX_LIST_ARRAY_SIZE; i++) {
//                    NSLog(@"cnnListStringArray:%@", cnnListStringArray[i]);
//                    NSLog(@"cnnScriptAddrStringArray:%@", cnnScriptAddrStringArray[i]);
//                }
//            }
            return;
            
        } else {
            if (isDebug) {
                NSLog(@"%s-%d, plist not exist", __FUNCTION__, __LINE__);
            }
        }
    } else {
        // write info to plist
        if (isDebug) {
            NSLog(@"%s-%d, write plist", __FUNCTION__, __LINE__);
        }
        for (int i =0; i<MAX_LIST_ARRAY_SIZE; i++) {
//            if (isDebug) {
//                NSLog(@"cnnListStringArray:%@", cnnListStringArray[i]);
//                NSLog(@"cnnScriptAddrStringArray:%@", cnnScriptAddrStringArray[i]);
//            }
        }
        
        // save file
        if ([cnnListStringArray writeToFile:filePath atomically: YES]) {
            if (isDebug) {
                NSLog(@"%s-%d, writePlist success", __FUNCTION__, __LINE__);
            }
        } else {
            if (isDebug) {
                NSLog(@"%s-%d, writePlist fail", __FUNCTION__, __LINE__);
            }
        }
        if ([cnnScriptAddrStringArray writeToFile:filePath2 atomically: YES]) {
            if (isDebug) {
                NSLog(@"%s-%d, writePlist success", __FUNCTION__, __LINE__);
            }
        } else {
            if (isDebug) {
                NSLog(@"%s-%d, writePlist fail", __FUNCTION__, __LINE__);
            }
        }
        return;
    }
}

- (void)writePlist
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    // get file path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/data.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *plistDict;
    if ([fileManager fileExistsAtPath: filePath]) // check file exist
    {
        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        
    }else{
        NSLog(@"file isn't exist");
        return;
    }
    
    [plistDict setValue:[NSNumber numberWithBool:isEverLoaded] forKey:@"IsEverLoad"];
    
    // save to file
    if ([plistDict writeToFile:filePath atomically:YES]) {
        if (isDebug) {
            NSLog(@"%s-%d, writePlist success", __FUNCTION__, __LINE__);
        }
    } else {
        NSLog(@"%s-%d, writePlist fail", __FUNCTION__, __LINE__);
    }
}

// read stored setting values from exist plist file or create default one if plist file isn't exist
- (void)initPlist
{
    if (isDebug) {
        NSLog(@"%s-%d", __FUNCTION__, __LINE__);
    }
    // get file path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/data.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *plistDict;
    if ([fileManager fileExistsAtPath: filePath]) // check file exist
    {
        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        // read stored value
//        NSString *value;
//        int temp;
        isEverLoaded = [plistDict objectForKey:@"IsEverLoad"];
        return;
        
    } else {
        
        if (isDebug) {
            NSLog(@"%s-%d, plist isn't exist", __FUNCTION__, __LINE__);
        }
        plistDict = [[NSMutableDictionary alloc] init];
        // write default value
//        int temp;
        [plistDict setValue:false forKey:@"IsEverLoad"];
        
        // save file
        if ([plistDict writeToFile:filePath atomically: YES]) {
            if (isDebug) {
                NSLog(@"%s-%d, writePlist success", __FUNCTION__, __LINE__);
            }
        } else {
            NSLog(@"%s-%d, writePlist fail", __FUNCTION__, __LINE__);
        }
        return;
    }
}

+ (int) getCurrentView {
    return currentView;
}

+ (void) setCurrentView : (int) value {
    currentView = value;
}

@end
