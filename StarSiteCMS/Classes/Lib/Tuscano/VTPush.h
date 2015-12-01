//
//  VTPush.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 6/15/15.
//  Copyright (c) 2013 Vincent Tuscano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTPush : NSObject{
    NSString *_deviceToken;
    NSString *_accountId;
    NSDictionary *_locationDetails;
}


+(VTPush *)sharedInstance;

@property(strong,nonatomic) NSString *accountId;
@property(strong,nonatomic) NSString *userId;

-(void)requestPushAccess;
-(void)setAccountId:(NSString *)token;
-(void)setUserId:(NSString *)userId;
-(void)setDeviceToken:(NSData *)token;
-(void)sendUpdatedDeviceToken;
-(void)resetBadgeToZero;
-(void)checkRemoteStatus:(UIUserNotificationSettings *)notificationSettings;
-(void)notificationReceived:(NSDictionary*)userInfo;


@end
