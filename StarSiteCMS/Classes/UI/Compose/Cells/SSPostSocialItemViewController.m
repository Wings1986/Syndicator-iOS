//
//  SSPostSocialItemViewController.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 5/3/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import "SSPostSocialItemViewController.h"

@interface SSPostSocialItemViewController ()

@end

@implementation SSPostSocialItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [_btnIcon setTitle:_item.icon forState:UIControlStateNormal];
    _dimColor = @"#616161";
    _btnIcon.clipsToBounds = YES;
    _btnIcon.layer.borderColor = [UIColor colorWithHexString:_dimColor].CGColor;
    _btnIcon.layer.borderWidth = 1;
    _btnIcon.layer.cornerRadius = _btnIcon.width/2;
    _checkmark.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(_item.isConnected){
            _btnIcon.selected = YES;
            [self makeSocialStateOn:YES];
        }
    });
}

-(NSDictionary *)packageForServer{
    return @{@"property_id":_item.pairingId,@"property":_item.title,@"active":(_btnIcon.selected) ? @"Y" : @"N",@"message":@"",@"message_custom":@"N"};
}

- (IBAction)socialBtnPressed:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self makeSocialStateOn:sender.selected];

    if(_item.pairingTypeId == SSParingTypeInstagram){
        
        if(_isPostingVideo){
            [[SSAppController sharedInstance] showAlertWithTitle:@"Video Limitation" andMessage:@"Instagram does now allow video posting at this time"];
            
        }else{
            NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
            if(![[UIApplication sharedApplication] canOpenURL:instagramURL]){
                [[SSAppController sharedInstance] showAlertWithTitle:@"Instagram not installed" andMessage:@"You will need to install Instagram on your device first"];
            }
        }
    }
}


-(void)makeSocialStateOn:(BOOL)val{
    
    if(_item.pairingTypeId == SSParingTypeInstagram){
        NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
        if(![[UIApplication sharedApplication] canOpenURL:instagramURL]){
            val = NO;
        }
        
        if(_isPostingVideo)
            val = NO;
    }
    
    if(val){
        _btnIcon.selected = YES;
        _btnIcon.layer.borderColor = [UIColor colorWithHexString:COLOR_GOLD].CGColor;
        _checkmark.hidden = NO;
    }else{
        _checkmark.hidden = YES;
        _btnIcon.selected = NO;
        _btnIcon.layer.borderColor = [UIColor colorWithHexString:_dimColor].CGColor;
    }

}




@end
