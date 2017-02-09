//
//  YouTableViewCell.h
//  P-Brain
//
//  Created by Patrick Quinn on 01/02/2017.
//  Copyright © 2017 GRAMMA Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YouTableViewCell : UITableViewCell

@property (nonatomic, weak, nullable) IBOutlet UIView *wrapper;
@property (nonatomic, weak, nullable) IBOutlet UILabel *content;
@property (nonatomic, weak, nullable) IBOutlet UIImageView *avatar;
@property (nonatomic, weak, nullable) IBOutlet UILabel *timestamp;

@end
