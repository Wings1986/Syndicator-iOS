//
//  SSDashboardViewController.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSViewController.h"
#import "UICountingLabel.h"
#import <MapKit/MapKit.h>
#import "HeatMap.h"
#import "HeatMapView.h"
#import "MGSwipeTableCell.h"

@interface SSDashboardViewController : SSViewController<UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,MGSwipeTableCellDelegate>{
    NSMutableArray *_items;
    NSIndexPath *_selectedIdx;
    HeatMap *_hm;
    UIView *_loadingScreen;
    UIRefreshControl *_refreshControl;
    NSDictionary *_totals;
    BOOL _mapLoadedOnce;
    UILabel *_topNoResults;
    UILabel *_middleNoResults;
    NSIndexPath *_pathInQuestion;
    
}

@property (strong, nonatomic) IBOutlet UILabel *earningsSubtitle;
@property (strong, nonatomic) IBOutlet UILabel *impressionsSubtitle;
@property (strong, nonatomic) IBOutlet UILabel *reachSubtitle;
@property (strong, nonatomic) IBOutlet UIView *performanceView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UICountingLabel *labelEarnings;
@property (strong, nonatomic) IBOutlet UICountingLabel *labelImpressions;
@property (strong, nonatomic) IBOutlet UICountingLabel *labelReach;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *mapViewHolder;
@property (strong, nonatomic) IBOutlet UIButton *btnExpandMap;
@property (strong, nonatomic) IBOutlet UIView *mapBottomView;
@property (strong, nonatomic) IBOutlet UILabel *titleVideos;
@property (strong, nonatomic) IBOutlet UILabel *mapPercentsLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *topScrollview;
@property (strong, nonatomic) IBOutlet UIView *cashOutView;
@property (strong, nonatomic) IBOutlet UIButton *btnCashOut;
@property (strong, nonatomic) IBOutlet UICountingLabel *btnBank;
@property (strong, nonatomic) IBOutlet UICountingLabel *btnPayPal;
@property (strong, nonatomic) IBOutlet UIView *cashOutInnerView;
@property (strong, nonatomic) IBOutlet UIView *cashOutScreen;

- (IBAction)showCashOutView:(id)sender;
- (IBAction)closeCashOut:(id)sender;
- (IBAction)toggleMapFullScreen;

@end
