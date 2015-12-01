//
//  SSSettingsCollectionViewCell.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 3/10/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import "SSSettingsCollectionViewCell.h"

@implementation SSSettingsCollectionViewCell

- (void)awakeFromNib {
    self.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2].CGColor;
    self.layer.borderWidth = 1;
}


-(void)setupCellWithItem:(SSParingItem *)item{
    [item checkPairingStatus];
    _title.text = item.title;
    _icon.text = item.icon;
    UIColor *statusColor = [UIColor greenColor];
    self.backgroundColor = [[UIColor colorWithHexString:@"000000"] colorWithAlphaComponent:0.2];
    self.layer.cornerRadius = 10;
    NSString *nTitle = [NSString stringWithFormat:@"%@ V",_title.text];
    
    if([SSAppController sharedInstance].isDemoApp || [SSAppController sharedInstance].isPinModeApp){
        item.atLeastOne = YES;
    }
    
    if(!item.atLeastOne){
        nTitle = @"NOT\nCONNECTED";
        _title.numberOfLines = 2;
        statusColor = [UIColor redColor];
    }else{
        nTitle = @"CONNECTED";
        _title.numberOfLines = 1;
    }
    
    _title.text = nTitle;
    _title.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:8];
    _title.textColor = statusColor;    
}


@end
