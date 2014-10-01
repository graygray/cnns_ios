//
//  CNNSTableViewController.h
//  cnns
//
//  Created by GRAY_LIN on 2013/10/29.
//  Copyright (c) 2013年 graylin. All rights reserved.
//

//#define isDebug true
#define isDebug false
#define MAX_LIST_ARRAY_SIZE 20

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#import "PlayVideoViewController.h"
#import "MBProgressHUD.h"


static int currentView;

@interface CNNSTableViewController : UITableViewController {
    NSMutableArray* CNNSListData;
    GADBannerView *admobView;
    IBOutlet UITableView *cnnsUITableView;
    
    bool isNeedUpdate;
    bool waitFlag;
    bool isEverLoaded;
    
    NSString *scriptAddressStringPrefix;
    NSString *scriptAddressStringPostfix;
//    NSString *scriptAddressString;
    NSString *videoAddressStringPrefix;
    NSString *videoAddressStringPostfix;
//    NSString *videoAddressString;
    NSString* CNNS_URL;
//    NSString* cnnVideoName;
    NSString* cnnScriptName;
    
    // store settings
    NSString *plistPath;
    NSMutableDictionary *plistDictionary;
    NSMutableArray *cnnListStringArray;
    NSMutableArray *cnnScriptAddrStringArray;
    
    bool isPortrait;
//    CGFloat screenWidth;
//    CGFloat screenHeight;
    
    NSMutableArray * imagesArray;

}

+ (NSString*) getVideoAddress;
+ (NSString*) getVideoAddress2;
+ (NSString*) getVideoAddress3;
+ (NSString*) getVideoAddress4;
+ (NSString*) getScriptAddress;
+ (NSString*) getVideoDate;
+ (Boolean) isNetworkAvailable;
+ (Boolean) isEnableDownload;
+ (Boolean) isDeviceiPhone;
+ (int) getScriptTheme;
+ (int) getScriptTextSize;
+ (NSString*) getTranslateLanguage;
+ (CGFloat) getScreenWidth;
+ (CGFloat) getScreenHeight;
+ (CGFloat) getADHeight;
+ (void) updateSettingValue;
+ (void) showAlertDialog : (NSString*)title warnMessage:(NSString*)message;
+ (NSString*) getVideoFileName;
+ (void)deleteOlderFile;
+ (NSTimeInterval) getSwipeTime;
+ (int) getCurrentView;
+ (void) setCurrentView : (int) value;

//@property (nonatomic, retain) UIImageView *imageView1;
//@property (nonatomic, retain) UIImageView *imageView2;

@end
