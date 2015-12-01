//
//  AppTermsViewController.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 4/20/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppTermsViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIWebView *webview;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;


- (IBAction)doCloseView;
- (void)showURL:(NSString *)url;


@end
