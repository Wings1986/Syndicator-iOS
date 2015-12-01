//
//  SSTempView.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 5/26/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import "SSTempView.h"

@implementation SSTempView


-(void)initThis{

    path = [UIBezierPath bezierPath];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.maximumNumberOfTouches = pan.minimumNumberOfTouches = 1;
    [self addGestureRecognizer:pan];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    
    CGPoint currentPoint = [pan locationInView:self];
    CGPoint midPoint = midpoint(previousPoint, currentPoint);
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        [path moveToPoint:currentPoint];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [path addQuadCurveToPoint:midPoint controlPoint:previousPoint];
    }
    
    previousPoint = currentPoint;
    
    [self setNeedsDisplay];
    
}

- (void)drawRect:(CGRect)rect
{
    [[UIColor blackColor] setStroke];
    [path setLineWidth:3.0];
    [path stroke];
}

static CGPoint midpoint(CGPoint p0, CGPoint p1) {
    return (CGPoint) {
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0
    };
}


@end
