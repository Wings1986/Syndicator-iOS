//
//  SSFBPageAccess.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 3/6/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSFBPageAccess : NSObject


@property(nonatomic,strong) NSString *accessToken;
@property(nonatomic,strong) NSString *category;
@property(nonatomic,strong) NSString *pid;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSArray *perms;


-(SSFBPageAccess *)initWithDictionary:(NSDictionary *)dict;



@end
