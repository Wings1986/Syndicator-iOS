//
//  AppTermsViewController.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 4/20/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import "AppTermsViewController.h"

@interface AppTermsViewController ()

@end

@implementation AppTermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _btnClose.layer.cornerRadius = 8;
    _webview.layer.cornerRadius = 4;
    _webview.clipsToBounds = YES;
}

- (void)showURL:(NSString *)url{
    [_webview loadHTMLString:@"Loading..." baseURL:nil];
    [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (IBAction)doCloseView {
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.view.y = 50;
                         self.view.alpha = 0;
                     } completion:^(BOOL finished) {
                         
                     }];

}
@end
