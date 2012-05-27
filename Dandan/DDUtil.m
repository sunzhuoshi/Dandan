//
//  DDUtil.m
//  Dandan
//
//  Created by Zhuoshi Sun on 5/25/12.
//  Copyright (c) 2012 Intel. All rights reserved.
//

#import "DDUtil.h"

void DDSimpleAlert(NSString *title, NSString *buttonTitle) {
    DDSimpleAlert2(title, buttonTitle, nil);
}

void DDSimpleAlert2(NSString *title, NSString *buttonTitle, id<UIAlertViewDelegate> delegate) {
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:title 
                                                         message:nil 
                                                        delegate:delegate 
                                               cancelButtonTitle:nil 
                                               otherButtonTitles:buttonTitle, nil] autorelease];
    [alertView show];    
}