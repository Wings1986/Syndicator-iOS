//
//  SSPostSocialItemViewController.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 5/3/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSPostSocialItemViewController : UIViewController{
    NSString *_dimColor;
}

@property (strong, nonatomic) IBOutlet UIButton *btnIcon;
@property (strong, nonatomic) SSParingItem *item;
@property (strong, nonatomic) IBOutlet UILabel *checkmark;
@property(nonatomic,assign) BOOL isPostingVideo;

- (IBAction)socialBtnPressed:(UIButton *)sender;
-(NSDictionary *)packageForServer;


@end
