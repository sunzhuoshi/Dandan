//
//  DDViewController.m
//  Dandan
//
//  Created by Zhuoshi Sun on 3/29/12.
//  Copyright (c) 2012 Intel. All rights reserved.
//

#import "DDViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "DDAboutViewController.h"
#import "DDAppDelegate.h"
#import "DDSendSinaWeiboViewController.h"

#define SLIDE_DISTANCE 150.0

typedef enum SlideDirection {
    SlideDirectionIn,
    SlideDirectionOut
} SlideDirection;

@interface DDViewController()

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
- (void)showImagePicker:(UIImagePickerControllerSourceType)source;
- (void)setFinalImage:(UIImage *)image;
- (void)slideButtionsWithDirection:(SlideDirection)slideDirection animated:(BOOL)animated;
- (void)showSendSinaWeiboViewWithImage:(UIImage *)image;
- (void)doDDSinaWeiboDidLogInNotification:(NSNotification *)notification;
- (void)doDDShakeNotification:(NSNotification *)notification;
- (void)reset;

@end

@implementation DDViewController

@synthesize leftButton = _leftButton;
@synthesize rightButton = _rightButton;
@synthesize saveButton = _saveButton;
@synthesize shareButton = _shareButton;
@synthesize photosBackgroundView = _photosBackgroundView;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_maskImage release];
    [_originalLeftImage release];
    [_originalRightImage release];
    [_leftButton release];
    [_rightButton release];
    [_saveButton release];
    [_shareButton release];
    [_photosBackgroundView release];
    [_processedAlertView release];
    [_resetAlertView release];
    [super dealloc];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != NULL) {
        DDSimpleAlert(@"保存失败了 T-T", @"好吧");
    }
    else {
        DDSimpleAlert(@"保存成功 ^_^", @"好的");
    }    
}

- (void)showImagePicker:(UIImagePickerControllerSourceType)source {
    UIImagePickerController *imagePickerController = [[[UIImagePickerController alloc] init] autorelease];;
    imagePickerController.sourceType = source;
    if (UIImagePickerControllerSourceTypeCamera == imagePickerController.sourceType) {
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
    imagePickerController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    imagePickerController.allowsEditing = YES;
    imagePickerController.delegate = self;
    [self presentModalViewController: imagePickerController animated: YES];    
}

- (void)setFinalImage:(UIImage *)image {
   [ _finalImage autorelease];
   _finalImage = [image retain];
}

- (void)slideButtionsWithDirection:(SlideDirection)slideDirection animated:(BOOL)animated {
    CGFloat duration = 0.0;
    if (animated) {
        duration = 0.7;
    }
    [UIView animateWithDuration:duration 
                          delay:0.0 
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGAffineTransform transform = CGAffineTransformIdentity;
                         if (SlideDirectionOut == slideDirection) {
                             transform = CGAffineTransformMakeTranslation(SLIDE_DISTANCE, 0.0);
                         }
                         self.saveButton.transform = transform;
                         self.shareButton.transform = transform;
                     } 
                     completion:^(BOOL finished) {
                     }
     ];
}

- (void)showSendSinaWeiboViewWithImage:(UIImage *)image {
    DDSendSinaWeiboViewController *newViewController = [[[DDSendSinaWeiboViewController alloc] initWithNibName:@"DDSendSinaWeiboViewController" bundle:nil] autorelease];
    [self presentModalViewController:newViewController animated:YES];
    // NOTE: access UIControls after present method called, for view is only loaded after that. by sunzhuoshi
    newViewController.imageView.image = image;    
}

- (void)doDDSinaWeiboDidLogInNotification:(NSNotification *)notification {
    if (_appeared) {
        [self showSendSinaWeiboViewWithImage:_finalImage];
    }
}

- (void)doDDShakeNotification:(NSNotification *)notification {
    if (_appeared) {
        if (_originalLeftImage != [self.leftButton imageForState:UIControlStateNormal] ||
            _originalRightImage != [self.rightButton imageForState:UIControlStateNormal]) {
            [_resetAlertView show];
        }
    }
}

- (void)reset {
    [self slideButtionsWithDirection:SlideDirectionOut animated:YES];
    [self.leftButton setImage:_originalLeftImage forState:UIControlStateNormal];
    [self.rightButton setImage:_originalRightImage forState:UIControlStateNormal];
    _rightImageProcessed = NO;
    [self setFinalImage:nil];
}

- (IBAction)doAboutButtonTouchUpInside:(id)sender {
    DDAboutViewController *aboutViewController = [[[DDAboutViewController alloc] initWithNibName:@"DDAboutViewController" bundle:nil] autorelease];
    [self presentModalViewController:aboutViewController animated:YES];
}

- (IBAction)doActionButtonTouchUpInside:(id)sender {
    if (_originalLeftImage == [self.leftButton imageForState:UIControlStateNormal]) {
        DDSimpleAlert(@"还没选择眈眈的对象哦", @"好的");
    }
    else if (_originalRightImage == [self.rightButton imageForState:UIControlStateNormal]) {
        DDSimpleAlert(@"还没选择自己的头像哦", @"好的");
    }
    else {
        if (_finalImage) {
            DDSimpleAlert(@"您现在已经在眈眈了呢", @"好的");
        }
        else {
            if (!_rightImageProcessed) {
                UIImage *image = [self.rightButton imageForState:UIControlStateNormal];
                UIGraphicsBeginImageContextWithOptions(image.size, YES, 1.0);
                CGRect imageRect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
                // Draw the image with the luminosity blend mode.
                // On top of a white background, this will give a black and white image.
                [image drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0];
                [_maskImage drawInRect:CGRectMake(0.0, 0.0, image.size.width * 0.4, image.size.height) blendMode:kCGBlendModePlusDarker alpha:0.5];
                [_maskImage drawInRect:CGRectMake(0.0, 0.0, image.size.width * 0.3, image.size.height) blendMode:kCGBlendModeNormal alpha:0.9];    
                // Get the resulting image.
                UIImage *filteredImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                [self.rightButton setImage:filteredImage forState:UIControlStateNormal];
                _rightImageProcessed = YES;
            }
            UIImage *leftImage = [self.leftButton imageForState:UIControlStateNormal];
            UIImage *rightImage = [self.rightButton imageForState:UIControlStateNormal];
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(leftImage.size.width * 2, leftImage.size.height), YES, 1.0);
            [leftImage drawAtPoint:CGPointZero];
            [rightImage drawInRect:CGRectMake(leftImage.size.width, 0.0, leftImage.size.width, leftImage.size.height)];
            [self setFinalImage:UIGraphicsGetImageFromCurrentImageContext()];
            UIGraphicsEndImageContext();           
            [_processedAlertView show];
        }
    }
}

- (IBAction)doPhotoButtonTouchUpInside:(id)sender {
    _currentPhotoButton = sender;
    if (_leftButton == sender) {
        [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];        
    }
    else if (_rightButton == sender) {
        UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"请选择自己的头像" 
                                                                  delegate:self 
                                                         cancelButtonTitle:@"取消" 
                                                    destructiveButtonTitle:nil 
                                                         otherButtonTitles:@"相册", @"拍照", nil] autorelease];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;                                                        
        [actionSheet showInView:self.view];                                                        
    }
}

- (IBAction)doSaveButtonTouchUpInside:(id)sender {
    if (!_finalImage) {
        DDSimpleAlert(@"您还没有眈眈哦", @"好的");
    }
    else {
        UIImageWriteToSavedPhotosAlbum(_finalImage, self,
                                       @selector(image:didFinishSavingWithError:contextInfo:), 
                                       nil);            
    }
}

- (IBAction)doShareButtonTouchUpInside:(id)sender {
    if (![[DDAppDelegate sharedAppDelegate] isLoggedInSinaWeibo]) {
        [[DDAppDelegate sharedAppDelegate] logInSinaWeibo];
    }
    else {
        [self showSendSinaWeiboViewWithImage:_finalImage];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [_currentPhotoButton setImage:image forState:UIControlStateNormal];
    if (self.rightButton == _currentPhotoButton) {
        _rightImageProcessed = NO;
    }
    [self setFinalImage:nil];
    [self slideButtionsWithDirection:SlideDirectionOut animated:YES];    
    [picker dismissModalViewControllerAnimated:YES];
    [UIApplication sharedApplication].statusBarHidden = YES;        
    self.view.frame = [UIScreen mainScreen].applicationFrame;        
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
    [UIApplication sharedApplication].statusBarHidden = YES;  
    self.view.frame = [UIScreen mainScreen].applicationFrame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _maskImage = [[UIImage imageNamed:@"Mask"] retain];
    _originalLeftImage = [[self.leftButton imageForState:UIControlStateNormal] retain];    
    _originalRightImage = [[self.rightButton imageForState:UIControlStateNormal] retain];
    [self slideButtionsWithDirection:SlideDirectionOut animated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doDDSinaWeiboDidLogInNotification:) name:DDSinaWeiboDidLogInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doDDShakeNotification:) name:DDShakeNotification object:nil];
    // set shadow effect of the photos' background view 
    CALayer *layer = [self.photosBackgroundView layer];
    [layer setShadowColor:[UIColor blackColor].CGColor];
    [layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [layer setShadowOpacity:0.5]; 
    [layer setShadowRadius:3.0];    
    
    _processedAlertView = [[UIAlertView alloc] initWithTitle:@"您现在真的眈眈了呢" 
                                                     message:nil 
                                                    delegate:self 
                                           cancelButtonTitle:nil 
                                           otherButtonTitles:@"是哦", nil];

    _resetAlertView = [[UIAlertView alloc] initWithTitle:@"您要重置眈眈么？" 
                                                 message:nil 
                                                delegate:self 
                                       cancelButtonTitle:nil 
                                       otherButtonTitles:@"不", @"重置", nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _appeared = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    _appeared = NO;    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case 1:
            [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
            break;
        case 2:
            break;
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (_processedAlertView == alertView) {
        [self slideButtionsWithDirection:SlideDirectionIn animated:YES];
    }
    else if (_resetAlertView == alertView) {
        if (1 == buttonIndex) {
            [self reset];
        }
    }
}

@end
