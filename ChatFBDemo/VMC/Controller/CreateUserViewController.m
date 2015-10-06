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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onCreateUser:(id)sender {

    [FirebaseSharedManager createUserAccount:self.txtEmail.text andPassword:self.txtPassword.text withCompletionBlock:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            NSDictionary *userDetail = [NSDictionary dictionaryWithObjects:@[self.txtEmail.text, self.txtFirstName.text, self.txtLastName.text] forKeys:@[@"emailId",@"firstName",@"lastName"]];

            [FirebaseSharedManager setupUserDirectory:userDetail withCompletionBlock:^(BOOL isSuccess, NSError *error) {

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

            NSLog(@"The error is......%@", error);
        }
    }];
}

@end
