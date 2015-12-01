//
//  SSAPIRequestBuilder.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 10/3/14.
//  Copyright (c) 2014 StarClub. All rights reserved.
//

#import "SSAPIRequestBuilder.h"

@implementation SSAPIRequestBuilder




+(NSSet *)APIAcceptableContentTypes{
    return [NSSet setWithObjects:@"text/plain",@"application/json",@"text/html", nil];
}

+(NSMutableDictionary *)APIDictionary{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if([[SSAppController sharedInstance].currentUser.userId isNotEmpty])
        [dict setObject:[SSAppController sharedInstance].currentUser.userId forKey:@"user_id"];
    
    if([[SSAppController sharedInstance].currentUser.token isNotEmpty])
        [dict setObject:[SSAppController sharedInstance].currentUser.token forKey:@"token"];
    
    return dict;
}

+(NSString *)APISuffix{
    return [NSString stringWithFormat:@"&cid=%@&apiversion=%@",[SSAppController sharedInstance].channelId,API_VERSION_NUMBER];
}

+(NSString *)APIAddKeyObjects:(NSMutableDictionary *)dict toString:(NSString *)str{
    for(NSString *i in dict){
        str = [str stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",i,[dict objectForKey:i]]];
    }
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(NSString *)APIForLogin{
    return [NSString stringWithFormat:@"%@option=login&ud_token=123455%@&",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
}

+(NSString *)APIForRegister{
    return [NSString stringWithFormat:@"%@option=register%@&",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
}

+(NSString *)APIForForgotPass{
    return [NSString stringWithFormat:@"%@option=forgotPass%@&",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
}

+(NSString *)APIForPostText{
    return [NSString stringWithFormat:@"%@option=add_text%@&",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
}

+(NSString *)APIForPostPhoto{
    return [NSString stringWithFormat:@"%@option=add_photo%@&",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
}

+(NSString *)APIForPostVideo{
    return [NSString stringWithFormat:@"%@option=add_video%@&",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
}



+(NSString *)APIForGetDashboardData{
    return [NSString stringWithFormat:@"%@a=dashboardData&%@&",WEB_SERVICE_STATS_ROOT,[SSAPIRequestBuilder APISuffix]];
}



@end
