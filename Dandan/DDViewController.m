//
//  DDViewController.m
//  Dandan
//
//  Created by Zhuoshi Sun on 3/29/12.
//  Copyright (c) 2012 Intel. All rights reserved.
//

#import "DDViewController.h"

#import "DDAboutViewController.h"
#import "DDAppDelegate.h"

@interface DDViewController()

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
- (void)showResultAlertView;

@end

@implementation DDViewController

@synthesize leftButton = _leftButton;
@synthesize rightButton = _rightButton;

- (void) dealloc {
    [_maskImage release];
    [_originalLeftImage release];
    [_originalRightImage release];
    [_leftButton release];
    [_rightButton release];
    [super dealloc];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != NULL) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"保存失败了呢" 
                                                             message:nil 
                                                            delegate:nil 
                                                   cancelButtonTitle:nil 
                                                   otherButtonTitles:@"好吧", nil] autorelease];
       [alertView show];
    }
    else {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"保存成功" 
                                                             message:nil 
                                                            delegate:nil 
                                                   cancelButtonTitle:nil 
                                                   otherButtonTitles:@"好的", nil] autorelease];
        [alertView show];
    }    
}

- (void)showResultAlertView {
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"您现在真的眈眈了呢"
                                                        message:nil 
                                                       delegate:nil 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"是哦", nil] autorelease];
    [alertView show];                                            
}

- (IBAction)doAboutButtonTouchUpInside:(id)sender {
    DDAboutViewController *aboutViewController = [[[DDAboutViewController alloc] initWithNibName:@"DDAboutViewController" bundle:nil] autorelease];
    [self presentModalViewController:aboutViewController animated:YES];
}

- (IBAction)doActionButtonTouchUpInside:(id)sender {
    if (_originalLeftImage == [self.leftButton imageForState:UIControlStateNormal]) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"还没选择眈眈的对象哦"
                                                             message:nil 
                                                            delegate:nil 
                                                   cancelButtonTitle:nil 
                                                   otherButtonTitles:@"好的", nil] autorelease];
        [alertView show];                                                    
    }
    else if (_originalRightImage == [self.rightButton imageForState:UIControlStateNormal]) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"还没选择自己的头像哦"
                                                             message:nil 
                                                            delegate:nil 
                                                   cancelButtonTitle:nil 
                                                   otherButtonTitles:@"好的", nil] autorelease];
        [alertView show];                                                            
    }
    else {
        if (_handled) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"您现在已经在眈眈了呢"
                                                                 message:nil 
                                                                delegate:nil 
                                                       cancelButtonTitle:nil 
                                                       otherButtonTitles:@"好的", nil] autorelease];  
            [alertView show];                                                
        }
        else {
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
            _handled = YES;
            [self performSelector:@selector(showResultAlertView) withObject:nil afterDelay:1.5];
        }
    }
}

- (IBAction)doPhotoButtonTouchUpInside:(id)sender {
    _currentPhotoButton = sender;
    UIImagePickerController *imagePickerController = [[[UIImagePickerController alloc] init] autorelease];;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    imagePickerController.allowsEditing = YES;
    imagePickerController.delegate = self;
    [self presentModalViewController: imagePickerController animated: YES];    
}

- (IBAction)doSaveButtonTouchUpInside:(id)sender {
    if (!_handled) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"您还没有眈眈哦"
                                                             message:nil 
                                                            delegate:nil 
                                                   cancelButtonTitle:nil 
                                                   otherButtonTitles:@"好的", nil] autorelease];  
        [alertView show];                                                        
    }
    else {
        UIImage *leftImage = [self.leftButton imageForState:UIControlStateNormal];
        UIImage *rightImage = [self.rightButton imageForState:UIControlStateNormal];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(leftImage.size.width * 2, leftImage.size.height), YES, 1.0);
        [leftImage drawAtPoint:CGPointZero];
        [rightImage drawInRect:CGRectMake(leftImage.size.width, 0.0, leftImage.size.width, leftImage.size.height)];
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageWriteToSavedPhotosAlbum(finalImage, self,
                                       @selector(image:didFinishSavingWithError:contextInfo:), 
                                       nil);            
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [_currentPhotoButton setImage:image forState:UIControlStateNormal];
    _handled = NO;
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
    _maskImage = [[UIImage imageNamed:@"mask"] retain];
    _originalLeftImage = [[self.leftButton imageForState:UIControlStateNormal] retain];    
    _originalRightImage = [[self.rightButton imageForState:UIControlStateNormal] retain];
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
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
}

@end
