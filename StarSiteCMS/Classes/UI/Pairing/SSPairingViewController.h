//
//  SSPairingViewController.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 10/21/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSViewController.h"
#import "TWTAPIManager.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>

#define kSSPairServiceFacebook @"SSPairServiceFacebook"
#define kSSPairServiceTwitter @"SSPairServiceTwitter"
#define kSSPairServiceTumblr @"SSPairServiceTumblr"
#define kSSPairServiceInstagram @"SSPairServiceInstagram"
#define kSSPairServiceGooglePlus @"kSSPairServiceGooglePlus"
#define kSSPairServicePinterest @"SSPairServicePinterest"


@interface SSPairingViewController : SSViewController<UIActionSheetDelegate,FBLoginViewDelegate,UIAlertViewDelegate>{
    UIView *_loadingScreen;
    int _stepIdx;
    NSTimer *_glowLogo;
    float _glowSpeed;
    BOOL _isAnimating;
    ACAccountStore *_accountStore;
    NSArray *_accounts;
    TWTAPIManager *_apiManager;
    NSMutableArray *_stepConfig;
    NSString *_currentService;
    UIScrollView *_accountSelectView;
    NSDictionary *_initialPositions;
    NSMutableArray *_pairedTwitterAccounts;
    
    UIView *_bottomSteps;
    UIView *_doneScreen;
    UIButton *_btnNext;
    
    NSMutableArray *_accountsForProperty;
    UIView *_webviewHolderForPairing;
    UIButton *_webviewBtnClose;
    UIWebView *_webviewForPairing;
    
    UIAlertView *_alertPermissions;
    NSString *_returnedFBUserData;
    SSParingItem *_currentPropertyInView;
    int _totalConnectedProperties;
}

@property (strong, nonatomic) IBOutlet UILabel *topTitle;
@property (strong, nonatomic) IBOutlet UIView *swappableView;
@property (strong, nonatomic) IBOutlet UILabel *logo;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UILabel *titleRowOne;
@property (strong, nonatomic) IBOutlet UILabel *titleRowTwo;
@property (strong, nonatomic) IBOutlet UIButton *titleBtn;
@property (strong, nonatomic) IBOutlet UIButton *btnOver;
@property (strong, nonatomic) IBOutlet UIButton *btnSkip;
@property (strong, nonatomic) IBOutlet UITextView *titleDesc;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (assign, nonatomic) BOOL initialAppPairing;
@property (strong, nonatomic) IBOutlet SSParingItem *startingProperty;


- (IBAction)btnPressed:(id)sender;
- (IBAction)skipPressed:(id)sender;
- (IBAction)goBack:(id)sender;

@end
