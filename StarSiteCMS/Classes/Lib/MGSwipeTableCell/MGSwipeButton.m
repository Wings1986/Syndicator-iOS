/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */

#import "MGSwipeButton.h"

@class MGSwipeTableCell;

@implementation MGSwipeButton

+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color
{
    return [self buttonWithTitle:title icon:nil backgroundColor:color];
}

+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color padding:(NSInteger) padding
{
    return [self buttonWithTitle:title icon:nil backgroundColor:color insets:UIEdgeInsetsMake(0, padding, 0, padding)];
}

+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color insets:(UIEdgeInsets) insets
{
    return [self buttonWithTitle:title icon:nil backgroundColor:color insets:insets];
}

+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color callback:(MGSwipeButtonCallback) callback
{
    return [self buttonWithTitle:title icon:nil backgroundColor:color callback:callback];
}

+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color padding:(NSInteger) padding callback:(MGSwipeButtonCallback) callback
{
    return [self buttonWithTitle:title icon:nil backgroundColor:color insets:UIEdgeInsetsMake(0, padding, 0, padding) callback:callback];
}

+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color insets:(UIEdgeInsets) insets callback:(MGSwipeButtonCallback) callback
{
    return [self buttonWithTitle:title icon:nil backgroundColor:color insets:insets callback:callback];
}

+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color
{
    return [self buttonWithTitle:title icon:icon backgroundColor:color callback:nil];
}

+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color padding:(NSInteger) padding
{
    return [self buttonWithTitle:title icon:icon backgroundColor:color insets:UIEdgeInsetsMake(0, padding, 0, padding) callback:nil];
}

+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color insets:(UIEdgeInsets) insets
{
    return [self buttonWithTitle:title icon:icon backgroundColor:color insets:insets callback:nil];
}

+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color callback:(MGSwipeButtonCallback) callback
{
    return [self buttonWithTitle:title icon:icon backgroundColor:color padding:10 callback:callback];
}

+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color padding:(NSInteger) padding callback:(MGSwipeButtonCallback) callback
{
    return [self buttonWithTitle:title icon:icon backgroundColor:color insets:UIEdgeInsetsMake(0, padding, 0, padding) callback:callback];
}

+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color insets:(UIEdgeInsets) insets callback:(MGSwipeButtonCallback) callback
{
    MGSwipeButton * button = [self buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_THIN size:button.titleLabel.font.pointSize];
    [button setTitle:title forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setImage:icon forState:UIControlStateNormal];
    button.callback = callback;
    [button setEdgeInsets:insets];
    return button;
}

+(instancetype) buttonWithTitle:(NSString *)title andIcon:(NSString*) icon backgroundColor:(UIColor *) color withHeight:(int)height{
    int bSize = height;
    int bWidth = height;
    if(bWidth > 70)
        bWidth = 70;
    
    MGSwipeButton * button = [self buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    //button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    //button.titleLabel.textAlignment = NSTextAlignmentCenter;
    //button.titleLabel.font
    //[button setTitle:title forState:UIControlStateNormal];
    //button.titleEdgeInsets = UIEdgeInsetsMake(height, 0, 0, 0);


    
    button.width = bWidth;
    button.height = bSize;
    

    
    
    UILabel *theIcon = [[UILabel alloc] initWithFrame:button.frame];
    theIcon.font = [UIFont fontWithName:FONT_ICONS size:28];
    theIcon.text = icon;
    theIcon.textColor = [UIColor whiteColor];
    theIcon.textAlignment = NSTextAlignmentCenter;
    [button addSubview:theIcon];
    theIcon.width = bWidth;
    theIcon.height = bSize;
    [theIcon sizeToFit];
    theIcon.height = bSize;
    theIcon.x = button.width/2 - theIcon.width/2;
    theIcon.y = 0;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if([title length] > 1){
        UILabel *theTitle = [[UILabel alloc] initWithFrame:button.frame];
        theTitle.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:9];
        theTitle.numberOfLines = 0;
        theTitle.text = title;
        theTitle.textColor = [UIColor whiteColor];
        theTitle.textAlignment = NSTextAlignmentCenter;
        [theTitle sizeToFit];
        theTitle.x = button.width/2 - theTitle.width/2;
        theTitle.y = button.height - theTitle.height - 12;
        [button addSubview:theTitle];
        theIcon.y -= 8;
    }
    
    UILabel *sh = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 2, button.height)];
    sh.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    sh.layer.shadowColor = [UIColor blackColor].CGColor;
    sh.layer.shadowOpacity = 1;
    sh.layer.shadowOffset = CGSizeMake(0, 0);
    sh.layer.shadowRadius = 10.0;
    

    
    
    [button addSubview:sh];
    
    
//    [button setImage:icon forState:UIControlStateNormal];
//    button.callback = callback;
//    [button setEdgeInsets:insets];
    return button;
}

-(BOOL) callMGSwipeConvenienceCallback: (MGSwipeTableCell *) sender
{
    if (_callback) {
        return _callback(sender);
    }
    return NO;
}

-(void) centerIconOverText {
	const CGFloat spacing = 3.0;
	CGSize size = self.imageView.image.size;
	self.titleEdgeInsets = UIEdgeInsetsMake(0.0,
											-size.width,
											-(size.height + spacing),
											0.0);
	size = [self.titleLabel.text sizeWithAttributes:@{ NSFontAttributeName: self.titleLabel.font }];
	self.imageEdgeInsets = UIEdgeInsetsMake(-(size.height + spacing),
											0.0,
											0.0,
											-size.width);
}

-(void) setPadding:(CGFloat) padding
{
    self.contentEdgeInsets = UIEdgeInsetsMake(0, padding, 0, padding);
    [self sizeToFit];
}

- (void)setButtonWidth:(CGFloat)buttonWidth
{
    _buttonWidth = buttonWidth;
    if (_buttonWidth > 0)
    {
        CGRect frame = self.frame;
        frame.size.width = _buttonWidth;
        self.frame = frame;
    }
    else
    {
        [self sizeToFit];
    }
}

-(void) setEdgeInsets:(UIEdgeInsets)insets
{
    self.contentEdgeInsets = insets;
    [self sizeToFit];
}

@end
