//
//  SSChannel.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 10/3/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSChannel : NSObject

@property(nonatomic,strong) NSString *channelId;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *img;
@property(nonatomic,strong) NSString *totalReachDisplay;
@property(nonatomic,strong) NSNumber *weeklyPostingRate;
@property(nonatomic,strong) NSNumber *weeklyRevenueRate;

@property(nonatomic,assign) BOOL hasAtLeastOnePairing;



-(SSChannel *)initWithDictionary:(NSDictionary *)dict;


@end
