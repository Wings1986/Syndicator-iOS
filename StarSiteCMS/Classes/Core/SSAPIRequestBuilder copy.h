//
//  SSAPIRequestBuilder.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 10/3/14.
//  Copyright (c) 2014 StarClub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSAPIRequestBuilder : NSObject


+(NSSet *)APIAcceptableContentTypes;
+(NSString *)APISuffix;
+(NSMutableDictionary *)APIDictionary;

+(NSString *)APIForLogin;
+(NSString *)APIForRegister;
+(NSString *)APIForForgotPass;

+(NSString *)APIForPostText;
+(NSString *)APIForPostPhoto;
+(NSString *)APIForPostVideo;



+(NSString *)APIForGetDashboardData;


@end
