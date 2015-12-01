//
//  SSHomeViewController.m
//  StarSiteCMS
//
//  Created by iGold on 10/5/15.
//  Copyright © 2015 StarClub. All rights reserved.
//

#import "SSHomeViewController.h"

#import "HomeHeaderCell.h"
#import "SSHomeFeedCell.h"

#import "SCItem.h"


@interface SSHomeViewController () <UITableViewDelegate, UITableViewDataSource>
{
    
    IBOutlet UITableView *mTableView;

    UIRefreshControl *_refreshControl;

    NSMutableArray *_items;
}


@end

@implementation SSHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"CHANNEL";
    
    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    [mTableView addTopBorderWithHeight:0.5 andColor:[UIColor colorWithHexString:COLOR_GRAY_LINE]];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.backgroundColor = [UIColor colorWithHexString:@"#192126"];
    _refreshControl.tintColor = [UIColor whiteColor];
    [_refreshControl addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventValueChanged];
    
    
    [mTableView addSubview:_refreshControl];

    _items = [NSMutableArray new];
    
    [self refreshPage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)refreshPage{
    [self fetchData];
}


-(void)fetchData{
    
    
    NSMutableDictionary *dict = [SSAPIRequestBuilder APIDictionary];
    
    NSString *url = [SSAPIRequestBuilder APIForGetCuratedData];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [SSAPIRequestBuilder APIAcceptableContentTypes];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [_refreshControl endRefreshing];
        
        if([VTUtils isResponseSuccessful:responseObject]){
            [_items removeAllObjects];
            for(NSDictionary *dict in [responseObject objectForKey:@"data"]){
                
                SCItem *item = [[SCItem alloc] initWithDictionary:dict];
                [_items addObject:item];
            }

            [mTableView reloadData];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self playVideo];
            });

            
        }else{
            [[SSAppController sharedInstance] alertWithServerResponse:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[SSAppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];

        [_refreshControl endRefreshing];
    }];
}


#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_items == nil)
        return 0;
    
    return [_items count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 46;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    HomeHeaderCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HomeHeaderCell"];
    
    return headerCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 345.0f; //435.0f
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SSHomeFeedCell *cell = (SSHomeFeedCell *)[tableView dequeueReusableCellWithIdentifier:@"SSHomeFeedCell"];
    
    
    SCItem *item = [_items objectAtIndex:indexPath.section];
    
    [cell setData:item];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [self playVideo];
    
}

//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    if(![scrollView isDecelerating] && ![scrollView isDragging]){
//        
//        [self playVideo];
//    }
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    if(!decelerate){
//        [self playVideo];
//    }
//}
-(void)playVideo
{
    if(_items.count==0){
        return;
    }

    NSArray *paths = [mTableView indexPathsForVisibleRows];
    
    for (NSIndexPath *path in paths) {
        UITableViewCell * myCell = [mTableView cellForRowAtIndexPath:path];
        if ([myCell isKindOfClass:[SSHomeFeedCell class]]) {
            [self checkFullCell:(SSHomeFeedCell*)myCell indexPath:path];
        }
    }

}

- (void) checkFullCell:(SSHomeFeedCell*) cell indexPath:(NSIndexPath*) indexPath;
{
    
    CGRect rtShowed = CGRectMake(mTableView.contentOffset.x, mTableView.contentOffset.y + 46.f, mTableView.frame.size.width, mTableView.frame.size.height - 46.f);

    CGRect rtFullVideo = CGRectMake(cell.frame.origin.x, cell.frame.origin.y,
                                 cell.frame.size.width, cell.frame.size.height-115);
    
    CGRect rtMinVideo = CGRectMake(cell.frame.origin.x, cell.frame.origin.y + 80.f,
                                   cell.frame.size.width, cell.frame.size.height - 115.f - 160.f);
    
    if (CGRectIntersectsRect(rtShowed, rtFullVideo)) {
        [cell preloadVideo];
    }
    
    if (CGRectContainsRect(rtShowed, rtFullVideo)) {
        [cell playVideo];
    }
    
    if (!CGRectIntersectsRect(rtShowed, rtMinVideo)) {
        [cell pauseVideo];
    }
    
//    NSLog(@"cell = %@", NSStringFromCGRect(rtShowed));
//    NSLog(@"cell2 = %@", NSStringFromCGRect(cell.frame));
//    CGRect rtUpCell = CGRectMake(cell.frame.origin.x, cell.frame.origin.y + 100,
//                                       cell.frame.size.width, cell.frame.size.height - 100);
//    CGRect rtBottomCell = CGRectMake(cell.frame.origin.x, cell.frame.origin.y + (cell.frame.size.height - 115 - 80),
//                                 cell.frame.size.width, 115+80);
//    if (CGRectContainsRect(rtShowed, rtUpCell)
//        || CGRectContainsRect(rtShowed, rtBottomCell)) {
//        // play
//        [cell preloadVideo];
//        [cell pauseVideo];
//    }
    
    
//    if ([self isCrossRectGood:rtShowed inRect:cell.frame]) {
//        // play
//        NSLog(@"play cell = %i", indexPath.section);
//        
//        [cell playVideo];
//    }
//    else {
//        // stop
//    }
}

-(BOOL) isCrossRectGood:(CGRect) rtOut inRect:(CGRect) rtIn
{
    if (CGRectGetHeight(rtOut) + CGRectGetHeight(rtIn) - (MAX(CGRectGetMaxY(rtIn), CGRectGetMaxY(rtOut)) - MIN(CGRectGetMinY(rtOut), CGRectGetMinY(rtIn))) > CGRectGetHeight(rtOut) * 0.6f) {
        return YES;
    }
    return NO;
}

@end
