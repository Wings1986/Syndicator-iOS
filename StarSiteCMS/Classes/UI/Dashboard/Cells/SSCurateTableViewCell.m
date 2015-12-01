//
//  SSCurateTableViewCell.m
//  StarSiteCMS
//
//  Continued by IC.
//  Copyright (c) 2014 US Mastertec. All rights reserved.
//

#import "SSCurateTableViewCell.h"

@implementation SSCurateTableViewCell

- (void)awakeFromNib {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addBottomBorderWithHeight:0.5 andColor:[UIColor colorWithHexString:COLOR_GRAY_LINE]];
    });
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    _itemImage.image = nil;
    _itemImage.layer.cornerRadius = 0;
    _itemImage.layer.borderColor = [[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.1].CGColor;
    _itemImage.layer.borderWidth = 1;
    _itemValue.alpha = 0.5;
    _itemImage.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    if(selected){
        self.backgroundColor = [UIColor colorWithHexString:@"#192126"];
    }else{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    }
}

-(void)setupWithContent:(NSDictionary *)dict{
    
    _itemTitle.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
    _itemImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[NSString returnStringObjectForKey:@"img" withDictionary:dict]]];
    _itemDate.text = [NSString stringWithFormat:@"%@",[NSString returnStringObjectForKey:@"ago" withDictionary:dict]];
}

-(void)setupWithItem:(SCItem *)item{
    _itemImage.image = nil;
    _itemTitle.text = item.message;
     [_itemImage setImageWithURL:[NSURL URLWithString:item.thumbnail] placeholderImage:[SSAppController sharedInstance].appImage];
    
    _itemDate.text = item.ss_videoLengthHuman;
    
    if ([_itemDate.text isEqualToString:@"00:00:00"]) {
        
        
            NSURL *videoURL=[NSURL URLWithString:item.fileURL];
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
            
            NSTimeInterval durationInSeconds = 0.0;
            if (asset ) {
                durationInSeconds = CMTimeGetSeconds(asset.duration);

                
                int seconds = (int) durationInSeconds % 60;
                int minutes = (int) (durationInSeconds / 60) % 60;
                int hours = (int) durationInSeconds / 3600;
                
            _itemDate.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];

        }
    }

 }



@end
