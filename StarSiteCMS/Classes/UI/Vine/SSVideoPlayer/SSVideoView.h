//
//  SSVideoView.h
//  StarSiteCMS
//
//  Created by iGold on 10/6/15.
//  Copyright © 2015 StarClub. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;
@class AVPlayerLayer;

@interface SSVideoView : UIView


@property (nonatomic) AVPlayer *player;
@property (nonatomic, readonly) AVPlayerLayer *playerLayer;

// defaults to AVLayerVideoGravityResizeAspect
@property (nonatomic) NSString *videoFillMode;

@end
