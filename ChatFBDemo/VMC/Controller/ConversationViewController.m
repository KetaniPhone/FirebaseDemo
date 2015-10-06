//
//  ConversationViewController.m
//  HushChat
//
//  Created by Hiren on 10/5/15.
//  Copyright © 2015 openxcell. All rights reserved.
//

#import "ConversationViewController.h"
#import "MessageCell.h"
#import "FirebaseManager.h"
#import "DAKeyboardControl.h"

@interface ConversationViewController ()
{
    NSMutableArray *messages;
}

@property (strong, nonatomic) IBOutlet UITableView *tblMessages;

@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tblMessages.rowHeight = UITableViewAutomaticDimension;
    self.tblMessages.estimatedRowHeight = 70;

    messages = [[NSMutableArray alloc] init];

    [self setInputbar];
    [self setKeyboardControl];
    [self getMessages];
    //Do any additional setup after loading the view.
}

- (void)setKeyboardControl
{
    __weak Inputbar *inputbar = _inputBar;
    __weak UITableView *tableView = _tblMessages;
    
//    __weak ConversationViewController *weakSelf = self;
    
    self.view.keyboardTriggerOffset = inputbar.frame.size.height;
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        /*
         Try not to call "self" inside this block (retain cycle).
         But if you do, make sure to remove DAKeyboardControl
         when you are done with the view controller by calling:
         [self.view removeKeyboardControl];
         */
        
        CGRect toolBarFrame = inputbar.frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        inputbar.frame = toolBarFrame;
        
        CGRect tableViewFrame = tableView.frame;
        tableViewFrame.size.height = toolBarFrame.origin.y - 64;
        tableView.frame = tableViewFrame;
        
//        [controller tableViewScrollToBottomAnimated:NO];
    }];
}

-(void)setInputbar
{
    self.inputBar.placeholder = nil;
    self.inputBar.delegate = self;
    self.inputBar.leftButtonImage = [UIImage imageNamed:@"share"];
    self.inputBar.rightButtonText = @"Send";
    self.inputBar.rightButtonTextColor = [UIColor colorWithRed:0 green:124/255.0 blue:1 alpha:1];
}

#pragma mark - Inputbar Delegate
-(void)inputbarDidPressRightButton:(Inputbar *)inputbar
{
    //NSLog(@"Input bar right button pressed %@", inputbar.text);
    [FirebaseSharedManager sendMessage:inputbar.text inConversation:[self.conversationDetail objectForKey:@"conversationId"]];
}

-(void)inputbarDidPressLeftButton:(Inputbar *)inputbar
{
    NSLog(@"Input bar left button pressed");

}

-(void)inputbarDidChangeHeight:(CGFloat)new_height
{
    //Update DAKeyboardControl
    self.view.keyboardTriggerOffset = new_height;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messages count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"messageCell";
    MessageCell *messageCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    NSDictionary *msgDictionary = messages[indexPath.row];
    messageCell.lblSender.text = msgDictionary[@"sender"];
    messageCell.lblMessageString.text = msgDictionary[@"msg"];
    
    return messageCell;
}

- (void)getMessages
{
    [FirebaseSharedManager getMessages:[self.conversationDetail objectForKey:@"conversationId"] withObservingBlock:^(BOOL isSuccess, NSArray *conversations) {
        [messages addObjectsFromArray:conversations];
        [self.tblMessages reloadData];
    }];
}

@end
