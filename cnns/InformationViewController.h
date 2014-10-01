//
//  InformationViewController.h
//  cnns
//
//  Created by GRAY_LIN on 2013/12/29.
//  Copyright (c) 2013年 graylin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNSTableViewController.h"

@interface InformationViewController : UIViewController {

    GADBannerView *admobView;
    UITextView *cnnsInformationTextView;
    UIWebView *cnnsInformationWebView;

    bool isPortrait;
    CGFloat screenWidth;
    CGFloat screenHeight;
}

@end
