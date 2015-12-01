//
//  AppTutorialViewController.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 4/21/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import "AppTutorialViewController.h"

@interface AppTutorialViewController ()

@end

@implementation AppTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _sections = @[
                @{@"img":@"0",@"title":@"Welcome to StarSite.",@"desc":@"    Swipe to continue.    "},
                @{@"img":@"1",@"title":@"Create",@"desc":@"Capture new photos or videos directly or select existing content from your media library."},
                @{@"img":@"2",@"title":@"Syndicate",@"desc":@"Post your content automatically to Facebook, Twitter and Instagram to drive maximum traffic and revenue."},
                @{@"img":@"3",@"title":@"Track",@"desc":@"View revenue earned and detailed post performance."},
                @{@"img":@"4",@"title":@"Grow",@"desc":@"Estimate your future revenue potential based on posting frequency."},
                @{@"img":@"",@"title":@"Start.",@"desc":@""}
                ];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self layoutUI];
}

-(void)layoutUI{
    if(_didLayout)
        return;
    _didLayout = YES;
    
    _pageControl.numberOfPages = [_sections count];
    
    [_topNav.view removeFromSuperview];


    UIImage *i = [VTUtils radialGradientImage:CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2];
    
    //    UIImage *i = [VTUtils radialGradientImage:CGSizeMake(self.view.width, self.view.height) start:[UIColor colorWithHexString:@"#373542"] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2];
    
    _backgroundView1 = [[UIImageView alloc] initWithImage:i];
    [self.view insertSubview:_backgroundView1 atIndex:0];
    

    int startingX = 0;
    for(NSDictionary *dict in _sections){
        UIView *v = [[UIView alloc] initWithFrame:_scrollView.frame];
        UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString returnStringObjectForKey:@"img" withDictionary:dict]]];
        iv.width = v.width - v.width/4;
        iv.height = v.width/2;
        iv.x = v.width/2 - iv.width/2;
        iv.contentMode = UIViewContentModeScaleAspectFit;
        iv.y = 80;
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, v.width, 80)];
        title.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
        title.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:28];
        title.textColor = [UIColor whiteColor];
        [title sizeToFit];
        title.x = v.width/2 - title.width/2;
        title.y = iv.maxY + 20;
        
        UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, v.width, 80)];
        desc.text = [NSString returnStringObjectForKey:@"desc" withDictionary:dict];
        desc.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_THIN size:20];
        desc.textColor = [UIColor whiteColor];
        desc.textAlignment = NSTextAlignmentCenter;
        desc.numberOfLines = 0;
        [desc sizeToFit];
        desc.adjustsFontSizeToFitWidth = YES;
        desc.width -= 40;
        desc.x = v.width/2 - desc.width/2;
        desc.y = title.maxY + 10;
        
        [v addSubview:iv];
        [v addSubview:title];
        [v addSubview:desc];
        v.x = startingX;
        startingX += v.width;
        [_scrollView addSubview:v];
    }

    [_scrollView setContentSize:CGSizeMake(startingX,_scrollView.height)];

}

-(void)leaveThis{
    
    [[SSAppController sharedInstance] saveSeenTutorial];
    [UIView animateWithDuration:0.8 animations:^{
        _scrollView.alpha = 0;
    } completion:^(BOOL finished) {
        [[SSAppController sharedInstance] routeUserToLogin];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    
    CGFloat pageWidth = _scrollView.width;
    
    float pagePercent = ((_scrollView.contentOffset.x - pageWidth / 2.0) / pageWidth) + 1;
    pagePercent -= 0.5;
    
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2.0) / pageWidth) + 1;
    
    float pageInView = ((_scrollView.contentOffset.x - pageWidth / 2.0) / pageWidth) + 1;
    pageInView -= 0.5;
    
    _pageControl.currentPage = page;
    float overallPagePercent = pagePercent - page;
    if(overallPagePercent < 0){
        overallPagePercent = 1 + overallPagePercent;
    }
    
    int realPageInFocus = floor(pageInView);
    if(realPageInFocus == [_sections count]-1){
        if(!_leaving){
            _leaving = YES;
            [self leaveThis];
        }
    }
}




@end
