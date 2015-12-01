//
//  SSTempView.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 5/26/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSTempView : UIView{
    UIBezierPath *path;
    CGPoint previousPoint;
}

-(void)initThis;
@end
