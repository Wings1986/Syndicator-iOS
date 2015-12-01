//
//  SCItem.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 1/15/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import "SCItem.h"

@implementation SCItem


- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if (self) {
        
        [self addKeyValueFromDictionary:dict];
    }
    return  self;
}

-(void)addKeyValueFromDictionary:(NSDictionary *)dict{
    
#ifdef API_3_4
    
    
    _itemId = [NSString returnStringObjectForKey:@"id" withDictionary:dict];
    _postId = [NSString returnStringObjectForKey:@"postId" withDictionary:dict];
    _thumbnail = [NSString returnStringObjectForKey:@"thumbnail" withDictionary:dict];
    _message = [NSString returnStringObjectForKey:@"message" withDictionary:dict];
    
    _fb_likes = [NSString returnStringObjectForKey:@"fb_likes" withDictionary:dict];
    _fb_shares = [NSString returnStringObjectForKey:@"fb_shares" withDictionary:dict];
    _fb_comments = [NSString returnStringObjectForKey:@"fb_comments" withDictionary:dict];
    _fb_reaches = [NSString returnStringObjectForKey:@"fb_reaches" withDictionary:dict];
    
    _tw_retweets = [NSString returnStringObjectForKey:@"tw_retweets" withDictionary:dict];
    _tw_favorites = [NSString returnStringObjectForKey:@"tw_favorites" withDictionary:dict];
    
    _gp_likes = [NSString returnStringObjectForKey:@"gp_likes" withDictionary:dict];
    _gp_comments = [NSString returnStringObjectForKey:@"gp_comments" withDictionary:dict];
    
    _tu_likes = [NSString returnStringObjectForKey:@"tu_likes" withDictionary:dict];
    _tu_comments = [NSString returnStringObjectForKey:@"tu_comments" withDictionary:dict];
    
    _ss_impressions = [NSString returnStringObjectForKey:@"ss_impressions" withDictionary:dict];
    _ss_engagements = [NSString returnStringObjectForKey:@"ss_engagement" withDictionary:dict];
    _message = [NSString returnStringObjectForKey:@"message" withDictionary:dict];
    _created = [NSString returnStringObjectForKey:@"created" withDictionary:dict];
    _ss_earnings = [NSString returnStringObjectForKey:@"ss_earnings" withDictionary:dict];
    _ss_earningsTitle = [NSString returnStringObjectForKey:@"ss_earnings_title" withDictionary:dict];
    _ss_videoViews = [NSString returnStringObjectForKey:@"ss_videoViews" withDictionary:dict];
    _ss_pageViews = [NSString returnStringObjectForKey:@"ss_pageViews" withDictionary:dict];
    
    _url = [NSString returnStringObjectForKey:@"url" withDictionary:dict];
    _embed = [NSString base64Decode:[NSString returnStringObjectForKey:@"embed" withDictionary:dict]];
    _fileURL = [NSString returnStringObjectForKey:@"fileURL" withDictionary:dict];

    
    _ss_videoLengthHuman = [NSString returnStringObjectForKey:@"ss_videolengthhuman" withDictionary:dict];
    _ss_videoLengthAndPercent = [NSString returnStringObjectForKey:@"ss_videoengagement" withDictionary:dict];
    
    _postType = [NSString returnStringObjectForKey:@"post_type" withDictionary:dict];
    _videoId = [NSString returnStringObjectForKey:@"video_db_id" withDictionary:dict];
    _photoId = [NSString returnStringObjectForKey:@"photo_db_id" withDictionary:dict];
    
    
#endif
    
#ifdef API_3_3
    
    
    
    
    
#endif
    
    
    if([_photoId isNotEmpty]){
        _isPhoto = YES;
    }
    
    _createdDate = [[dict objectForKey:@"created_time"] floatValue];
}


@end
