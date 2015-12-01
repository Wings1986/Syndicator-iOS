//
//  SSCurateTableViewCell.h
//  StarSiteCMS
//
//  Continued by IC.
//  Copyright (c) 2014 US Mastertec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCItem.h"
#import "UICountingLabel.h"
#import "MGSwipeTableCell.h"

@interface SSCurateTableViewCell : MGSwipeTableCell

@property (strong, nonatomic) IBOutlet UIImageView *itemImage;
@property (strong, nonatomic) IBOutlet UILabel *itemTitle;
@property (strong, nonatomic) IBOutlet UILabel *itemDate;
@property (strong, nonatomic) IBOutlet UICountingLabel *itemValue;


-(void)setupWithContent:(NSDictionary *)dict;
-(void)setupWithItem:(SCItem *)item;
    
@end
