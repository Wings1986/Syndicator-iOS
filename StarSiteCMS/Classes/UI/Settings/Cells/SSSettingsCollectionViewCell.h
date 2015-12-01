//
//  SSSettingsCollectionViewCell.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 3/10/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSSettingsCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *icon;

-(void)setupCellWithItem:(SSParingItem *)item;


@end
