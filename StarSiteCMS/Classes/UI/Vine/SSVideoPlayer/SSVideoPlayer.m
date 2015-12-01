//
//  SSVideoPlayer.m
//  StarSiteCMS
//
//  Created by iGold on 10/6/15.
//  Copyright © 2015 StarClub. All rights reserved.
//

#import "SSVideoPlayer.h"
#import "SSVideoView.h"


#define LOG_PLAYER 0
#ifndef DLog
#if !defined(NDEBUG) && LOG_PLAYER
#   define DLog(fmt, ...) NSLog((@"player: " fmt), ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
#endif

// KVO contexts
static NSString * const SSVideoPlayerObserverContext = @"SSVideoPlayerObserverContext";
static NSString * const SSVideoPlayerItemObserverContext = @"SSVideoPlayerItemObserverContext";
static NSString * const SSVideoPlayerLayerObserverContext = @"SSVideoPlayerLayerObserverContext";

// KVO player keys
static NSString * const SSVideoPlayerControllerTracksKey = @"tracks";
static NSString * const SSVideoPlayerControllerPlayableKey = @"playable";
static NSString * const SSVideoPlayerControllerDurationKey = @"duration";
static NSString * const SSVideoPlayerControllerRateKey = @"rate";

// KVO player item keys
static NSString * const SSVideoPlayerControllerStatusKey = @"status";
static NSString * const SSVideoPlayerControllerEmptyBufferKey = @"playbackBufferEmpty";
static NSString * const SSVideoPlayerControllerPlayerKeepUpKey = @"playbackLikelyToKeepUp";

// KVO player layer keys
static NSString * const SSVideoPlayerControllerReadyForDisplay = @"readyForDisplay";

// TODO: scrubbing support
//static float const PBJVideoPlayerControllerRates[PBJVideoPlayerRateCount] = { 0.25, 0.5, 0.75, 1, 1.5, 2 };
//static NSInteger const PBJVideoPlayerRateCount = 6;

@interface SSVideoPlayer ()
{
    AVAsset *_asset;
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    
    NSString *_videoPath;
    SSVideoView *_videoView;
    
    PBJVideoPlayerPlaybackState _playbackState;
    PBJVideoPlayerBufferingState _bufferingState;
    
    // flags
    struct {
        unsigned int playbackLoops:1;
        unsigned int playbackFreezesAtEnd:1;
    } __block _flags;
    
    float _volume;
}

@end


@implementation SSVideoPlayer

@synthesize delegate = _delegate;
@synthesize videoPath = _videoPath;
@synthesize playbackState = _playbackState;
@synthesize bufferingState = _bufferingState;
@synthesize videoFillMode = _videoFillMode;


- (void)setVideoFillMode:(NSString *)videoFillMode
{
    if (_videoFillMode != videoFillMode) {
        _videoFillMode = videoFillMode;
        _videoView.videoFillMode = _videoFillMode;
    }
}

- (NSString *)videoPath
{
    return _videoPath;
}

- (void)setVideoPath:(NSString *)videoPath
{
    if (!videoPath || [videoPath length] == 0) {
        _videoPath = nil;
        [self setAsset:nil];
        return;
    }
    
    NSURL *videoURL = [NSURL URLWithString:videoPath];
    if (!videoURL || ![videoURL scheme]) {
        videoURL = [NSURL fileURLWithPath:videoPath];
    }
    _videoPath = [videoPath copy];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    [self setAsset:asset];
}

- (void)setAsset:(AVAsset *)asset {
    [self _setAsset:asset];
}

- (AVAsset *)asset {
    return _asset;
}

- (BOOL)playbackLoops
{
    return _flags.playbackLoops;
}

- (void)setPlaybackLoops:(BOOL)playbackLoops
{
    _flags.playbackLoops = (unsigned int)playbackLoops;
    if (!_player)
        return;
    
    if (!_flags.playbackLoops) {
        _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    } else {
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }
}

- (BOOL)playbackFreezesAtEnd
{
    return _flags.playbackFreezesAtEnd;
}

- (void)setPlaybackFreezesAtEnd:(BOOL)playbackFreezesAtEnd
{
    _flags.playbackFreezesAtEnd = (unsigned int)playbackFreezesAtEnd;
}

- (NSTimeInterval)maxDuration {
    NSTimeInterval maxDuration = -1;
    
    if (CMTIME_IS_NUMERIC(_playerItem.duration)) {
        maxDuration = CMTimeGetSeconds(_playerItem.duration);
    }
    
    return maxDuration;
}

- (float)volume {
    return _player.volume;
}

- (void)setVolume:(float)volume {
    _volume = volume;
    
    if (!_player) {
        return;
    }
    
    _player.volume = volume;
}

- (void)_setAsset:(AVAsset *)asset
{
    if (_asset == asset) {
        return;
    }
    
    if (_playbackState == PBJVideoPlayerPlaybackStatePlaying) {
        [self pause];
    }
    
    _bufferingState = PBJVideoPlayerBufferingStateUnknown;
    if ([_delegate respondsToSelector:@selector(videoPlayerBufferringStateDidChange:)]){
        [_delegate videoPlayerBufferringStateDidChange:self];
    }
    
    _asset = asset;
    
    if (!_asset) {
        [self _setPlayerItem:nil];
    }
    
    NSArray *keys = @[SSVideoPlayerControllerTracksKey, SSVideoPlayerControllerPlayableKey, SSVideoPlayerControllerDurationKey];
    
    [_asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        [self _enqueueBlockOnMainQueue:^{
            
            // check the keys
            for (NSString *key in keys) {
                NSError *error = nil;
                AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key error:&error];
                if (keyStatus == AVKeyValueStatusFailed) {
                    _playbackState = PBJVideoPlayerPlaybackStateFailed;
                    [_delegate videoPlayerPlaybackStateDidChange:self];
                    return;
                }
            }
            
            // check playable
            if (!_asset.playable) {
                _playbackState = PBJVideoPlayerPlaybackStateFailed;
                [_delegate videoPlayerPlaybackStateDidChange:self];
                return;
            }
            
            // setup player
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:_asset];
            [self _setPlayerItem:playerItem];
            
        }];
    }];
}

- (void)_setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem == playerItem)
        return;
    
    // remove observers
    if (_playerItem) {
        // AVPlayerItem KVO
        [_playerItem removeObserver:self forKeyPath:SSVideoPlayerControllerEmptyBufferKey context:(__bridge void *)(SSVideoPlayerItemObserverContext)];
        [_playerItem removeObserver:self forKeyPath:SSVideoPlayerControllerPlayerKeepUpKey context:(__bridge void *)(SSVideoPlayerItemObserverContext)];
        [_playerItem removeObserver:self forKeyPath:SSVideoPlayerControllerStatusKey context:(__bridge void *)(SSVideoPlayerItemObserverContext)];
        
        // notifications
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:_playerItem];
    }
    
    _playerItem = playerItem;
    
    // add observers
    if (_playerItem) {
        // AVPlayerItem KVO
        [_playerItem addObserver:self forKeyPath:SSVideoPlayerControllerEmptyBufferKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(SSVideoPlayerItemObserverContext)];
        [_playerItem addObserver:self forKeyPath:SSVideoPlayerControllerPlayerKeepUpKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(SSVideoPlayerItemObserverContext)];
        [_playerItem addObserver:self forKeyPath:SSVideoPlayerControllerStatusKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(SSVideoPlayerItemObserverContext)];
        
        // notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playerItemFailedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:_playerItem];
    }
    
    if (!_flags.playbackLoops) {
        _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    } else {
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }
    
    [_player replaceCurrentItemWithPlayerItem:_playerItem];
}

#pragma mark - init

- (void)dealloc
{
    _videoView.player = nil;
    _delegate = nil;
    
    // notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Layer KVO
    [_videoView.layer removeObserver:self forKeyPath:SSVideoPlayerControllerReadyForDisplay context:(__bridge void *)SSVideoPlayerLayerObserverContext];
    
    // AVPlayer KVO
    [_player removeObserver:self forKeyPath:SSVideoPlayerControllerRateKey context:(__bridge void *)SSVideoPlayerObserverContext];
    
    // player
    [_player pause];
    
    // player item
    [self _setPlayerItem:nil];
}

#pragma mark - view lifecycle
- (void) setVideoFrame:(CGRect) rt {
    _videoView.frame = rt;
}

- (void)initWithValue:(UIView*) view
{
    _player = [[AVPlayer alloc] init];
    _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    // Player KVO
    [_player addObserver:self forKeyPath:SSVideoPlayerControllerRateKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(SSVideoPlayerObserverContext)];
    
    // load the playerLayer view
    _videoView = [[SSVideoView alloc] initWithFrame:view.frame];
    _videoView.videoFillMode = AVLayerVideoGravityResize;
    _videoView.playerLayer.hidden = YES;

    for (UIView* v in view.subviews) {
        if ([v isKindOfClass:[SSVideoView class]]) {
            [v removeFromSuperview];
        }
    }
    [view addSubview:_videoView];
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapClick:)]];
    //    view = _videoView;
    
    
    // playerLayer KVO
    [_videoView.playerLayer addObserver:self forKeyPath:SSVideoPlayerControllerReadyForDisplay options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(SSVideoPlayerLayerObserverContext)];
    
    // Application NSNotifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(_applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [nc addObserver:self selector:@selector(_applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}


#pragma mark - public methods

- (void)playFromBeginning
{
    DLog(@"playing from beginnging...");
    
    [_delegate videoPlayerPlaybackWillStartFromBeginning:self];
    [_player seekToTime:kCMTimeZero];
    [self playFromCurrentTime];
}

- (void)playFromCurrentTime
{
    DLog(@"playing...");
    
    _playbackState = PBJVideoPlayerPlaybackStatePlaying;
    [_delegate videoPlayerPlaybackStateDidChange:self];
    [_player play];
}

- (void)pause
{
    if (_playbackState != PBJVideoPlayerPlaybackStatePlaying)
        return;
    
    DLog(@"pause");
    
    [_player pause];
    _playbackState = PBJVideoPlayerPlaybackStatePaused;
    [_delegate videoPlayerPlaybackStateDidChange:self];
}

- (void)stop
{
    if (_playbackState == PBJVideoPlayerPlaybackStateStopped)
        return;
    
    DLog(@"stop");
    
    [_player pause];
    _playbackState = PBJVideoPlayerPlaybackStateStopped;
    [_delegate videoPlayerPlaybackStateDidChange:self];
}

#pragma mark - main queue helper

typedef void (^PBJVideoPlayerBlock)();

- (void)_enqueueBlockOnMainQueue:(PBJVideoPlayerBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

#pragma mark - UIResponder
- (void) onTapClick:(UIGestureRecognizer*) gesture {
    if (_videoPath || _asset) {
        
//        switch (_playbackState) {
//            case PBJVideoPlayerPlaybackStateStopped:
//            {
//                [self playFromBeginning];
//                break;
//            }
//            case PBJVideoPlayerPlaybackStatePaused:
//            {
//                [self playFromCurrentTime];
//                break;
//            }
//            case PBJVideoPlayerPlaybackStatePlaying:
//            case PBJVideoPlayerPlaybackStateFailed:
//            default:
//            {
//                [self pause];
//                break;
//            }
//        }

        [_player setVolume:1.0 - _player.volume];
        
        
    }
}

#pragma mark - AV NSNotificaions

- (void)_playerItemDidPlayToEndTime:(NSNotification *)aNotification
{
    if (_flags.playbackLoops || !_flags.playbackFreezesAtEnd) {
        [_player seekToTime:kCMTimeZero];
    }
    
    if (!_flags.playbackLoops) {
        [self stop];
        [_delegate videoPlayerPlaybackDidEnd:self];
    }
}

- (void)_playerItemFailedToPlayToEndTime:(NSNotification *)aNotification
{
    _playbackState = PBJVideoPlayerPlaybackStateFailed;
    [_delegate videoPlayerPlaybackStateDidChange:self];
    DLog(@"error (%@)", [[aNotification userInfo] objectForKey:AVPlayerItemFailedToPlayToEndTimeErrorKey]);
}

#pragma mark - App NSNotifications

- (void)_applicationWillResignActive:(NSNotification *)aNotfication
{
    if (_playbackState == PBJVideoPlayerPlaybackStatePlaying)
        [self pause];
}

- (void)_applicationDidEnterBackground:(NSNotification *)aNotfication
{
    if (_playbackState == PBJVideoPlayerPlaybackStatePlaying)
        [self pause];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == (__bridge void *)(SSVideoPlayerObserverContext) ) {
        
        // Player KVO
        
    } else if ( context == (__bridge void *)(SSVideoPlayerItemObserverContext) ) {
        
        // PlayerItem KVO
        
        if ([keyPath isEqualToString:SSVideoPlayerControllerEmptyBufferKey]) {
            if (_playerItem.playbackBufferEmpty) {
                _bufferingState = PBJVideoPlayerBufferingStateDelayed;
                if ([_delegate respondsToSelector:@selector(videoPlayerBufferringStateDidChange:)]) {
                    [_delegate videoPlayerBufferringStateDidChange:self];
                }
                DLog(@"playback buffer is empty");
            }
        } else if ([keyPath isEqualToString:SSVideoPlayerControllerPlayerKeepUpKey]) {
            if (_playerItem.playbackLikelyToKeepUp) {
                _bufferingState = PBJVideoPlayerBufferingStateReady;
                if ([_delegate respondsToSelector:@selector(videoPlayerBufferringStateDidChange:)]) {
                    [_delegate videoPlayerBufferringStateDidChange:self];
                }
                DLog(@"playback buffer is likely to keep up");
                if (_playbackState == PBJVideoPlayerPlaybackStatePlaying) {
                    [self playFromCurrentTime];
                }
            }
        }
        
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            case AVPlayerStatusReadyToPlay:
            {
                _videoView.playerLayer.backgroundColor = [[UIColor clearColor] CGColor];
                [_videoView.playerLayer setPlayer:_player];
                _videoView.playerLayer.hidden = NO;
                break;
            }
            case AVPlayerStatusFailed:
            {
                _playbackState = PBJVideoPlayerPlaybackStateFailed;
                [_delegate videoPlayerPlaybackStateDidChange:self];
                break;
            }
            case AVPlayerStatusUnknown:
            default:
                break;
        }
        
    } else if ( context == (__bridge void *)(SSVideoPlayerLayerObserverContext) ) {
        
        // PlayerLayer KVO
        
        if ([keyPath isEqualToString:SSVideoPlayerControllerReadyForDisplay]) {
            if (_videoView.playerLayer.readyForDisplay) {
                [_delegate videoPlayerReady:self];
            }
        }
        
    } else {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        
    }
}
@end
