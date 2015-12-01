//
//  SSParingButton.m
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 3/22/15.
//  Copyright (c) 2015 Vincent Tuscano. All rights reserved.
//

#import "SSParingButton.h"

@implementation SSParingButton


-(void)buildButtonWithDictionary:(NSDictionary *)dict{
    
    _dict = [NSMutableDictionary dictionaryWithDictionary:dict];
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self setTitle:[NSString returnStringObjectForKey:@"title" withDictionary:_dict] forState:UIControlStateNormal];
    _isAddMore = [[NSString returnStringObjectForKey:@"add" withDictionary:_dict] isEqualToString:@"Y"];

    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    self.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2].CGColor;
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 8;

    _connectedStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 30)];
    [self addSubview:_connectedStatusLabel];

    _checkmark = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _checkmark.text = @"V";
    _checkmark.font = [UIFont fontWithName:FONT_ICONS size:22];
    _checkmark.textColor = [UIColor whiteColor];
    [_checkmark sizeToFit];
    _checkmark.x = 20;//
    _checkmark.x = self.width - _checkmark.width - 10;
    _checkmark.y = self.height/2 - _checkmark.height/2;
    _checkmark.tag = 301;
    _checkmark.hidden = NO;
    
    _actview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _actview.x = _checkmark.x;
    _actview.y = _checkmark.y;
    _actview.tag = 302;
    _actview.hidden = YES;
    [self addSubview:_actview];
    
    [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    _theSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _theSwitch.x = self.width - _theSwitch.width - 10;
    _theSwitch.y = self.height/2 - _theSwitch.height/2;
    [_theSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_theSwitch];
    
    _connectedStatusLabel.text = @"V CONNECTED";
    _connectedStatusLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:11];
    _connectedStatusLabel.textColor = [UIColor colorWithHexString:@"888888"];
    self.selected = ([[NSString returnStringObjectForKey:@"active" withDictionary:_dict] isEqualToString:@"Y"]);
    [self updateConnectedTitle];
}

-(void)switchChanged:(UISwitch *)s{
    [self buttonPressed];
}

-(void)updateConnectedTitle{
    
    if(_isAddMore){
        _connectedStatusLabel.hidden = YES;
        _theSwitch.hidden = YES;
        return;
    }
    
    _theSwitch.hidden = NO;
    
    if(self.selected){
        _connectedStatusLabel.text = @"V CONNECTED";
        _connectedStatusLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:11];
        _connectedStatusLabel.textColor = [UIColor colorWithHexString:@"888888"];
    
        NSRange range = NSMakeRange(0,1);
        UIColor *statusColor = [UIColor greenColor];
        
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:statusColor, NSForegroundColorAttributeName,
                                  [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:11], NSFontAttributeName,
                                  nil];
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont fontWithName:FONT_ICONS size:8], NSFontAttributeName,
                               statusColor, NSForegroundColorAttributeName,nil];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:_connectedStatusLabel.text attributes:subAttrs];
        [attributedText setAttributes:attrs range:range];
        [_connectedStatusLabel setAttributedText:attributedText];
    }else{
        _connectedStatusLabel.text = @"NOT CONNECTED";
        _connectedStatusLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:11];
        _connectedStatusLabel.textColor = [UIColor colorWithHexString:@"#CC0000"];
        self.backgroundColor = [UIColor clearColor];
    }
    [_theSwitch setOn:self.selected animated:YES];
    [_connectedStatusLabel sizeToFit];
    _connectedStatusLabel.x = 10;
    _connectedStatusLabel.width = _theSwitch.x - _connectedStatusLabel.x;
    _connectedStatusLabel.y = self.height - _connectedStatusLabel.height - 4;
    
}

-(void)buttonPressed{
    self.selected = !self.selected;
    [_theSwitch setOn:self.selected animated:YES];
    [self updateConnectedTitle];
    
    if(_isAddMore){
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PARING_ADD_MORE object:nil];
    }else{
        [_dict setValue:(self.selected) ? @"Y" : @"N" forKey:@"active"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PARING_TOGGLE_CHANGED object:_dict];
    }
    
}



@end
