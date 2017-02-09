//
//  YouTableViewCell.m
//  P-Brain
//
//  Created by Patrick Quinn on 01/02/2017.
//  Copyright © 2017 GRAMMA Music. All rights reserved.
//

#import "YouTableViewCell.h"

@implementation YouTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.transform = CGAffineTransformMakeRotation(M_PI);
    self.wrapper.layer.cornerRadius = 12.0;
    self.wrapper.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2;
    self.avatar.layer.masksToBounds = YES;

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
