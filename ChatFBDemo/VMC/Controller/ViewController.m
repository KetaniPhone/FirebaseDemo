//
//  ViewController.m
//  ChatFBDemo
//
//  Created by Ketan on 10/5/15.
//  Copyright (c) 2015 kETAN pATEL. All rights reserved.
//

#import "ViewController.h"
#import <Firebase/Firebase.h>

#define kFirechatNS @"https://chatnatest.firebaseio.com/"
#define kEmailId    @"ketan@gmail.com"
#define kPassword   @"123456"

@interface ViewController () {
    Firebase *ref;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ref = [[Firebase alloc] initWithUrl:kFirechatNS];
    [self createUser];
}

//-(void)removeUser {
//    [ref removeUser:kEmailId password:kPassword withCompletionBlock:^(NSError *error) {
//        if (error) {
//            NSLog(@"Error");
//            [self createUser];
//        } else {
//            NSLog(@"Successfully Deleted");
//            [self createUser];
//        }
//    }];
//}

-(void)createUser {
    
    [ref createUser:kEmailId password:kPassword withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
        if (error) {
            NSLog(@"Already Exist");
            [self loginUser];
        } else {
            NSString *uid = [result objectForKey:@"uid"];
            NSLog(@"Successfully created user account with uid: %@", uid);
            [self loginUser];
        }
        
    }];
    
}

-(void)loginUser {
    
    [ref authUser:kEmailId password:kPassword withCompletionBlock:^(NSError *error, FAuthData *authData) {
        if (error) {
            NSLog(@"Error");
        } else {
            NSLog(@"Successfully created user account with authData: %@", authData);
            [self createUserEntryWithId:[authData.auth valueForKey:@"uid"]];
        }
        
    }];
    
}

-(void)createUserEntryWithId:(NSString *)strId {
    
    Firebase *postRef = [ref childByAppendingPath: @"userList"];
    postRef = [postRef childByAppendingPath: strId];
    postRef = [postRef childByAppendingPath: @"Profile"];
    NSDictionary *post = @{
                           @"email": @"ketan@gmail.com",
                           @"firstName": @"Ketan",
                           @"lastName": @"Patel"
                           };
    [postRef setValue: post];
    
    
    [postRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"User  ::     %@", snapshot.value[@"email"]);
        NSLog(@"fName ::     %@", snapshot.value[@"firstName"]);
        NSLog(@"LName ::     %@", snapshot.value[@"lastName"]);
    }];
    
}

@end
