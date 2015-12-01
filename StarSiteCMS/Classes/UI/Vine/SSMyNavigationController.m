//
//  SSMyNavigationController.m
//  StarSiteCMS
//
//  Created by iGold on 10/5/15.
//  Copyright © 2015 StarClub. All rights reserved.
//

#import "SSMyNavigationController.h"

@interface SSMyNavigationController ()

@end

@implementation SSMyNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.barTintColor = [UIColor colorWithRed:156/255.0f green:107/255.0f blue:177/255.0f alpha:1];
    self.navigationBar.titleTextAttributes =  @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
