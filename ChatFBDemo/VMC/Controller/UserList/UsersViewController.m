//
//  UsersViewController.m
//  HushChat
//
//  Created by Hiren on 10/2/15.
//  Copyright (c) 2015 openxcell. All rights reserved.
//

#import "UsersViewController.h"
#import "FirebaseManager.h"
#import "HomeViewController.h"

@interface UsersViewController ()
{
    NSMutableArray *users;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation UsersViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    users = [[NSMutableArray alloc] init];
    
    [FirebaseSharedManager getUserswithObservationBlock:^(id object) {
        NSDictionary *dictionary = (NSDictionary *)object;
        if ([[dictionary allKeys] count] > 0) {
            
            for (int i=0; i<[[dictionary allKeys] count]; i++) {
                NSString *key = [[dictionary allKeys] objectAtIndex:i];
                NSDictionary *profile = [[dictionary objectForKey:key] objectForKey:@"profile"];
                NSDictionary *combinedDict = [NSDictionary dictionaryWithObjects:@[key,profile] forKeys:@[@"userId",@"profile"]];
                [users addObject:combinedDict];
            }
            
            [self.tableView reloadData];
        }
    }];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [users count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
    NSDictionary *dict = users[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",    [[dict objectForKey:@"profile"] objectForKey:@"firstName"],     [[dict objectForKey:@"profile"] objectForKey:@"lastName"]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(startNewChatWithUser:)]) {
        [self.delegate startNewChatWithUser:users[indexPath.row]];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Event Handlers
- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
