//
//  SSSettingsViewController.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 3/10/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import "SSSettingsViewController.h"
#import "SSSettingsCollectionViewCell.h"

#define kSSSettingsCollectionViewCell @"SSSettingsCollectionViewCell"

@interface SSSettingsViewController ()

@end

@implementation SSSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _btnLogout.layer.cornerRadius = 4;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self layoutUI];
    [_collectionView registerNib:[UINib nibWithNibName:kSSSettingsCollectionViewCell bundle:nil] forCellWithReuseIdentifier:kSSSettingsCollectionViewCell];
    [_collectionView reloadData];
}

-(void)layoutUI{
    
    if(_didLayout) return;
    _didLayout = YES;
    
    _userImage.layer.cornerRadius = _userImage.width/2;
    _userImage.layer.borderWidth = 2;
    _userImage.layer.borderColor = [[UIColor colorWithHexString:@"888888"] colorWithAlphaComponent:0.2].CGColor;
    _userImage.clipsToBounds = YES;
    _userImage.backgroundColor = [UIColor colorWithHexString:COLOR_DARK_END];

    _btnUpdatePairing.hidden = YES;
    _btnUpdatePairing.backgroundColor = [UIColor clearColor];
    _btnUpdatePairing.layer.borderWidth = 1;
    _btnUpdatePairing.layer.borderColor = [[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.2].CGColor;
    _btnUpdatePairing.layer.cornerRadius = 8;
    _btnUpdatePairing.x = _collectionView.maxX - _btnUpdatePairing.width;

    [_topNav showSettings:NO];
    

    UIImage *i = [VTUtils radialGradientImage:CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2];
    
//    UIImage *i = [VTUtils radialGradientImage:CGSizeMake(self.view.width, self.view.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2];
    
    _backgroundView1 = [[UIImageView alloc] initWithImage:i];
    [self.view insertSubview:_backgroundView1 atIndex:0];

    
    _userName.text = [SSAppController sharedInstance].currentChannel.name;
    [_userImage setImageWithURL:[NSURL URLWithString:[SSAppController sharedInstance].currentChannel.img] placeholderImage:[SSAppController sharedInstance].personImage];
    
    [_collectionView reloadData];
    int padding = 0;
    

    _projectionMap = [[SSProjectionViewController alloc] initWithNibName:@"SSProjectionViewController" bundle:nil];
    _projectionMap.view.height = self.view.height - _titleProjections.maxY - padding;
    _projectionMap.view.width = self.view.width;
    [self.view addSubview:_projectionMap.view];
    _projectionMap.view.y = _titleProjections.maxY + padding;
    _collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_btnLogout];
    [_projectionMap layoutUI];
    
    if([SSAppController sharedInstance].isDemoApp){
        _btnLogout.hidden = YES;
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[SSAppController sharedInstance].pairingItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SSSettingsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSSSettingsCollectionViewCell forIndexPath:indexPath];
    SSParingItem *item = [[SSAppController sharedInstance].pairingItems objectAtIndex:indexPath.row];
    [cell setupCellWithItem:item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(65,60);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SSParingItem *item = [[SSAppController sharedInstance].pairingItems objectAtIndex:indexPath.row];
    [[SSAppController sharedInstance] routeToSocialPairingWithProperty:item];
}

- (IBAction)doChangeAvatar:(id)sender {
    if(!_imagePicker){
        _imagePicker = [[VTImagePicker alloc] init];
        _imagePicker.delegateViewController = self;
    }
    
    [_imagePicker presentPhotoPicker];
}

- (IBAction)doLogout:(id)sender {
    [[SSAppController sharedInstance] logout];
}

- (void)imagePickedForAvatarPreview:(UIImage *)image{
    _userImage.image = image;
}

- (void)imagePickedForAvatar:(UIImage *)image{
    
    _userImage.image = image;
    
    NSMutableDictionary *dict = [SSAPIRequestBuilder APIDictionary];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [SSAPIRequestBuilder APIAcceptableContentTypes];
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    [manager POST:[SSAPIRequestBuilder APIUpdateAvatar] parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"avatar.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([VTUtils isResponseSuccessful:responseObject]){
            [SSAppController sharedInstance].currentUser.img = [NSString returnStringObjectForKey:@"img" withDictionary:responseObject];
            
            [SSAppController sharedInstance].currentChannel.img = [SSAppController sharedInstance].currentUser.img;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_INFO_UPDATED object:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _userImage.image = nil;
        [[SSAppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to save Photo, please try again."];
    }];
}




@end
