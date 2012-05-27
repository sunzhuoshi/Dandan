//
//  DDAppDelegate.m
//  Dandan
//
//  Created by Zhuoshi Sun on 3/29/12.
//  Copyright (c) 2012 Intel. All rights reserved.
//

#import "DDAppDelegate.h"

#import "DDViewController.h"

#define APP_KEY @"2700004869"
#define APP_SECRET @"5e89949d6e635cd09d5d1093b7d85a7a"
#define CSS_HACK @"<style>\
    .container::before{\
        background: -webkit-gradient(linear,left top,right top,from(#474747),to(#BEBEBE)) no-repeat;\
    }\
    a.btnP{\
        border: 1px solid #474747;\
        border-bottom-color: #414141;\
        background: -webkit-gradient(linear,left top,left bottom,from(#797979),to(#474747));\
    }\
</style>"

#define KEY_LAST_SINA_WEIBO_TEXT @"LastSinaWeiboText"
#define KEY_LAST_SINA_WEIBO_TIME @"LastSinaWeiboTime"

#define SAME_SINA_WEIBO_INTERVAL 60.0


NSString *const DDShakeNotification = @"DDShakeNotification";

NSString *const DDSinaWeiboDidLogInNotification = @"DDSinaWeiboDidLogInNotification";
NSString *const DDSinaWeiboFailToLogInWithErrorNotification = @"DDSinaWeiboFailToLogInWithErrorNotification";
NSString *const DDSinaWeiboDidLogOutNotification = @"DDSinaWeiboDidLogOutNotification";
NSString *const DDSinaWeiboNotAuthorizedNotification = @"DDSinaWeiboNotAuthorizedNotification";
NSString *const DDSinaWeiboAuthorizeExpiredNotification = @"DDSinaWeiboAuthorizeExpiredNotification";
NSString *const DDSinaWeiboRequestDidFailWithErrorNotification = @"DDSinaWeiboRequestDidFailWithErrorNotification";
NSString *const DDSinaWeiboRequestDidFailWithErrorNotificationErrorKey = @"error";
NSString *const DDSinaWeiboRequestDidSucceedWithResultNotification = @"DDSinaWeiboRequestDidSucceedWithResultNotification"; 
NSString *const DDSinaWeiboRequestDidSucceedWithResultNotificationResultKey = @"result";
NSString *const DDSinaWeiboAuthorizWebViewDidHideNotification = @"WBAuthorizWebViewDidHideNotification"; 

static BOOL IsShaking(UIAcceleration* last, UIAcceleration* current, CGFloat threshold) {
    double deltaX = fabs(last.x - current.x),
    deltaY = fabs(last.y - current.y),
    deltaZ = fabs(last.z - current.z);    
    double speed = sqrt(deltaX*deltaX + deltaY*deltaY + deltaZ*deltaZ) / (current.timestamp-last.timestamp);
    return speed >= threshold;
}

@interface DDAppDelegate()

@end

@implementation DDAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize lastAcceleration = _lastAcceleration;

- (void)dealloc
{
    [_wbEngine release];
    [_lastSinaWeiboText release];
    [_lastSinaWeiboTime release];
    [_window release];
    [_viewController release];
    [_lastAcceleration release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[DDViewController alloc] initWithNibName:@"DDViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    // accelerometer
    [UIAccelerometer sharedAccelerometer].delegate = self;
    
    _wbEngine = [[WBEngine alloc] initWithAppKey:APP_KEY appSecret:APP_SECRET];
    [_wbEngine setRootViewController:self.viewController];
    [_wbEngine setDelegate:self];
    [_wbEngine setRedirectURI:@"http://"];
    [_wbEngine setIsUserExclusive:YES];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

+ (DDAppDelegate *)sharedAppDelegate {
    return (DDAppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (void)logInSinaWeibo {
    [_wbEngine logIn];
}

- (void)logOutSinaWeibo {
    [_wbEngine logOut];
}

- (BOOL)isLoggedInSinaWeibo {
    return [_wbEngine isLoggedIn];
}

- (void)sendSinaWeiboWithText:(NSString *)text image:(UIImage *)image {
    if (_lastSinaWeiboTime && _lastSinaWeiboText) {
        if ([_lastSinaWeiboText isEqualToString:text]) {
            CGFloat interval = [[NSDate date] timeIntervalSinceDate:_lastSinaWeiboTime];
            if (0.0 < interval && SAME_SINA_WEIBO_INTERVAL > interval) {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"/2/statuses/upload.json", @"request",
                                                                                    @"20019", @"error_code",
                                                                                    @"repeat content!", @"error",
                                                                                    nil];
                NSError *error = [NSError errorWithDomain:@"FakeWeiBoSDKErrorDomain" code:100 userInfo:userInfo];                                            
                [[NSNotificationCenter defaultCenter] postNotificationName:DDSinaWeiboRequestDidFailWithErrorNotification 
                                                                    object:_wbEngine 
                                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil]];
                return;
            }
        }
    }
    [_wbEngine sendWeiBoWithText:text image:image];
}

#pragma mark - WBEngineDelegate

- (void)engineDidLogIn:(WBEngine *)engine {
    NSDictionary *lastWeiboInfo = [[NSUserDefaults standardUserDefaults] objectForKey:engine.userID];
    [_lastSinaWeiboText release];
    [_lastSinaWeiboTime release];
    _lastSinaWeiboText = [[lastWeiboInfo objectForKey:KEY_LAST_SINA_WEIBO_TEXT] copy];
    _lastSinaWeiboTime = [[lastWeiboInfo objectForKey:KEY_LAST_SINA_WEIBO_TIME] retain];

    [[NSNotificationCenter defaultCenter] postNotificationName:DDSinaWeiboDidLogInNotification object:engine];
}

- (void)engine:(WBEngine *)engine didFailToLogInWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:DDSinaWeiboFailToLogInWithErrorNotification object:engine];
}

- (void)engineDidLogOut:(WBEngine *)engine {
    [[NSNotificationCenter defaultCenter] postNotificationName:DDSinaWeiboDidLogOutNotification object:engine];
}

- (void)engineNotAuthorized:(WBEngine *)engine {
    [[NSNotificationCenter defaultCenter] postNotificationName:DDSinaWeiboNotAuthorizedNotification object:engine];
}

- (void)engineAuthorizeExpired:(WBEngine *)engine {
    [[NSNotificationCenter defaultCenter] postNotificationName:DDSinaWeiboAuthorizeExpiredNotification object:engine];
}

- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"error"];
    [[NSNotificationCenter defaultCenter] postNotificationName:DDSinaWeiboRequestDidFailWithErrorNotification object:engine userInfo:userInfo];
}

- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result {
    NSString *text = [result objectForKey:@"text"];
    if (text) {
        [_lastSinaWeiboText release];
        _lastSinaWeiboText = [text copy];
        [_lastSinaWeiboTime release];
        _lastSinaWeiboTime = [[NSDate date] retain];
        NSDictionary *lastWeiboInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       _lastSinaWeiboText, KEY_LAST_SINA_WEIBO_TEXT,
                                       _lastSinaWeiboTime, KEY_LAST_SINA_WEIBO_TIME,
                                       nil];
        [[NSUserDefaults standardUserDefaults] setValue:lastWeiboInfo forKey:engine.userID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:result forKey:@"result"];
    [[NSNotificationCenter defaultCenter] postNotificationName:DDSinaWeiboRequestDidSucceedWithResultNotification object:engine userInfo:userInfo];
}

- (void)engine:(WBEngine *)engine authorizeWebViewDidFinishLoad:(UIWebView *)webView {
    NSError *error = nil;
    NSMutableString *script = [NSMutableString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"grayscale" ofType:@"js"] 
                                                               encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    else {
        [script appendString:@"grayscale(document.body);"];
        [script appendString:[NSString stringWithFormat:@"document.getElementById('outer').insertAdjacentHTML('beforebegin', '%@');", CSS_HACK]];
        [webView stringByEvaluatingJavaScriptFromString:script];        
    }
}

- (void)engine:(WBEngine *)engine authorizeWebViewDidFailLoadWithError:(UIWebView *)webView error:(NSError *)error {
    DDSimpleAlert(@"网络出错了，请您稍候再试", @"好吧");
}

#pragma mark - UIAccelerometerDelegate

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{
    if (self.lastAcceleration) {
        if (!_histeresisExcited && IsShaking(self.lastAcceleration, acceleration, 20.0)) {
            _histeresisExcited = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:DDShakeNotification object:nil];
        } else if (_histeresisExcited && !IsShaking(self.lastAcceleration, acceleration, 10.0)) {
            _histeresisExcited = NO;
        }
    }
    self.lastAcceleration = acceleration;
}

@end
