//
//  SSPostSocialRowViewController.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 3/18/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import "SSPostSocialRowViewController.h"

@interface SSPostSocialRowViewController ()

@end

@implementation SSPostSocialRowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_btnIcon setTitle:_item.icon forState:UIControlStateNormal];
    _socialTitle.text = _item.title;
    _dimColor = @"#616161";
    _socialTextView.text = @"";
    _socialSwitch.alpha = 0;
    _btnIcon.clipsToBounds = YES;
    _btnIcon.layer.borderColor = [UIColor colorWithHexString:_dimColor].CGColor;
    _btnIcon.layer.borderWidth = 1;
    _btnIcon.layer.cornerRadius = _btnIcon.width/2;
    [_btnCancel setTitleColor:[UIColor colorWithHexString:COLOR_GOLD] forState:UIControlStateNormal];
    _btnCancel.backgroundColor = [[UIColor colorWithHexString:COLOR_GOLD] colorWithAlphaComponent:0.1];
    _btnCancel.layer.cornerRadius = 5;
    _btnCancel.clipsToBounds = YES;
    _btnCancel.hidden = YES;
    _viewBtnHideKeyboard = [[SSAppController sharedInstance] buildHideKeyboardViewWithTarget:self];
    _viewBtnHideKeyboard.x = _viewBtnHideKeyboard.y = 0;
    

    _keybordHelper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, _viewBtnHideKeyboard.height)];
    _keybordHelper.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
    _keybordHelper.clipsToBounds = YES;
    [_keybordHelper addSubview:_viewBtnHideKeyboard];
    _viewBtnHideKeyboard.width = _keybordHelper.width;
    _viewBtnHideKeyboard.height = _keybordHelper.height;
    _socialTextView.layer.cornerRadius = 5;

    [_socialTextView setInputAccessoryView:_keybordHelper];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _socialTextView.x = self.view.width;
        if(_item.isConnected){
            _btnIcon.selected = YES;
            [self makeSocialStateOn:YES];
        }

    });
}

- (IBAction)socialBtnPressed:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self makeSocialStateOn:sender.selected];
}

- (void)hideKeyboard {
    [[SSAppController sharedInstance] hideKeyboard];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EDITING_LOWER_SHARING object:@{@"showing":@"N"}];
}


-(void)makeSocialStateOn:(BOOL)val{

    if(val){
        _btnIcon.selected = YES;
        _btnIcon.layer.borderColor = [UIColor colorWithHexString:COLOR_GOLD].CGColor;
        _checkmark.hidden = NO;
        
        if(_item.hideCaptionOption){
            _socialTitle.textColor = [UIColor colorWithHexString:COLOR_GOLD];
            return;
        }
        _socialTitle.text = @"Custom Caption?";
        [_socialTitle sizeToFit];
        _socialSwitch.x = 240;
        _socialTextView.x = self.view.width;
        _btnCancel.x = self.view.width;
        [_socialSwitch setOn:NO];
        [UIView animateWithDuration:1.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone|UIViewAnimationOptionAllowUserInteraction animations:^{
            _socialTitle.x = _socialSwitch.x - _socialTitle.width - 5;
            _socialTitle.textColor = [UIColor colorWithHexString:COLOR_GOLD];
            _socialSwitch.alpha = 1;
            _socialTitle.alpha = 0;
        } completion:^(BOOL finished) {
        }];
        
        _socialTextView.hidden = YES;
        _socialSwitch.hidden = YES;
        
    }else{
        _checkmark.hidden = YES;
        _btnIcon.selected = NO;
        _btnIcon.layer.borderColor = [UIColor colorWithHexString:_dimColor].CGColor;
        _socialTitle.text = _item.title;
        [_socialTitle sizeToFit];
        [_socialSwitch setOn:NO];
        
        [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone|UIViewAnimationOptionAllowUserInteraction animations:^{
            _socialTitle.x = _btnIcon.maxX + 10;
            _socialTitle.textColor = [UIColor colorWithHexString:_dimColor];
            _socialSwitch.alpha = 0;
            _socialTitle.y = _socialSwitch.y + 5;
            if(!_item.hideCaptionOption){
                _socialTextView.x = self.view.width;
                _btnCancel.x = self.view.width;
            }
            
        } completion:^(BOOL finished) {
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EDITING_LOWER_SHARING object:@{@"showing":@"N"}];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADJUST_SHARING_VIEW object:nil];
}



-(void)textViewDidBeginEditing:(UITextView *)textView{
    if([textView.text isEqualToString:@"Write a custom caption..."]){
        textView.text = @"";
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EDITING_LOWER_SHARING object:@{@"showing":@"Y"}];
}

- (IBAction)switchChanged:(UISwitch *)sender {

//    _socialTextView.text = _itemCaption.text;
    if([_socialTextView.text isEmpty]){
        _socialTextView.text = @"Write a custom caption...";
    }

    if(_socialSwitch.isOn){
        _btnCancel.hidden = NO;
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone|UIViewAnimationOptionAllowUserInteraction animations:^{
            _socialTextView.x = _btnIcon.maxX + 5;
            _socialTextView.width = self.view.width - _socialTextView.x - 10;
            _socialTextView.y = _btnIcon.y;
            _btnCancel.x = self.view.width - _btnCancel.width - 15;
            _btnCancel.y = _socialTextView.maxY - _btnCancel.height - 5;
        } completion:^(BOOL finished) {

        }];
    }else{
        [[SSAppController sharedInstance] hideKeyboard];
        _socialTextView.text = @"";
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone|UIViewAnimationOptionAllowUserInteraction animations:^{
            _socialTextView.x = self.view.width;
            _btnCancel.x = self.view.width;
        } completion:^(BOOL finished) {
            _btnCancel.hidden = YES;
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EDITING_LOWER_SHARING object:@{@"showing":@"N"}];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADJUST_SHARING_VIEW object:nil];
}

- (IBAction)cancelCustom:(id)sender {
    [_socialSwitch setOn:NO];
    [self switchChanged:_socialSwitch];
}

-(NSDictionary *)packageForServer{
    return @{@"property_id":_item.pairingId,@"property":_item.title,@"active":(_btnIcon.selected) ? @"Y" : @"N",@"message":_socialTextView.text,@"message_custom":(_socialSwitch.isOn) ? @"Y" : @"N"};
}





@end
