//
//  SSViewController.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSViewController.h"

@interface SSViewController ()

@end

@implementation SSViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _topNav = [[SSTopNavViewController alloc] initWithNibName:@"SSTopNavViewController" bundle:nil];
    [self.view addSubview:_topNav.view];
    self.view.clipsToBounds = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)hideTopNav:(BOOL)val{
    _topNav.view.hidden = val;
}

@end
