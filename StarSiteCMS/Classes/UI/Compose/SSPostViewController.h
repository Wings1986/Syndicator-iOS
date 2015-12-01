//
//  SSPostViewController.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface SSPostViewController : SSViewController<UITextViewDelegate>{
    NSString *_dimColor;
    MPMoviePlayerController *_moviePlayer;
    BOOL _bKeyboardIsUp;
    float _nKeyboardHeight;
    UIView *_loadingScreen;
    
    NSMutableArray *_socialProperties;
    UIView *_socialPropertiesHolder;
    UIView *_keybordHelper;
    int _paddingRows;
    BOOL _didBuildThumbs;
    UIView *_viewBtnHideKeyboard;

}

@property (strong, nonatomic) IBOutlet UIView *thumbPickView;
@property (strong, nonatomic) IBOutlet UIImageView *itemImage;
@property (strong, nonatomic) IBOutlet UITextView *itemCaption;
@property (strong, nonatomic) UIImage *capturedImage;
@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) NSArray *videoThumbs;



@property (assign, nonatomic) BOOL isVideo;
@property (strong, nonatomic) IBOutlet UILabel *sectionHeaderText;

@property (strong, nonatomic) IBOutlet UILabel *placeholderText;
@property (strong, nonatomic) IBOutlet UILabel *charCount;
@property (strong, nonatomic) IBOutlet UIButton *btnShare;
@property (strong, nonatomic) IBOutlet UIButton *btnPlayVideo;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *topView;

@property (strong, nonatomic) IBOutlet UIView *fullCurtain;
@property (strong, nonatomic) IBOutlet UIButton *btnChangeThumb;

@property (strong, nonatomic) IBOutlet UIScrollView *thumbScrollview;

- (IBAction)doShare;
- (IBAction)playVideo;
- (IBAction)doChangeThumb;
- (IBAction)doCancelThumbPick;

@end