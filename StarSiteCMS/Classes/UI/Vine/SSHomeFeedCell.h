//
//  SSHomeFeedCell.h
//  StarSiteCMS
//
//  Created by iGold on 10/5/15.
//  Copyright © 2015 StarClub. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SSVideoPlayerDefine.h"
#import "SCItem.h"


@interface SSHomeFeedCell : UITableViewCell <SSVideoPlayerDelegate>

@property (strong, nonatomic) SCItem * item;

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (strong, nonatomic) IBOutlet UIView *videoView;
@property (strong, nonatomic) IBOutlet SSVideoPlayer *ssPlayer;

- (void) setData:(SCItem *) item;

- (void) preloadVideo;
- (void) playVideo;
- (void) pauseVideo;
- (void) stopVideo;

@end
