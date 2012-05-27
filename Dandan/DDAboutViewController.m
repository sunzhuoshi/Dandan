//
//  DDAboutViewController.m
//  Dandan
//
//  Created by Zhuoshi Sun on 3/30/12.
//  Copyright (c) 2012 Intel. All rights reserved.
//

#import "DDAboutViewController.h"

#import "DDAppDelegate.h"

#define EVENT_URL @"http://weibo.com/1640571365/ybPWJdXn9"
#define VERSION_FORMAT @"version %@, thanks to James Padolsey for his grayscale script"

@interface DDAboutViewController() 

- (void)doDDSinaWeiboDidLogInNotification:(NSNotification *)notification;
- (void)doDDSinaWeiboFailToLogInWithErrorNotification:(NSNotification *)notification;

@end

@implementation DDAboutViewController

@synthesize bindSinaWeiboSwitch = _bindSinaWeiboSwitch;
@synthesize versionLabel = _versionLabel;

- (void)dealloc {
    [_bindSinaWeiboSwitch release];
    [_versionLabel release];
    [super dealloc];
}

- (IBAction)doBackBarButtonItemAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)doLaoluoButtonTouchUpInside:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:EVENT_URL]];
}

- (IBAction)doBindSinaWeiboSwitchValueChanged:(id)sender {
    if (self.bindSinaWeiboSwitch.on) {
        self.bindSinaWeiboSwitch.on = NO;
        [[DDAppDelegate sharedAppDelegate] logInSinaWeibo];
    }
    else {
        [[DDAppDelegate sharedAppDelegate] logOutSinaWeibo];
        DDSimpleAlert(@"解除绑定成功", @"好的");
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"关于眈眈";
    self.versionLabel.text = [NSString stringWithFormat:VERSION_FORMAT, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    self.bindSinaWeiboSwitch.on = [[DDAppDelegate sharedAppDelegate] isLoggedInSinaWeibo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doDDSinaWeiboDidLogInNotification:) name:DDSinaWeiboDidLogInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doDDSinaWeiboFailToLogInWithErrorNotification:) name:DDSinaWeiboFailToLogInWithErrorNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}    

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIDeviceOrientationLandscapeRight);
}

- (void)doDDSinaWeiboDidLogInNotification:(NSNotification *)notification {
    self.bindSinaWeiboSwitch.on = YES;
    DDSimpleAlert(@"绑定成功", @"好的");
}

- (void)doDDSinaWeiboFailToLogInWithErrorNotification:(NSNotification *)notification {
    NSError *error = notification.object;
    NSString *title = [NSString stringWithFormat:@"绑定失败了，错误代码：%d", error.code];
    DDSimpleAlert(title, @"好吧");
}

@end
