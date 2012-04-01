//
//  DDViewController.h
//  Dandan
//
//  Created by Zhuoshi Sun on 3/29/12.
//  Copyright (c) 2012 Intel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIImage *_maskImage;
    UIImage *_originalRightImage;
}

@property (nonatomic, retain) IBOutlet UIImageView *leftImageView;
@property (nonatomic, retain) IBOutlet UIImageView *rightImageView;

- (IBAction)doAboutButtonTouchUpInside:(id)sender;
- (IBAction)doActionButtonTouchUpInside:(id)sender;
- (IBAction)doSaveButtonTouchUpInside:(id)sender;

@end
