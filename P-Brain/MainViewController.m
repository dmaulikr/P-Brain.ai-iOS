//
//  MainViewController.m
//  P-Brain
//
//  Created by Patrick Quinn on 16/02/2017.
//  Copyright © 2017 GRAMMA Music. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
    
    BOOL is_showing = [self showServerURLBox];
    
    if (!is_showing){
        [self tokenCheck];
    }
    
    
}

- (void) tokenCheck {
    NSString * token = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"token"];
    
    if (token){
        [self navigate_to_screen:@"Brain"];
    } else {
        [self navigate_to_screen:@"Login"];
    }

}

- (void) navigate_to_screen: (NSString*)screen{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:screen];
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) showServerURLBox {
    
    NSString *serverURL = [[NSUserDefaults standardUserDefaults]
                           valueForKey:@"pburl"];
    
    if (serverURL == nil){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter P-Brain.ai URL" message:@"Enter the local URL for your P-Brain.ai server here..." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            NSString * url = alert.textFields.firstObject.text;
            if (url){
                NSString * pburl = [NSString stringWithFormat:@"http://%@:4567/api/",url];
                [[NSUserDefaults standardUserDefaults] setValue:pburl forKey:@"pburl"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self tokenCheck];
            } else {
                [self showServerURLBox];
            }
        }]];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"x.x.x.x";
            textField.secureTextEntry = NO;
        }];
        [self presentViewController:alert animated:YES completion:nil];
        return YES;
    }
    
    return NO;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
