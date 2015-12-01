//
//  SSComposeViewController.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "VTImagePicker.h"
#import <AviarySDK/AviarySDK.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface SSComposeViewController : SSViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,VTImagePickerDelegate,AFPhotoEditorControllerDelegate,UINavigationControllerDelegate>{
    AVCaptureSession *_session;
    AVCaptureVideoPreviewLayer *_previewLayer;
    AVCaptureStillImageOutput *_stillImageOutput;
    BOOL _lockBtn;
    VTImagePicker *_imagePicker;
    UIImage *_currentImage;
    AFPhotoEditorController *_editorController;
    AVCaptureDeviceInput *_videoDeviceInput;
    UIView *_upArrow;
    UIView *_curtain;
    UILabel *_curtainIcon;
    UIImagePickerController *_cameraUI;
}

@property (strong, nonatomic) IBOutlet UIView *loadingFiltersCurtain;
@property (strong, nonatomic) IBOutlet UIImageView *previewImage;
@property (strong, nonatomic) IBOutlet UIView *controlsView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIButton *btnPhoto;
@property (strong, nonatomic) IBOutlet UIButton *btnVideo;
@property (strong, nonatomic) IBOutlet UIButton *btnRecord;
@property (strong, nonatomic) IBOutlet UIButton *btnRecordInner;
@property (strong, nonatomic) IBOutlet UIButton *btnExisting;
@property (strong, nonatomic) IBOutlet UIButton *btnLines;
@property (strong, nonatomic) IBOutlet UIImageView *lastImagePreview;
@property (strong, nonatomic) IBOutlet UILabel *labelDot;
@property (strong, nonatomic) IBOutlet UIButton *btnTorch;
@property (strong, nonatomic) IBOutlet UIButton *btnToggleFrontBackCamera;
@property (strong, nonatomic) IBOutlet UIView *videoRecordingView;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UILabel *currentlyReaching;
@property (strong, nonatomic) IBOutlet UILabel *focusRing;

- (IBAction)loadExistingPicker;
- (IBAction)gotoDash;
- (IBAction)gotoCurated;
- (IBAction)togglePhotoVideo:(UIButton *)sender;
- (IBAction)takePhotoVideo;
- (IBAction)toggleTorch;
- (IBAction)toggleFrontBackCamera;
- (IBAction)gotoRecordVideoFullscreen;


@end
