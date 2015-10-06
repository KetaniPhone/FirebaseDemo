//
//  CreateUserViewController.h
//  HushChat
//
//  Created by Hiren on 10/2/15.
//  Copyright (c) 2015 openxcell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"

@interface CreateUserViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtFirstName;
@property (strong, nonatomic) IBOutlet UITextField *txtLastName;


- (IBAction)onCreateUser:(id)sender;

@end
