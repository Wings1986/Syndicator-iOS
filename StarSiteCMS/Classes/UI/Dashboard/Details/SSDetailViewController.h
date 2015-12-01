//
//  SSDetailViewController.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//

#import "SSViewController.h"
#import "UICountingLabel.h"
#import "SCItem.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface SSDetailViewController : SSViewController{
    NSMutableArray *_sections;
    MPMoviePlayerController *_moviePlayer;
}

@property(nonatomic,strong) SCItem *selectedItem;
@property (strong, nonatomic) IBOutlet UIImageView *itemImage;
@property (strong, nonatomic) IBOutlet UILabel *itemTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelPerformance;
@property (strong, nonatomic) IBOutlet UILabel *labelPosted;
@property (strong, nonatomic) IBOutlet UILabel *labelEarningsTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnPlay;
@property (strong, nonatomic) IBOutlet UICountingLabel *labelTotal;

- (IBAction)playVideo;
    
@end
