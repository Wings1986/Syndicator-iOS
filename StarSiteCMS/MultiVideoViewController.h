//
//  MultiVideoViewController.h
//  StarSiteCMS
//
//  Created by Ian Cartwright on 01.09.15.
//  Copyright (c) 2015 StarClub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultiVideoViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property(strong,nonatomic) NSMutableArray * viewsArray;
@property (strong, nonatomic) IBOutlet UIScrollView *myScrollView;
@property int numberOfViews;
@property(strong,nonatomic) NSMutableArray * playersArray;


@end
