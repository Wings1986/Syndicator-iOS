//
//  SSDetailViewController.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSDetailViewController.h"

@interface SSDetailViewController ()

@end

@implementation SSDetailViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self layoutUI];
}


-(void)layoutUI{
    if(_didLayout) return;
    _didLayout = YES;
    
    [_topNav showSettings:NO];
    
    _sections = [NSMutableArray arrayWithArray:@[
                                                 @[   // Starclub
                                                     @{@"title":@"Revenue",@"color":COLOR_PINK,@"icon":@"~",@"total":_selectedItem.ss_earnings},
                                                     @{@"title":@"Views",@"color":COLOR_PINK,@"icon":@"~",@"total":_selectedItem.ss_impressions},
                                                     ],
                                                 
                                                 @[   // Facebook
                                                     @{@"title":@"Likes",@"color":COLOR_TAN,@"icon":@"~",@"total":_selectedItem.fb_likes},
                                                     @{@"title":@"Shares",@"color":COLOR_TEAL,@"icon":@"~",@"total":_selectedItem.fb_reaches},
                                                     ],
                                                 @[    // Twitter
                                                     @{@"title":@"Favorites",@"color":COLOR_TAN,@"icon":@"~",@"total":_selectedItem.tw_favorites},
                                                     @{@"title":@"Re-tweets",@"color":COLOR_TEAL,@"icon":@"~",@"total":_selectedItem.tw_retweets},
                                                     ],
                                                 @[    //  Google +
                                                     @{@"title":@"Likes",@"color":COLOR_TAN,@"icon":@"~",@"total":_selectedItem.gp_likes},
                                                     @{@"title":@"Comments",@"color":COLOR_TEAL,@"icon":@"~",@"total":_selectedItem.gp_comments},
                                                     ],
                                                 @[     // Tumblr
                                                     @{@"title":@"Likes",@"color":COLOR_TAN,@"icon":@"~",@"total":_selectedItem.tu_likes},
                                                     @{@"title":@"Comments",@"color":COLOR_TEAL,@"icon":@"~",@"total":_selectedItem.tu_comments},
                                                     ]
                                                 ]];
    
    if(_selectedItem.isPhoto){
        [_sections removeObjectAtIndex:3];
        [_sections removeObjectAtIndex:3];
        _btnPlay.hidden = YES;
    }
    
    _itemTitle.text = _selectedItem.message;
    [_itemImage setImageWithURL:[NSURL URLWithString:_selectedItem.thumbnail] placeholderImage:[SSAppController sharedInstance].appImage];
    _itemImage.layer.borderColor = [[UIColor colorWithHexString:@"000000"] colorWithAlphaComponent:0.2].CGColor;
    _itemImage.layer.borderWidth = 1;
    _itemImage.layer.cornerRadius = 4;
    _itemImage.clipsToBounds = YES;
    _labelTotal.format = @"$%d";
    _labelTotal.method = UILabelCountingMethodLinear;
    _labelEarningsTitle.text = _selectedItem.ss_earningsTitle;
    
    if([SSAppController sharedInstance].showTheMoney){
        _labelEarningsTitle.hidden = _labelTotal.hidden = NO;
    }else{
        _labelEarningsTitle.hidden = _labelTotal.hidden = YES;
    }
    
    float endingNumber = [_selectedItem.ss_earnings floatValue];
    int yAmount = 100;
    float damping = 0.7;
    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDetected:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRecognizer];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, Y, hh:mm a"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    _labelPosted.text = [[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:_selectedItem.createdDate]] uppercaseString];
    
    [_labelTotal countFrom:0 to:endingNumber withDuration:0.6f];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
        [formatter setGroupingSeparator:groupingSeparator];
        [formatter setGroupingSize:3];
        [formatter setAlwaysShowsDecimalSeparator:NO];
        [formatter setUsesGroupingSeparator:YES];
        NSString *formattedString = [formatter stringFromNumber:[NSNumber numberWithFloat:endingNumber]];
        _labelTotal.text = formattedString;
        _labelTotal.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
            _labelTotal.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        } completion:nil];
        
    });
    
    int rowHeight = 70;
    int startingY = _labelPerformance.maxY + 10;
    int startingX = 0;
    float delay = 0.4;
    int count = 0;
    
    for(NSArray *arr in _sections){
        int offsetX = 40;
        int padding = 10;
        float maxWidth = (self.view.width/[arr count] - offsetX/2) - 20;
        startingX = offsetX;
        
        if([arr count] == 1){
            maxWidth = (self.view.width/[arr count]);
            startingX = 0;
        }
        UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, startingY, self.view.width,rowHeight)];
        UILabel *theSocial = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 20, 20)];
        
        switch (count) {
            case 0:
                theSocial.text = @"~";  // Starclub
                break;
            case 1:
                theSocial.text = @"9";   // Facebook
                break;
            case 2:
                theSocial.text = @"8";   // Twitter
                break;
            case 3:
                theSocial.text = @"J";   // Google +
                break;
            case 4:
                theSocial.text = @"U";   // Tumblr
                break;
            case 5:
                theSocial.text = @"H";   // Pintrest
                break;
            default:
                theSocial.hidden = YES;
                break;
        }
        
        theSocial.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        theSocial.font = [UIFont fontWithName:FONT_ICONS size:22];
        theSocial.textAlignment = NSTextAlignmentCenter;
        [theSocial sizeToFit];
        theSocial.alpha = 0;
        theSocial.y = rowHeight/2 - theSocial.height/2;
        [row addSubview:theSocial];
        
        
        for(NSDictionary *dict in arr){
            
            UILabel *theNumber = [[UILabel alloc] initWithFrame:CGRectMake(startingX, 0, maxWidth, rowHeight - 10)];
            theNumber.text = [NSString returnStringObjectForKey:@"total" withDictionary:dict];
            theNumber.textColor = [UIColor colorWithHexString:[NSString returnStringObjectForKey:@"color" withDictionary:dict]];
            theNumber.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:29];
            theNumber.adjustsFontSizeToFitWidth = YES;
            theNumber.textAlignment = NSTextAlignmentCenter;
            [row addSubview:theNumber];
            
            UILabel *theTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 10)];
            theTitle.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
            theTitle.textColor = [[UIColor colorWithHexString:@"#C0C0C0"] colorWithAlphaComponent:0.8];
            theTitle.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:14];
            [theTitle sizeToFit];
            theTitle.x = theNumber.x + theNumber.width/2 - theTitle.width/2;
            theTitle.y = rowHeight - theTitle.height - 6;
            [row addSubview:theTitle];
            
            startingX += maxWidth + padding-2;
        }
        
        row.alpha = 0;
        [self.view addSubview:row];
        row.y += yAmount;
        
        [UIView animateWithDuration:0.5 delay:delay usingSpringWithDamping:damping initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
            row.y -= yAmount;
            row.alpha = 1;
            theSocial.x = 50;
            theSocial.alpha = 1;
        } completion:nil];
        
        [UIView animateWithDuration:1.0 delay:delay usingSpringWithDamping:damping initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
            theSocial.x = 30;
            theSocial.alpha = 1;
        } completion:nil];
        
        delay += 0.1;
        startingY += rowHeight + 1;
        count++;
    }

        _backgroundView1 = [[UIImageView alloc] initWithImage:[VTUtils radialGradientImage:CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2]];
    
//    _backgroundView1 = [[UIImageView alloc] initWithImage:[VTUtils radialGradientImage:CGSizeMake(self.view.width, self.view.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2]];
    
    [self.view insertSubview:_backgroundView1 atIndex:0];

    _btnPlay.layer.shadowColor = [UIColor colorWithHexString:@"#000000"].CGColor;
    _btnPlay.layer.shadowOpacity = 1.0;
    _btnPlay.layer.shadowRadius = 4.0;
    _btnPlay.layer.shadowOffset = CGSizeMake(0, 0);
}

- (void)swipeDetected:(UISwipeGestureRecognizer *)sender {
    [[SSAppController sharedInstance] goBack];
}

- (IBAction)playVideo {
    
    if(_selectedItem.isPhoto)
        return;
    
    
    
    NSString *hlsURL = [_selectedItem.fileURL stringByDeletingPathExtension];
    hlsURL = [hlsURL stringByAppendingString:@"/master.m3u8"];
    NSURL *url = [NSURL URLWithString:hlsURL];
    
    
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
/*
 
 - (void) moviePlayBackDidFinish:(NSNotification*)notification {
 NSLog(@"moviePlayBackDidFinish %@",notification);
 [self exitFullscreen];
 }
 */

-(void)exitFullscreen{
    [_moviePlayer setFullscreen:NO animated:NO];
    [_moviePlayer.view removeFromSuperview];
    _moviePlayer = nil;
}




@end
