//
//  CreateUserViewController.m
//  HushChat
//
//  Created by Hiren on 10/2/15.
//  Copyright (c) 2015 openxcell. All rights reserved.
//

#import "CreateUserViewController.h"
#import "FirebaseManager.h"

@interface CreateUserViewController ()

@end

@implementation CreateUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)onCreateUser:(id)sender {

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    [FirebaseSharedManager createUserAccount:self.txtEmail.text andPassword:self.txtPassword.text withCompletionBlock:^(BOOL isSuccess, NSError *error) {
        
        if (isSuccess) {
            NSDictionary *userDetail = [NSDictionary dictionaryWithObjects:@[self.txtEmail.text, self.txtFirstName.text, self.txtLastName.text] forKeys:@[@"emailId",@"firstName",@"lastName"]];

            [FirebaseSharedManager setupUserDirectory:userDetail withCompletionBlock:^(BOOL isSuccess, NSError *error) {

                [SVProgressHUD dismiss];
                
                if (isSuccess) {
                    NSLog(@"Successfully setup directory");
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else {
                    NSLog(@"The error is......%@", error);
                }
            }];
        }
        else {

            [SVProgressHUD dismiss];
            NSLog(@"The error is......%@", error);
        }
    }];
}

@end
