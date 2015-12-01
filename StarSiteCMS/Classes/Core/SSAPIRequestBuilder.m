//
//  SSAPIRequestBuilder.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 10/3/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSAPIRequestBuilder.h"

@implementation SSAPIRequestBuilder


+(NSSet *)APIAcceptableContentTypes{
    return [NSSet setWithObjects:@"text/plain",@"application/json",@"text/html", nil];
}

+(NSMutableDictionary *)APIDictionary{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if([[SSAppController sharedInstance].currentUser.token isNotEmpty]){
        [dict setObject:[SSAppController sharedInstance].currentUser.token forKey:@"token"];
    }
    if([[SSAppController sharedInstance].currentChannel.channelId isNotEmpty]){
        [dict setObject:[SSAppController sharedInstance].currentChannel.channelId forKey:@"channel_id"];
    }
    return dict;
}

+(NSString *)APISuffix{
    return [NSString stringWithFormat:@"?apiversion=%@&nd=%@&smm=%@&pm=%@",API_VERSION_NUMBER,(![SSAppController sharedInstance].isDemoApp) ? @"1" : @"0",([SSAppController sharedInstance].shouldShowMeTheMoney) ? @"Y" : @"0",([SSAppController sharedInstance].isPinModeApp) ? @"Y" : @"0"];
}

+(NSString *)APIAddKeyObjects:(NSMutableDictionary *)dict toString:(NSString *)str{
    for(NSString *i in dict){
        str = [str stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",i,[dict objectForKey:i]]];
    }
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(NSString *)APIForLogin{
    return [NSString stringWithFormat:@"%@login/%@",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
}

+(NSString *)APIForStoreSocialKeys{
    return [NSString stringWithFormat:@"%@storeSocialKeys/%@",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
}

+(NSString *)APIForUpdateSocialKeyStatus{
    return [NSString stringWithFormat:@"%@updateSocialKeyStatus/%@",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
}

+(NSString *)APIForHeatMapData{
    return [NSString stringWithFormat:@"%@heatMapData/%@",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
}

+(NSString *)APIForGetDashboardData{
    return [NSString stringWithFormat:@"%@dashboardData/%@",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
}

+(NSString *)APIForGetCuratedData{
        return [NSString stringWithFormat:@"%@curateData/%@",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
 //   return [NSString stringWithFormat:@"%@dashboardData/%@",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
    
}

+(NSString *)APIForPostContent{
    return [NSString stringWithFormat:@"%@post/%@",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
}

+(NSString *)APIForPostCuratedContent{
    return [NSString stringWithFormat:@"%@curatePost/%@",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
}

+(NSString *)APIUpdateAvatar{
    return [NSString stringWithFormat:@"%@updateAvatar/%@",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
}

+(NSString *)APIForDeletePost{
    return [NSString stringWithFormat:@"%@deletePost/%@",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
}

+(NSString *)APIForUpdatePost{
    return [NSString stringWithFormat:@"%@updatePost/%@",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
}

+(NSString *)APIForUpdateDeviceId{
    return [NSString stringWithFormat:@"%@updatePushDeviceId/%@",WEB_SERVICE_ROOT,[SSAPIRequestBuilder APISuffix]];
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





@end
