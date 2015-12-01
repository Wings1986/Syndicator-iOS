//
//  SSSettingsViewController.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 3/10/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import "SSViewController.h"
#import "SSProjectionViewController.h"
#import "VTImagePicker.h"

@interface SSSettingsViewController : SSViewController<UICollectionViewDataSource,UICollectionViewDelegate>{
    SSProjectionViewController *_projectionMap;
    VTImagePicker *_imagePicker;
    
}

@property (strong, nonatomic) IBOutlet UIButton *btnLogout;
@property (strong, nonatomic) IBOutlet UIButton *btnUpdatePairing;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *titleProjections;
@property (strong, nonatomic) IBOutlet UILabel *headerStatus;

- (IBAction)doChangeAvatar:(id)sender;
- (IBAction)doLogout:(id)sender;


@end
