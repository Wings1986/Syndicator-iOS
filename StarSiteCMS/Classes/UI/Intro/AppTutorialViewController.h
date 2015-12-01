//
//  AppTutorialViewController.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 4/21/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppTutorialViewController : SSViewController<UIScrollViewDelegate>{
    NSArray *_sections;
    BOOL _leaving;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@end
