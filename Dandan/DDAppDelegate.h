//
//  DDAppDelegate.h
//  Dandan
//
//  Created by Zhuoshi Sun on 3/29/12.
//  Copyright (c) 2012 Intel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDViewController;

#import "WBEngine.h"

@interface DDAppDelegate : UIResponder <UIApplicationDelegate, WBEngineDelegate, UIAccelerometerDelegate> {
    WBEngine *_wbEngine;
    BOOL _histeresisExcited;
    NSString *_lastSinaWeiboText;
    NSDate *_lastSinaWeiboTime;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DDViewController *viewController;
@property (strong, nonatomic) UIAcceleration *lastAcceleration;

+ (DDAppDelegate *)sharedAppDelegate;
- (void)logInSinaWeibo;
- (void)logOutSinaWeibo;
- (BOOL)isLoggedInSinaWeibo;
- (void)sendSinaWeiboWithText:(NSString *)text image:(UIImage *)image;

@end

extern NSString *const DDShakeNotification;

extern NSString *const DDSinaWeiboDidLogInNotification;
extern NSString *const DDSinaWeiboFailToLogInWithErrorNotification;
extern NSString *const DDSinaWeiboDidLogOutNotification;
extern NSString *const DDSinaWeiboNotAuthorizedNotification;
extern NSString *const DDSinaWeiboAuthorizeExpiredNotification;
extern NSString *const DDSinaWeiboRequestDidFailWithErrorNotification;
extern NSString *const DDSinaWeiboRequestDidFailWithErrorNotificationErrorKey;
extern NSString *const DDSinaWeiboRequestDidSucceedWithResultNotification; 
extern NSString *const DDSinaWeiboRequestDidSucceedWithResultNotificationResultKey;
extern NSString *const DDSinaWeiboAuthorizWebViewDidHideNotification; 

