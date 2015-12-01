//
//  SSVideoView.m
//  StarSiteCMS
//
//  Created by iGold on 10/6/15.
//  Copyright © 2015 StarClub. All rights reserved.
//

#import "SSVideoView.h"

#import <AVFoundation/AVFoundation.h>

@implementation SSVideoView


+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

#pragma mark - getters/setters

- (void)setPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (AVPlayer *)player
{
    return [(AVPlayerLayer *)[self layer] player];
}

- (AVPlayerLayer *)playerLayer
{
    return (AVPlayerLayer *)self.layer;
}

- (void)setVideoFillMode:(NSString *)videoFillMode
{
    [self playerLayer].videoGravity = videoFillMode;
}

- (NSString *)videoFillMode
{
    return [self playerLayer].videoGravity;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.playerLayer.backgroundColor = [[UIColor blackColor] CGColor];
    }
    return self;
}


@end
