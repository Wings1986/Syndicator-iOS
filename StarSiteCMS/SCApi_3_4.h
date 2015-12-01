//
//  SCApi_3_4.h
//  StarSiteCMS
//
//  Created by Ian Cartwright on 9/20/15.
//  Copyright © 2015 StarClub. All rights reserved.
//


@interface SCItem : NSObject



@property(nonatomic,strong) NSString *itemId;
@property(nonatomic,strong) NSString *postId;
@property(nonatomic,strong) NSString *thumbnail;
@property(nonatomic,strong) NSString *message;
@property(nonatomic,strong) NSString *postType;
@property(nonatomic,strong) NSString *videoId;
@property(nonatomic,strong) NSString *photoId;
@property(nonatomic,strong) NSString *url;
@property(nonatomic,strong) NSString *embed;
@property(nonatomic,strong) NSString *created;

// Facebook Insights
@property(nonatomic,strong) NSString *fb_likes;
@property(nonatomic,strong) NSString *fb_comments;
@property(nonatomic,strong) NSString *fb_shares;
@property(nonatomic,strong) NSString *fb_reaches;
// Twitter Insights
@property(nonatomic,strong) NSString *tw_retweets;
@property(nonatomic,strong) NSString *tw_favorites;
// Google + Insights
@property(nonatomic,strong) NSString *gp_likes;
@property(nonatomic,strong) NSString *gp_comments;
// Tublr Insights
@property(nonatomic,strong) NSString *tu_likes;
@property(nonatomic,strong) NSString *tu_comments;
// Starstats
@property(nonatomic,strong) NSString *ss_impressions;
@property(nonatomic,strong) NSString *ss_engagements;
@property(nonatomic,strong) NSString *ss_earnings;
@property(nonatomic,strong) NSString *ss_pageViews;
@property(nonatomic,strong) NSString *ss_videoViews;
@property(nonatomic,strong) NSString *ss_videoLengthHuman;
@property(nonatomic,strong) NSString *ss_videoLengthAndPercent;
@property(nonatomic,strong) NSString *ss_earningsTitle;

// Starsite CMS / Content Media
@property(nonatomic,strong) NSString *fileURL;
@property (assign, nonatomic) NSTimeInterval createdDate;
@property (assign, nonatomic) BOOL isPhoto;


-(SCItem *)initWithDictionary:(NSDictionary *)dict;

@end