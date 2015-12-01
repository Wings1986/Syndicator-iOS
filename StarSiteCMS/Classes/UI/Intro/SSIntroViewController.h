//
//  SSIntroViewController.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSViewController.h"
#import "AppTermsViewController.h"
#import "SSTempView.h"

@interface SSIntroViewController : SSViewController<UITextFieldDelegate,UIWebViewDelegate>{
    UIView *_loadingScreen;
    UIButton *_termsHitArea1;
    UIButton *_termsHitArea2;
    AppTermsViewController *_termsVC;
    BOOL _doingLoginWithStoredData;
    UIWebView *_webView;
    SSTempView *_drawArea;
}


@property (strong, nonatomic) IBOutlet UIView *innerView;
@property (strong, nonatomic) IBOutlet UILabel *logo;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;
@property (strong, nonatomic) IBOutlet UIButton *btnSignup;
@property (strong, nonatomic) IBOutlet UITextField *inputEmail;
@property (strong, nonatomic) IBOutlet UITextField *inputPass;
@property (strong, nonatomic) IBOutlet UIButton *btnForgot;
@property (strong, nonatomic) IBOutlet UIButton *btnLoginLarge;
@property (strong, nonatomic) IBOutlet UILabel *termsText;

- (IBAction)toggleLoginSignup:(UIButton *)sender;
-(IBAction)doLogin;

@end
