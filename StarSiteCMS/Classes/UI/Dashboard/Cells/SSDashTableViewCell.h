//
//  SSDashTableViewCell.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCItem.h"
#import "UICountingLabel.h"
#import "MGSwipeTableCell.h"

@interface SSDashTableViewCell : MGSwipeTableCell

@property (strong, nonatomic) IBOutlet UIImageView *itemImage;
@property (strong, nonatomic) IBOutlet UILabel *itemTitle;
@property (strong, nonatomic) IBOutlet UILabel *itemDate;
@property (strong, nonatomic) IBOutlet UICountingLabel *itemValue;


-(void)setupWithContent:(NSDictionary *)dict;
-(void)setupWithItem:(SCItem *)item;
    
@end
