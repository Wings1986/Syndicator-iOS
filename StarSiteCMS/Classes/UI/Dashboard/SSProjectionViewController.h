//
//  SSProjectionViewController.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 2/27/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSProjectionViewController : SSViewController{
    
    NSMutableArray *_builtBars;
    float _currentPerWeek;
    float _currentRevenuePerWeekRate;
    int _totalBars;
    UIView *_upArrow;
}

@property (strong, nonatomic) IBOutlet UIView *graphView;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UILabel *videoIcons;
@property (strong, nonatomic) IBOutlet UILabel *currentPerWeekLabel;
@property (strong, nonatomic) IBOutlet UILabel *labelCurrentPath;
@property (strong, nonatomic) IBOutlet UILabel *labelIdealPath;
@property (strong, nonatomic) IBOutlet UIView *bottomControls;
@property (strong, nonatomic) IBOutlet UILabel *appVersion;
@property (strong, nonatomic) IBOutlet UILabel *lowValLabel;

-(void)layoutUI;

@end
