//
//  SSPairingBottomButton.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 3/10/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import "SSPairingBottomButton.h"

@implementation SSPairingBottomButton


-(void)setupWithDictionary:(NSDictionary *)dict{
    
    self.titleLabel.font = [UIFont fontWithName:FONT_ICONS size:18];
    [self setTitle:[dict objectForKey:@"icon"] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.alpha = 0.3;
    _completedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _isConnected = NO;
    
    int propertyId = [[dict objectForKey:@"propertyId"] intValue];
    _completedLabel.text = @"DISABLED";
    if([SSAppController sharedInstance].isDemoApp || [SSAppController sharedInstance].isPinModeApp){
        _completedLabel.text = @"ENABLED";
        _isConnected = YES;
    }
    
    for(SSParingItem *i in [SSAppController sharedInstance].pairingItems){
        if(i.pairingTypeId == propertyId){
            if(i.isConnected){
                _completedLabel.text = @"ENABLED";
                _isConnected = YES;
            }
        }
    }

    _completedLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:7];
    _completedLabel.textColor = [UIColor whiteColor];
    [_completedLabel sizeToFit];
    _completedLabel.x = self.width/2 - _completedLabel.width/2;
    _completedLabel.y = self.height - _completedLabel.height;
    [self addSubview:_completedLabel];
}

@end
