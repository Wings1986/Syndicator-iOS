//
//  SSPostCuratedViewController.h
//  StarSiteCMS
//
//  Adapted by IC on 8/31/2015.
//  Copyright (c) 2014 USMT LLC. All rights reserved.
//

#import "SSPostCuratedViewController.h"
#import "SSPostSocialRowViewController.h"
#import "SSPostSocialItemViewController.h"

@interface SSPostCuratedViewController ()

@end

@implementation SSPostCuratedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _paddingRows = 3;
    _socialProperties = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustHeight) name:NOTIFICATION_ADJUST_SHARING_VIEW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingLower:) name:NOTIFICATION_EDITING_LOWER_SHARING object:nil];
}


-(void)viewWillAppear:(BOOL)animated{
    [VTUtils removeLoadingView:self.view];

    [super viewWillAppear:animated];
    [self layoutUI];
}

-(void)layoutUI{
    
    if(_didLayout) return;
    
    NSArray *tempArray = [SSAppController sharedInstance].pairingItems;

    _didLayout = YES;
    _dimColor = @"#ffffff";

    _btnPlayVideo.hidden = !_isVideo;
    _charCount.text = @"";
    _itemImage.clipsToBounds = YES;
    _itemImage.image = _capturedImage;
    _btnShare.layer.cornerRadius = 8;
    _btnChangeThumb.hidden = YES;
    
    if(_isVideo && [_videoThumbs count] > 1){
        _btnChangeThumb.hidden = NO;
        _btnChangeThumb.layer.borderColor = [UIColor colorWithHexString:COLOR_GOLD].CGColor;
        _btnChangeThumb.layer.borderWidth = 1;
        _btnChangeThumb.layer.cornerRadius = 10;
    }
    
    [_topNav showSettings:NO];
    _fullCurtain.hidden = YES;
    _topView.backgroundColor = [UIColor clearColor];
    _socialPropertiesHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _scrollView.width,_scrollView.height)];
    _socialPropertiesHolder.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0];
    _scrollView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0];
    [_scrollView addSubview:_socialPropertiesHolder];
    
    int startingX = 0;
    
    [_socialProperties removeAllObjects];
    for(SSParingItem *item in tempArray){
        SSPostSocialItemViewController *s = [[SSPostSocialItemViewController alloc] init];
        
        if([SSAppController sharedInstance].isDemoApp || [SSAppController sharedInstance].isPinModeApp){
            item.isConnected = YES;
        }
        s.item = item;
        s.view.width = 62;
        s.view.height = _scrollView.height;
        s.view.y = 0;
      //  s.view.clipsToBounds = YES;
        [_socialProperties addObject:s];
        s.view.x = startingX;
        
        s.isPostingVideo = _isVideo;
        
        startingX += s.view.width + 2;
        [_socialPropertiesHolder addSubview:s.view];
    }

    startingX += 56 + 2;
    [_scrollView setContentSize:CGSizeMake(startingX, _scrollView.height)];
    _socialPropertiesHolder.width = startingX;

    _keybordHelper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, _btnShare.height + 20)];
    _keybordHelper.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    _keybordHelper.clipsToBounds = YES;
    [_keybordHelper addSubview:_btnShare];
    _btnShare.y = 0;
    _btnShare.x = _keybordHelper.width/2 - _btnShare.width/2;
    
    [_itemCaption setInputAccessoryView:_keybordHelper];
    
    UITapGestureRecognizer *largeImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleImageLarger)];
    largeImageView.numberOfTapsRequired = 1;
    [_itemImage addGestureRecognizer:largeImageView];
    _itemImage.userInteractionEnabled = YES;
    
    _itemImage.layer.borderWidth = 0.5;
    _itemImage.layer.borderColor = [UIColor colorWithHexString:@"000000"].CGColor;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [_itemCaption addBottomBorderWithHeight:1 andColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3]];
    
    if(_viralCaption.length > 0){
        _itemCaption.text = @"";
        [_itemCaption insertText:_viralCaption];
    }

    UIImage *i = [VTUtils radialGradientImage:CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2];
    
//    UIImage *i = [VTUtils radialGradientImage:CGSizeMake(self.view.width, self.view.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2];
    
    _backgroundView1 = [[UIImageView alloc] initWithImage:i];
    [self.view insertSubview:_backgroundView1 atIndex:0];
    
    [self textViewDidEndEditing:_itemCaption];
    
    //CHECK IF PAIRED
//    [self socialBtnPressed:_btnFacebook];
//    [self socialBtnPressed:_btnTwitter];
//    [self socialBtnPressed:_btnInstagram];
    [self adjustHeight];
    [_itemCaption becomeFirstResponder];
    
}



- (void)keyboardWillShow:(NSNotification*)aNotification{
    _bKeyboardIsUp = YES;
    CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _nKeyboardHeight = kbSize.height;
    [self adjustScrollArea];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    _bKeyboardIsUp = NO;
    [self adjustScrollArea];
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    _charCount.alpha = 0;
    _charCount.x = self.view.width;
    int length = (int)[textView.text length];
    if(length == 0){
        _charCount.text = @"Suggestion 100 characters";
    }
    else{
        _charCount.text = [NSString stringWithFormat:@"%d char",length];
    }
    
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
        _placeholderText.y = textView.y + 5;
        _placeholderText.textColor = [UIColor whiteColor];
    } completion:^(BOOL finished) {
    }];
    
    [UIView animateWithDuration:0.7 delay:0.4 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
        _charCount.alpha = 1;
        _charCount.x = self.view.width - _charCount.width - 20;
    } completion:^(BOOL finished) {
    }];
    
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
        _placeholderText.y = textView.maxY - _placeholderText.height - 5;
        _placeholderText.textColor = [UIColor colorWithHexString:@"666666"];
        _charCount.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if(textView == _itemCaption){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            int length = (int)[textView.text length];
            if(length == 0){
                _charCount.text = @"Suggestion 100 characters";
                _placeholderText.hidden = NO;
            }
            else{
                _placeholderText.hidden = YES;
                _charCount.text = [NSString stringWithFormat:@"%d char",length];
            }
        });
    }
    return YES;
}



-(void)toggleImageLarger{
    
    int newW = self.view.width - 40;
    int newX = self.view.width/2 - newW/2;
    int newY = self.view.height/2 - newW/2;
    int tag = 2;
    BOOL goingFull = YES;
    
    if(_itemImage.tag == 2){
        goingFull = NO;
    }
    
    
    if(goingFull){
        [self.view addSubview:_fullCurtain];
        [_fullCurtain addSubview:_itemImage];
        _itemImage.x = _topView.x + 8;
        _itemImage.y = _topView.y + 10;
        _fullCurtain.hidden = NO;
        _fullCurtain.alpha = 0;
    }else{
        newW = 90;
        tag = 1;
        newX = 8;
        newY = 10;
        [_topView insertSubview:_itemImage belowSubview:_btnPlayVideo];
    }
    
    _itemImage.tag = tag;
    
    
    [[SSAppController sharedInstance] hideKeyboard];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        _itemImage.width = newW;
        _itemImage.height = newW;
        _itemImage.x = newX;
        _itemImage.y = newY;
        
        if(goingFull){
            _fullCurtain.alpha = 1;
        }else{
            _fullCurtain.alpha = 0;
        }
    } completion:^(BOOL finished) {
       if(!goingFull){
           _fullCurtain.hidden = YES;
           
       }
    }];
}


- (void)hideKeyboard {
    [[SSAppController sharedInstance] hideKeyboard];
}


-(void)adjustScrollArea{
    float extra = 0.0;
    if(_bKeyboardIsUp)
        extra = 100;
//    [_scrollView setContentSize:CGSizeMake(_socialPropertiesHolder.width, _socialPropertiesHolder.height + (self.view.height - _btnShare.y) + 50 + extra) ];
}


-(void)adjustHeight{
    
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
//        _btnShare.y = self.view.height - _btnShare.height - 20;
    } completion:^(BOOL finished) {
    }];
    

}

-(void)editingLower:(NSNotification *)note{
    
    BOOL scrollUp = [[NSString returnStringObjectForKey:@"showing" withDictionary:note.object] isEqualToString:@"Y"];
    
    if(scrollUp){
        [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
            _topView.alpha = 0;
            [_topNav hideBack:YES];
        } completion:^(BOOL finished) {
        }];
    }else{
        [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
            _topView.alpha = 1;
            [_topNav hideBack:NO];
        } completion:^(BOOL finished) {
        }];
    }
}

- (IBAction)doShare{
    
    if([_itemCaption.text length] == 0){
        [[SSAppController sharedInstance] showAlertWithTitle:@"Missing Caption" andMessage:@"Please add a caption"];
        return;
    }
    
    BOOL sendToInstagram = NO;
    //gather what we are sharing
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(SSPostSocialItemViewController *s in _socialProperties){
        [arr addObject:[s packageForServer]];
        if(s.item.pairingTypeId == SSParingTypeInstagram && s.btnIcon.selected){
            sendToInstagram = YES;
        }
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSDictionary *dict = @{@"caption":_itemCaption.text,
                           @"image":(_capturedImage) ? _capturedImage : @"",
                           @"viralContentId":_viralContentId,
                           @"is_video":(_isVideo) ? @"Y" : @"N",
                           @"sendToInstagram":(sendToInstagram) ? @"Y" : @"N",
                           @"pairing_data":jsonString
                           };
    NSLog(@"dict::: %@",dict);
    
    if(!_capturedImage && !_isVideo){
        [[SSAppController sharedInstance] showAlertWithTitle:@"Image or Video required" andMessage:@"Please add a video or an image"];
    }else{
        
        [[SSAppController sharedInstance] doCuratedShareWithDictionary:dict];
        [[SSAppController sharedInstance] hideKeyboard];
//        [[SSAppController sharedInstance] donePost];
    }
}







- (IBAction)playVideo {

    NSLog(@"playVideo");

    if(!_isVideo)
        return;

    
    NSString *hlsURL = [_videoURL.absoluteString stringByDeletingPathExtension];
    hlsURL = [hlsURL stringByAppendingString:@"/master.m3u8"];
    
    NSURL *url = [NSURL URLWithString:hlsURL];
    

    
  //  NSURL *url = [NSURL URLWithString:_videoURL.absoluteString];
    
    
    
    _moviePlayer =  [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_moviePlayer];
    


    
    [_moviePlayer.view setFrame: self.view.bounds];
    [self.view addSubview: _moviePlayer.view];

    
    
    [self.view addSubview: _moviePlayer.view];
    _moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    _moviePlayer.shouldAutoplay = YES;
    //       _moviePlayer.repeatMode =  MPMovieRepeatModeNone;
    _moviePlayer.allowsAirPlay = YES;
    //       _moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    _moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
    [_moviePlayer.view setFrame: self.view.bounds];
    [_moviePlayer prepareToPlay];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didExitFullScreen:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    

    [_moviePlayer play];
    [_moviePlayer setFullscreen:YES animated:YES];
    
    NSLog(@"PLAYING");
    
}

- (IBAction)doChangeThumb {
    
    if(!_didBuildThumbs){
        int count = 0;
        
        UIImage *i = [VTUtils radialGradientImage:CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2];
        
//        UIImage *i = [VTUtils radialGradientImage:CGSizeMake(self.view.width, self.view.height) start:[UIColor colorWithHexString:@"#373542"] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2];
        UIImageView *bg = [[UIImageView alloc] initWithImage:i];
        [_thumbPickView insertSubview:bg atIndex:0];
    
        
        _didBuildThumbs = YES;
        int startingX = 50;
        for(UIImage *i in _videoThumbs){
            UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(startingX, 0, _thumbScrollview.height, _thumbScrollview.height)];
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, b.width, b.height)];
            iv.contentMode = UIViewContentModeScaleAspectFill;
//            iv.layer.shadowColor = [UIColor colorWithHexString:@"CCCCCC"].CGColor;
//            iv.layer.shadowOffset = CGSizeMake(0,0);
//            iv.layer.shadowOpacity = 1;
//            iv.layer.shadowRadius = 12;
            iv.layer.borderColor = [[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.2].CGColor;
            iv.layer.borderWidth = 2;
            iv.clipsToBounds = YES;
            
            b.tag = count++;
            [b addTarget:self action:@selector(changeOutThumb:) forControlEvents:UIControlEventTouchUpInside];
            iv.image = i;
            [b addSubview:iv];
            [_thumbScrollview addSubview:b];
            startingX += b.width + 50;
        }
        [_thumbScrollview setContentSize:CGSizeMake(startingX, _thumbScrollview.height)];
        _thumbScrollview.clipsToBounds = NO;
    }
     [[SSAppController sharedInstance] hideKeyboard];
    _thumbPickView.width = self.view.width;
    _thumbPickView.height = self.view.height;
    _thumbScrollview.width = _thumbPickView.width;
    _thumbScrollview.x = 0;
//    _thumbScrollview.backgroundColor =[UIColor redColor];
    _thumbPickView.alpha = 0;
    _thumbPickView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    [self.view addSubview:_thumbPickView];

    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
        _thumbPickView.alpha = 1;
        _thumbPickView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {

    }];
    
}

-(void)changeOutThumb:(UIButton *)btn{
    NSLog(@"changeOutThumb!!!");
    int idx = (int)btn.tag;
    UIImage *i = [_videoThumbs objectAtIndex:idx];
    _capturedImage = i;
    _itemImage.image = i;
    [self doCancelThumbPick];
}

- (IBAction)doCancelThumbPick {

    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
        _thumbPickView.alpha = 0;
        _thumbPickView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
    } completion:^(BOOL finished) {
        _thumbPickView.transform = CGAffineTransformIdentity;
        [_thumbPickView removeFromSuperview];
    }];
}




#pragma mark - Player Notifications

- (void)onMovieState:(NSNotification *)notification {
    NSLog(@"onMovieState %@",notification);
}

- (void)onPlayerNotification:(NSNotification*)notification {
    NSLog(@"onPlayerNotification %@",notification);
}

- (void)didExitFullScreen:(NSNotification*)notification {
    NSLog(@"didExitFullScreen %@",notification);
    [self exitFullscreen];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    NSLog(@"moviePlayBackDidFinish %@",notification);
    //   MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:_moviePlayer ];
    
    if ([_moviePlayer
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [_moviePlayer.view removeFromSuperview];
    }
}

-(void)exitFullscreen{
    [_moviePlayer setFullscreen:NO animated:NO];
    [_moviePlayer.view removeFromSuperview];
    _moviePlayer = nil;
}




@end
