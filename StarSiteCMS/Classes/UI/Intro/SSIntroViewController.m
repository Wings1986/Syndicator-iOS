//
//  SSIntroViewController.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSIntroViewController.h"
#import "SSPostViewController.h"


@interface SSIntroViewController ()

@end

@implementation SSIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideTopNav:YES];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self layoutUI];
}

-(void)handleRemoteLogin:(NSNotification *)note{
    [_webView removeFromSuperview];
    [_loadingScreen removeFromSuperview];
    if([SSAppController sharedInstance].storedLogin != nil){
        _inputEmail.text = [NSString returnStringObjectForKey:@"username" withDictionary:[SSAppController sharedInstance].storedLogin];
        _inputPass.text = [NSString returnStringObjectForKey:@"pass" withDictionary:[SSAppController sharedInstance].storedLogin];
    }
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [_loadingScreen removeFromSuperview];
    [webView removeFromSuperview];
}

-(void)layoutUI{
    
    if(_didLayout) return;
    _didLayout = YES;
    
    _inputEmail.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 20)];
    _inputEmail.leftViewMode = UITextFieldViewModeAlways;
    _inputEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_inputEmail.placeholder attributes:@{NSForegroundColorAttributeName: [[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.6]}];
    [_inputEmail addTopBorderWithHeight:0.5 andColor:[UIColor colorWithHexString:COLOR_GRAY_LINE]];
    
    _inputPass.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 20)];
    _inputPass.leftViewMode = UITextFieldViewModeAlways;
    _inputPass.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_inputPass.placeholder attributes:@{NSForegroundColorAttributeName: [[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.6]}];
    [_inputPass addTopBorderWithHeight:0.5 andColor:[UIColor colorWithHexString:COLOR_GRAY_LINE]];
    [_inputPass addBottomBorderWithHeight:0.5 andColor:[UIColor colorWithHexString:COLOR_GRAY_LINE]];
    
    _inputEmail.tintColor = [UIColor colorWithHexString:COLOR_PURPLE];
    _inputPass.tintColor = [UIColor colorWithHexString:COLOR_PURPLE];
    _inputEmail.layer.cornerRadius = 5;
    _inputPass.layer.cornerRadius = 5;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    

    UILabel *appIcon = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    appIcon.text = @"~";
    appIcon.font = [UIFont fontWithName:FONT_ICONS size:200];
    appIcon.textColor = [UIColor colorWithHexString:@"CCCCCC"];
    [appIcon sizeToFit];
    appIcon.width += 140;
    appIcon.height += 140;
    appIcon.textAlignment = NSTextAlignmentCenter;
    
    UIGraphicsBeginImageContext(appIcon.bounds.size);
    [appIcon.layer renderInContext:UIGraphicsGetCurrentContext()];
    [SSAppController sharedInstance].appImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    appIcon.text = @"p";
    appIcon.textColor = [UIColor colorWithHexString:@"333333"];
    [appIcon sizeToFit];
    appIcon.width += 140;
    appIcon.height += 140;
    appIcon.textAlignment = NSTextAlignmentCenter;
    
    UIGraphicsBeginImageContext(appIcon.bounds.size);
    [appIcon.layer renderInContext:UIGraphicsGetCurrentContext()];
    [SSAppController sharedInstance].personImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    

    _btnSignup.hidden = YES;
    _termsText.width = self.view.width - 40;
    _termsText.x = 20;
    _termsText.text = @"By logging in, you agree to our\nTerms of Service & Privacy Policy";
    _btnForgot.hidden = YES;
    _btnLoginLarge.layer.cornerRadius = 15;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 15.f;
    paragraphStyle.maximumLineHeight = 18.f;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attrs = @{ NSParagraphStyleAttributeName :paragraphStyle,NSForegroundColorAttributeName:[[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.7]};
    
    
    NSRange range = [_termsText.text rangeOfString:@"Terms of Service"];
    NSRange range2 = [_termsText.text rangeOfString:@"Privacy Policy"];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:_termsText.text attributes:attrs];
    NSDictionary *subAttrs = @{NSForegroundColorAttributeName:[[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.8],
                               NSUnderlineStyleAttributeName : @1,
                               NSParagraphStyleAttributeName : paragraphStyle};
    [attributedText setAttributes:subAttrs range:range];
    [attributedText setAttributes:subAttrs range:range2];
    _termsText.attributedText = attributedText;
    
    
    _termsHitArea1 = [[UIButton alloc] initWithFrame:_termsText.frame];
    _termsHitArea1.x = _termsHitArea1.y = 0;
    _termsHitArea1.width = _termsText.width/2;
    [_termsText addSubview:_termsHitArea1];
    _termsText.userInteractionEnabled = YES;
    [_termsHitArea1 addTarget:self action:@selector(showTerms:) forControlEvents:UIControlEventTouchUpInside];
    
    _termsHitArea2 = [[UIButton alloc] initWithFrame:_termsText.frame];
    _termsHitArea2.width = _termsText.width/2;
    _termsHitArea2.x = _termsHitArea2.width;
    _termsHitArea2.y = 0;
    [_termsText addSubview:_termsHitArea2];
    _termsText.userInteractionEnabled = YES;
    [_termsHitArea2 addTarget:self action:@selector(showTerms:) forControlEvents:UIControlEventTouchUpInside];
    
    _inputEmail.y += 100;
    _inputPass.y += 100;

    _inputEmail.alpha = _inputPass.alpha = 0;
    [UIView animateWithDuration:0.5 delay:0.4 usingSpringWithDamping:0.56 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _inputEmail.y -= 100;
                         _termsVC.view.y = 0;
                         _inputEmail.alpha =  1;
                     } completion:^(BOOL finished) {
                         
                     }];
    [UIView animateWithDuration:0.5 delay:0.5 usingSpringWithDamping:0.56 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _inputPass.y -= 100;
                         _inputPass.alpha = 1;
                     } completion:^(BOOL finished) {
                         
                     }];
    
    
   
    if([SSAppController sharedInstance].isDemoApp){
        _inputEmail.text = @"sc@starsite.com";
        _inputPass.text = @"star";
        [self doLogin];
        return;
    }
    
    if([SSAppController sharedInstance].storedLogin != nil){
        _inputEmail.text = [NSString returnStringObjectForKey:@"username" withDictionary:[SSAppController sharedInstance].storedLogin];
        _inputPass.text = [NSString returnStringObjectForKey:@"pass" withDictionary:[SSAppController sharedInstance].storedLogin];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _doingLoginWithStoredData = YES;
            [self doLogin];
        });
    }
    
    if([SSAppController sharedInstance].isPinModeApp){
        _inputEmail.text = @"";
        _inputEmail.hidden = YES;
        _inputPass.placeholder = @"Enter Pin";
        _inputPass.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_inputPass.placeholder attributes:@{NSForegroundColorAttributeName: [[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.6]}];
    }
}

-(void)showTerms:(UIButton *)btn{
    [[SSAppController sharedInstance] hideKeyboard];
    if(!_termsVC){
        _termsVC = [[AppTermsViewController alloc] initWithNibName:@"AppTermsViewController" bundle:nil];
        _termsVC.view.frame = self.view.frame;
    }
    [self.view addSubview:_termsVC.view];

    [_termsVC showURL:(btn == _termsHitArea1) ? URL_TERMS : URL_PRIVACY];
    _termsVC.view.alpha = 0;
    _termsVC.view.y = 100;
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _termsVC.view.alpha = 1;
                         _termsVC.view.y = 0;
                     } completion:^(BOOL finished) {
                         
                     }];
    

}

-(IBAction)doLogin{
    
    if([SSAppController sharedInstance].cameFromInvite){
        [SSAppController sharedInstance].cameFromInvite = NO;
        return;
    }
    
    if(!_doingLoginWithStoredData){
        
        if([_inputEmail.text length] == 0){
            if(![SSAppController sharedInstance].isPinModeApp){
                [[SSAppController sharedInstance] showAlertWithTitle:@"Email Address" andMessage:@"A valid email address is required"];
                return;
            }
        }
        
        if([_inputPass.text length] == 0){
             [[SSAppController sharedInstance] showAlertWithTitle:@"Password" andMessage:@"Please enter your password"];
            return;
        }
    }

    [[SSAppController sharedInstance] hideKeyboard];

    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Logging In" andColor:nil];
    [self.view addSubview:_loadingScreen];


    NSMutableDictionary *dict = [SSAPIRequestBuilder APIDictionary];
    [dict addEntriesFromDictionary:@{@"email":_inputEmail.text,@"password":_inputPass.text}];
    
    NSString *url = [SSAPIRequestBuilder APIForLogin];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [SSAPIRequestBuilder APIAcceptableContentTypes];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [_loadingScreen removeFromSuperview];
        
        if([VTUtils isResponseSuccessful:responseObject]){            
            [[SSAppController sharedInstance] saveUserLoginUsername:_inputEmail.text andPassword:_inputPass.text];
            [[SSAppController sharedInstance] setupUserAndChannelWithDictionary:responseObject];
            
#ifdef SCROLLVIDEO
            [[SSAppController sharedInstance] routeToChannel];
#else
            //Check if they need to pair - welcome screen
            if([SSAppController sharedInstance].currentChannel.hasAtLeastOnePairing){
                [[SSAppController sharedInstance] routeToCompose];
            }else{
                [[SSAppController sharedInstance] routeToSocialPairing];
            }
#endif
            
        }else{
            if(!_doingLoginWithStoredData){
                [[SSAppController sharedInstance] alertWithServerResponse:responseObject];
            }
        }

        _doingLoginWithStoredData = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(!_doingLoginWithStoredData){
            [[SSAppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
            [_loadingScreen removeFromSuperview];
        }
        _doingLoginWithStoredData = NO;
    }];
}



- (void)keyboardWillShow:(NSNotification*)aNotification{
    CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    int allowed = self.view.height - _btnForgot.maxY;
    if(kbSize.height > allowed){
        int diff = kbSize.height - allowed;
        NSLog(@"Diff %d %f",diff,kbSize.height);
        _innerView.y = -diff;
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    _innerView.y = 0;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == _inputEmail){
        [_inputPass becomeFirstResponder];
        return NO;
    }
    [self doLogin];
    //[[SSAppController sharedInstance] routeToCompose];
    return YES;
}


- (IBAction)toggleLoginSignup:(UIButton *)sender {
    _btnLogin.selected = _btnSignup.selected = NO;
    sender.selected = YES;
    
}

@end
