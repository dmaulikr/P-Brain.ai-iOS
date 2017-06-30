//
//  MeTableViewCell.m
//  P-Brain
//
//  Created by Patrick Quinn on 01/02/2017.
//  Copyright © 2017 GRAMMA Music. All rights reserved.
//

#import "MeTableViewCell.h"

@implementation MeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.transform = CGAffineTransformMakeRotation(M_PI);
//    self.wrapper.layer.cornerRadius = 8.0;
//    self.wrapper.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2;
    self.avatar.layer.masksToBounds = YES;
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:self.wrapper.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomRight|UIRectCornerTopRight cornerRadii:CGSizeMake(10.0, 10.0)];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    self.wrapper.layer.mask = shape;
    
    [self.wrapper.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [self.wrapper.layer setShadowOpacity:0.8];
    [self.wrapper.layer setShadowRadius:3.0];
    [self.wrapper.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
