//
//  DDAboutViewController.h
//  Dandan
//
//  Created by Zhuoshi Sun on 3/30/12.
//  Copyright (c) 2012 Intel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDAboutViewController : UIViewController

@property (nonatomic, retain) IBOutlet UISwitch *bindSinaWeiboSwitch;
@property (nonatomic, retain) IBOutlet UILabel *versionLabel;

- (IBAction)doBackBarButtonItemAction:(id)sender;
- (IBAction)doLaoluoButtonTouchUpInside:(id)sender;
- (IBAction)doBindSinaWeiboSwitchValueChanged:(id)sender;

@end
