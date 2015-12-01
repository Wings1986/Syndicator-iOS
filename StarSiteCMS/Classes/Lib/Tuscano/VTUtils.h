//
//  VTUtils.h
//  
//
//  Created by Vincent Tuscano on 5/4/13.
//  Copyright (c) 2013 Vincent Tuscano. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "UIView+Additions.h"

@interface VTUtils : NSObject




+(BOOL)isResponseSuccessful:(NSDictionary *)dict;
+(UIView *)buildAnimatedLoadingViewWithMessage:(NSString *)message andColor:(UIColor *)color;
+(UIView *)buildLoaderViewWithMessage:(NSString *)message andColor:(UIColor *)color;
+(UIView *)buildBlackLoaderViewWithMessage:(NSString *)message;
+(UIView *)buildLoaderViewWithMessage:(NSString *)message;
+(NSString *)getTimeInStringFormatWithSeconds:(int)seconds;
+(NSString *)getTimeInStringFormatWithoutHours:(int)seconds;
+(void)applyHexagonMask:(UIView *)obj;
+(UIImage *)blur:(UIImage*)image;

+(void)makeStarPathWithView:(UIView *)view withWidth:(float)width andColor:(UIColor *)color;
//+(void)makeStarPathWithView:(UIView *)view withWidth:(float)width andColor:(UIColor *)color withOutlineColor:(UIColor *)outlineColor andOutlineWidth:(float)outlineWidth;
+(NSString *)commaFormatted:(int)val;


+(void)removeLoadingView:(UIView *)view;

+ (UIImage *)radialGradientImage:(CGSize)size start:(UIColor *)start end:(UIColor *)end centre:(CGPoint)center radius:(float)radius;



+(void)performAnimateSlideUpWithView:(UIView *)v endingY:(int)endingY;


@end
