//
//  ConversationViewController.h
//  HushChat
//
//  Created by Hiren on 10/5/15.
//  Copyright © 2015 openxcell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Inputbar.h"

@interface ConversationViewController : UIViewController <UITableViewDelegate ,UITableViewDataSource, InputbarDelegate>
{

}
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *inputBarBottomConstraint;

@property (strong, nonatomic) IBOutlet Inputbar *inputBar;
@property (nonatomic, strong) NSDictionary *conversationDetail;

@end
