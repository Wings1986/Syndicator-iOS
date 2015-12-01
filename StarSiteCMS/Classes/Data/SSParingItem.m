//
//  SSParingItem.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 3/10/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import "SSParingItem.h"

@implementation SSParingItem

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if (self) {
        
        [self addKeyValueFromDictionary:dict];
    }
    return  self;
}

-(void)addKeyValueFromDictionary:(NSDictionary *)dict{

    _pairingId = [NSString returnStringObjectForKey:@"id" withDictionary:dict];
    _title = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
    _token = [NSString returnStringObjectForKey:@"token" withDictionary:dict];
    _img = [NSString returnStringObjectForKey:@"img" withDictionary:dict];
    _icon = [NSString returnStringObjectForKey:@"icon" withDictionary:dict];
    _colorHex = [NSString returnStringObjectForKey:@"color" withDictionary:dict];
    _authURL = [NSString returnStringObjectForKey:@"auth_url" withDictionary:dict];
    
    _isConnected = [[NSString returnStringObjectForKey:@"connected" withDictionary:dict] isEqualToString:@"Y"];
    _atLeastOne = NO;
    if(_isConnected){
        _connectedPages = [[NSArray alloc] initWithArray:[dict objectForKey:@"connected_pages"]];
        [self checkPairingStatus];
    }else{

    }

    _hideCaptionOption = [[NSString returnStringObjectForKey:@"hide_caption" withDictionary:dict] isEqualToString:@"Y"];
    if([_pairingId isEqualToString:@"1"]){
        _pairingTypeId = SSParingTypeFacebook;
    }else if([_pairingId isEqualToString:@"2"]){
        _pairingTypeId = SSParingTypeTwitter;
    }else if([_pairingId isEqualToString:@"3"]){
        _pairingTypeId = SSParingTypeInstagram;
    }else if([_pairingId isEqualToString:@"4"]){
        _pairingTypeId = SSParingTypeTumblr;
    }
}

-(void)checkPairingStatus{
    _atLeastOne = NO;
    for(NSDictionary *d in _connectedPages){
        if([[NSString returnStringObjectForKey:@"active" withDictionary:d] isEqualToString:@"Y"]){
            _atLeastOne = YES;
        }
    }
}


+(void)findAndReplacePairingItemActiveStateWithDictionary:(NSDictionary *)dict{
    
    NSLog(@"Item passed :%@",dict);
    
    for(SSParingItem *i in [SSAppController sharedInstance].pairingItems){
        NSLog(@"Item :%@",i);
        
        for(NSDictionary *d in i.connectedPages){
            NSLog(@"Item D :%@",d);
            if([[NSString returnStringObjectForKey:@"id" withDictionary:d] isEqualToString:[NSString returnStringObjectForKey:@"id" withDictionary:dict]]){
                NSLog(@"MATCH-----> !");
                
                NSMutableArray *newPagesData = [[NSMutableArray alloc] init];
                
                for(NSDictionary *subD in i.connectedPages){
                    NSMutableDictionary *newMD = [NSMutableDictionary dictionaryWithDictionary:subD];
                    
                    if([[NSString returnStringObjectForKey:@"id" withDictionary:newMD] isEqualToString:[NSString returnStringObjectForKey:@"id" withDictionary:dict]]){
                        newMD = [NSMutableDictionary dictionaryWithDictionary:dict];
                    }
                    [newPagesData addObject:newMD];
                }
                NSLog(@"NEW SET -----> %@",newPagesData);
                i.connectedPages = [NSArray arrayWithArray:newPagesData];
                NSLog(@"NEW SET2 -----> %@",i.connectedPages);
                
                return;
                
            }
        }
    }
}



@end
