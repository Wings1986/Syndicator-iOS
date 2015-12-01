//
//  VTUploadProgressViewController.m
//  Freebee
//
//  Created by Vincent Tuscano on 9/10/14.
//  Copyright (c) 2014 Ravn. All rights reserved.
//

#import "VTUploadProgressViewController.h"

@interface VTUploadProgressViewController ()

@end

@implementation VTUploadProgressViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    _progressView.progress = 0;
    self.view.clipsToBounds = YES;
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressUpdated:) name:NOTIFICATION_UPLOAD_PROGRESS object:nil];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImage *i = [VTUtils radialGradientImage:CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2];
    
//    UIImage *i = [VTUtils radialGradientImage:CGSizeMake(self.view.width, self.view.height) start:[UIColor colorWithHexString:@"333333"] end:[UIColor colorWithHexString:@"000000"] centre:CGPointMake(0.5,0.5) radius:1.2];
    
    
    _backgroundView1 = [[UIImageView alloc] initWithImage:i];
    [self.view insertSubview:_backgroundView1 atIndex:0];

    _backgroundView1.alpha = 0.96;
}

-(void)progressUpdated:(NSNotification *)note{
    
    NSLog(@"HEARD OBJECT: %@",note.object);
    
    NSString *event = [note.object objectForKey:@"event"];
    
    NSLog(@"HEARD EVENT: %@",event);
    if([event isEqualToString:@"starting"]){
        self.view.hidden = NO;
        self.view.backgroundColor = [UIColor clearColor];
        self.view.height = [SSAppController sharedInstance].screenBoundsSize.height;

        _backgroundView1.hidden = NO;
        _backgroundView1.width = [SSAppController sharedInstance].screenBoundsSize.width;
        _backgroundView1.height = [SSAppController sharedInstance].screenBoundsSize.height;
        
        //self.view.backgroundColor = [[UIColor colorWithHexString:@"7F007F"] colorWithAlphaComponent:0.7];
        _labelSaving.textColor = [UIColor colorWithHexString:@"FFFFFF"];
        _labelSaving.text = @"...";
        _labelExtra.text = @"Uploading";
        _labelSaving.y  = self.view.height;

        
        _progressView.progress = 0;
//        _progressView.x = _labelSaving.width + 60;
//        _progressView.width = self.view.width - _progressView.x - 60;
        _progressView.y = self.view.height;
        NSLog(@"STARTING");
        [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone|UIViewAnimationOptionAllowUserInteraction animations:^{
            _progressView.y = self.view.height/2 - _progressView.height/2;
            _labelSaving.y = _progressView.y - _labelSaving.height - 50;
            _labelExtra.y = _labelSaving.y - _labelExtra.height - 20;
        } completion:^(BOOL finished) {
        }];
        
        
    }else if([event isEqualToString:@"finished"]){
        

        _labelSaving.text = @"Finished! Please allow a few minutes to see results";
        _labelSaving.adjustsFontSizeToFitWidth = YES;
                    _backgroundView1.hidden = YES;
        [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone|UIViewAnimationOptionAllowUserInteraction animations:^{
            self.view.backgroundColor = [UIColor colorWithHexString:COLOR_GOLD];
            _labelSaving.textColor = [UIColor colorWithHexString:@"111111"];
            self.view.height = 35;
            _labelSaving.y = self.view.height/2 - _labelSaving.height/2;
            [[SSAppController sharedInstance] donePost];
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.view.hidden = YES;
                self.view.height = 10;
                [SSAppController clearTmpDirectory];

            });
        }];

        
        
    }else if([event isEqualToString:@"progress"]){
        self.view.hidden = NO;
        
        long long totalBytesWritten = [[note.object objectForKey:@"totalDone"] longLongValue];
        long long totalBytesExpectedToWrite = [[note.object objectForKey:@"total"] longLongValue];
        NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
        float percent = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
        NSLog(@"percent %f", percent);
        _progressView.progress = percent;
        if(percent > 0.9)
            _labelExtra.text = @"Finishing Up";
        else if(percent > 0.7)
            _labelExtra.text = @"Almost Done!";
        else if(percent > 0.5)
            _labelExtra.text = @"Half Way!";
        else{
            _labelExtra.text = @"Uploading";
        }
        
        _labelSaving.text = [NSString stringWithFormat:@"%0.2f%%",100*percent];
    
        if(percent >= 1){
//            _progressLabel.text = @"Finishing Up...";
        }else{
//            _progressLabel.text = [NSString stringWithFormat:@"Uploading: %0.0f%%",percent*100];
        }
        
    }else if([event isEqualToString:@"failed"]){
        self.view.hidden = YES;
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0);
        dispatch_after(delay, dispatch_get_main_queue(), ^(void){
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.2);
            dispatch_after(delay, dispatch_get_main_queue(), ^(void){
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.2);
                dispatch_after(delay, dispatch_get_main_queue(), ^(void){
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                });
            });
        });
    }
    
    //@"starting" finished
    // @"event":@"progress",@"uid":randomNumber,@"total",totalBytesExpectedToWrite,@"totalDone",
    
    //     NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
}



@end
