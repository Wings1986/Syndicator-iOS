//
//  SSDashboardViewController.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSDashboardViewController.h"
#import "SSDashTableViewCell.h"
#import "SSDetailViewController.h"
#import "parseCSV.h"
#import "SCItem.h"
#import "MGSwipeButton.h"

#define kSSDashTableViewCell @"SSDashTableViewCell"

@interface SSDashboardViewController ()

@end

@implementation SSDashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _items = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredForeground:) name:NOTIFICATION_ENTERED_FOREGROUND object:nil];
    [self fetchHeatMapData];
    [SSAppController clearTmpDirectory];
    
    [[VTPush sharedInstance] setUserId:[SSAppController sharedInstance].currentUser.token];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[VTPush sharedInstance] requestPushAccess];
    });

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
    
    UILabel *btnExpandBg = [[UILabel alloc] initWithFrame:_btnExpandMap.frame];
    int offset = 16;
    btnExpandBg.width -= offset;
    btnExpandBg.height -= offset;
    btnExpandBg.x = offset/2;
    btnExpandBg.y = offset/2;
    btnExpandBg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [_btnExpandMap addSubview:btnExpandBg];
    btnExpandBg.layer.cornerRadius = 2;
    btnExpandBg.clipsToBounds = YES;
    _btnExpandMap.backgroundColor = [UIColor clearColor];
    
    [_topNav showSettings:NO];
    
    [_tableView registerNib:[UINib nibWithNibName:kSSDashTableViewCell bundle:nil] forCellReuseIdentifier:kSSDashTableViewCell];
    
    [_performanceView addTopBorderWithHeight:0.5 andColor:[UIColor colorWithHexString:COLOR_GRAY_LINE]];
    [_performanceView addBottomBorderWithHeight:0.5 andColor:[UIColor colorWithHexString:COLOR_GRAY_LINE]];
    
    UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(_performanceView.width/3, 20, 1, _performanceView.height - 40)];
    [line1 addRightBorderWithWidth:0.5 andColor:[UIColor colorWithHexString:COLOR_GRAY_LINE]];
    [_performanceView addSubview:line1];
    
    UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(_performanceView.width/3 + _performanceView.width/3, 20, 1, _performanceView.height - 40)];
    [line2 addRightBorderWithWidth:0.5 andColor:[UIColor colorWithHexString:COLOR_GRAY_LINE]];
    [_performanceView addSubview:line2];
    
    [_tableView addTopBorderWithHeight:0.5 andColor:[UIColor colorWithHexString:COLOR_GRAY_LINE]];
    
    _labelEarnings.text = @"- - -";
    _labelImpressions.text = @"- - -";
    _labelReach.text = @"- - -";
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.backgroundColor = [UIColor colorWithHexString:@"#192126"];
    _refreshControl.tintColor = [UIColor whiteColor];
    [_refreshControl addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Loading Real-Time" andColor:nil];
    
    UIImage *i = [VTUtils radialGradientImage:CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2];
    
// iOS9 issue
// UIImage *i = [VTUtils radialGradientImage:CGSizeMake(self.view.width, self.view.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2];
        _backgroundView1 = [[UIImageView alloc] initWithImage:i];
        [self.view insertSubview:_backgroundView1 atIndex:0];

    _mapViewHolder.width = self.view.width;
    _btnExpandMap.x = self.view.width;
    [self setupMapAnnotationsWithItems];
    
    BOOL doingCashOut = [SSAppController sharedInstance].showTheMoney;
    
    if(doingCashOut){
        
        UIImage *i2 = [VTUtils radialGradientImage:CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2];
        
//        UIImage *i2 = [VTUtils radialGradientImage:CGSizeMake(_cashOutView.width, _cashOutView.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2];
        
        
        UIImageView *b2 = [[UIImageView alloc] initWithImage:i2];
        [_cashOutView insertSubview:b2 atIndex:0];
        _btnCashOut.layer.cornerRadius = 8;
        _btnBank.layer.cornerRadius = _btnPayPal.layer.cornerRadius = _btnBank.width/2;
        _btnBank.clipsToBounds = YES;
        _btnPayPal.clipsToBounds = YES;
        _btnBank.backgroundColor = _btnPayPal.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
        _cashOutScreen.width = self.view.width;
        _cashOutScreen.height = self.view.height;
        _cashOutInnerView.layer.cornerRadius = 10;
        _cashOutInnerView.clipsToBounds = YES;
        
        UIImage *i3 = [VTUtils radialGradientImage:CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) start:[UIColor colorWithHexString:COLOR_DARK_BEGIN] end:[UIColor colorWithHexString:COLOR_DARK_END] centre:CGPointMake(0.5,0.5) radius:1.2];
//        UIImage *i3 = [VTUtils radialGradientImage:CGSizeMake(_cashOutInnerView.width, _cashOutInnerView.height) start:[UIColor colorWithHexString:@"#79C46D"] end:[UIColor colorWithHexString:@"#53CA01"] centre:CGPointMake(0.5,0.5) radius:1.2];
        
        UIImageView *b3 = [[UIImageView alloc] initWithImage:i3];
        [_cashOutInnerView insertSubview:b3 atIndex:0];
        [_topScrollview addSubview:_cashOutView];
        _performanceView.x = _cashOutView.width;
        [_topScrollview setContentSize:CGSizeMake(_topScrollview.width + _cashOutView.width, _topScrollview.height)];
        [_topScrollview setContentOffset:CGPointMake(_cashOutView.width, 0)];
    }
}


-(void)refreshPage{
    [self fetchData];
    [self fetchHeatMapData];
}

-(void)setupMapAnnotationsWithItems{
    
    _mapView.y = _mapView.height;
    _mapViewHolder.clipsToBounds = YES;
    _mapViewHolder.backgroundColor = [UIColor clearColor];
   
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction  animations:^{
            _mapView.y = 0;
        } completion:^(BOOL finished) {
            if([self.view.subviews containsObject:_loadingScreen]){
                [self.view addSubview:_mapViewHolder];
                [self.view addSubview:_loadingScreen];
            }else{
                [self.view addSubview:_mapViewHolder];
            }

        }];
    
    });
}



-(void)fetchData{
    
    [_loadingScreen removeFromSuperview];
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Loading Real-Time" andColor:nil];
    [self.view addSubview:_loadingScreen];
    
    NSMutableDictionary *dict = [SSAPIRequestBuilder APIDictionary];
    
    NSString *url = [SSAPIRequestBuilder APIForGetDashboardData];
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

-(void)fetchHeatMapData{
    
    NSMutableDictionary *dict = [SSAPIRequestBuilder APIDictionary];
    NSString *url = [SSAPIRequestBuilder APIForHeatMapData];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [SSAPIRequestBuilder APIAcceptableContentTypes];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([VTUtils isResponseSuccessful:responseObject]){

            NSMutableDictionary *toRet = [[NSMutableDictionary alloc] init];
            for(NSDictionary *dict in [responseObject objectForKey:@"data"]){
                MKMapPoint point = MKMapPointForCoordinate(CLLocationCoordinate2DMake([[NSString returnStringObjectForKey:@"lat" withDictionary:dict] doubleValue],[[NSString returnStringObjectForKey:@"lng" withDictionary:dict] doubleValue]));
                NSValue *pointValue = [NSValue value:&point withObjCType:@encode(MKMapPoint)];
                [toRet setObject:[NSNumber numberWithInt:1] forKey:pointValue];
            }
            _mapBottomView.width = self.view.width;
            NSString *percentDisplay = [NSString returnStringObjectForKey:@"percents_display" withDictionary:responseObject];
            _mapPercentsLabel.text = percentDisplay;
            [self rebuildHeatMapWithData:toRet];
        }else{
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}


-(void)rebuildHeatMapWithData:(NSMutableDictionary *)dict{
    if(_hm != nil){
        [_mapView removeOverlay:_hm];
        _hm = nil;
    }
    _hm = [[HeatMap alloc] initWithData:dict];
    [_mapView addOverlay:_hm];
    [_mapView setVisibleMapRect:[_hm boundingMapRect] animated:YES];
}

-(void)updateTotals{
   
    float totalEarnings = [[NSString returnStringObjectForKey:@"earnings_avg" withDictionary:_totals] floatValue];
    NSString *totalEarningsSymbol = [NSString returnStringObjectForKey:@"earnings_avg_symbol" withDictionary:_totals];
    _earningsSubtitle.text = [NSString returnStringObjectForKey:@"earnings_subtitle" withDictionary:_totals];
    
    float totalImpressions = [[NSString returnStringObjectForKey:@"impressions_avg" withDictionary:_totals] floatValue];
    NSString *totalImpressionsSymbol = [NSString returnStringObjectForKey:@"impressions_avg_symbol" withDictionary:_totals];
    _impressionsSubtitle.text = [NSString returnStringObjectForKey:@"impressions_subtitle" withDictionary:_totals];
    
    float totalReach = [[NSString returnStringObjectForKey:@"reach_avg" withDictionary:_totals] floatValue];
    NSString *totalReachSymbol = [NSString returnStringObjectForKey:@"reach_avg_symbol" withDictionary:_totals];
    _reachSubtitle.text = [NSString returnStringObjectForKey:@"reach_subtitle" withDictionary:_totals];
    
    [SSAppController sharedInstance].currentChannel.weeklyPostingRate = [NSNumber numberWithInt:[[NSString returnStringObjectForKey:@"weekly_post_rate" withDictionary:_totals] intValue]];
    
    _labelEarnings.text = @"- - -";

    _labelEarnings.format = totalEarningsSymbol;
    _labelEarnings.method = UILabelCountingMethodLinear;
    [_labelEarnings countFrom:0 to:totalEarnings withDuration:1.0f];

    if(totalImpressions > 0){
        _labelImpressions.format = totalImpressionsSymbol;
        _labelImpressions.method = UILabelCountingMethodLinear;
        [_labelImpressions countFrom:0 to:totalImpressions withDuration:1.0f];
    }else{
        _labelImpressions.text = @"- - -";
    }

    if(totalReach > 0){
        _labelReach.format = totalReachSymbol;
        _labelReach.method = UILabelCountingMethodLinear;
        [_labelReach countFrom:0 to:totalReach withDuration:1.5f];
    }else{
        _labelReach.text = @"- - -";
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        float expandEndX = self.view.width - _btnExpandMap.width - 20;
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction  animations:^{
            _btnExpandMap.x = self.view.width;
            _btnExpandMap.x = expandEndX;
        }completion:^(BOOL finished) {}];

    });
    
    int totalVideos = (int)[_items count];
    
    if(totalVideos == 0){
        _titleVideos.text = [NSString stringWithFormat:@""];
        if(!_topNoResults){
            _topNoResults = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _topScrollview.width, _topScrollview.height)];
            _topNoResults.text = @"No Reports yet, collecting data";
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
        _titleVideos.text = [NSString stringWithFormat:@"POSTS: %d",totalVideos];
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
    
    SSDashTableViewCell *cell = (SSDashTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kSSDashTableViewCell];
    if (cell == nil) {
        cell = [[SSDashTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kSSDashTableViewCell];
    }
    
    SCItem *item = [_items objectAtIndex:indexPath.row];
    [cell setupWithItem:item];
    
    if(item.isPhoto){
        cell.rightButtons = @[
                              [MGSwipeButton buttonWithTitle:@"DELETE" andIcon:@"X" backgroundColor:[UIColor colorWithHexString:@"FF0000"] withHeight:80],
                              [MGSwipeButton buttonWithTitle:@"EDIT" andIcon:@"E" backgroundColor:[UIColor colorWithHexString:@"#75BF6B"] withHeight:80],
                              [MGSwipeButton buttonWithTitle:@"VIEW" andIcon:@"d" backgroundColor:[UIColor colorWithHexString:COLOR_PURPLE] withHeight:80]
                              ];

    }else{
        cell.rightButtons = @[
                          [MGSwipeButton buttonWithTitle:@"DELETE" andIcon:@"X" backgroundColor:[UIColor colorWithHexString:@"FF0000"] withHeight:80],
                          [MGSwipeButton buttonWithTitle:@"EDIT" andIcon:@"E" backgroundColor:[UIColor colorWithHexString:@"#75BF6B"] withHeight:80],
                          [MGSwipeButton buttonWithTitle:@"EMBED" andIcon:@"a" backgroundColor:[UIColor colorWithHexString:COLOR_TEAL] withHeight:80],
                          [MGSwipeButton buttonWithTitle:@"VIEW" andIcon:@"d" backgroundColor:[UIColor colorWithHexString:COLOR_PURPLE] withHeight:80]
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
    
    if(index == 0) {
        //delete button
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to delete this?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete",nil];
        alert.tag = 32;
        [alert show];
        return NO;
    }else if(index == 1) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Update description" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update",nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.text = item.message;
        alert.tag = 29;
        [alert show];
        return NO;
    }else if(index == 2) {
        
        if(item.isPhoto){
            if([SSAppController sharedInstance].isDemoApp || [SSAppController sharedInstance].isPinModeApp){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://sc.on.starsite.com"]];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:item.url]];
            }
        }else{
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = item.embed;
            [[SSAppController sharedInstance] showAlertWithTitle:@"Copied to Clipboard" andMessage:@"The embed code for this item is now in your clipboard, paste to share"];
        }
    
        return YES;
    }else if(index == 3) {
        if([SSAppController sharedInstance].isDemoApp || [SSAppController sharedInstance].isPinModeApp){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://sc.on.starsite.com"]];
        }else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:item.url]];
        }
        return YES;
    }
    return YES;
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
    SSDetailViewController *vc = [[SSDetailViewController alloc] initWithNibName:@"SSDetailViewController" bundle:nil];
    vc.selectedItem = [_items objectAtIndex:indexPath.row];
    [[SSAppController sharedInstance].navController pushViewController:vc animated:YES];
}


- (IBAction)showCashOutView:(id)sender {
    
    [self.view addSubview:_cashOutScreen];
    _cashOutScreen.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    _cashOutScreen.alpha = 0;
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction  animations:^{
        _cashOutScreen.transform = CGAffineTransformIdentity;
        _cashOutScreen.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];

}

- (IBAction)closeCashOut:(id)sender {
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction  animations:^{
        _cashOutScreen.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
        _cashOutScreen.alpha = 0;
    } completion:^(BOOL finished) {
        [_cashOutScreen removeFromSuperview];
    }];
}

- (IBAction)toggleMapFullScreen {
    
    if(_btnExpandMap.tag != 2){
        _mapBottomView.y = self.view.height;
        [self.view addSubview:_mapBottomView];
        [_btnExpandMap setTitle:@"b" forState:UIControlStateNormal];
        _btnExpandMap.tag = 2;
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction  animations:^{
            _mapViewHolder.y = _topNav.view.height;
            _mapViewHolder.height = self.view.height - _mapViewHolder.y;
        } completion:^(BOOL finished) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction  animations:^{
                    _mapBottomView.y = self.view.height - _mapBottomView.height;
                } completion:^(BOOL finished) {
                    
                }];
                
            });
        }];
    }else{
        _btnExpandMap.tag = 1;
        [_btnExpandMap setTitle:@"v" forState:UIControlStateNormal];
        [_mapBottomView removeFromSuperview];
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction  animations:^{
            _mapViewHolder.y = _topScrollview.maxY;
            _mapViewHolder.height = 105;
            
        } completion:^(BOOL finished) {
            
        }];
        
    }
}


@end
