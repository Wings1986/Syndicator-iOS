//
//  SSAppController.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSAppController.h"
#import "SSDashboardViewController.h"
#import "SSCurateViewController.h"
#import "SSProjectionViewController.h"
#import "SSSettingsViewController.h"
#import "KeychainItemWrapper.h"
#import "AppTutorialViewController.h"
#import "UIView+MJAlertView.h"
#import "MultiVideoViewController.h"
#import "SSChannelViewController.h"
#import "SSHomeViewController.h"
#import "AppDelegate.h"

#define kKeychainUserCredentials @"com.starsite.starstatus"

static SSAppController *_instance;

@implementation SSAppController


#pragma mark - Singleton

+ (SSAppController *)sharedInstance {
    @synchronized(self)
    {
        if (_instance == nil) {
            _instance = [[self alloc] init];
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
                    CGSize result = [[UIScreen mainScreen] bounds].size;
                    CGFloat scale = [UIScreen mainScreen].scale;
                    result = CGSizeMake(result.width * scale, result.height * scale);
                }
            }else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
                    CGSize result = [[UIScreen mainScreen] bounds].size;
                    CGFloat scale = [UIScreen mainScreen].scale;
                    result = CGSizeMake(result.width * scale, result.height * scale);
                }
            }else{
            }
        }
    }
    return _instance;
}

-(void)initialize{

    
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    _isDemoApp = NO;
    _isPinModeApp = NO;
    _shouldShowMeTheMoney = NO;

    
    if([bundleId isEqualToString:@"com.starclub.starstatus.pin"]){
        _isPinModeApp = YES;
    }else if([bundleId isEqualToString:@"com.starclub.starstatus.demo"]){

    }
    
  // added pre-processor flags as bundle ID is not a good idea with multple versions
    
#if( IS_PIN )
    _isPinModeApp = YES;
#endif
#if( IS_DEMO )
    _isDemoApp = YES;
#endif
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredBackground:) name:NOTIFICATION_ENTERED_BACKGROUND object:nil];
    [self loadUserData];
    _screenBoundsSize = [[UIScreen mainScreen] bounds].size;
    _navController = [[SSRootNavigationController alloc] init];
    _uploaderHUD = [[VTUploadProgressViewController alloc] initWithNibName:@"VTUploadProgressViewController" bundle:nil];
    _uploaderHUD.view.width = _screenBoundsSize.width;
    _uploaderHUD.view.hidden = YES;
    _uploaderHUD.view.y = 18;
    [_navController.view addSubview:_uploaderHUD.view];

    //check if 1st time load, get data from safari cookie
    if([SSAppController sharedInstance].isDemoApp || [SSAppController sharedInstance].isPinModeApp){
        
    }else{
        NSString *alreadyCheckedCookie = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstTimeLoadedCheckCookiePage"];
        if([[NSString stringWithFormat:@"%@",alreadyCheckedCookie] isEqualToString:@"Y"]){
        
        }else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@auth.php?fromApp=1",WEB_SERVICE_ROOT]]];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"Y" forKey:@"firstTimeLoadedCheckCookiePage"];
            [defaults synchronize];
        }
    }
}


-(void)enteredBackground:(NSNotification *)note{
//    _wasInBackground = YES;
}

-(void)routeUserEntryPoint{
#ifdef SCROLLVIDEO
    [self routeUserToLogin];
#else
    if([[SSAppController sharedInstance] haveSeenTutorial]){
        [self routeUserToLogin];
    }else{
        AppTutorialViewController *vc = [[AppTutorialViewController alloc] initWithNibName:@"AppTutorialViewController" bundle:nil];
        _navController.viewControllers = @[vc];
    }
#endif
}

-(void)routeUserToLogin{
    _loginVC = [[SSIntroViewController alloc] initWithNibName:@"SSIntroViewController" bundle:nil];
    _navController.viewControllers = @[_loginVC];
}

-(void)routeToCompose{
    
    NSArray *viewControllers = _navController.viewControllers;
    if(!_composeVC || [viewControllers indexOfObject:_composeVC] == NSNotFound ){
        _composeVC = nil;
        _composeVC = [[SSComposeViewController alloc] initWithNibName:@"SSComposeViewController" bundle:nil];
        [_navController pushViewController:_composeVC animated:YES];
    }else{
        [_navController popToViewController:_composeVC animated:YES];
    }
}

-(void)routeToDashboard{
    SSDashboardViewController *vc = [[SSDashboardViewController alloc] initWithNibName:@"SSDashboardViewController" bundle:nil];
    [[SSAppController sharedInstance].navController pushViewController:vc animated:YES];
}

-(void)routeToCurated{
    SSCurateViewController *vc = [[SSCurateViewController alloc] initWithNibName:@"SSCurateViewController" bundle:nil];
    [[SSAppController sharedInstance].navController pushViewController:vc animated:YES];
}


-(void)routeToProjectionView{
    SSProjectionViewController *vc = [[SSProjectionViewController alloc] initWithNibName:@"SSProjectionViewController" bundle:nil];
    [_navController pushViewController:vc animated:YES];
}

-(void)routeToSocialPairing{
    SSPairingViewController *vc = [[SSPairingViewController alloc] initWithNibName:@"SSPairingViewController" bundle:nil];
    vc.initialAppPairing = YES;
    [_navController pushViewController:vc animated:YES];
}

-(void)routeToSocialPairingWithProperty:(SSParingItem *)property{
    SSPairingViewController *vc = [[SSPairingViewController alloc] initWithNibName:@"SSPairingViewController" bundle:nil];
    vc.startingProperty = property;
    [_navController pushViewController:vc animated:YES];
}

-(void)routeToSettings{
    
//    MultiVideoViewController*vc = [[MultiVideoViewController alloc] initWithNibName:@"MultiVideoViewController" bundle:nil];
//    [_navController pushViewController:vc animated:YES];
  
    SSSettingsViewController *vc = [[SSSettingsViewController alloc] initWithNibName:@"SSSettingsViewController" bundle:nil];
    [_navController pushViewController:vc animated:YES];

}

-(void)routeToChannel{
    
    UIViewController * vc =[[UIStoryboard storyboardWithName:@"vine" bundle:nil] instantiateViewControllerWithIdentifier:@"SSMyNavigationController"];
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.window.rootViewController = vc;
    
//    SSChannelViewController *vc = [[SSChannelViewController alloc] initWithNibName:@"SSChannelViewController" bundle:nil];
//    [_navController pushViewController:vc animated:YES];
}
-(void)routeToHomeFeed{
    SSHomeViewController *vc = [[SSHomeViewController alloc] initWithNibName:@"SSHomeViewController" bundle:nil];
    [_navController pushViewController:vc animated:YES];
}



-(void)goBack{
    [_navController popViewControllerAnimated:YES];
}

-(void)donePost{
    

    
    [[SSAppController sharedInstance].navController popViewControllerAnimated:YES];
 //   [NSThread sleepForTimeInterval:1.0];
    [[SSAppController sharedInstance].navController popViewControllerAnimated:YES];
    
    NSString *labelSaving = @"Curated! Please allow a few mins to see results!";
    
    [UIView addMJNotifierWithText:labelSaving dismissAutomatically:YES];
    
    
/*
    SSDashboardViewController *vc = [[SSDashboardViewController alloc] initWithNibName:@"SSDashboardViewController" bundle:nil];
    [[SSAppController sharedInstance].navController pushViewController:vc animated:YES];
 
 */
    [self checkIfPostToInstagram];
}

-(void)setupUserAndChannelWithDictionary:(NSDictionary *)dict{
    
    _currentUser = [[SSUser alloc] initWithDictionary:[dict objectForKey:@"user"]];
    _currentChannel = [[SSChannel alloc] initWithDictionary:[dict objectForKey:@"channel"]];
    BOOL atLeastOnePairing = NO;

    _pairingItems = [[NSMutableArray alloc] init];
    for(NSDictionary *d in [dict objectForKey:@"pairing"]){
        SSParingItem *pi = [[SSParingItem alloc] initWithDictionary:d];
        if(pi.isConnected)
            atLeastOnePairing = YES;
        [_pairingItems addObject:pi];
    }
    
    _currentChannel.hasAtLeastOnePairing = atLeastOnePairing;
    _showTheMoney = [[NSString returnStringObjectForKey:@"showmethemoney" withDictionary:dict] isEqualToString:@"Y"];
}


-(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)alertWithServerResponse:(NSDictionary *)dict{
    
    
    if([[[dict objectForKey:@"status"] stringValue] isEqualToString:@"-3"]){
        //upgrade
        _upgradeInfo = dict;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString returnStringObjectForKey:@"title" withDictionary:dict] message:[NSString returnStringObjectForKey:@"message" withDictionary:dict] delegate:nil cancelButtonTitle:[NSString returnStringObjectForKey:@"btn" withDictionary:dict] otherButtonTitles:nil];
        alert.delegate = self;
        alert.tag = 3;
        [alert show];
        return;
    }

    if([[dict objectForKey:@"message"] isNotEmpty]){
        if([[[dict objectForKey:@"status"] stringValue] isEqualToString:@"-1"]){
        }else{
            NSString *title = [[dict objectForKey:@"title"] isNotEmpty] ? [dict objectForKey:@"title"] : @"Error";
            [[SSAppController sharedInstance] showAlertWithTitle:title andMessage:[dict objectForKey:@"message"]];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 3){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString returnStringObjectForKey:@"url" withDictionary:_upgradeInfo]]];
    }
}

-(void)showAlertConnectionError{
    [self showAlertWithTitle:@"Connection Error" andMessage:@"Error connecting to the internet, please try again."];
}



-(void)checkIfPostToInstagram{
    
    NSString *caption = [_lastSharingData objectForKey:@"caption"];
    UIImage *image = [_lastSharingData objectForKey:@"image"];
    BOOL sendToInstagram = [[NSString returnStringObjectForKey:@"sendToInstagram" withDictionary:_lastSharingData] isEqualToString:@"Y"];

    if(sendToInstagram){
        NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
        
        if([[UIApplication sharedApplication] canOpenURL:instagramURL]){
            NSString *documentDirectory=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *saveImagePath=[documentDirectory stringByAppendingPathComponent:@"Image.igo"];
            NSData *imageData=UIImagePNGRepresentation(image);
            [imageData writeToFile:saveImagePath atomically:YES];
            NSURL *imageURL=[NSURL fileURLWithPath:saveImagePath];
            _docController=[[UIDocumentInteractionController alloc]init];
            _docController.delegate=self;
            _docController.UTI = @"com.instagram.exclusivegram";
            _docController.annotation=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",caption],@"InstagramCaption", nil];
            [_docController setURL:imageURL];
            [_docController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:[SSAppController sharedInstance].navController.view animated:YES];
        }
    }
}



- (void)doShareWithDictionary:(NSDictionary *)passedDict{
    
    _lastSharingData = passedDict;
    NSString *caption = [passedDict objectForKey:@"caption"];

    UIImage *image = [passedDict objectForKey:@"image"];
    NSURL *videoUrl = nil;
    if([[NSString returnStringObjectForKey:@"is_video" withDictionary:passedDict] isEqualToString:@"Y"]){
        videoUrl = [passedDict objectForKey:@"videoURL"];
    }
    
    NSString *file = @"…";
    CFStringRef fileExtension = (__bridge CFStringRef) [file pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    
    if (UTTypeConformsTo(fileUTI, kUTTypeImage)) NSLog(@"It's an image");
    else if (UTTypeConformsTo(fileUTI, kUTTypeMovie)) NSLog(@"It's a movie");
    else if (UTTypeConformsTo(fileUTI, kUTTypeText)) NSLog(@"It's text");
    
    CFRelease(fileUTI);
    
    NSMutableDictionary *dict = [SSAPIRequestBuilder APIDictionary];
    [dict addEntriesFromDictionary:@{@"pairing_data":[NSString base64Encode:[passedDict objectForKey:@"pairing_data"]],@"description":caption,@"type":(videoUrl) ? @"video" : @"photo"}];
    NSString *randomNumber = [NSString stringWithFormat:@"%u",arc4random() % 16];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [SSAPIRequestBuilder APIAcceptableContentTypes];
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST" URLString:[SSAPIRequestBuilder APIForPostContent] parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if(videoUrl){
            NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
            [formData appendPartWithFileData:videoData
                                        name:@"data"
                                    fileName:@"video.mp4"
                                    mimeType:@"video/mov"];
            
            NSData *data = UIImageJPEGRepresentation(image,1.0f);
            [formData appendPartWithFileData:data
                                        name:@"thumb"
                                    fileName:@"photo.jpg"
                                    mimeType:@"image/jpeg"];
        }else{
            NSData *data = UIImageJPEGRepresentation(image,1.0f);
            [formData appendPartWithFileData:data
                                        name:@"data"
                                    fileName:@"photo.jpg"
                                    mimeType:@"image/jpeg"];
            
        }
        
    } error:nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPLOAD_PROGRESS object:@{@"event":@"starting",@"uid":randomNumber}];
    
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPLOAD_PROGRESS object:@{@"event":@"finished",@"uid":randomNumber}];
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPLOAD_PROGRESS object:@{@"event":@"failed",@"uid":randomNumber}];
                                         [[SSAppController sharedInstance] showAlertWithTitle:@"Upload Failed" andMessage:@"Unable to upload content, please try again."];
                                     }];
    
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPLOAD_PROGRESS object:@{@"event":@"progress",@"uid":randomNumber,@"total":[NSNumber numberWithLongLong:totalBytesExpectedToWrite],@"totalDone":[NSNumber numberWithLongLong:totalBytesWritten]}];
    }];
    
    [operation start];
}


- (void)doCuratedShareWithDictionary:(NSDictionary *)passedDict{
    
    _lastSharingData = passedDict;
    NSString *caption = [passedDict objectForKey:@"caption"];
    
//    UIImage *image = [passedDict objectForKey:@"image"];
    NSString *viralId = [passedDict objectForKey:@"viralContentId"];
    NSString *mtype = ([passedDict objectForKey:@"is_video"]) ? @"video" : @"photo";
    
    NSMutableDictionary *dict = [SSAPIRequestBuilder APIDictionary];
    [dict addEntriesFromDictionary:@{@"pairing_data":[NSString base64Encode:[passedDict objectForKey:@"pairing_data"]],@"description":caption,@"type":mtype,@"viral_id":viralId}];
 //   NSString *randomNumber = [NSString stringWithFormat:@"%u",arc4random() % 16];

    
    NSString *url = [SSAPIRequestBuilder APIForPostCuratedContent];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [SSAPIRequestBuilder APIAcceptableContentTypes];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self donePost];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SSAppController clearTmpDirectory];
            
            });
            
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [[SSAppController sharedInstance] showAlertWithTitle:@"Curating Failed" andMessage:@"Unable to curate selected content, please try again."];
        
    }];
    
 

}



-(void)logout{
    [self removeAllData];
    [[SSAppController sharedInstance].navController popToRootViewControllerAnimated:YES];
}

-(void)hideKeyboard{
    UITextField *tempT = [[UITextField alloc] init];
    [_navController.view addSubview:tempT];
    [tempT becomeFirstResponder];
    [tempT resignFirstResponder];
    [tempT removeFromSuperview];
    tempT = nil;
}

-(UIView *)buildHideKeyboardViewWithTarget:(id)theTarget{
    UIView *keyboardHelper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenBoundsSize.width, 60)];
    keyboardHelper.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
    UIButton *hideKeyboard = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, keyboardHelper.width, keyboardHelper.height)];
    hideKeyboard.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0];
    hideKeyboard.titleLabel.textAlignment = NSTextAlignmentCenter;
    [hideKeyboard addTarget:theTarget action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchDown];
    [keyboardHelper addSubview:hideKeyboard];

    NSString *nTitle = @"Hide Keyboard D";
    int iconTextSize = 10;
    NSRange range = NSMakeRange([nTitle length]-1,1);
    
    
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,
                              [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:14], NSFontAttributeName,
                              nil];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [UIFont fontWithName:FONT_ICONS size:iconTextSize], NSFontAttributeName,
                           [UIColor colorWithHexString:COLOR_GOLD], NSForegroundColorAttributeName,nil];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:nTitle attributes:attrs];
    [attributedText setAttributes:subAttrs range: NSMakeRange(0,range.location)];
    [hideKeyboard setAttributedTitle:attributedText forState:UIControlStateNormal];
    return keyboardHelper;
}


#pragma mark STORAGE

+ (void)clearTmpDirectory{
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}

-(BOOL)haveSeenTutorial{
    
    BOOL seenTutorial = [[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"seenTutorial"]] isEqualToString:@"Y"];
    if(seenTutorial){
        return YES;
    }
    return NO;
}

-(void)saveSeenTutorial{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Y" forKey:@"seenTutorial"];
    [defaults synchronize];
}

-(void)saveUserLoginUsername:(NSString *)username andPassword:(NSString *)password{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username forKey:@"username"];
    [defaults setObject:password forKey:@"password"];
    [defaults synchronize];
    _storedLogin = [[NSDictionary alloc] initWithObjectsAndKeys:username,@"username",password,@"pass", nil];
}

-(void)loadUserData{
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    _storedLogin = [[NSDictionary alloc] initWithObjectsAndKeys:username,@"username",password,@"pass", nil];
}

-(void)removeAllData{
    _storedLogin = nil;
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
}







@end
