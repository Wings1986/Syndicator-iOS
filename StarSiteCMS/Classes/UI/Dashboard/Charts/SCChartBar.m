//
//  SCChartBar.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 2/27/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import "SCChartBar.h"

@implementation SCChartBar



-(void)drawRect:(CGRect)rect{
    

    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, -15, self.width, 20)];
    _title.text = @"";
    _title.backgroundColor = [[UIColor colorWithHexString:COLOR_PURPLE] colorWithAlphaComponent:0];
    _title.textColor = [UIColor colorWithHexString:@"FFFFFF"];
    _title.textAlignment  = NSTextAlignmentCenter;
    _title.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:11];
    _title.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_title];
    
}


@end
