//
//  UsersViewController.h
//  HushChat
//
//  Created by Hiren on 10/2/15.
//  Copyright (c) 2015 openxcell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsersViewController.h"

@class HomeViewController;
@interface UsersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL isNewChat;

@end
