//
//  LoginViewController.m
//  HushChat
//
//  Created by Hiren on 10/5/15.
//  Copyright © 2015 openxcell. All rights reserved.
//

#import "LoginViewController.h"
#import "FirebaseManager.h"
#import "HomeViewController.h"
#import "SVProgressHUD.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.txtEmail.text = @"k1@gmail.com";
    self.txtPassword.text = @"apple";
}

- (IBAction)onLogin:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    [[FirebaseManager sharedInstance] loginUserWithEmail:self.txtEmail.text andPassword:self.txtPassword.text withBlock:^(BOOL isSuccess, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        if (isSuccess) {
            NSLog(@"User logined successfully");
            [self showHomeViewController];
        }
        else
        {
            NSLog(@"User Failed to login %@", error);
        }
    }];
}

#pragma mark - Common Methods
- (void)showHomeViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    HomeViewController *homeViewController = [storyboard instantiateViewControllerWithIdentifier:@"homeViewController"];
    [self.navigationController pushViewController:homeViewController animated:YES];
}

@end
