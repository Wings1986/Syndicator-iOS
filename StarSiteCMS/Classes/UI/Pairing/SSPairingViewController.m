//
//  SSPairingViewController.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 10/21/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSPairingViewController.h"
#import "SSPairingBottomButton.h"
#import "SSParingButton.h"


@interface SSPairingViewController ()

@end

@implementation SSPairingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideTopNav:YES];
    
    [FBSession.activeSession close];
    [FBSession.activeSession closeAndClearTokenInformation];
    FBSession.activeSession = nil;
    _totalConnectedProperties = 0;

    _accountsForProperty = [[NSMutableArray alloc] init];
    
    _pairedTwitterAccounts = [[NSMutableArray alloc] init];
    _initialPositions = [[NSMutableDictionary alloc] init];
    _stepConfig = [[NSMutableArray alloc] initWithArray:@[
                                                          
              @{@"service":kSSPairServiceFacebook,
                @"propertyId" : @"1",
                @"titleOne" : @"Step 1",
                @"titleTwo" : @"Tap to Connect Facebook",
                @"icon": @"9",
                @"color": @"#6079B5"
                },
              @{@"service":kSSPairServiceTwitter,
                @"propertyId" : @"2",
                @"titleOne" : @"Step 2",
                @"titleTwo" : @"Tap to Connect Twitter",
                @"icon": @"8",
                @"color": @"#1DAEEC"
                },
              @{@"service":kSSPairServiceInstagram,
                @"propertyId" : @"3",
                @"titleOne" : @"Step 3",
                @"titleTwo" : @"Tap to Connect Instagram",
                @"icon": @"0",
                @"color": @"#EDE6DB"
                },
              @{@"service":kSSPairServiceTumblr,
                @"propertyId" : @"4",
                @"titleOne" : @"Step 4",
                @"titleTwo" : @"Tap to Connect Tumblr",
                @"icon": @"T",
                @"color": @"#FFFFFF"
                },
              @{@"service":kSSPairServiceGooglePlus,
                @"propertyId" : @"4",
                @"titleOne" : @"Step 5",
                @"titleTwo" : @"Tap to Connect Google+",
                @"icon": @"J",
                @"color": @"#DF4A32"
                },
              @{@"service":kSSPairServicePinterest,
                @"propertyId" : @"5",
                @"titleOne" : @"Step 6",
                @"titleTwo" : @"Tap to Connect Pinterest",
                @"icon": @"H",
                @"color": @"#BF0112"
                }
              ]];
    
    if(![SSAppController sharedInstance].isDemoApp && ![SSAppController sharedInstance].isPinModeApp){
        [_stepConfig removeLastObject];
        [_stepConfig removeLastObject];
//        [_stepConfig removeLastObject];
//        [_stepConfig removeLastObject];
    }
    
    _accountStore = [[ACAccountStore alloc] init];
    _apiManager = [[TWTAPIManager alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heardOAuthPaired:) name:NOTIFICATION_USER_SOCIAL_OAUTH_ID_PAIRED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backFromFacebookAuth:) name:NOTIFICATION_BACK_FROM_FB_AUTH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heardBtnAddMorePairing) name:NOTIFICATION_PARING_ADD_MORE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heardBtnPairingToggleChanged:) name:NOTIFICATION_PARING_TOGGLE_CHANGED object:nil];
    
    _titleDesc.text = @"";
    
    if(_initialAppPairing){
        _btnBack.hidden = YES;
    }
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self layoutUI];

}

-(void)layoutUI{
    
    if(_didLayout) return;
    _didLayout = YES;
    
    _btnNext = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.width/2,50)];
    _btnNext.backgroundColor = [UIColor clearColor];
    _btnNext.layer.borderWidth = 1;
    _btnNext.layer.borderColor = [[UIColor colorWithHexString:COLOR_TWITTER_BLUE] colorWithAlphaComponent:0.2].CGColor;
    _btnNext.layer.cornerRadius = 8;
    _btnNext.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:22];
    [_btnNext setTitleColor:[UIColor colorWithHexString:COLOR_TWITTER_BLUE] forState:UIControlStateNormal];
    [_btnNext setTitle:@"NEXT" forState:UIControlStateNormal];
    _btnNext.x = self.view.width/2 - _btnNext.width/2;
    [_btnNext addTarget:self action:@selector(skipPressed:) forControlEvents:UIControlEventTouchUpInside];
    _btnNext.hidden = YES;
    [_swappableView addSubview:_btnNext];
    
    [_btnSkip setTitleColor:[UIColor colorWithHexString:[[_stepConfig objectAtIndex:_stepIdx] objectForKey:@"color"]] forState:UIControlStateNormal];
    _btnSkip.alpha = 1;
    
    _btnSkip.y = self.view.height - _btnSkip.height - 10;
    _swappableView.width = self.view.width;
    _swappableView.layer.cornerRadius = 20;
    _swappableView.hidden = YES;
    _swappableView.x = self.view.width/2 - _swappableView.width/2;
    _swappableView.y = _logo.maxY;
    
    [self.view addSubview:_swappableView];
    
    _swappableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    _doneScreen = [[UIView alloc] initWithFrame:_swappableView.frame];
    _btnOver.backgroundColor = [UIColor clearColor];
    
    [_titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _titleBtn.layer.cornerRadius = _titleBtn.width/2;
    _titleBtn.layer.borderColor = _titleBtn.titleLabel.textColor.CGColor;
    _titleBtn.layer.borderWidth = 3;

    _stepIdx = 0;
    if(_startingProperty != nil){
        if(_startingProperty.pairingTypeId == SSParingTypeTwitter){
            _stepIdx = 1;
        }else if(_startingProperty.pairingTypeId == SSParingTypeInstagram){
            _stepIdx = 2;
        }else if(_startingProperty.pairingTypeId == SSParingTypeTumblr){
            _stepIdx = 3;
        }
    }


    [_logo sizeToFit];
    [_topTitle sizeToFit];
    _topTitle.x = self.view.width/2 - _topTitle.width/2 + 15;
    _logo.x = _topTitle.x - _logo.width - 10;
    _logo.y = _topTitle.y;
    _glowSpeed = 0.72;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self bringInStep:_stepIdx];
    });
    
    _pageControl.numberOfPages = 3;
    _pageControl.hidden = YES;
    _bottomSteps = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
    _bottomSteps.backgroundColor = [UIColor clearColor];
    [self rebuildBottomButtons];
    _bottomSteps.hidden = YES;
    _swappableView.height = _bottomSteps.y - _swappableView.y - 10;
    
    _backgroundView1 = [[UIImageView alloc] initWithImage:[VTUtils radialGradientImage:CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2]];
    
//    _backgroundView1 = [[UIImageView alloc] initWithImage:[VTUtils radialGradientImage:CGSizeMake(self.view.width, self.view.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2]];
    
    [self.view insertSubview:_backgroundView1 atIndex:0];

}

-(void)rebuildBottomButtons{
    
    [_bottomSteps removeAllSubviews];
    _bottomSteps.y = _btnSkip.y - _bottomSteps.height - 20;
    
    int count = 1;
    int xPos = 0;
    int bHeight = 45;
    int xPadding = 0;
    int playArea = self.view.width - 40;
    int buttonWidth = playArea/[_stepConfig count];
    
    for(NSDictionary *dict in _stepConfig){
        
        SSPairingBottomButton *b = [[SSPairingBottomButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, bHeight)];
        [b setupWithDictionary:dict];
        [b addTarget:self action:@selector(bottomNavButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        b.tag = count++;
        b.x = xPos;
        
        if(b.isConnected)
            _totalConnectedProperties++;
        
        if(count <= [_stepConfig count])
        for(int i=1; i<2; i++){
            UILabel *dot = [[UILabel alloc] initWithFrame:CGRectMake(b.x + b.width + (xPadding/5*i), 25, 2, 2)];
            dot.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
            dot.layer.cornerRadius = dot.width/2;
            dot.clipsToBounds = YES;
            dot.tag = 999;
            [_bottomSteps addSubview:dot];
        }
        [_bottomSteps addSubview:b];
        xPos += b.width + xPadding;
    }
    
    UILabel *done = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    done.text = @"DONE";
    done.font = [UIFont fontWithName:done.font.fontName size:10];
    [done sizeToFit];
    done.height = bHeight/2;
    done.textColor = [UIColor whiteColor];
    done.x = xPos;
    done.y = done.height/2 + 4;
    done.tag = 888;

    [_bottomSteps addSubview:done];
    _bottomSteps.width = done.maxX;
    _bottomSteps.x = self.view.width/2 - _bottomSteps.width/2;
    [self.view addSubview:_bottomSteps];
}


-(void)bottomNavButtonPressed:(UIButton *)btn{
    int tag = (int)btn.tag - 1;
    _stepIdx = tag;
    [self moveOutStep:_stepIdx];
    
}

-(void)glowLogo{
    
    float val = _titleBtn.alpha;
    if(val > 0.9){
        val = 0.6;
    }else{
        val = 1;
    }
    
    CGAffineTransform t = CGAffineTransformIdentity;
    if(val < 1)
        t = CGAffineTransformScale(CGAffineTransformIdentity, 0.85, 0.85);
    
    [UIView animateWithDuration:_glowSpeed delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _titleBtn.alpha = val;
        _titleBtn.transform = t;
    } completion:^(BOOL finished) {}];
}


-(void)resetSwappableStates{

    if(_accountSelectView != nil){
        [_accountSelectView removeFromSuperview];
        _accountSelectView = nil;
    }
    _doneScreen.hidden = YES;
    _btnOver.hidden = NO;
    _swappableView.hidden = NO;
    _titleBtn.alpha = 0;
    _titleBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    _titleBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _titleBtn.y = _titleRowTwo.maxY;
    for(UIView *v in _bottomSteps.subviews){
        v.alpha = 0.3;
    }
    _bottomSteps.hidden = NO;
    _btnSkip.alpha = 0.4;
    [_btnSkip setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}


-(void)bringInStep:(int)step{
    _titleDesc.text = @"";
    [self resetSwappableStates];
    
    [_titleRowOne.layer removeAllAnimations];
    [_titleRowTwo.layer removeAllAnimations];
    _titleRowOne.alpha = _titleRowTwo.alpha = 0;
    _pageControl.currentPage = step;
    _titleBtn.backgroundColor = [_titleBtn.backgroundColor colorWithAlphaComponent:1];
    NSDictionary *stepDict = [_stepConfig objectAtIndex:_stepIdx];
    _currentService = [stepDict objectForKey:@"service"];
    
    // CHECK TO SEE IF WE HAVE EXISTING PAIRING
    int propertyId = [[stepDict objectForKey:@"propertyId"] intValue];
    _currentPropertyInView = nil;
    
    for(SSParingItem *i in [SSAppController sharedInstance].pairingItems){
        if(i.pairingTypeId == propertyId){
            
            if(i.isConnected && ![SSAppController sharedInstance].isDemoApp && ![SSAppController sharedInstance].isPinModeApp){
                _currentPropertyInView = i;
                _titleRowOne.y = 20;
                _titleRowOne.text = @"Manage Connections";  
                _titleRowTwo.y = _titleRowOne.maxY;
                if(_currentPropertyInView.pairingTypeId == SSParingTypeFacebook){
                    _titleRowTwo.text = @"Found Facebook Connections";
                    _titleRowTwo.adjustsFontSizeToFitWidth = YES;
                }else if(_currentPropertyInView.pairingTypeId == SSParingTypeTwitter){
                    _titleRowTwo.text = @"Found Twitter Connections";
                    _titleRowTwo.adjustsFontSizeToFitWidth = YES;
                }else if(_currentPropertyInView.pairingTypeId == SSParingTypeInstagram){
                    _titleRowTwo.text = @"Found Instagram Connections";
                    _titleRowTwo.adjustsFontSizeToFitWidth = YES;
                }else if(_currentPropertyInView.pairingTypeId == SSParingTypeTumblr){
                    _titleRowTwo.text = @"Found Tumblr Connections";
                    _titleRowTwo.adjustsFontSizeToFitWidth = YES;
                }
                
                [self showActiveAccountsFoundForProperty:i];
            }
        }
    }
    [self rebuildBottomButtons];
    UIView *bottomViewItem = [_bottomSteps viewWithTag:_stepIdx+1];
    
    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         bottomViewItem.alpha = 1.0;
                     } completion:^(BOOL finished) {
                     }];
    
    if(_currentPropertyInView){
        _btnSkip.hidden = NO;
        [_btnSkip setTitle:@"NEXT" forState:UIControlStateNormal];
        float delay = 0.3;
        for(UIView *v in _swappableView.subviews){
            v.alpha = 0;
            [v.layer removeAllAnimations];
            if(v.tag == 5){
                
            }else{
                v.y += 30;
                [UIView animateWithDuration:0.8 delay:delay usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     v.alpha = 1.0;
                                     v.y -= 30;
                                 } completion:^(BOOL finished) {
                                 }];
            }
            delay += 0.03;
        }
        
    }else{
        
        _isAnimating = YES;
        _titleRowOne.text = [stepDict objectForKey:@"titleOne"];
        _titleRowTwo.text = [stepDict objectForKey:@"titleTwo"];
        _titleRowOne.y = 100;
        _titleRowTwo.y = _titleRowOne.maxY;
        _titleBtn.y = _titleRowTwo.maxY;
        
        _titleBtn.backgroundColor = [UIColor clearColor];//[UIColor colorWithHexString:[stepDict objectForKey:@"color"]];
        [_titleBtn setTitleColor:[UIColor colorWithHexString:[stepDict objectForKey:@"color"]] forState:UIControlStateNormal];
        [_titleBtn setTitle:[stepDict objectForKey:@"icon"] forState:UIControlStateNormal];
        
        _btnSkip.hidden = YES;
        [_btnSkip setTitle:@"SKIP" forState:UIControlStateNormal];
        
        _btnOver.y = _titleBtn.y;
        float delay = 0.3;
        for(UIView *v in _swappableView.subviews){
            v.alpha = 0;
            [v.layer removeAllAnimations];
            if(v.tag == 5){
                
                if(_glowLogo != nil){
                    [_glowLogo invalidate];
                }
                v.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.2, 0.2);
                [UIView animateWithDuration:1.0 delay:delay usingSpringWithDamping:0.4 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     v.alpha = 1.0;
                                     bottomViewItem.alpha = 1.0;
                                     v.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                                     _btnSkip.hidden = NO;
                                 } completion:^(BOOL finished) {
                                     [self glowLogo];
                                     _glowLogo = [NSTimer scheduledTimerWithTimeInterval:_glowSpeed target:self selector:@selector(glowLogo) userInfo:nil repeats:YES];
                                     _isAnimating = NO;
                                     
                                 }];
            }else{
                v.y += 30;
                [UIView animateWithDuration:0.8 delay:delay usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     v.alpha = 1.0;
                                     v.y -= 30;
                                 } completion:^(BOOL finished) {
                                     
                                 }];
                
            }
            delay += 0.03;
        }
    }
}


-(void)moveOutStep:(int)step{
    
    if(_isAnimating) return;
    
    [_glowLogo invalidate];
    _titleBtn.layer.shadowOpacity = 0;
    
    float delay = 0;
    UIView *viewToMoveOut = _swappableView;
    if(step == -1){
        viewToMoveOut = _doneScreen;
        _stepIdx = 0;
    }
    
    for(UIView *v in viewToMoveOut.subviews){
        
        [v.layer removeAllAnimations];
        
        [UIView animateWithDuration:0.8 delay:delay usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             v.alpha = 0;
                             v.y += 30;
                         } completion:^(BOOL finished) {
                             v.y -= 30;
                         }];
        
        delay += 0.03;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _btnNext.hidden = YES;
        if(_stepIdx >= [_stepConfig count]){
            if(_totalConnectedProperties == 0){
                [[SSAppController sharedInstance] showAlertWithTitle:@"Pairing Required" andMessage:@"At least one account must be paired to continue"];
                _stepIdx = 0;
                [self bringInStep:_stepIdx];
                return;
            }else{
                [self gotoDoneScreen];
            }
        }

        else
            [self bringInStep:_stepIdx];
        
    });
}



- (IBAction)btnPressed:(id)sender {
    
    if([SSAppController sharedInstance].isDemoApp || [SSAppController sharedInstance].isPinModeApp){
        [[SSAppController sharedInstance] showAlertWithTitle:@"Demo" andMessage:@"Disabled for demo"];
        return;
    }
    if([_currentService isEqualToString:kSSPairServiceTwitter]){
       [self startTwitterPairing];
    }else if([_currentService isEqualToString:kSSPairServiceInstagram]){
        [self startInstagramPairing];
    }else if([_currentService isEqualToString:kSSPairServiceTumblr]){
        [self startTumblrPairing];
    }else{
       [self startFacebookPairing];
    }
    
    [_glowLogo invalidate];
    
    [UIView animateWithDuration:1.2 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         _titleBtn.alpha = 1;
                         _titleBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.85, 0.85);;
                         _titleBtn.y = _titleRowOne.y - _titleBtn.height;
                         _titleBtn.layer.borderColor = [UIColor clearColor].CGColor;
                     } completion:^(BOOL finished) {
                         
                     }];
    
    
    _btnOver.hidden = YES;
    _titleBtn.backgroundColor = [_titleBtn.backgroundColor colorWithAlphaComponent:0];
}


- (IBAction)skipPressed:(id)sender {
    if(_isAnimating) return;
    
    if(_btnSkip.tag == -1){
        _btnSkip.tag = 0;
        
        [self moveOutStep:-1];
    }else
        [self moveOutStep:++_stepIdx];
}


- (IBAction)goBack:(id)sender {
    [[SSAppController sharedInstance] goBack];
}

-(void)showActiveAccountsFoundForProperty:(SSParingItem *)propertyItem{
    
    if(_accountSelectView != nil){
        [_accountSelectView removeFromSuperview];
        _accountSelectView = nil;
    }
    
    _accountSelectView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _titleRowTwo.maxY + 10, _swappableView.width, _swappableView.height - _titleRowTwo.maxY)];
    _accountSelectView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0];
    [_swappableView addSubview:_accountSelectView];
    

    int startingY = 0;
    float delay = 0.8;
    int totalAccounts = (int)[propertyItem.connectedPages count];
    int spacing = 20;
    int btnSize = 60;
    int spaceAvail = (_swappableView.height - (_titleRowTwo.maxY + 10));
    while( (btnSize + spacing)*totalAccounts > spaceAvail){
        btnSize--;
        spacing--;
    }
    if(btnSize < 50){
        btnSize = 50;
        spacing = 10;
    }
    
    NSMutableArray *items = [NSMutableArray arrayWithArray:propertyItem.connectedPages];
    if(propertyItem.pairingTypeId == SSParingTypeInstagram || propertyItem.pairingTypeId == SSParingTypeTumblr)
        [items addObject:@{@"title":@"Refresh...",@"add":@"Y"}];
    else
        [items addObject:@{@"title":@"Add More...",@"add":@"Y"}];

    for (NSDictionary *acct in items){
        
        SSParingButton *pBtn = [[SSParingButton alloc] initWithFrame:CGRectMake(0, startingY, _accountSelectView.width - 20, btnSize)];
        
        [pBtn buildButtonWithDictionary:acct];
        pBtn.y += 100;
        pBtn.alpha = 0;
        pBtn.x = _accountSelectView.width/2 - pBtn.width/2;
        startingY += pBtn.height + spacing;
        [_accountSelectView addSubview:pBtn];
        [UIView animateWithDuration:0.7 delay:delay usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             pBtn.y -= 100;
                             pBtn.alpha = 1;
                         } completion:^(BOOL finished) {
                             
                         }];
        delay += 0.03;
    }
    
    [_accountSelectView setContentSize:CGSizeMake(_accountSelectView.width, startingY)];
}

-(void)heardBtnAddMorePairing{
    
    if(_currentPropertyInView.pairingTypeId == SSParingTypeFacebook){
        [self startFacebookPairing];
    }else if(_currentPropertyInView.pairingTypeId == SSParingTypeTwitter){
        [self startTwitterPairing];
    }else if(_currentPropertyInView.pairingTypeId == SSParingTypeInstagram){
        [self startInstagramPairing];
    }else if(_currentPropertyInView.pairingTypeId == SSParingTypeTumblr){
        [self startTumblrPairing];
    }
}

-(void)heardBtnPairingToggleChanged:(NSNotification *)note{
    NSDictionary *dict = (NSDictionary *)note.object;
    [SSParingItem findAndReplacePairingItemActiveStateWithDictionary:dict];
    NSString *url = [SSAPIRequestBuilder APIForUpdateSocialKeyStatus];
    NSMutableDictionary *fullDict = [SSAPIRequestBuilder APIDictionary];
    [fullDict setValue:dict forKey:@"property"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [SSAPIRequestBuilder APIAcceptableContentTypes];
    [manager POST:url parameters:fullDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([VTUtils isResponseSuccessful:responseObject]){
        }else{
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}



#pragma mark DONE SCREEN

-(void)gotoDoneScreen{
    
    for(UIView *v in _bottomSteps.subviews){
        v.alpha = 0.3;
    }

    [_bottomSteps viewWithTag:888].alpha = 1.0;
    _doneScreen.hidden = NO;
    [_doneScreen removeAllSubviews];
    [self.view insertSubview:_doneScreen belowSubview:_bottomSteps];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:_titleRowOne.frame];
    titleLabel.text = @"FINISHED";
    titleLabel.font = _titleRowOne.font;
    titleLabel.textColor = _titleRowOne.textColor;
    [titleLabel sizeToFit];
    titleLabel.y = self.view.height/2 - titleLabel.height/2;
    titleLabel.x = _doneScreen.width/2 - titleLabel.width/2;
    [_doneScreen addSubview:titleLabel];
    titleLabel.alpha = 0;
    titleLabel.y -= 100;
    titleLabel.y += 200;
    [_btnSkip setTitle:@"BACK" forState:UIControlStateNormal];
    _btnSkip.tag = -1;
    [_btnSkip setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnSkip.alpha = 0;

    
    [UIView animateWithDuration:1.2 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         titleLabel.alpha = 1;
                         titleLabel.y -= 200;
                         _bottomSteps.alpha = 0;
                     } completion:^(BOOL finished) {
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             if(_initialAppPairing){
                                 _initialAppPairing = NO;
                                 [[SSAppController sharedInstance].navController popViewControllerAnimated:NO];
                                 [[SSAppController sharedInstance] routeToCompose];
                             }else{
                                 [self goBack:nil];
                             }
                         });
                     }];
}

-(void)finishedSetup{
    [[SSAppController sharedInstance] routeToCompose];
}

#pragma mark INSTAGRAM


-(void)heardOAuthPaired:(NSNotification *)note{
    NSDictionary *dictToSend = note.object;
    [_webviewHolderForPairing removeFromSuperview];
        [_glowLogo invalidate];
    [self sendPairingToServer:dictToSend];
}

-(void)doClosePairingWebView{
    
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
        _webviewHolderForPairing.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
        _webviewHolderForPairing.alpha = 0;
    } completion:^(BOOL finished) {
        [_webviewHolderForPairing removeFromSuperview];
    }];
    
    [self bringInStep:_stepIdx];
    
}

-(void)startInstagramPairing{
    
    SSParingItem *pairingItem;
    
    for(SSParingItem *pi in [SSAppController sharedInstance].pairingItems){
        if(pi.pairingTypeId == SSParingTypeInstagram){
            pairingItem = pi;
            break;
        }
    }
    [self buildWebViewHolderForPairing:pairingItem];
    
}

-(void)buildWebViewHolderForPairing:(SSParingItem *)pairingItem{
    if(!_webviewHolderForPairing){
        int btnSize = 30;
        _webviewHolderForPairing  = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.width,self.view.height)];
        _webviewHolderForPairing.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        _webviewForPairing = [[UIWebView alloc] initWithFrame:CGRectMake(btnSize, btnSize*2, _webviewHolderForPairing.width-btnSize*1.5, _webviewHolderForPairing.height/2)];
        _webviewForPairing.scalesPageToFit = YES;
        _webviewForPairing.backgroundColor = [UIColor whiteColor];
        [_webviewHolderForPairing addSubview:_webviewForPairing];
        _webviewBtnClose = [[UIButton alloc] initWithFrame:CGRectMake(_webviewForPairing.maxX-btnSize/2, _webviewForPairing.y-btnSize/2, btnSize, btnSize)];
        _webviewBtnClose.layer.cornerRadius = _webviewBtnClose.width/2;
        _webviewBtnClose.layer.borderWidth = 1;
        _webviewBtnClose.layer.borderColor = [UIColor whiteColor].CGColor;
        [_webviewBtnClose addTarget:self action:@selector(doClosePairingWebView) forControlEvents:UIControlEventTouchUpInside];
        [_webviewBtnClose setTitle:@"X" forState:UIControlStateNormal];
        _webviewBtnClose.titleLabel.font = [UIFont fontWithName:FONT_ICONS size:22];
        _webviewBtnClose.backgroundColor = [UIColor blackColor];
        [_webviewBtnClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_webviewHolderForPairing addSubview:_webviewBtnClose];
    }
    
    [self.view addSubview:_webviewHolderForPairing];
    [_webviewForPairing loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pairingItem.authURL]]];
    _webviewHolderForPairing.alpha = 0;
    _webviewHolderForPairing.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
    [UIView animateWithDuration:0.5 delay:0.4 usingSpringWithDamping:0.65 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
        _webviewHolderForPairing.transform = CGAffineTransformIdentity;
        _webviewHolderForPairing.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}



#pragma mark TUMBLR

-(void)startTumblrPairing{
    
    SSParingItem *pairingItem;
    for(SSParingItem *pi in [SSAppController sharedInstance].pairingItems){
        if(pi.pairingTypeId == SSParingTypeTumblr){
            pairingItem = pi;
            break;
        }
    }
    [self buildWebViewHolderForPairing:pairingItem];
}


#pragma mark TWITTER

-(void)startTwitterPairing{
    [self refreshTwitterAccounts];
}

-(void)noNativeTwitterAccounts{

    _titleRowTwo.text = @"Load Fabric";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showSuccessStateForLogo];
    });
    
//    [[Twitter sharedInstance] logInWithCompletion:^
//     (TWTRSession *session, NSError *error) {
//         if (session) {
//             NSLog(@"signed in as %@", [session userName]);
//         } else {
//             NSLog(@"error: %@", [error localizedDescription]);
//         }
//     }];
    
}

-(void)showNativeTwitterAccounts{
    
    [_btnSkip setTitle:@"NEXT" forState:UIControlStateNormal];
    
    if([_accounts count] > 1)
        _titleRowTwo.text = @"Which Account?";
    else
        _titleRowTwo.text = @"We found it!";
    
    if(_accountSelectView != nil){
        [_accountSelectView removeFromSuperview];
        _accountSelectView = nil;
    }
    
    _accountSelectView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _titleRowTwo.maxY + 10, _swappableView.width, _swappableView.height - _titleRowTwo.maxY)];
    [_swappableView addSubview:_accountSelectView];

    int startingY = 0;
    int count = 0;
    float delay = 0.8;
    int totalAccounts = (int)[_accounts count];
    int spacing = 20;
    int btnSize = 60;
    int spaceAvail = (_swappableView.height - (_titleRowTwo.maxY + 10));
    while( (btnSize + spacing)*totalAccounts > spaceAvail){
        btnSize--;
        spacing--;
    }
    for (ACAccount *acct in _accounts) {
        UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(0, startingY, _accountSelectView.width-20, btnSize)];
        b.backgroundColor = [UIColor clearColor];
        b.tag = count++;
        b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [b setTitle:acct.username forState:UIControlStateNormal];
        b.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        b.y += 100;
        b.x = self.view.width/2 - b.width/2;
        b.alpha = 0;
        b.titleLabel.textAlignment = NSTextAlignmentCenter;
        b.x = _accountSelectView.width/2 - b.width/2;
        b.layer.borderColor = [UIColor whiteColor].CGColor;
        b.layer.borderWidth = 1;
        b.layer.cornerRadius = 8;
        [b addTarget:self action:@selector(onTwitterAccountSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *tap = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        tap.text = @"Tap To Connect";
        tap.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:13];
        tap.textColor = [UIColor whiteColor];
        [tap sizeToFit];

        tap.x = b.width - tap.width - 10;
        tap.y = b.height/2 - tap.height/2;
        
        UILabel *tap2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        tap2.text = @"DISCONNECTED";
        tap2.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:9];
        tap2.textColor = [UIColor redColor];
        [tap2 sizeToFit];
        
        tap2.x = b.width - tap2.width - 10;
        tap2.y = tap.maxY;
      
        [b addSubview:tap];
        [b addSubview:tap2];
        [b setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, tap.width+10)];
        
        UILabel *check = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        check.text = @"V";
        check.font = [UIFont fontWithName:FONT_ICONS size:22];
        check.textColor = [UIColor whiteColor];
        [check sizeToFit];
        check.x = 20;//
        check.x = b.width - check.width - 10;
        check.y = b.height/2 - check.height/2;
        check.tag = 301;
        check.hidden = YES;
        [b addSubview:check];
        
        UIActivityIndicatorView *iv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        iv.x = check.x;
        iv.y = check.y;
        iv.tag = 302;
        iv.hidden = YES;
        [b addSubview:iv];
        
        startingY += b.height + spacing;
        
        [_accountSelectView addSubview:b];
        [UIView animateWithDuration:0.7 delay:delay usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             b.y -= 100;
                             b.alpha = 1;
                         } completion:^(BOOL finished) {
                             
                         }];
        delay += 0.03;
    }
}



-(void)onTwitterAccountSelected:(UIButton *)btn{
    
    [_glowLogo invalidate];
    int tag = (int) btn.tag;
    
    if(btn.selected){
        btn.selected = NO;
        [_pairedTwitterAccounts removeObject:_accounts[tag]];
        [self refreshTwitterButtonStates];
        return;
    }
    
    _titleRowTwo.text = @"Connecting...";
    
    for(UIButton *b in _accountSelectView.subviews){
        b.alpha = 0.3;
        b.enabled = NO;
    }
    
    [(UIActivityIndicatorView *)[btn viewWithTag:302] startAnimating];
    NSDictionary *stepDict = [_stepConfig objectAtIndex:_stepIdx];
    btn.layer.borderColor = [UIColor colorWithHexString:[stepDict objectForKey:@"color"]].CGColor;
    btn.alpha = 1;
    
    [_apiManager performReverseAuthForAccount:_accounts[tag] withHandler:^(NSData *responseData, NSError *error) {
        
        if(responseData) {
            
            NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
            
            if( (int) [parts count] <= 1){
                [[SSAppController sharedInstance] showAlertWithTitle:@"Unable To Connect" andMessage:@"Please make sure you entered your password into your Twitter Settings in your iPhone Settings"];
                btn.selected = NO;
                [self refreshTwitterButtonStates];
            }else{
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parts options:NSJSONWritingPrettyPrinted error:&error];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSDictionary *dict = @{@"pairing_service":@"twitter",@"pairing_data":jsonString};
                [self sendPairingToServer:dict];
                [_pairedTwitterAccounts addObject:_accounts[tag]];
                btn.selected = YES;
                [self refreshTwitterButtonStates];
            }
        }
        else {
            NSLog(@"Reverse Auth process failed. Error returned was: %@\n", [error localizedDescription]);
        }
        _titleRowTwo.text = @"Which Account?";
    }];
}

-(void)refreshTwitterButtonStates{
    
    BOOL atLeastOne = NO;
    for(UIView *v in _accountSelectView.subviews){
        
        if(![v isKindOfClass:[UIButton class]]){
            return;
        }
        UIButton *b = (UIButton *)v;
        b.alpha = 1;
        b.enabled = YES;
        b.backgroundColor = [UIColor clearColor];
        b.layer.borderColor = [UIColor whiteColor].CGColor;
        [b viewWithTag:301].hidden = YES;
        [(UIActivityIndicatorView *)[b viewWithTag:302] stopAnimating];
        if(b.selected){
            atLeastOne = YES;
            b.layer.borderColor = [UIColor colorWithHexString:[[_stepConfig objectAtIndex:_stepIdx] objectForKey:@"color"]].CGColor;
            b.backgroundColor = [UIColor colorWithHexString:[[_stepConfig objectAtIndex:_stepIdx] objectForKey:@"color"]];
            [b viewWithTag:301].hidden = NO;
        }
    }
    
    if(atLeastOne){
        [_btnSkip setTitleColor:[UIColor colorWithHexString:[[_stepConfig objectAtIndex:_stepIdx] objectForKey:@"color"]] forState:UIControlStateNormal];
        _btnSkip.alpha = 1;
    }else{
        [_btnSkip setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnSkip.alpha = 0.4;
    }
}



- (void)_displayAlertWithMessage:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TEMP ERROR" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)refreshTwitterAccounts{
    _titleRowTwo.text = @"Checking Settings...";
    
    if (![TWTAPIManager isLocalTwitterAccountAvailable]) {
        [self noNativeTwitterAccounts];
    }
    else {
        [self _obtainAccessToAccountsWithBlock:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self showNativeTwitterAccounts];
//                    _reverseAuthBtn.enabled = YES;
                }
                else {
                    [self _displayAlertWithMessage:@"NO PERMSSIONS"];
//                    [self _displayAlertWithMessage:ERROR_PERM_ACCESS];
                }
            });
        }];
    }
}


- (void)_obtainAccessToAccountsWithBlock:(void (^)(BOOL))block{
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            _accounts = [_accountStore accountsWithAccountType:twitterType];
            NSLog(@"_accounts : %@",_accounts);
        }
        block(granted);
    };
    [_accountStore requestAccessToAccountsWithType:twitterType options:NULL completion:handler];
}






#pragma mark FACEBOOK


- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    NSLog(@"You're logged in as %@",user.name);
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {

}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSLog(@"FBERROR %@",error);
}

-(void)backFromFacebookAuth:(NSNotification *)note{
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        NSLog(@"ALREADY OPEN 1");
    }
    [self showSuccessStateForLogo];

    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
            _returnedFBUserData = [NSString stringWithFormat:@"%@",jsonString];
            [FBRequestConnection startWithGraphPath:@"/me/accounts"
                                         parameters:nil
                                         HTTPMethod:@"GET"
                                  completionHandler:^(
                                                      FBRequestConnection *connection,id result,NSError *error){[self onFBResult:result andError:error];}];
        } else {
            return;
        }
    }];
}


-(void)showSuccessStateForLogo{

    [_glowLogo invalidate];
    if((1))
        return;
    _titleRowTwo.text = @"Success!";
    
    [UIView animateWithDuration:1.0 animations:^{
        
        [_titleBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        _titleBtn.layer.shadowColor = [UIColor greenColor].CGColor;
        _titleBtn.layer.shadowOpacity = 1.0;
        _titleBtn.layer.shadowRadius = 25.0;
        _titleBtn.layer.shadowOffset = CGSizeMake(0, 0);
    
    }];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _titleBtn.alpha = 1;
        _titleBtn.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        _btnNext.hidden = NO;
        _btnSkip.hidden = YES;
        
        [VTUtils performAnimateSlideUpWithView:_btnNext endingY:_titleDesc.maxY];
    }];
}


-(void)onFBResult:(id)mainResult andError:(id)mainError{
    
    
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,id result,NSError *error){
                            
                              NSDictionary *pDict = [[NSDictionary alloc] initWithDictionary:result];
                              
                              NSDictionary *keyValue = @{@"public_profile":@"Profile",@"email":@"Email Address",@"manage_pages":@"Manage Page",@"publish_actions":@"Publish Actions",@"read_insights":@"Read Insights",@"publish_pages":@"Publish Pages"};
                              NSString *alertMessage = @"Please grant all access:\n\n";
                              BOOL doContinue = YES;
                              
                              if([pDict objectForKey:@"data"] != nil){
                                  for(NSDictionary *row in [pDict objectForKey:@"data"]){
                                      
                                      
                                      if([[NSString returnStringObjectForKey:@"status" withDictionary:row] rangeOfString:@"decli"].location != NSNotFound) {
                                          doContinue = NO;
                                          @try{
                                              alertMessage = [alertMessage stringByAppendingString:[NSString stringWithFormat:@"%@: %@ \n",[keyValue objectForKey:[row objectForKey:@"permission"]],[row objectForKey:@"status"]]];
                                          }@catch(NSException *e){
                                          }
                                      }
                                      
                                  }
                              }
                              
                              _titleRowTwo.text = @"New Connections found";
                              if(_loadingScreen && [_loadingScreen superview])
                                  [_loadingScreen removeFromSuperview];
                              
                              [_glowLogo invalidate];
                              [_titleBtn.layer removeAllAnimations];
                              _titleBtn.alpha = 0;
                              
                              if(doContinue){
                                  _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Pairing" andColor:nil];
                                  [self.view addSubview:_loadingScreen];
                                  
                                  if(mainResult){
                                      
                                      NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mainResult options:NSJSONWritingPrettyPrinted error:&error];
                                      NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                      NSDictionary *dict = @{@"pairing_service":@"facebook",@"pairing_data":jsonString,@"user_data":[NSString stringWithFormat:@"%@",_returnedFBUserData],@"user_token":[[[FBSession activeSession] accessTokenData] accessToken]};
                                      [self sendPairingToServer:dict];
                                  }
                              }else{
                                  if(_alertPermissions == nil){
                                      _alertPermissions = [[UIAlertView alloc] initWithTitle:@"Permissions Issue" message:alertMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
                                      _alertPermissions.tag = 301;
                                      [_alertPermissions show];
                                  }
                              }
                              
                          }];

}


-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 301){
         _alertPermissions = nil;
        int idx = (int)buttonIndex;
        if(idx == 0){
            //cancel
            [self bringInStep:_stepIdx];
        }else{
            //retry
            [self startFacebookPairing];
        }
    }
}



-(void)sendPairingToServer:(NSDictionary *)dict{

    NSString *url = [SSAPIRequestBuilder APIForStoreSocialKeys];
    NSMutableDictionary *fullDict = [SSAPIRequestBuilder APIDictionary];
    [fullDict addEntriesFromDictionary:dict];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [SSAPIRequestBuilder APIAcceptableContentTypes];
    [manager POST:url parameters:fullDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [_loadingScreen removeFromSuperview];
        if([VTUtils isResponseSuccessful:responseObject]){

            [[SSAppController sharedInstance].pairingItems removeAllObjects];
            for(NSDictionary *d in [responseObject objectForKey:@"pairing"]){
                SSParingItem *pi = [[SSParingItem alloc] initWithDictionary:d];
                [[SSAppController sharedInstance].pairingItems addObject:pi];
            }
            [self bringInStep:0];
            
        }else{
            [[SSAppController sharedInstance] alertWithServerResponse:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[SSAppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
        [_loadingScreen removeFromSuperview];
    }];
}


-(void)startFacebookPairing{
    
    _titleRowTwo.text = @"Checking...";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        if (FBSession.activeSession.isOpen) {
                [FBSession.activeSession requestNewPublishPermissions:@[@"public_profile",@"email",@"manage_pages",@"publish_actions",@"read_insights",@"publish_pages"]  defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BACK_FROM_FB_AUTH object:@{}];
                }];
        }else{
            [FBSession openActiveSessionWithPublishPermissions:@[@"public_profile",@"email",@"manage_pages",@"publish_actions",@"read_insights",@"publish_pages"] defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BACK_FROM_FB_AUTH object:@{}];
            }];
        }
    });
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




@end
