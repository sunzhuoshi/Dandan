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

@synthesize leftImageView = _leftImageView;
@synthesize rightImageView = _rightImageView;

- (void) dealloc {
    [_maskImage release];
    [_originalRightImage release];
    [_leftImageView release];
    [_rightImageView release];
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
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"您现在真的耽耽了呢"
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
    UIImagePickerController *imagePickerController = [[[UIImagePickerController alloc] init] autorelease];;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    imagePickerController.allowsEditing = YES;
    imagePickerController.delegate = self;
    [self presentModalViewController: imagePickerController animated: YES];        
}

- (IBAction)doSaveButtonTouchUpInside:(id)sender {
    if (_originalRightImage != self.rightImageView.image) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.leftImageView.image.size.width * 2, self.leftImageView.image.size.height), YES, 1.0);
        [self.leftImageView.image drawAtPoint:CGPointZero];
        [self.rightImageView.image drawInRect:CGRectMake(self.leftImageView.image.size.width, 0.0, self.leftImageView.image.size.width, self.leftImageView.image.size.height)];
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageWriteToSavedPhotosAlbum(finalImage, self,
                                       @selector(image:didFinishSavingWithError:contextInfo:), 
                                       nil);    
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {

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

    self.rightImageView.image = filteredImage;
    [picker dismissModalViewControllerAnimated:YES];
    [UIApplication sharedApplication].statusBarHidden = YES;    
    [self performSelector:@selector(showResultAlertView) withObject:nil afterDelay:1.5];
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
    _originalRightImage = [self.rightImageView.image retain];
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
