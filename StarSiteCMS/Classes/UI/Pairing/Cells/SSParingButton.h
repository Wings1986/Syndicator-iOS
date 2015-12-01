//
//  SSParingButton.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 3/22/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSParingButton : UIButton{
    UILabel *_checkmark;
    UIActivityIndicatorView *_actview;
    NSMutableDictionary *_dict;
    UILabel *_connectedStatusLabel;
    BOOL _isAddMore;
    UISwitch *_theSwitch;
}


-(void)buildButtonWithDictionary:(NSDictionary *)dict;
    
@end
