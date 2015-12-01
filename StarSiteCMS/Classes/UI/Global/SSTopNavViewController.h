//
//  SSTopNavViewController.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSTopNavViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UILabel *topTitle;
@property (strong, nonatomic) IBOutlet UILabel *logo;
@property (strong, nonatomic) IBOutlet UILabel *settingsGear;
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) IBOutlet UIButton *btnDashboard;
@property (strong, nonatomic) IBOutlet UIButton *btnSettings;

- (IBAction)goBack;
-(void)hideBack:(BOOL)val;
-(void)showSettings:(BOOL)val;
-(void)showTitle:(NSString *)title;
- (IBAction)gotoSettings;
- (IBAction)gotoDashboard;
-(void)makeTransparent:(BOOL)val;
@end
