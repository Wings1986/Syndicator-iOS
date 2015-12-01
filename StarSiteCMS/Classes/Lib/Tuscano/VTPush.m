//
//  VTPush.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 6/15/15.
//  Copyright (c) 2013 Vincent Tuscano. All rights reserved.
//

#import "VTPush.h"


static VTPush *_instance;

@implementation VTPush


+ (VTPush *)sharedInstance {
    @synchronized(self){
        if (_instance == nil) {
            _instance = [[self alloc] init];
            [_instance getUserLocationDetails];
        }
    }
    return _instance;
}



-(void)setDeviceToken:(NSData *)token{
    NSString *deviceTokenAsString = [[[[token description]
                                       stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                      stringByReplacingOccurrencesOfString: @">" withString: @""]
                                     stringByReplacingOccurrencesOfString: @" " withString: @""];

    _deviceToken = deviceTokenAsString;
    [self sendUpdatedDeviceToken];
}

-(void)requestPushAccess{
    
    
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
}

-(void)setUserId:(NSString *)userId{
    _userId = userId;
    [self sendUpdatedDeviceToken];
}

-(void)resetBadgeToZero{
    if([UIApplication sharedApplication].applicationIconBadgeNumber > 0){
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
}

-(void)notificationReceived:(NSDictionary*)userInfo{
    
    NSString *alertValue = [[userInfo valueForKey:@"aps"] valueForKey:@"badge"];
    if ([UIApplication sharedApplication].applicationState  == UIApplicationStateActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PUSH_RECEIVED object:userInfo];
    }
}

-(void)checkRemoteStatus:(UIUserNotificationSettings *)notificationSettings{
    
    if(notificationSettings == nil){
        
    }else{
        
        if(notificationSettings.types == UIUserNotificationTypeNone){
            [[SSAppController sharedInstance] showAlertWithTitle:@"Push Notifications Are Off" andMessage:@"You will need to enable push notifcations to receive alerts. Please enable them in your device settings under \"Notification Center\" "];
        }
    }
    
}

-(void)getUserLocationDetails{

    _locationDetails = @{};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [SSAPIRequestBuilder APIAcceptableContentTypes];
    [manager POST:@"http://ip-api.com/json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @try{
            _locationDetails = responseObject;
        }@catch(NSException *e){
            _locationDetails = @{};
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {}];
    
}


-(void)sendUpdatedDeviceToken{
    if(!_deviceToken){
        return;
    }

    if(_locationDetails == nil){
        _locationDetails = @{};
    }
    
    NSMutableDictionary *dict = [SSAPIRequestBuilder APIDictionary];
    [dict setObject:_deviceToken forKey:@"device_token"];
    [dict setObject:_locationDetails forKey:@"loc"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [SSAPIRequestBuilder APIAcceptableContentTypes];
    [manager POST:[SSAPIRequestBuilder APIForUpdateDeviceId] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {}];
}


@end


