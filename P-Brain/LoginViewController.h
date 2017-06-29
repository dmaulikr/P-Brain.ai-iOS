//
//  LoginViewController.h
//  P-Brain
//
//  Created by Patrick Quinn on 16/02/2017.
//  Copyright © 2017 GRAMMA Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PComms.h"

@interface LoginViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *go;
@property (strong, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) IBOutlet UITextField *pass;


- (IBAction)login:(UIButton *)sender;


@end
