//
//  SSUser.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 10/3/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSUser.h"

@implementation SSUser

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if (self) {
        
        [self addKeyValueFromDictionary:dict];
    }
    return  self;
}

-(void)addKeyValueFromDictionary:(NSDictionary *)dict{
    
    _name = [NSString returnStringObjectForKey:@"name" withDictionary:dict];
    _token = [NSString returnStringObjectForKey:@"token" withDictionary:dict];
    _img = [NSString returnStringObjectForKey:@"img" withDictionary:dict];
}

@end
