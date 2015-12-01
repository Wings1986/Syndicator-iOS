//
//  SSPairingBottomButton.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 3/10/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSPairingBottomButton : UIButton{
    UILabel *_completedLabel;
}

@property(nonatomic,assign) BOOL isConnected;

-(void)setupWithDictionary:(NSDictionary *)dict;

@end
