//
//  SSViewController.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSTopNavViewController.h"

@interface SSViewController : UIViewController{
    BOOL _didLayout;
    SSTopNavViewController *_topNav;
    UIView *_backgroundView1;
}

-(void)hideTopNav:(BOOL)val;

@end
