//
//  SSHomeFeedCell.m
//  StarSiteCMS
//
//  Created by iGold on 10/5/15.
//  Copyright © 2015 StarClub. All rights reserved.
//

#import "SSHomeFeedCell.h"


@implementation SSHomeFeedCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (void) setData:(SCItem *) item {
    _item = item;
    
    NSLog(@"image url = %@", item.thumbnail);
    [self.ivPhoto setImageWithURL:[NSURL URLWithString:item.thumbnail] placeholderImage:[SSAppController sharedInstance].appImage];

}

- (void) preloadVideo{
/*
    if (self.avPlayer != nil && (self.avPlayer.rate != 0 && self.avPlayer.error == nil)) {
        return;
    }
    
    NSString * urlString = @"";
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"123456" ofType:@"mp4"]];
    
    self.avPlayer = [AVPlayer playerWithURL:url];
    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    self.avPlayerLayer.frame = self.containerView.layer.bounds;
    self.avPlayerLayer.videoGravity = AVLayerVideoGravityResize;
    
    for (CALayer *layer in self.containerView.layer.sublayers) {
        if ([layer isKindOfClass:[AVPlayerLayer class]]) {
            [layer removeFromSuperlayer];
        }
    }
    
    [self.containerView.layer addSublayer: self.avPlayerLayer];
    [self.avPlayer play];
*/
    if (_ssPlayer != nil) {
        return;
    }
    
    _ssPlayer = [[SSVideoPlayer alloc] init];
//    _ssPlayer.backgroundColor = [UIColor clearColor];
    _ssPlayer.delegate = self;
    [_ssPlayer initWithValue:self.videoView];

    //    _videoPlayerController.videoPath = PBJViewControllerVideoPath;
//    NSString * hlsURL = @"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8";
    NSString *hlsURL = [_item.fileURL stringByDeletingPathExtension];
    hlsURL = [hlsURL stringByAppendingString:@"/master.m3u8"];

    _ssPlayer.asset = [[AVURLAsset alloc] initWithURL:[[NSURL alloc] initWithString:hlsURL] options:nil];

    [_ssPlayer setPlaybackLoops:YES];
    [_ssPlayer setVolume:0];
}

- (void) playVideo {
    if (_ssPlayer == nil) {
        return;
    }
    
    if (_ssPlayer.playbackState == PBJVideoPlayerPlaybackStatePlaying) {
        return;
    }
    
    [_ssPlayer playFromBeginning];
}
- (void) pauseVideo {

    if (_ssPlayer == nil) {
        return;
    }
    
    if (_ssPlayer.playbackState == PBJVideoPlayerPlaybackStatePlaying) {
        [_ssPlayer pause];
    }

}

- (void) stopVideo{
//    if (self.avPlayer.rate != 0 && self.avPlayer.error == nil) {
//        [self.avPlayer pause];
//        self.avPlayer = nil;
//    }
    
    [_ssPlayer pause];
    _ssPlayer = nil;

//    if (_ssPlayer != nil) {
//        [_ssPlayer removeFromSuperview];
//    }
    
    _ivPhoto.alpha = 1.0f;
    _ivPhoto.hidden = NO;
}

- (void)prepareForReuse {
    [self stopVideo];
}

#pragma mark - PBJVideoPlayerControllerDelegate

- (void)videoPlayerReady:(SSVideoPlayer *)videoPlayer
{
    //NSLog(@"Max duration of the video: %f", videoPlayer.maxDuration);
    
    _ivPhoto.alpha = 1.0f;
    _ivPhoto.hidden = NO;
    
    [UIView animateWithDuration:0.1f animations:^{
        _ivPhoto.alpha = 0.0f;
    } completion:^(BOOL finished) {
        _ivPhoto.hidden = YES;
    }];
}

- (void)videoPlayerPlaybackStateDidChange:(SSVideoPlayer *)videoPlayer
{
}

- (void)videoPlayerBufferringStateDidChange:(SSVideoPlayer *)videoPlayer
{
    switch (videoPlayer.bufferingState) {
        case PBJVideoPlayerBufferingStateUnknown:
            NSLog(@"Buffering state unknown!");
            break;
            
        case PBJVideoPlayerBufferingStateReady:
            NSLog(@"Buffering state Ready! Video will start/ready playing now.");
            break;
            
        case PBJVideoPlayerBufferingStateDelayed:
            NSLog(@"Buffering state Delayed! Video will pause/stop playing now.");
            break;
        default:
            break;
    }
    
    switch (videoPlayer.playbackState) {
        case PBJVideoPlayerPlaybackStateStopped:
            NSLog(@"play state stopped!");
            break;
            
        case PBJVideoPlayerPlaybackStatePlaying:
            NSLog(@"play state playing");
            break;
            
        case PBJVideoPlayerPlaybackStatePaused:
            NSLog(@"play state paused");
            break;

        case PBJVideoPlayerPlaybackStateFailed:
            NSLog(@"play state failed");
            break;
            
        default:
            break;
    }

}

- (void)videoPlayerPlaybackWillStartFromBeginning:(SSVideoPlayer *)videoPlayer
{
    
}

- (void)videoPlayerPlaybackDidEnd:(SSVideoPlayer *)videoPlayer
{

//    _ivPhoto.hidden = NO;
//    
//    [UIView animateWithDuration:1.0f animations:^{
//        _ivPhoto.alpha = 1.0f;
//    } completion:^(BOOL finished) {
//    }];
}

@end
