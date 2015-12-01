//
//  SSChannelViewController.m
//  StarSiteCMS
//
//  Created by iGold on 10/5/15.
//  Copyright © 2015 StarClub. All rights reserved.
//

#import "SSChannelViewController.h"

#import "JDFPeekabooCoordinator.h"
#import "ChannelCell.h"


@interface SSChannelViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    IBOutlet UICollectionView *mCollectionView;
    
}

@property (nonatomic, strong) JDFPeekabooCoordinator *scrollCoordinator;

@end

@implementation SSChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    self.scrollCoordinator = [[JDFPeekabooCoordinator alloc] init];
//    self.scrollCoordinator.scrollView = mCollectionView;
//    self.scrollCoordinator.topView = self.navigationController.navigationBar;
//    self.scrollCoordinator.topViewMinimisedHeight = 20.0f;
//    self.scrollCoordinator.bottomView = nil; //self.navigationController.toolbar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = @"EXPLORER";
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark = UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 16;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    ChannelCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ChannelCell" forIndexPath:indexPath];
    
    
    cell.lbTitle.text = [NSString stringWithFormat:@"Channel %d", indexPath.item + 1];
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    self.navigationController.navigationBar.topItem.title = @"";
    [self performSegueWithIdentifier:@"goto_feed" sender:nil];
}


@end
