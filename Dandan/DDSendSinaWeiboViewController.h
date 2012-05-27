//
//  DDSendSinaWeiboViewController.h
//  Dandan
//
//  Created by Zhuoshi Sun on 5/22/12.
//  Copyright (c) 2012 Intel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDSendSinaWeiboViewController : UIViewController<UITextViewDelegate> {
    CGFloat _textViewBackgroundViewOriginalHeight;
    UILabel *_titleLabel;
    NSString *_lastWeiboText;
    NSDate *_lastWeiboTime;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIView *textViewBackgroundView;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UINavigationItem *myNavigationItem;
@property (nonatomic, retain) IBOutlet UIView *activityIndicatorBackgroundView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *sendBarButtonItem;

- (IBAction)doCancelBarButtonItemAction:(id)sender;
- (IBAction)doSendBarButtonItemAction:(id)sender;

@end
