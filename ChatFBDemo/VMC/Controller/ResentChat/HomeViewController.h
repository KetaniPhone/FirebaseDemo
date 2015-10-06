//
//  HomeViewController.h
//  HushChat
//
//  Created by Hiren on 10/5/15.
//  Copyright © 2015 openxcell. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface HomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

-(void)startNewChatWithUser:(NSDictionary *)user;

@end