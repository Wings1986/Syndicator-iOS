//
//  SSProjectionViewController.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 2/27/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import "SSProjectionViewController.h"
#import "SCChartBar.h"

@interface SSProjectionViewController ()

@end

@implementation SSProjectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _totalBars = 12;
    
    _currentPerWeek = [[SSAppController sharedInstance].currentChannel.weeklyPostingRate intValue];
    if(_currentPerWeek > 100)
        _currentPerWeek = 100;
    
    if(_currentPerWeek < 1)
        _currentPerWeek = 1;
    
    _currentRevenuePerWeekRate = [[SSAppController sharedInstance].currentChannel.weeklyRevenueRate floatValue];
    
    _builtBars = [[NSMutableArray alloc] init];
    [_slider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];
    _appVersion.text = [NSString stringWithFormat:@"Api Version: %@",API_VERSION_NUMBER];
}


-(void)layoutUI{
    if(_didLayout) return;
    _didLayout = YES;
    
    _topNav.view.hidden = YES;
    [UIView animateWithDuration:0.8 animations:^{
        _topNav.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        
    }];
    
    _bottomControls.y = self.view.height - _bottomControls.height;
    _graphView.y = 20;
    _graphView.width = [SSAppController sharedInstance].screenBoundsSize.width;
    _graphView.backgroundColor = [[UIColor colorWithHexString:COLOR_TWITTER_BLUE] colorWithAlphaComponent:0];

    _graphView.height =  _bottomControls.y - _graphView.y - 20;
    _lowValLabel.layer.shadowColor = [UIColor greenColor].CGColor;
    _lowValLabel.layer.shadowOpacity = 0;
    _lowValLabel.layer.shadowRadius = 5.0;
    _lowValLabel.layer.shadowOffset = CGSizeMake(0, 0);

    [self tempGraph];
    [self adjustBars];
    self.view.backgroundColor = [UIColor clearColor];
    
    CAShapeLayer *shapeView = [[CAShapeLayer alloc] init];
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(_graphView.x,_graphView.height)];
    [path addQuadCurveToPoint:CGPointMake(_graphView.width,0) controlPoint:CGPointMake(_graphView.width/2,_graphView.height)];

    _labelIdealPath.textColor = [UIColor colorWithHexString:COLOR_GOLD];
    [shapeView setPath:path.CGPath];
    shapeView.strokeColor = [[UIColor colorWithHexString:COLOR_GOLD] colorWithAlphaComponent:1].CGColor;
    shapeView.fillColor = [UIColor clearColor].CGColor;
    shapeView.lineWidth = 2.0;
    [[_graphView layer] addSublayer:shapeView];
    
    float maxCurrentYPoint = _graphView.height - ((_currentPerWeek/100) * _graphView.height);
    
    CAShapeLayer *shapeViewCurrent = [[CAShapeLayer alloc] init];
    UIBezierPath *pathCurrent = [[UIBezierPath alloc] init];
    [pathCurrent moveToPoint:CGPointMake(_graphView.x,_graphView.height)];
    [pathCurrent addQuadCurveToPoint:CGPointMake(_graphView.width,maxCurrentYPoint) controlPoint:CGPointMake(_graphView.width/2,_graphView.height)];
    
    _labelCurrentPath.textColor = [UIColor colorWithHexString:@"FFFFFF"];
    [shapeViewCurrent setPath:pathCurrent.CGPath];
    shapeViewCurrent.strokeColor = [[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:1].CGColor;
    
    shapeViewCurrent.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:5],[NSNumber numberWithInt:4], nil];
    shapeViewCurrent.lineWidth = 1.5;
    shapeViewCurrent.fillColor = [UIColor clearColor].CGColor;
    
    [[_graphView layer] addSublayer:shapeViewCurrent];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.04 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self adjustBars];
    });
    
}


-(void)sliderChanged{
    [self adjustBars];
}

-(void)adjustBars{
    float delay = 0;
    float count = 1.0;
    
    _lowValLabel.text = [NSString stringWithFormat:@"%d",(int)round(50 * _slider.value)];
    
    [_lowValLabel sizeToFit];
    
    for(SCChartBar *bar in _builtBars){
        float sliderValRounded = round(_slider.value*50.0)/50.00;
        
        float properHeight = _graphView.height * sliderValRounded;
        float multiplier = (float)(count/(int)[_builtBars count]);
        properHeight *= multiplier;
        count++;

        float endingY = _graphView.height - properHeight;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        NSString *groupingSeparator = @",";
        [formatter setGroupingSeparator:groupingSeparator];
        [formatter setGroupingSize:3];
        [formatter setAlwaysShowsDecimalSeparator:NO];
        [formatter setUsesGroupingSeparator:YES];
        
        NSString *formattedString = [formatter stringFromNumber:[NSNumber numberWithFloat:properHeight*_currentRevenuePerWeekRate]];
        NSArray *parts = [formattedString componentsSeparatedByString:@","];
        NSArray *partsLabel = @[@"k",@"m",@"b",@"t"];
        int totalParts = (int)[parts count];
        
        if(totalParts > 1){
            NSString *afterDecimal = [parts objectAtIndex:1];
            afterDecimal = [afterDecimal substringToIndex:1];
            if(totalParts <= 2){
                afterDecimal = @"0";
            }
            NSString *cleanStr = [NSString stringWithFormat:@"%@%@%@",[parts firstObject],([afterDecimal isEqualToString:@"0"]) ? @"" : [NSString stringWithFormat:@".%@",afterDecimal],[partsLabel objectAtIndex:totalParts-2]];
            bar.title.text = cleanStr;
        }else{
            NSString *cleanStr = [NSString stringWithFormat:@"%@",[parts firstObject]];
            bar.title.text = cleanStr;
        }

        float bgPercent = _slider.value;
        if(bgPercent <= .75)
            bgPercent = 0;
        else{
            bgPercent = (bgPercent/.25) - 3;
        }
        
        _lowValLabel.layer.shadowOpacity = 1*bgPercent;
        [UIView animateWithDuration:1 delay:delay usingSpringWithDamping:0.4 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             bar.height = properHeight;
                             bar.y = endingY;
                         } completion:^(BOOL finished) {
                             
                         }];
    
        delay += 0.01;
        
    }
    
}

-(void)tempGraph{

    _slider.value = _currentPerWeek/50.0;
    int startingX = 0;
    int spacing = 2;
    int itemWidth = ((_graphView.width - (startingX*2)) / _totalBars) - spacing;

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM"];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];

    
    for(int i=0; i<_totalBars; i++){
        SCChartBar *bar = [[SCChartBar alloc] initWithFrame:CGRectMake(startingX, _graphView.height,itemWidth,1)];
        bar.backgroundColor = [[UIColor colorWithHexString:COLOR_TWITTER_BLUE] colorWithAlphaComponent:0.1 + (0.1 * i)];
        bar.alpha = 1;
        [_graphView addSubview:bar];
        [_builtBars addObject:bar];
        
        [dateComponents setMonth:i];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
        NSString *myMonthString = [df stringFromDate:newDate];
        UILabel *month = [[UILabel alloc] initWithFrame:CGRectMake(startingX,_graphView.height + 20,itemWidth, 20)];
        month.text = myMonthString;
        month.backgroundColor = [[UIColor colorWithHexString:COLOR_PURPLE] colorWithAlphaComponent:0];
        month.textColor = [UIColor colorWithHexString:@"FFFFFF"];
        month.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:9];
        month.textAlignment  = NSTextAlignmentCenter;
        month.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:month];
        startingX += itemWidth + spacing;
    }
    
    float arrowHeight = 8.0;
    float arrowWidth = 12.0;
    
    _upArrow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, arrowWidth, arrowHeight)];
    [_videoIcons sizeToFit];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,NULL,0.0,arrowHeight);
    CGPathAddLineToPoint(path, NULL, arrowWidth/2, 0.0f);
    CGPathAddLineToPoint(path, NULL, arrowWidth, arrowHeight);
    CGPathAddLineToPoint(path, NULL, 0.0f, arrowHeight);
    
    CAShapeLayer *arrowShapeLayer = [CAShapeLayer layer];
    [arrowShapeLayer setPath:path];
    [arrowShapeLayer setFillColor:[UIColor colorWithHexString:@"666666"].CGColor];
    CGPathRelease(path);
    
    [_upArrow.layer addSublayer:arrowShapeLayer];
    [_bottomControls addSubview:_slider];
    [_bottomControls addSubview:_upArrow];
    
    _upArrow.x = _slider.x + (_slider.width * (_currentPerWeek/50.0));
    if(_currentPerWeek > 0){
        _upArrow.x += 5; //knob
    }
    _upArrow.y = _slider.maxY - 5;
    _currentPerWeekLabel.textColor = [UIColor colorWithHexString:@"666666"];
    _currentPerWeekLabel.text = [NSString stringWithFormat:@"YOU: %.0f Video%@",_currentPerWeek,(_currentPerWeek == 1) ? @"" : @"s"];
    [_currentPerWeekLabel sizeToFit];
    _currentPerWeekLabel.x = _upArrow.x;
    _currentPerWeekLabel.y = _upArrow.maxY + 2;
    if(_currentPerWeekLabel.x < _videoIcons.maxX){
        _upArrow.y = _slider.maxY - 8;
        _currentPerWeekLabel.x = _upArrow.maxX + 4;
        _currentPerWeekLabel.y = _upArrow.y;
    }
}


@end
