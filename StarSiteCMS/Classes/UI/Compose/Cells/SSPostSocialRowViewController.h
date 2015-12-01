//
//  SSPostSocialRowViewController.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 3/18/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSPostSocialRowViewController : UIViewController<UITextViewDelegate>{
    NSString *_dimColor;
    UIView *_keybordHelper;
    UIView *_viewBtnHideKeyboard;
}

@property (strong, nonatomic) IBOutlet UIButton *btnIcon;
@property (strong, nonatomic) IBOutlet UILabel *socialTitle;
@property (strong, nonatomic) IBOutlet UISwitch *socialSwitch;
@property (strong, nonatomic) IBOutlet UITextView *socialTextView;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) SSParingItem *item;
@property (strong, nonatomic) IBOutlet UILabel *checkmark;


- (IBAction)socialBtnPressed:(UIButton *)sender;
- (IBAction)switchChanged:(UISwitch *)sender;
- (IBAction)cancelCustom:(id)sender;


-(NSDictionary *)packageForServer;

@end
