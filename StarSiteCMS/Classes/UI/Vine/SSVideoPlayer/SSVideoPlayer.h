//
//  SSVideoPlayer.h
//  StarSiteCMS
//
//  Created by iGold on 10/6/15.
//  Copyright © 2015 StarClub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, PBJVideoPlayerPlaybackState) {
    PBJVideoPlayerPlaybackStateStopped = 0,
    PBJVideoPlayerPlaybackStatePlaying,
    PBJVideoPlayerPlaybackStatePaused,
    PBJVideoPlayerPlaybackStateFailed,
};

typedef NS_ENUM(NSInteger, PBJVideoPlayerBufferingState) {
    PBJVideoPlayerBufferingStateUnknown = 0,
    PBJVideoPlayerBufferingStateReady,
    PBJVideoPlayerBufferingStateDelayed,
};

//provides the interface for playing/streaming videos
@protocol SSVideoPlayerDelegate;

@interface SSVideoPlayer : NSObject

@property (nonatomic, weak) id<SSVideoPlayerDelegate> delegate;

@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, copy) AVAsset *asset;

@property (nonatomic, copy, setter=setVideoFillMode:) NSString *videoFillMode; // default, AVLayerVideoGravityResizeAspect

@property (nonatomic) BOOL playbackLoops;
@property (nonatomic) BOOL playbackFreezesAtEnd;
@property (nonatomic, readonly) PBJVideoPlayerPlaybackState playbackState;
@property (nonatomic, readonly) PBJVideoPlayerBufferingState bufferingState;

@property (nonatomic, readonly) NSTimeInterval maxDuration;

@property (nonatomic) float volume;

- (void)initWithValue:(UIView*) view;
- (void) setVideoFrame:(CGRect) rtl;

- (void)setPlaybackLoops:(BOOL)playbackLoops;

- (void)playFromBeginning;
- (void)playFromCurrentTime;
- (void)pause;
- (void)stop;

@end


@protocol SSVideoPlayerDelegate <NSObject>
@required
- (void)videoPlayerReady:(SSVideoPlayer *)videoPlayer;
- (void)videoPlayerPlaybackStateDidChange:(SSVideoPlayer *)videoPlayer;

- (void)videoPlayerPlaybackWillStartFromBeginning:(SSVideoPlayer *)videoPlayer;
- (void)videoPlayerPlaybackDidEnd:(SSVideoPlayer *)videoPlayer;

@optional
- (void)videoPlayerBufferringStateDidChange:(SSVideoPlayer *)videoPlayer;

@end