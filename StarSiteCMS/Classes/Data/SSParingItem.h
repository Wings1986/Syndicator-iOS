//
//  SSParingItem.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 3/10/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SSParingTypeNone = 0,
    SSParingTypeFacebook,
    SSParingTypeTwitter,
    SSParingTypeInstagram,
    SSParingTypeTumblr
} SSParingTypeId;



@interface SSParingItem : NSObject



@property(nonatomic,strong) NSString *token;
@property(nonatomic,strong) NSString *pairingId;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *authURL;
@property(nonatomic,strong) NSString *colorHex;
@property(nonatomic,strong) NSString *img;
@property(nonatomic,strong) NSString *icon;
@property(nonatomic,strong) NSArray *connectedPages;

@property(nonatomic,assign) BOOL isConnected;

@property(nonatomic,assign) BOOL atLeastOne;
@property(nonatomic,assign) BOOL hideCaptionOption;

@property(nonatomic,assign) SSParingTypeId pairingTypeId;


-(SSParingItem *)initWithDictionary:(NSDictionary *)dict;
-(void)checkPairingStatus;

+(void)findAndReplacePairingItemActiveStateWithDictionary:(NSDictionary *)dict;

@end
