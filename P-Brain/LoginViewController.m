//
//  LoginViewController.m
//  P-Brain
//
//  Created by Patrick Quinn on 16/02/2017.
//  Copyright © 2017 GRAMMA Music. All rights reserved.
//

#import "LoginViewController.h"
#import "ViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController {
    BOOL isKeyboardHidden;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initKeyboardNotifications];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loginUserWithName: (NSString*)name andPass:(NSString*)pass {
    [[PComms getComms] makeLoginRequestWithUser:name andPass:pass withBlock:^(id response, id error) {
        NSLog(@"RES %@", response);
        NSLog(@"ERR %@", error);

        if ([response valueForKey:@"token"]){
            [[NSUserDefaults standardUserDefaults] setValue:[response valueForKey:@"token"] forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] removeObserver:self];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideKeyboard];
                UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Brain"];
                [self presentViewController:vc animated:NO completion:nil];
            });
            
        }
    }];
}

- (void) initKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    isKeyboardHidden = YES;
}

- (IBAction)login:(UIButton *)sender {
    NSString * name = self.name.text;
    NSString * pass = self.pass.text;
    
    if (name && pass){
        [self loginUserWithName:name andPass:pass];
    }
}

- (void) hideKeyboard {
    [self.name resignFirstResponder];
    [self.pass resignFirstResponder];
}

- (void) keyboardWillShow: (NSNotification*) notification {
    if (isKeyboardHidden){
        [UIView beginAnimations:nil context:NULL];
        
        [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        //        [UIView setAnimationCurve:[[[notification userInfo] objectForKey: UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        CGRect rect = [[self view] frame];
        
        rect.origin.y -= [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
        
        [[self view] setFrame: rect];
        
        [UIView commitAnimations];
        isKeyboardHidden = NO;
    }
}

- (void) keyboardWillHide: (NSNotification*) notification {
    if (!isKeyboardHidden){
        [UIView beginAnimations:nil context:NULL];
        
        [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        //        [UIView setAnimationCurve:[[[notification userInfo] objectForKey: UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        CGRect rect = [[self view] frame];
        
        rect.origin.y += [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
        
        [[self view] setFrame: rect];
        
        [UIView commitAnimations];
        isKeyboardHidden = YES;
    }
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
