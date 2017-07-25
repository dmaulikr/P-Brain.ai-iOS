//
//  MainViewController.m
//  P-Brain
//
//  Created by Patrick Quinn on 16/02/2017.
//  Copyright © 2017 GRAMMA Music. All rights reserved.
//

#import "MainViewController.h"
#import "PData.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.activity startAnimating];
    NSString * base_ip = [[PData getData] getIPAddress];

    NSArray *nets = [base_ip componentsSeparatedByString:@"."];

    NSString * path = [NSString stringWithFormat:@"%@.%@.%@.",[nets objectAtIndex:0],[nets objectAtIndex:1],[nets objectAtIndex:2]];
    [self loopThroughSubnet:path];
}

- (void) loopThroughSubnet:(NSString*)path {
    for (int i = 0; i<= 255;i++){
        NSString * sub = [NSString stringWithFormat:@"%d", i];

        NSString * combi = [path stringByAppendingString:sub];

        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:4567/api/status",combi]]];
        if (!self.queue){
            self.queue = [[NSOperationQueue alloc] init];
        }
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:self.queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (!error){
                NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                if ([[resp valueForKey:@"msg"] isEqualToString:@"OK"]){
                    [self.queue cancelAllOperations];
                    [self.timer invalidate];
                    NSString * pburl = [NSString stringWithFormat:@"http://%@:4567/api/",combi];
                    [[NSUserDefaults standardUserDefaults] setValue:pburl forKey:@"pburl"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self tokenCheck];
                    });
                }
            }
        }];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(checkWetherToShow)
                                   userInfo:nil
                                    repeats:NO];
}
- (void) checkWetherToShow {
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] synchronize];


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
        [self.activity stopAnimating];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Local P-Brain.ai Server Found." message:@"Enter the URL for your P-Brain.ai server here..." preferredStyle:UIAlertControllerStyleAlert];
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
