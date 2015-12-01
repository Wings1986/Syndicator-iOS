//
//  VTUploadProgressViewController.h
//  Freebee
//
//  Created by Vincent Tuscano on 9/10/14.
//  Copyright (c) 2014 Ravn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VTUploadProgressViewController : UIViewController{
    UIImageView *_backgroundView1;
}

@property (strong, nonatomic) IBOutlet UILabel *labelSaving;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UILabel *labelExtra;

@end
