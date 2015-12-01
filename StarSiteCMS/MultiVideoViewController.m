//
//  MultiVideoViewController.m
//  StarSiteCMS
//
//  Created by Ian Cartwright on 01.09.15.
//  Copyright (c) 2015 StarClub. All rights reserved.
//

#import "MultiVideoViewController.h"
#import "MediaPlayer/MediaPlayer.h"

@interface MultiVideoViewController ()

@end

@implementation MultiVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //The number of views inside myScrollView
    _numberOfViews = 4;
    
    //Initialization
    _viewsArray = [[NSMutableArray alloc] init];
    _myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _playersArray = [[NSMutableArray alloc] init];
    NSMutableArray * videoNamesArray = [[NSMutableArray alloc] initWithObjects:
                    @"http://d1o8tuak29oxqa.cloudfront.net/viral/assets/ufile/video/2015/06/4d39386f99d3273bbbb4c2f76d36941c.mov",
                    @"http://d1o8tuak29oxqa.cloudfront.net/viral/assets/ufile/video/2015/06/a95d987ee211a943d15dcf973898b9fe.mov",
                    @"http://d1o8tuak29oxqa.cloudfront.net/viral/assets/ufile/video/2015/06/c514c826ab7e5a4c1a29f075353b41d6.mov",
                    @"http://d1o8tuak29oxqa.cloudfront.net/viral/assets/ufile/video/2015/06/560b63124d943e9219dd814afab3abd7.mov",
                    nil];
    
    //Customization
    _myScrollView.delaysContentTouches = NO;
    _myScrollView.contentSize = CGSizeMake(_myScrollView.frame.size.width * _numberOfViews, _myScrollView.frame.size.height);
    _myScrollView.delegate = self;
    _myScrollView.showsHorizontalScrollIndicator = YES;
    _myScrollView.pagingEnabled = YES;
    _myScrollView.userInteractionEnabled = YES;
    _myScrollView.bounces = NO;
    _myScrollView.showsHorizontalScrollIndicator = NO;
    
    //Create the views that will populate the scrollView
    for (int i = 0; i < _numberOfViews; i++) {
        
        UIView *cView = [[UIView alloc] init];
        
        //Set the frame for each view inside the ScrollView
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height);
        frame.origin.x = frame.size.width * i;
        cView.frame = frame;
        
        //Set the path of the video to the MPMoviePlayerController
         NSURL *url = [NSURL URLWithString:[videoNamesArray objectAtIndex:i]];
        


        MPMoviePlayerController * player = [[MPMoviePlayerController alloc] initWithContentURL:url];
        
        //Customization
        player.fullscreen = NO;
        player.scalingMode = MPMovieScalingModeAspectFill;
        [player.view setFrame:self.view.bounds];
        player.controlStyle = MPMovieControlStyleNone;
        player.shouldAutoplay = NO;
        player.view.clipsToBounds = YES;
        
        [player prepareToPlay];
        [player stop];
        
        //Get the image from the currentPlaybackTime to set it above the player
        
        
        UIImage *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];        UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame:player.view.frame];
        [thumbnailView setImage:thumbnail];
        [thumbnailView setContentMode:UIViewContentModeScaleAspectFill];
        thumbnailView.clipsToBounds = YES;
        
        //Add both views (player.view, and ImageView) to the currentView
        [cView addSubview:player.view];
        [cView addSubview:thumbnailView];
         
        
        
        //Add the view to myScrollView
        [_myScrollView addSubview:cView];
        
        //Add the player and the currentView to arrays for further manipulation
        [_playersArray addObject:player];
        [_viewsArray addObject:cView];
    }
    //add the ScrollView to the ViewController's view
    [self.view addSubview:_myScrollView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //Get the view (page) that is currently showing in the screen, inside the scrollView
    static NSInteger previousPage = 0;
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    int page = lround(fractionalPage);
    NSLog(@"page: %i",page);
    previousPage = page;
    
    //Get the current player from playerArray
    MPMoviePlayerController * startPlayer = [_playersArray objectAtIndex:page];
    
    //Pause the player;
    [startPlayer pause];
    
    //Get the thumbnail from the currentPlaybackTime
    UIImage *thumbnail = [startPlayer thumbnailImageAtTime:[startPlayer currentPlaybackTime] timeOption:MPMovieTimeOptionExact];
    UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame:startPlayer.view.frame];
    [thumbnailView setImage:thumbnail];
    
    //Customization
    [thumbnailView setContentMode:UIViewContentModeScaleAspectFill];
    thumbnailView.clipsToBounds = YES;
    
    //Get the second view (thumbnail) from the view.subviews array and unhide it (I hide it in scrollViewDidEndDecelerating method)
    UIView * startView = [_viewsArray objectAtIndex:page];
    UIView * imagestartView = [startView.subviews objectAtIndex:1];
    imagestartView.hidden = NO;
    imagestartView = thumbnailView;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //Get the view (page) that is currently showing in the screen, inside the scrollView
    static NSInteger previousPage = 0;
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    int page = lround(fractionalPage);
    NSLog(@"pageend: %i",page);
    previousPage = page;
    
    //Get the current player from playerArray and play it
    MPMoviePlayerController * endPlayer = [_playersArray objectAtIndex:page];
    [endPlayer play];
    
    //Get the second view (thumbnail) from the view.subviews array and hide it
    UIView * endView = [_viewsArray objectAtIndex:page];
    UIView * imageEndView = [endView.subviews objectAtIndex:1];
    imageEndView.hidden = YES;
    
}






/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
