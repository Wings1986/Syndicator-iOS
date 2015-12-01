//
//  SSFBPageAccess.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 3/6/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import "SSFBPageAccess.h"

@implementation SSFBPageAccess


- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if (self) {
        
        [self addKeyValueFromDictionary:dict];
    }
    return  self;
}

-(void)addKeyValueFromDictionary:(NSDictionary *)dict{
    
    _accessToken = [NSString returnStringObjectForKey:@"access_token" withDictionary:dict];
    _category = [NSString returnStringObjectForKey:@"category" withDictionary:dict];
    _pid = [NSString returnStringObjectForKey:@"id" withDictionary:dict];
    _name = [NSString returnStringObjectForKey:@"name" withDictionary:dict];
    _perms = [NSArray arrayWithObject:[dict objectForKey:@"perms"]];

}


@end
