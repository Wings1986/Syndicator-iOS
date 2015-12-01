//
//  AppTakeVideoViewController.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 4/22/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import "AppTakeVideoViewController.h"

@interface AppTakeVideoViewController ()

@end

@implementation AppTakeVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
        
    });
    
}


@end
