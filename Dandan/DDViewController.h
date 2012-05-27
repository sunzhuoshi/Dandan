//
//  DDViewController.h
//  Dandan
//
//  Created by Zhuoshi Sun on 3/29/12.
//  Copyright (c) 2012 Intel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDViewController : UIViewController<UIImagePickerControllerDelegate, 
        UINavigationControllerDelegate, 
        UIActionSheetDelegate, 
        UIAlertViewDelegate> {
    UIImage *_maskImage;
    UIImage *_originalLeftImage;
    UIImage *_originalRightImage;
    UIButton *_currentPhotoButton;
    UIImage *_finalImage;
    BOOL _rightImageProcessed;
    BOOL _appeared;
    UIAlertView *_processedAlertView;
    UIAlertView *_resetAlertView;
}

@property (nonatomic, retain) IBOutlet UIButton *leftButton;
@property (nonatomic, retain) IBOutlet UIButton *rightButton;
@property (nonatomic, retain) IBOutlet UIButton *saveButton;
@property (nonatomic, retain) IBOutlet UIButton *shareButton;
@property (nonatomic, retain) IBOutlet UIView *photosBackgroundView;

- (IBAction)doAboutButtonTouchUpInside:(id)sender;
- (IBAction)doActionButtonTouchUpInside:(id)sender;
- (IBAction)doPhotoButtonTouchUpInside:(id)sender;
- (IBAction)doSaveButtonTouchUpInside:(id)sender;
- (IBAction)doShareButtonTouchUpInside:(id)sender;

@end
