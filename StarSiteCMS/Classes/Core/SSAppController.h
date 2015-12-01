//
//  SSAppController.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSRootNavigationController.h"
#import "SSIntroViewController.h"
#import "SSComposeViewController.h"
#import "VTUploadProgressViewController.h"
#import "SSPairingViewController.h"
#import <UIKit/UIKit.h>
#include "VTUtils.h"

@interface SSAppController : NSObject<UIAlertViewDelegate, UIDocumentInteractionControllerDelegate>{
    SSIntroViewController *_loginVC;
    SSComposeViewController *_composeVC;
    VTUploadProgressViewController *_uploaderHUD;
    NSDictionary *_upgradeInfo;
    UIDocumentInteractionController *_docController;
    NSDictionary *_lastSharingData;
}

@property(nonatomic,strong) SSRootNavigationController *navController;
@property(nonatomic,assign) CGSize screenBoundsSize;
@property(nonatomic,strong) SSUser *currentUser;
@property(nonatomic,strong) SSChannel *currentChannel;
@property(nonatomic,strong) NSMutableArray *pairingItems;
@property(nonatomic,strong) UIImage *appImage;
@property(nonatomic,strong) UIImage *personImage;
@property(nonatomic,assign) BOOL wasInBackground;
@property(nonatomic,assign) BOOL cameFromInvite;
@property(nonatomic,strong) NSDictionary *storedLogin;
@property(nonatomic,assign) BOOL showTheMoney;
@property(nonatomic,assign) BOOL isDemoApp;
@property(nonatomic,assign) BOOL isPinModeApp;
@property(nonatomic,assign) BOOL shouldShowMeTheMoney;


+ (SSAppController *)sharedInstance;
-(void)initialize;
-(void)routeUserToLogin;
-(void)routeUserEntryPoint;
-(void)routeToCompose;
-(void)routeToProjectionView;
-(void)routeToSocialPairing;
-(void)routeToSocialPairingWithProperty:(SSParingItem *)property;
-(void)routeToSettings;
-(void)routeToChannel;
-(void)routeToHomeFeed;

-(void)goBack;
-(void)logout;
-(void)donePost;
-(void)hideKeyboard;
-(void)setupUserAndChannelWithDictionary:(NSDictionary *)dict;
-(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message;
-(void)alertWithServerResponse:(NSDictionary *)dict;
-(void)showAlertConnectionError;
-(void)routeToDashboard;
-(void)routeToCurated;
-(void)doShareWithDictionary:(NSDictionary *)passedDict;
-(void)doCuratedShareWithDictionary:(NSDictionary *)passedDict;
-(void)saveUserLoginUsername:(NSString *)username andPassword:(NSString *)password;
-(void)loadUserData;
-(BOOL)haveSeenTutorial;
-(void)saveSeenTutorial;
-(void)removeAllData;
+ (void)clearTmpDirectory;
-(UIView *)buildHideKeyboardViewWithTarget:(id)theTarget;
@end
