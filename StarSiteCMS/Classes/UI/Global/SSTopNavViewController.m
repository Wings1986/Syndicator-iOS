//
//  SSTopNavViewController.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSTopNavViewController.h"

@interface SSTopNavViewController ()

@end

@implementation SSTopNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _topTitle.hidden = YES;
    _userImage.hidden = YES;
    
    
    _userImage.layer.cornerRadius = _userImage.width/2;
    _userImage.layer.borderWidth = 1;
    _userImage.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5].CGColor;
    _userImage.clipsToBounds = YES;
    _userImage.backgroundColor = [UIColor colorWithHexString:COLOR_DARK_END];
    [_userImage setImageWithURL:[NSURL URLWithString:[SSAppController sharedInstance].currentChannel.img] placeholderImage:[SSAppController sharedInstance].personImage];
     
     
    
    _settingsGear.width = _settingsGear.height = 20;
    _settingsGear.x = _userImage.maxX - _settingsGear.width/2 - _settingsGear.width/8;
    _settingsGear.layer.shadowColor = [UIColor blackColor].CGColor;
    _settingsGear.layer.shadowOpacity = 1.0;
    _settingsGear.layer.shadowRadius = 6.0;
    _settingsGear.layer.shadowOffset = CGSizeMake(0, 0);
    [self makeTransparent:YES];
     
     
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdated) name:NOTIFICATION_USER_INFO_UPDATED object:nil];
}

-(void)userInfoUpdated{
    [_userImage setImageWithURL:[NSURL URLWithString:[SSAppController sharedInstance].currentChannel.img] placeholderImage:[SSAppController sharedInstance].personImage];
}
-(void)showSettings:(BOOL)val{
    if(val){
        _userImage.hidden = YES;
        _btnSettings.hidden = NO;
        _btnDashboard.hidden = NO;
        _settingsGear.hidden = NO;
    }else{
        _userImage.hidden = YES;
        _btnSettings.hidden = YES;
        _btnDashboard.hidden = YES;
        _settingsGear.hidden = YES;
    }
}

-(void)hideBack:(BOOL)val{
    _btnBack.hidden = val;
}

- (IBAction)goBack {
    [[SSAppController sharedInstance] goBack];
}

-(void)showTitle:(NSString *)title{
    _topTitle.text = title;
    _topTitle.hidden = NO;
    _logo.y = 16;
}

- (IBAction)gotoSettings {
    [[SSAppController sharedInstance] routeToSettings];
}

- (IBAction)gotoDashboard {
    [[SSAppController sharedInstance] routeToDashboard];
}
-(void)makeTransparent:(BOOL)val{
    if(val){
        self.view.backgroundColor = [UIColor clearColor];
    }else{
        self.view.backgroundColor = [UIColor blackColor];
    }
}

@end
