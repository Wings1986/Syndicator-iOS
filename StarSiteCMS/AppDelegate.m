//
//  AppDelegate.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    [[SSAppController sharedInstance] initialize];
    UINavigationController *nav = [[SSAppController sharedInstance] navController];
    nav.navigationBarHidden = YES;
    [[VTPush sharedInstance] setAccountId:@"STARSITEAPP"];
    [[SSAppController sharedInstance] routeUserEntryPoint];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENTERED_BACKGROUND object:@{}];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[VTPush sharedInstance] resetBadgeToZero];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENTERED_FOREGROUND object:@{}];
}
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    [[VTPush sharedInstance] setDeviceToken:deviceToken];
}
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    [[VTPush sharedInstance] checkRemoteStatus:nil];
}
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    [[VTPush sharedInstance] checkRemoteStatus:notificationSettings];
}
-(void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo{
    [[VTPush sharedInstance] notificationReceived:userInfo];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    BOOL wasHandled;
    
    if([url.scheme isEqualToString:@"com.starsite.cms"]){
        NSArray *queryPairs = [url.absoluteString componentsSeparatedByString:@"/"];
        
        if([queryPairs containsObject:@"tumblr-pair"]){
            NSString *returnedId = [queryPairs lastObject];

            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_SOCIAL_OAUTH_ID_PAIRED object:@{@"pairing_service":[NSNumber numberWithInt:SSParingTypeTumblr],@"db_id":returnedId}];
        }else if([queryPairs containsObject:@"instagram-pair"]){
            NSString *returnedId = [queryPairs lastObject];

            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_SOCIAL_OAUTH_ID_PAIRED object:@{@"pairing_service":[NSNumber numberWithInt:SSParingTypeInstagram],@"db_id":returnedId}];
        }else if([queryPairs containsObject:@"login-page"] || [queryPairs containsObject:@"login-email"]){
            NSString *json = [NSString base64Decode:[queryPairs lastObject]];
            if([json length] < 8){
                json = [NSString base64Decode:[queryPairs objectAtIndex:[queryPairs count]-2]];
            }
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"Y" forKey:@"firstTimeLoadedCheckCookiePage"];
            [defaults synchronize];
            
            if(json != nil){

                NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                NSString *email = [NSString returnStringObjectForKey:@"email" withDictionary:jsonObject];
                NSString *pass = [NSString returnStringObjectForKey:@"pass" withDictionary:jsonObject];
                
                if([queryPairs containsObject:@"login-page"]){
                    [SSAppController sharedInstance].cameFromInvite = YES;
                    [[SSAppController sharedInstance] saveUserLoginUsername:email andPassword:pass];
                    [[SSAppController sharedInstance] loadUserData];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_LOGIN_DETAILS object:nil];
                }else{
                    [[SSAppController sharedInstance] logout];
                    [SSAppController sharedInstance].cameFromInvite = YES;
                    [[SSAppController sharedInstance] saveUserLoginUsername:email andPassword:pass];
                    [[SSAppController sharedInstance] loadUserData];
                    [[SSAppController sharedInstance] routeUserEntryPoint];
                }
            }
            wasHandled = YES;
        }
        
    }else{
        wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    }
    
    return wasHandled;
}


@end
