//
//  SScurateViewController.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSCurateViewController.h"
#import "SSDashboardViewController.h"
#import "SSCurateTableViewCell.h"
#import "SSDetailViewController.h"
#import "parseCSV.h"
#import "SCItem.h"
#import "MGSwipeButton.h"
#import "SSPostCuratedViewController.h"


#define kSSCurateTableViewCell @"SSCurateTableViewCell"


@interface SSCurateViewController ()



@end

@implementation SSCurateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _items = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredForeground:) name:NOTIFICATION_ENTERED_FOREGROUND object:nil];

    [SSAppController clearTmpDirectory];

    
    [[VTPush sharedInstance] setUserId:[SSAppController sharedInstance].currentUser.token];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[VTPush sharedInstance] requestPushAccess];
    });
    [self refreshPage];
    
}

- (void)swipeDetected:(UISwipeGestureRecognizer *)sender {
    [[SSAppController sharedInstance] goBack];
}

-(void)enteredForeground:(NSNotification *)note{
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self layoutUI];
    if(_selectedIdx){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_tableView reloadRowsAtIndexPaths:@[_selectedIdx] withRowAnimation:UITableViewRowAnimationFade];
        });
    }
    return;
}

-(void)layoutUI{
    if(_didLayout) return;
    _didLayout = YES;
    
    
    [_topNav showSettings:NO];
    
    [_tableView registerNib:[UINib nibWithNibName:kSSCurateTableViewCell bundle:nil] forCellReuseIdentifier:kSSCurateTableViewCell];
    
       [_tableView addTopBorderWithHeight:0.5 andColor:[UIColor colorWithHexString:COLOR_GRAY_LINE]];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.backgroundColor = [UIColor colorWithHexString:@"#192126"];
    _refreshControl.tintColor = [UIColor whiteColor];
    [_refreshControl addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventValueChanged];
   

    [_tableView addSubview:_refreshControl];

}

-(void)refreshPage{
    [self fetchData];
}


-(void)fetchData{
    
    [_loadingScreen removeFromSuperview];
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Loading !!" andColor:nil];
    [self.view addSubview:_loadingScreen];
    
    
    NSMutableDictionary *dict = [SSAPIRequestBuilder APIDictionary];
    
    NSString *url = [SSAPIRequestBuilder APIForGetCuratedData];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [SSAPIRequestBuilder APIAcceptableContentTypes];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [_loadingScreen removeFromSuperview];
        [_refreshControl endRefreshing];
        
        if([VTUtils isResponseSuccessful:responseObject]){
            [_items removeAllObjects];
            for(NSDictionary *dict in [responseObject objectForKey:@"data"]){
                _totals = [responseObject objectForKey:@"totals"];
                SCItem *item = [[SCItem alloc] initWithDictionary:dict];
                [_items addObject:item];
            }
            [_tableView reloadData];
            [self updateTotals];
            
        }else{
            [[SSAppController sharedInstance] alertWithServerResponse:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[SSAppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
        [_loadingScreen removeFromSuperview];
        [_refreshControl endRefreshing];
    }];
}

-(void)updateTotals{
     int totalVideos = (int)[_items count];
    
    if(totalVideos == 0){
        _titleVideos.text = [NSString stringWithFormat:@""];
        if(!_topNoResults){
            _titleCurated.hidden = YES;
            _topNoResults = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _topScrollview.width, _topScrollview.height)];
            _topNoResults.text = @"No Curated content for this Channel.";
            _topNoResults.textAlignment = NSTextAlignmentCenter;
            _topNoResults.adjustsFontSizeToFitWidth = YES;
            _topNoResults.textColor = [UIColor colorWithHexString:COLOR_GOLD];
            [_topScrollview addSubview:_topNoResults];
            _topNoResults.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        }
        _topNoResults.hidden = NO;
    }else{
        if(_topNoResults){
            _topNoResults.hidden = YES;
        }
        _performanceView.hidden = NO;
        _titleVideos.text = [NSString stringWithFormat:@"Media: %d",totalVideos];
    }
}


#pragma mark Map

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    
    if(_mapLoadedOnce) return;
    _mapLoadedOnce = YES;
    [self fetchData];
    
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay{
    return [[HeatMapView alloc] initWithOverlay:overlay];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_items count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SSCurateTableViewCell *cell = (SSCurateTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kSSCurateTableViewCell];
    if (cell == nil) {
        cell = [[SSCurateTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kSSCurateTableViewCell];
    }
    
    SCItem *item = [_items objectAtIndex:indexPath.row];
    [cell setupWithItem:item];
    
    if(item.isPhoto){
        cell.rightButtons = @[

                              [MGSwipeButton buttonWithTitle:@"SHARE" andIcon:@"3" backgroundColor:[UIColor colorWithHexString:@"#75BF6B"] withHeight:80],
                              [MGSwipeButton buttonWithTitle:@"VIEW" andIcon:@"d" backgroundColor:[UIColor colorWithHexString:COLOR_PURPLE] withHeight:80]
                              ];
        
    }else{
        cell.rightButtons = @[

                              [MGSwipeButton buttonWithTitle:@"SHARE" andIcon:@"3" backgroundColor:[UIColor colorWithHexString:COLOR_TEAL] withHeight:80],
                              [MGSwipeButton buttonWithTitle:@"PLAY" andIcon:@"d" backgroundColor:[UIColor colorWithHexString:COLOR_PURPLE] withHeight:80]
                              ];
    }
    cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;
}

-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    
    _pathInQuestion = [_tableView indexPathForCell:cell];
    SCItem *item = [_items objectAtIndex:_pathInQuestion.row];
    
    
    // NOTE: !!  above
    
    if(index == 0) {
        NSLog(@"Share Button");
        [self shareSelectedCurated:item];
    }else if(index == 1) {
        
        NSLog(@"Play Button");
        
        [self playSelectedCurated:item];
        
    }else if(index == 2) {

        
        [self playSelectedCurated:item];
        
     }
    return YES;
         
         
}


- (void) moviePlayBackDidFinish:(NSNotification*)notification {
//    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:_moviePlayer];
    
    if ([_moviePlayer
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [_moviePlayer.view removeFromSuperview];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    int idx =(int)buttonIndex;
    if(alertView.tag == 33){
        if(idx == 1){
            
        }
    }else if(alertView.tag == 32){
        if(idx == 1){
            SCItem *item = [_items objectAtIndex:_pathInQuestion.row];
            [self deleteItem:item];
            [_items removeObjectAtIndex:_pathInQuestion.row];
            [_tableView deleteRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationLeft];
            _titleVideos.text = [NSString stringWithFormat:@"POSTS: %d",(int)[_items count]];
        }else{
            [_tableView reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationRight];
        }
    }else if(alertView.tag == 29){
        if(idx == 1){
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSString *groupNameString = textField.text;
            if([groupNameString isEmpty]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Cannot have a blank description" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
                [alert show];
                [_tableView reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationRight];
                return;
            }
            SCItem *item = [_items objectAtIndex:_pathInQuestion.row];
            item.message = groupNameString;
            [self saveEditedItem:item];
            [_tableView reloadData];
        }else{
            [_tableView reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationRight];
        }
    }
    _pathInQuestion = nil;
}

-(void)deleteItem:(SCItem *)item{
    
    NSMutableDictionary *dict = [SSAPIRequestBuilder APIDictionary];
    [dict addEntriesFromDictionary:@{@"video_id":item.videoId}];
    [dict addEntriesFromDictionary:@{@"item_type":item.postType}];
    [dict addEntriesFromDictionary:@{@"photo_id":item.videoId}];
    
    NSString *url = [SSAPIRequestBuilder APIForDeletePost];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [SSAPIRequestBuilder APIAcceptableContentTypes];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
}

-(void)saveEditedItem:(SCItem *)item{
    
    NSMutableDictionary *dict = [SSAPIRequestBuilder APIDictionary];
    [dict addEntriesFromDictionary:@{@"video_id":item.videoId}];
    [dict addEntriesFromDictionary:@{@"item_type":item.postType}];
    [dict addEntriesFromDictionary:@{@"photo_id":item.videoId}];
    [dict addEntriesFromDictionary:@{@"msg":item.message}];
    
    NSString *url = [SSAPIRequestBuilder APIForUpdatePost];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [SSAPIRequestBuilder APIAcceptableContentTypes];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    _selectedIdx = indexPath;
     [self playSelectedCurated:[_items objectAtIndex:indexPath.row]];
    
 // In case select is now share again !!!
 //    [self shareSelectedCurated:[_items objectAtIndex:indexPath.row]];


}

-(void)playSelectedCurated: (SCItem *) item {
    
    NSString *hlsURL = [item.fileURL stringByDeletingPathExtension];
    hlsURL = [hlsURL stringByAppendingString:@"/master.m3u8"];
    
    NSLog(@"hlsUrl =  %@", hlsURL);
    
    NSURL *url = [NSURL URLWithString:hlsURL];
    
    
    _moviePlayer =  [[MPMoviePlayerController alloc]
                     initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_moviePlayer];
    
    
    [self.view addSubview: _moviePlayer.view];
    _moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    _moviePlayer.shouldAutoplay = YES;
    //       _moviePlayer.repeatMode =  MPMovieRepeatModeNone;
    _moviePlayer.allowsAirPlay = YES;
    //       _moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    _moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    [_moviePlayer.view setFrame: self.view.bounds];
    [_moviePlayer prepareToPlay];

}


-(void)shareSelectedCurated:(SCItem *) item {
    
    SSPostCuratedViewController *vc = [[SSPostCuratedViewController alloc] initWithNibName:@"SSPostCuratedViewController" bundle:nil];
    
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Please wait.." andColor:nil];
    [self.view addSubview:_loadingScreen];
    
    vc.capturedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:item.thumbnail]]];
    vc.isVideo = YES;
    vc.videoURL = [NSURL URLWithString:item.fileURL];
    //   vc.videoThumbs = [self thumbnailsFromCuratedVideoAtURL:vc.videoURL];
    vc.videoThumbs = nil;
    vc.viralContentId = item.itemId;
    vc.viralCaption  = item.message;
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_loadingScreen removeFromSuperview];
    });
    
    
    [[SSAppController sharedInstance].navController pushViewController:vc animated:YES];
    return;
    
}

- (NSMutableArray *)thumbnailsFromCuratedVideoAtURL:(NSURL *)url{
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    
    //  Get thumbnail at the very start of the video
    CMTime thumbnailTime = [asset duration];
    int totalTime = (int)CMTimeGetSeconds(thumbnailTime);
    thumbnailTime.value = 0;
    int intervals = 1;
    //    if(totalTime > 10){
    //        intervals = floor(totalTime/5);
    //    }else{
    intervals = 3;
    //    }
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    for(int i=0; i<totalTime; i+=intervals){
        
        thumbnailTime.value = thumbnailTime.timescale * i;
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        imageGenerator.appliesPreferredTrackTransform = YES;
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbnailTime actualTime:NULL error:NULL];
        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        [thumbs addObject:thumbnail];
    }
    return thumbs;
}


@end
