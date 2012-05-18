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
    UIImage *_originalLeftImage;    
    UIImage *_originalRightImage;
    UIButton *_currentPhotoButton;
    BOOL _handled;
}

@property (nonatomic, retain) IBOutlet UIButton *leftButton;
@property (nonatomic, retain) IBOutlet UIButton *rightButton;

- (IBAction)doAboutButtonTouchUpInside:(id)sender;
- (IBAction)doActionButtonTouchUpInside:(id)sender;
- (IBAction)doPhotoButtonTouchUpInside:(id)sender;
- (IBAction)doSaveButtonTouchUpInside:(id)sender;

@end
