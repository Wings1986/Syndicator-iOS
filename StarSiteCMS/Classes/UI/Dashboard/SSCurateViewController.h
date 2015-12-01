//
//  MultiVideoViewController.h
//  StarSiteCMS
//
//  Adapted by Ian Cartwright on 01.09.15.
//  Copyright (c) 2015 StarClub. All rights reserved.
//

#import "SSViewController.h"
#import "UICountingLabel.h"
#import <MapKit/MapKit.h>
#import "HeatMap.h"
#import "HeatMapView.h"
#import "MGSwipeTableCell.h"
#import "UIKit/UIkit.h"
#import "MediaPlayer/MediaPlayer.h"


@interface SSCurateViewController : SSViewController<UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,MGSwipeTableCellDelegate>{
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

@property (strong, nonatomic) IBOutlet UILabel *titleCurated;
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


@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;



@end
