//
//  MeTableViewCell.h
//  P-Brain
//
//  Created by Patrick Quinn on 01/02/2017.
//  Copyright © 2017 GRAMMA Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeTableViewCell : UITableViewCell

@property (nonatomic, strong, nullable) IBOutlet UIView *wrapper;
@property (nonatomic, strong, nullable) IBOutlet UILabel *content;
@property (nonatomic, strong, nullable) IBOutlet UIImageView *avatar;
@property (nonatomic, strong, nullable) IBOutlet UILabel *timestamp;


@end
