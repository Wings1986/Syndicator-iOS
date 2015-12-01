//
//  SSDashTableViewCell.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSDashTableViewCell.h"

@implementation SSDashTableViewCell

- (void)awakeFromNib {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addBottomBorderWithHeight:0.5 andColor:[UIColor colorWithHexString:COLOR_GRAY_LINE]];
    });
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    _itemImage.image = nil;
    _itemImage.layer.cornerRadius = 0;
    _itemImage.layer.borderColor = [[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.1].CGColor;
    _itemImage.layer.borderWidth = 1;
    _itemValue.alpha = 0.5;
    _itemImage.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    if(selected){
        self.backgroundColor = [UIColor colorWithHexString:@"#192126"];
    }else{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    }
}

-(void)setupWithContent:(NSDictionary *)dict{
    
    _itemTitle.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
    _itemImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[NSString returnStringObjectForKey:@"img" withDictionary:dict]]];
    _itemDate.text = [NSString stringWithFormat:@"%@",[NSString returnStringObjectForKey:@"ago" withDictionary:dict]];
}

-(void)setupWithItem:(SCItem *)item{
    _itemImage.image = nil;
    _itemTitle.text = item.message;
     [_itemImage setImageWithURL:[NSURL URLWithString:item.thumbnail] placeholderImage:[SSAppController sharedInstance].appImage];
    _itemDate.text = [NSString stringWithFormat:@"%@",[[NSDate dateWithTimeIntervalSince1970:item.createdDate] timeAgo]];

    if([SSAppController sharedInstance].showTheMoney){
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
        [formatter setGroupingSeparator:groupingSeparator];
        [formatter setGroupingSize:3];
        [formatter setAlwaysShowsDecimalSeparator:NO];
        [formatter setUsesGroupingSeparator:YES];
        
        NSString *formattedString = [formatter stringFromNumber:[NSNumber numberWithFloat:[item.ss_earnings floatValue]]];
        _itemValue.text = formattedString;
        _itemValue.hidden = NO;
    }else{
        _itemValue.hidden = YES;
    }
}

@end
