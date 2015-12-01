//
//  SSUser.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 10/3/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSUser : NSObject


@property(nonatomic,strong) NSString *token;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *img;


-(SSUser *)initWithDictionary:(NSDictionary *)dict;


@end
