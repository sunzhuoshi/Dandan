//
//  DDSendSinaWeiboViewController.m
//  Dandan
//
//  Created by Zhuoshi Sun on 5/22/12.
//  Copyright (c) 2012 Intel. All rights reserved.
//

#import "DDSendSinaWeiboViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "DDAppDelegate.h"

#define DEFAULT_KEYBOARD_HEIGHT 162.0
//#define WEIBO_DEFAULT_TEXT @"#给方舟子一个眈眈#我也不是不会眈眈哦"
#define WEIBO_DEFAULT_TEXT @"我也不是不会眈眈哦"
#define WEIBO_MAX_TEXT_LENGTH 140
#define TITLE_FORMAT @"新浪微博(%d)"

@interface DDSendSinaWeiboViewController ()

- (void)doUIKeyboardWillShow:(NSNotification *)notification;
- (void)updateNavigationItemTitle;
- (void)showActivityIndicator:(BOOL)visible;
- (void)showKeyboard:(BOOL)visible;
- (void)doDDSinaWeiboRequestDidFailWithErrorNotification:(NSNotification *)notification;
- (void)doDDSinaWeiboRequestDidSucceedWithResultNotification:(NSNotification *)notification;
- (void)doDDSinaWeiboAuthorizeExpiredNotification:(NSNotification *)notification;
- (void)doDDSinaWeiboNotAuthorizedNotification:(NSNotification *)notification;
- (void)doDDSinaWeiboDidLogInNotification:(NSNotification *)notification;
- (void)doDDSinaWeiboAuthorizWebViewDidHideNotification:(NSNotification *)notification;
- (NSInteger)characterLeft;

@end

@implementation DDSendSinaWeiboViewController

@synthesize imageView = _imageView;
@synthesize textViewBackgroundView = _textViewBackgroundView;
@synthesize textView = _textView;
@synthesize myNavigationItem = _myNavigationItem;
@synthesize activityIndicatorBackgroundView = _activityIndicatorBackgroundView;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize sendBarButtonItem = _sendBarButtonItem;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_titleLabel release];
    [_lastWeiboText release];
    [_lastWeiboTime release];
    [_imageView release];
    [_textViewBackgroundView release];
    [_textView release];
    [_myNavigationItem release];
    [_activityIndicatorBackgroundView release];
    [_activityIndicatorView release];
    [_sendBarButtonItem release];
    [super dealloc];
}

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
    [super viewDidLoad];
    // read the original height of text view's background view to adjust its height according to keyboard height
    _textViewBackgroundViewOriginalHeight = self.textViewBackgroundView.frame.size.height;
    // set image view's effect
    CALayer *layer = [self.imageView layer];
    [layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [layer setBorderWidth:5.0];
    [layer setShadowColor:[UIColor blackColor].CGColor];
    [layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [layer setShadowOpacity:0.5]; 
    [layer setShadowRadius:3.0];
    
    self.textView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(doUIKeyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
    self.textView.text = WEIBO_DEFAULT_TEXT;
    
    CGRect frame = CGRectMake(0, 0, 400, 44);
    _titleLabel = [[UILabel alloc] initWithFrame:frame];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    self.myNavigationItem.titleView = _titleLabel;    
    
    [self updateNavigationItemTitle];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
 
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showKeyboard:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doDDSinaWeiboRequestDidFailWithErrorNotification:) 
                                                 name:DDSinaWeiboRequestDidFailWithErrorNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(doDDSinaWeiboRequestDidSucceedWithResultNotification:) 
                                                 name:DDSinaWeiboRequestDidSucceedWithResultNotification 
                                               object:nil];                                        
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(doDDSinaWeiboAuthorizeExpiredNotification:) 
                                                 name:DDSinaWeiboAuthorizeExpiredNotification 
                                               object:nil];                                       
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(doDDSinaWeiboNotAuthorizedNotification:) 
                                                 name:DDSinaWeiboNotAuthorizedNotification 
                                               object:nil];               
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(doDDSinaWeiboDidLogInNotification:) 
                                                 name:DDSinaWeiboDidLogInNotification 
                                               object:nil];               
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(doDDSinaWeiboAuthorizWebViewDidHideNotification:) 
                                                 name:DDSinaWeiboAuthorizWebViewDidHideNotification 
                                               object:nil];                                                             
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:DDSinaWeiboRequestDidFailWithErrorNotification 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:DDSinaWeiboRequestDidSucceedWithResultNotification 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:DDSinaWeiboAuthorizeExpiredNotification 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:DDSinaWeiboNotAuthorizedNotification 
                                                  object:nil];                                                  
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:DDSinaWeiboDidLogInNotification 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:DDSinaWeiboAuthorizWebViewDidHideNotification 
                                                  object:nil];                                                                                                                                                        
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIDeviceOrientationLandscapeRight);
}

- (IBAction)doCancelBarButtonItemAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)doSendBarButtonItemAction:(id)sender {
    [self showActivityIndicator:YES];
    [[DDAppDelegate sharedAppDelegate] sendSinaWeiboWithText:self.textView.text image:self.imageView.image];
}

- (void)doUIKeyboardWillShow:(NSNotification *)notification {
    CGSize keyboardEndSize = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat delta = keyboardEndSize.width - DEFAULT_KEYBOARD_HEIGHT;
    self.textViewBackgroundView.frame = CGRectMake(self.textViewBackgroundView.frame.origin.x, 
                                     self.textViewBackgroundView.frame.origin.y, 
                                     self.textViewBackgroundView.frame.size.width, 
                                     _textViewBackgroundViewOriginalHeight-delta);
}

- (void)updateNavigationItemTitle {
    NSInteger characterLeft = [self characterLeft];
    _titleLabel.text = [NSString stringWithFormat:TITLE_FORMAT, characterLeft];        
    if (0 > characterLeft) {
        _titleLabel.textColor = [UIColor redColor];
    }
    else {
        _titleLabel.textColor = [UIColor whiteColor];
    }
}

- (void)showActivityIndicator:(BOOL)visible {
    if (!visible) {
        self.activityIndicatorBackgroundView.hidden = YES;
        [self.activityIndicatorView stopAnimating];
        [self showKeyboard:YES];        
    }
    else {
        self.activityIndicatorBackgroundView.hidden = NO;
        [self.activityIndicatorView startAnimating];
        [self showKeyboard:NO];        
    }
}

- (void)showKeyboard:(BOOL)visible {
    if (visible) {
        [self.textView becomeFirstResponder];
    }
    else {
        [self.textView resignFirstResponder];
        self.textViewBackgroundView.frame = CGRectMake(self.textViewBackgroundView.frame.origin.x, 
                                                       self.textViewBackgroundView.frame.origin.y,
                                                       self.textViewBackgroundView.frame.size.width,
                                                       _textViewBackgroundViewOriginalHeight);
    }
}

- (void)doDDSinaWeiboRequestDidFailWithErrorNotification:(NSNotification *)notification {
    [self showActivityIndicator:NO];
    NSError *error = [notification.userInfo objectForKey:DDSinaWeiboRequestDidFailWithErrorNotificationErrorKey];
    NSString *sinaErrorCode = [error.userInfo objectForKey:@"error_code"];
    NSString *alertTitle = @"分享失败了 T-T";
    if (sinaErrorCode) {
        switch ([sinaErrorCode integerValue]) {
            case 20019:
                alertTitle = @"您刚发过相同文字内容的微博,\n请修改后再发送";
                break;
            default:
                alertTitle = [NSString stringWithFormat:@"分享失败了 T_T,\n错误代码: %@", sinaErrorCode]; 
                break;
        }
    }
    DDSimpleAlert(alertTitle, @"好吧");
}

- (void)doDDSinaWeiboRequestDidSucceedWithResultNotification:(NSNotification *)notification {
    [self showActivityIndicator:NO];
    [self dismissModalViewControllerAnimated:YES];
    DDSimpleAlert(@"分享成功 ^_^", @"好的");    
}

- (void)doDDSinaWeiboAuthorizeExpiredNotification:(NSNotification *)notification {
    [self showActivityIndicator:NO];
    [self showKeyboard:NO];
    [[DDAppDelegate sharedAppDelegate] logInSinaWeibo];
}

- (void)doDDSinaWeiboNotAuthorizedNotification:(NSNotification *)notification {
    [self showActivityIndicator:NO];
    [self showKeyboard:NO];    
    [[DDAppDelegate sharedAppDelegate] logInSinaWeibo];
}

- (void)doDDSinaWeiboDidLogInNotification:(NSNotification *)notification {
    [self doSendBarButtonItemAction:nil];
}

- (void)doDDSinaWeiboAuthorizWebViewDidHideNotification:(NSNotification *)notification {
    [self showKeyboard:YES];    
}

- (NSInteger)characterLeft {
    return WEIBO_MAX_TEXT_LENGTH - [self.textView.text length];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    NSInteger characterLeft = [self characterLeft];
    if (0 > characterLeft) {
        self.sendBarButtonItem.enabled = NO;
    }
    else {
        self.sendBarButtonItem.enabled = YES;
    }
    [self updateNavigationItemTitle];
}

@end
