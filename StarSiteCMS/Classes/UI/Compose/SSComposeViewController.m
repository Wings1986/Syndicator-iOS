//
//  SSComposeViewController.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSComposeViewController.h"
#import "SSDashboardViewController.h"
#import "SSCurateViewController.h"
#import "SSPostViewController.h"
#import "AppTakeVideoViewController.h"


@interface SSComposeViewController ()

@end

@implementation SSComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _lockBtn = NO;
    if(_curtain){
        [_curtain removeFromSuperview];
    }
    [self layoutUI];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if([_session isRunning])
        [_session stopRunning];
    [self turnOffTorch];
}

-(void)layoutUI{
    if(_didLayout){
        [_session stopRunning];
        [_session startRunning];
        return;
    }
    _didLayout = YES;
    
    [_topNav hideBack:YES];
    _btnRecord.layer.cornerRadius = _btnRecord.width/2;
    _btnRecord.backgroundColor = [UIColor colorWithHexString:COLOR_GOLD];
    
    _btnRecordInner.layer.cornerRadius = _btnRecordInner.width/2;
    _btnRecordInner.layer.borderColor = [UIColor colorWithHexString:@"#000000"].CGColor;
    _btnRecordInner.layer.borderWidth = 4;
    _btnRecordInner.backgroundColor = [UIColor colorWithHexString:@"FFFFFF"];
    
    _lastImagePreview.clipsToBounds = YES;
    _lastImagePreview.layer.cornerRadius = 3;
    _lastImagePreview.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5].CGColor;
    _lastImagePreview.layer.borderWidth = 1;
    
    _btnExisting.layer.cornerRadius = 3;
    
    float arrowHeight = 8.0;
    float arrowWidth = 12.0;
    _labelDot.width = arrowWidth;
    _labelDot.height = arrowHeight;
    _upArrow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, arrowWidth, arrowHeight)];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,NULL,0.0,arrowHeight);
    CGPathAddLineToPoint(path, NULL, arrowWidth/2, 0.0f);
    CGPathAddLineToPoint(path, NULL, arrowWidth, arrowHeight);
    CGPathAddLineToPoint(path, NULL, 0.0f, arrowHeight);
    
    CAShapeLayer *arrowShapeLayer = [CAShapeLayer layer];
    [arrowShapeLayer setPath:path];
    [arrowShapeLayer setFillColor:_labelDot.backgroundColor.CGColor];
    [arrowShapeLayer setBounds:CGRectMake(0.0f, 0.0f, arrowWidth, arrowHeight)];
    [arrowShapeLayer setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    CGPathRelease(path);
    
    [_upArrow.layer addSublayer:arrowShapeLayer];
    [_labelDot addSubview:_upArrow];
    _labelDot.backgroundColor = [UIColor clearColor];
    _labelDot.clipsToBounds = YES;
    _labelDot.y = _btnPhoto.y + _btnPhoto.height/2 + 10;
    _videoRecordingView.alpha = 0;
    
    _btnLines.layer.cornerRadius = 5;
    _btnLines.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];

     
    
    [self togglePhotoVideo:_btnVideo];
    int overflow = 0;
    
    _contentView.height =_contentView.width + overflow;
    _controlsView.y = _contentView.maxY - overflow;
    _controlsView.height = self.view.height - _controlsView.y;
    
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            
            if (alAsset) {
                ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                *stop = YES; *innerStop = YES;
                
                _lastImagePreview.image = latestPhoto;
//                [self sendTweet:latestPhoto];
            }
        }];
    } failureBlock: ^(NSError *error) {
    
        NSLog(@"No groups");
    }];
    
    
    UIImage *i = [VTUtils radialGradientImage:CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2];
    

    //   UIImage *i = [VTUtils radialGradientImage:CGSizeMake(self.view.width, self.view.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2];

    _backgroundView1 = [[UIImageView alloc] initWithImage:i];
    [self.view insertSubview:_backgroundView1 belowSubview:_contentView];

    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDetected:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeRecognizer];
    
    _currentlyReaching.text = [SSAppController sharedInstance].currentChannel.totalReachDisplay;
    _currentlyReaching.hidden = YES;
    [self animateSceneIn];
    
    _curtain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    _curtain.backgroundColor = [UIColor blackColor];
    _curtainIcon = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _curtain.width, _curtain.height)];
    _curtainIcon.text = @"~";
    _curtainIcon.font = [UIFont fontWithName:FONT_ICONS size:144];
    _curtainIcon.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    [_curtainIcon sizeToFit];
    _curtainIcon.x = _curtain.width/2 - _curtainIcon.width/2;
    _curtainIcon.y = _curtain.height/2 - _curtainIcon.height/2;
    [_curtain addSubview:_curtainIcon];
    
    _focusRing.width = _focusRing.height = 90;
    _focusRing.layer.cornerRadius = 10;
    _focusRing.layer.borderColor = [UIColor colorWithHexString:COLOR_GOLD].CGColor;
    _focusRing.layer.borderWidth = 1;
    _focusRing.backgroundColor = [UIColor clearColor];
    _focusRing.alpha = 0;
    
    [AFOpenGLManager beginOpenGLLoad];

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initializeCamera];
    });
    
}


- (void)swipeDetected:(UISwipeGestureRecognizer *)sender {
    [self gotoDash];
}

-(void)animateSceneIn{
    
    _contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
    int endingY = _controlsView.y;
    int endingBottomY = _bottomView.y;
    _bottomView.y += 200;
    _controlsView.y += 200;
    
    [UIView animateWithDuration:0.7 delay:1 usingSpringWithDamping:0.65 initialSpringVelocity:2 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _contentView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         
                         _currentlyReaching.hidden = NO;
                         _currentlyReaching.x = self.view.width;
                         
                         [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.88 initialSpringVelocity:1 options:UIViewAnimationOptionTransitionNone
                                          animations:^{
                                              _currentlyReaching.x = self.view.width - _currentlyReaching.width - 10;
                                          } completion:^(BOOL finished) {
                                              [_contentView.layer removeAllAnimations];
                                          }];
                         
                     }];
    
    
    [UIView animateWithDuration:0.9 delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _controlsView.y = endingY;
                         _bottomView.y = endingBottomY;
                     } completion:^(BOOL finished) {
                     }];
    
    

    UITapGestureRecognizer *focusTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusOnTap:)];
    focusTap.numberOfTapsRequired = 1;
    [_contentView addGestureRecognizer:focusTap];
    _contentView.userInteractionEnabled = YES;
}






- (void)initializeCamera{
    
    
#if TARGET_IPHONE_SIMULATOR
    return;
#endif

    
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:nil];
   
    [inputDevice lockForConfiguration:nil];
    [inputDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    if ([inputDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
        [inputDevice setExposureMode:AVCaptureExposureModeAutoExpose];
    }
    [inputDevice unlockForConfiguration];
    
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{ AVVideoCodecKey : AVVideoCodecJPEG};
    [_stillImageOutput setOutputSettings:outputSettings];
    
    _session = [[AVCaptureSession alloc] init];
    NSString* preset = 0;
    if (!preset) {
        preset = AVCaptureSessionPresetHigh;
    }
    
    [_session beginConfiguration];
    _session.sessionPreset = preset;
    if ([_session canAddInput:_videoDeviceInput]) {
        [_session addInput:_videoDeviceInput];
    }
    if ([_session canAddOutput:_stillImageOutput]) {
        [_session addOutput:_stillImageOutput];
    }
    [self setFlashMode:AVCaptureFlashModeOff forDevice:[_videoDeviceInput device]];
    [_session commitConfiguration];
    
    //handle prevLayer
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    }

    _previewLayer.frame = _contentView.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_contentView.layer addSublayer: _previewLayer];
    [_session startRunning];
}

-(void)focusOnTap:(UITapGestureRecognizer *)touch{
    
    CGPoint touchPoint = [touch locationInView:touch.view];
    NSLog(@"touchPoint: %fx%f",touchPoint.x,touchPoint.y);

    [_focusRing.layer removeAllAnimations];
    _focusRing.alpha = 1;
    _focusRing.transform = CGAffineTransformIdentity;
    _focusRing.x = touchPoint.x - _focusRing.width/2;
    _focusRing.y = touchPoint.y - _focusRing.height/2;
    _focusRing.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _focusRing.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         _focusRing.alpha = 0;
                     }];
    [_contentView addSubview:_focusRing];
    [self focus:touchPoint];
}

- (void) focus:(CGPoint) aPoint;{

    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [captureDeviceClass defaultDeviceWithMediaType:AVMediaTypeVideo];
        if([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                NSLog(@"try 1");

            CGRect screenRect = [[UIScreen mainScreen] bounds];
            double screenWidth = screenRect.size.width;
            double screenHeight = screenRect.size.height;
            double focus_x = aPoint.x/screenWidth;
            double focus_y = aPoint.y/screenHeight;
            if([device lockForConfiguration:nil]) {
                [device setFocusPointOfInterest:CGPointMake(focus_x,focus_y)];
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
                    [device setExposureMode:AVCaptureExposureModeAutoExpose];
                }
                [device unlockForConfiguration];
            }
        }
    }
}


-(void)capturePhoto{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         
         NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *takenImage = [UIImage imageWithData:jpegData];
         
         CGRect outputRect = [_previewLayer metadataOutputRectOfInterestForRect:_previewLayer.bounds];
         CGImageRef takenCGImage = takenImage.CGImage;
         size_t width = CGImageGetWidth(takenCGImage);
         size_t height = CGImageGetHeight(takenCGImage);
         CGRect cropRect = CGRectMake(outputRect.origin.x * width, outputRect.origin.y * height, outputRect.size.width * width, outputRect.size.height * height);
         
         CGImageRef cropCGImage = CGImageCreateWithImageInRect(takenCGImage, cropRect);
         takenImage = [UIImage imageWithCGImage:cropCGImage scale:1 orientation:takenImage.imageOrientation];
         CGImageRelease(cropCGImage);
         
         UIGraphicsBeginImageContext(takenImage.size);
         [takenImage drawAtPoint:CGPointZero];
         takenImage = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         _currentImage = takenImage;
         [self gotoPostWithCurrentImage];
     }];
}


- (void)displayEditorForImage:(UIImage *)imageToEdit{

    [self turnOffTorch];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AFPhotoEditorController setAPIKey:AVIERY_KEY secret:AVIERY_SECRET];
        [AFPhotoEditorCustomization setLeftNavigationBarButtonTitle:kAFLeftNavigationTitlePresetCancel];
        [AFPhotoEditorCustomization setRightNavigationBarButtonTitle:kAFRightNavigationTitlePresetNext];
//        [AFPhotoEditorCustomization setCropToolCustomEnabled:NO];
//        [AFPhotoEditorCustomization setCropToolInvertEnabled:NO];
//        [AFPhotoEditorCustomization setCropToolOriginalEnabled:NO];
        
        // Set the tools to Contrast, Brightness, Enhance, and Crop (to be displayed in that order).
//        [AFPhotoEditorCustomization setToolOrder:@[kAFEnhance,kAFEffects kAFStickers kAFOrientation kAFCrop kAFAdjustments kAFSharpness kAFDraw kAFText kAFRedeye kAFWhiten kAFBlemish kAFMeme kAFFrames; kAFFocus]];
    });
    
    _editorController = [[AFPhotoEditorController alloc] initWithImage:imageToEdit];
    [_editorController setDelegate:self];
    [[SSAppController sharedInstance].navController presentViewController:_editorController animated:NO completion:^{
            [_loadingFiltersCurtain removeFromSuperview];
    }];
}

- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image{
    [[SSAppController sharedInstance].navController dismissViewControllerAnimated:NO completion:nil];
    [self gotoPostViewWithImage:image andVideoURL:nil withThumbsArray:nil];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor{
    [[SSAppController sharedInstance].navController dismissViewControllerAnimated:NO completion:nil];
    _previewLayer.hidden = NO;
}

-(void)gotoPostWithCurrentImage{
    _loadingFiltersCurtain.width = self.view.width;
    _loadingFiltersCurtain.height = self.view.height;
    _previewImage.width = _previewImage.height = _loadingFiltersCurtain.width;
    _previewImage.image = _currentImage;
    [self.view addSubview:_loadingFiltersCurtain];
    _previewLayer.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self displayEditorForImage:_currentImage];
    });
}


-(void)gotoPostViewWithImage:(UIImage *)image andVideoURL:(NSURL *)videoURL withThumbsArray:(NSArray *)thumbs{
    SSPostViewController *vc = [[SSPostViewController alloc] initWithNibName:@"SSPostViewController" bundle:nil];
    vc.capturedImage = image;
    vc.isVideo = _btnVideo.selected;
    vc.videoURL = videoURL;
    vc.videoThumbs = thumbs;
    [[SSAppController sharedInstance].navController pushViewController:vc animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _previewLayer.hidden = NO;
    });
}

- (IBAction)loadExistingPicker {
    _curtainIcon.y = _curtain.height/2;
    [self.view addSubview:_curtain];
        _curtain.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        _curtain.alpha = 1;
        _curtainIcon.y = _curtain.height/2 - _curtainIcon.height/2;
    } completion:^(BOOL finished) {
        
    }];
    
    if(_btnVideo.selected){
        
        UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.videoQuality = UIImagePickerControllerQualityTypeHigh;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
        cameraUI.allowsEditing = YES;
        cameraUI.delegate = self;
        
        [self presentViewController:cameraUI animated:YES completion:nil];
        
    }else{
        if(!_imagePicker){
            _imagePicker = [[VTImagePicker alloc] init];
            _imagePicker.delegateViewController = self;
        }
        [_imagePicker pickFromLibrary];
    }
}


- (void)imagePickedForAvatarPreview:(UIImage *)image{
    _currentImage = image;
    [self gotoPostWithCurrentImage];
}

- (IBAction)gotoDash {
    [[SSAppController sharedInstance] routeToDashboard];
}

- (IBAction)gotoCurated {
    [[SSAppController sharedInstance] routeToCurated];
}


- (IBAction)togglePhotoVideo:(UIButton *)sender {
    
    
    if(sender == _btnPhoto){
        _btnPhoto.selected = YES;
        _btnVideo.selected = NO;
        _btnRecord.layer.borderColor = [UIColor colorWithHexString:COLOR_GOLD].CGColor;
        _btnRecord.backgroundColor = [UIColor colorWithHexString:COLOR_GOLD];
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             _labelDot.x = sender.center.x - _labelDot.width/2;
//                             _videoRecordingView.alpha = 0;
                         } completion:^(BOOL finished) {
                             
                         }];
        
        
    }else{
        _btnVideo.selected = YES;
        _btnPhoto.selected = NO;
        _btnRecord.layer.borderColor = [UIColor colorWithHexString:@"#FF0000"].CGColor;
        _btnRecord.backgroundColor = [UIColor colorWithHexString:@"#FF0000"];
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             _labelDot.x = sender.center.x  - _labelDot.width/2;
//                             _videoRecordingView.alpha = 1;
                         } completion:^(BOOL finished) {
//                             UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Add Video"] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Video",@"Upload From Folder",nil];
//                             [as showInView:[SSAppController sharedInstance].navController.view];
                             
                         }];
    }
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    int idx = (int)buttonIndex;
    switch(idx){
        case 1: [self gotoRecordVideoFullscreen]; break;
        case 2: [self togglePhotoVideo:_btnPhoto]; break;
            default:
            [self loadExistingPicker]; break;
    }
}




- (void)showVideoPicker{
    
    _cameraUI = [[UIImagePickerController alloc] init];
    _cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    _cameraUI.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    _cameraUI.videoQuality = UIImagePickerControllerQualityTypeHigh;
    _cameraUI.showsCameraControls = YES;
    _cameraUI.modalPresentationStyle = UIModalPresentationCurrentContext;
    _cameraUI.allowsEditing = YES;
    _cameraUI.delegate = self;
    
    [_session stopRunning];

    
    [self presentViewController:_cameraUI animated:NO completion:^(){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
        });
    }];

}

- (IBAction)gotoRecordVideoFullscreen{
    [self showVideoPicker];
    return;
}

- (IBAction)takePhotoVideo {

#if TARGET_IPHONE_SIMULATOR
    [self gotoPostWithCurrentImage];
#endif
    
    if(_btnVideo.selected){
        [self gotoRecordVideoFullscreen];
        
    }else{
        
        if(_lockBtn) return;
        _lockBtn = YES;
        [self capturePhoto];
    }
}

- (void)turnOffTorch{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if([device isTorchActive])
            [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

- (IBAction)toggleTorch {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if([device isTorchActive])
            [device setTorchMode:AVCaptureTorchModeOff];
        else
            [device setTorchMode:AVCaptureTorchModeOn];
        
        [device unlockForConfiguration];
    }
}

- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

-(void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode]){
        _btnTorch.hidden = NO;
        NSError *error = nil;
        if ([device lockForConfiguration:&error]){
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else{
            
            NSLog(@"%@", error);
        }
    }else{
        _btnTorch.hidden = YES;
    }
}

- (IBAction)toggleFrontBackCamera {
    

    AVCaptureDevice *currentVideoDevice = [_videoDeviceInput device];
    AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
    AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
    
    switch (currentPosition)
    {
        case AVCaptureDevicePositionUnspecified:
            preferredPosition = AVCaptureDevicePositionBack;
            break;
        case AVCaptureDevicePositionBack:
            preferredPosition = AVCaptureDevicePositionFront;
            break;
        case AVCaptureDevicePositionFront:
            preferredPosition = AVCaptureDevicePositionBack;
            break;
    }
    
    AVCaptureDevice *videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    
    [_session beginConfiguration];
    
    [_session removeInput:_videoDeviceInput];
    if ([_session canAddInput:videoDeviceInput]){
        [self setFlashMode:AVCaptureFlashModeOff forDevice:videoDevice];
        [_session addInput:videoDeviceInput];
        _videoDeviceInput = videoDeviceInput;
        
    }
    else{
        [_session addInput:_videoDeviceInput];
    }
    
    [_session commitConfiguration];
}





#pragma mark - Camera Delegates
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]){
        
    } else {
        //get the videoURL
        NSURL *fileURL = (NSURL *)[info objectForKey:UIImagePickerControllerMediaURL];
        NSMutableArray *videoThumbs = [self thumbnailsFromVideoAtURL:fileURL];
        UIImage *singleFrameImage = [videoThumbs firstObject];
        _currentImage = singleFrameImage;
        [self gotoPostViewWithImage:_currentImage andVideoURL:fileURL withThumbsArray:videoThumbs];
        
    }

    [self dismissViewControllerAnimated:NO completion:^{
        [_session startRunning];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:NO completion:^{
        [_session stopRunning];
        [_session startRunning];
    }];
}


- (NSMutableArray *)thumbnailsFromVideoAtURL:(NSURL *)url{
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    
    //  Get thumbnail at the very start of the video
    CMTime thumbnailTime = [asset duration];
    int totalTime = (int)CMTimeGetSeconds(thumbnailTime);
    thumbnailTime.value = 0;
    int intervals = 1;
//    if(totalTime > 10){
//        intervals = floor(totalTime/5);
//    }else{
        intervals = 3;
//    }
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    for(int i=0; i<totalTime; i+=intervals){
    
        thumbnailTime.value = thumbnailTime.timescale * i;
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        imageGenerator.appliesPreferredTrackTransform = YES;
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbnailTime actualTime:NULL error:NULL];
        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        [thumbs addObject:thumbnail];
    }
    return thumbs;
}




@end
