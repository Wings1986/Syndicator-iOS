//
//  SSChannel.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 10/3/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSChannel.h"

@implementation SSChannel

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if (self) {
        
        [self addKeyValueFromDictionary:dict];
    }
    return  self;
}

-(void)addKeyValueFromDictionary:(NSDictionary *)dict{
    
    _channelId = [NSString returnStringObjectForKey:@"id" withDictionary:dict];
    _name = [NSString returnStringObjectForKey:@"name" withDictionary:dict];
    _img = [NSString returnStringObjectForKey:@"img" withDictionary:dict];
    _totalReachDisplay = [NSString returnStringObjectForKey:@"total_reach_display" withDictionary:dict];

    _weeklyPostingRate = [NSNumber numberWithInt:[[NSString returnStringObjectForKey:@"weekly_post_rate" withDictionary:dict] intValue]];
    _weeklyRevenueRate = [NSNumber numberWithFloat:[[NSString returnStringObjectForKey:@"weekly_revenue_rate" withDictionary:dict] floatValue]];

}


@end
