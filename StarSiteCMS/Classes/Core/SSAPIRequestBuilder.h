//
//  SSAPIRequestBuilder.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 10/3/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSAPIRequestBuilder : NSObject


+(NSSet *)APIAcceptableContentTypes;
+(NSString *)APISuffix;
+(NSMutableDictionary *)APIDictionary;

+(NSString *)APIForLogin;
+(NSString *)APIForPostContent;
+(NSString *)APIForPostCuratedContent;
+(NSString *)APIForStoreSocialKeys;
+(NSString *)APIForHeatMapData;
+(NSString *)APIForUpdateSocialKeyStatus;
+(NSString *)APIForPostText;
+(NSString *)APIForPostPhoto;
+(NSString *)APIForPostVideo;
+(NSString *)APIForDeletePost;
+(NSString *)APIForUpdatePost;
+(NSString *)APIUpdateAvatar;
+(NSString *)APIForGetDashboardData;
+(NSString *)APIForGetCuratedData;
+(NSString *)APIForUpdateDeviceId;

@end
