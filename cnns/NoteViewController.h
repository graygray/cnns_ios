//
//  NoteViewController.h
//  cnns
//
//  Created by GRAY_LIN on 2013/12/14.
//  Copyright (c) 2013年 graylin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNSTableViewController.h"

@interface NoteViewController : UIViewController {

    GADBannerView *admobView;
    UITextView *cnnsNoteTextView;
    UIWebView *cnnsNoteWebView;
    NSString *cnnsNoteContent;
    
    bool isPortrait;
    CGFloat screenWidth;
    CGFloat screenHeight;
}

@end
