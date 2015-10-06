//
//  MessageCell.h
//  HushChat
//
//  Created by Hiren on 10/5/15.
//  Copyright © 2015 openxcell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblSender;
@property (strong, nonatomic) IBOutlet UILabel *lblMessageString;

@end
