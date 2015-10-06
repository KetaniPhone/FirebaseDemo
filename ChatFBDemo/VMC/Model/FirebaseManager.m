//
//  FirebaseManager.m
//  HushChat
//
//  Created by Hiren on 10/2/15.
//  Copyright (c) 2015 openxcell. All rights reserved.
//

#import "FirebaseManager.h"
#import <CommonCrypto/CommonDigest.h>


#define MAIN_URL                @"https://hushchat.firebaseio.com/"
#define USER_DIRECTORY          @"users/"
#define MESSAGES_DIRECTORY      @"messages/"
#define LIST_OF_CONVERSATIONS   @"chats/"

@implementation FirebaseManager
{
    FAuthData *authenticationData;
    NSString *currentUserEmailId;
    NSDictionary *myProfile;
}

+ (FirebaseManager*)sharedInstance
{
    // 1
    static FirebaseManager *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[FirebaseManager alloc] init];
        [_sharedInstance setup];
    });
    return _sharedInstance;
}

- (void)setup
{
    [Firebase defaultConfig].persistenceEnabled = true;
    firebaseRef = [[Firebase alloc] initWithUrl:MAIN_URL];
}

#pragma mark - Create User account

- (void)createUserAccount:(NSString *)email andPassword:(NSString *)password withCompletionBlock:(void(^)(BOOL isSuccess, NSError *error))completionBlock
{
    [firebaseRef createUser:email password:password withCompletionBlock:^(NSError *error) {
        if (error) {
            NSLog(@"The error is.......%@", error);
            completionBlock(false,error);
        }
        else {
            NSLog(@"The account is created successfully");
            completionBlock(true,nil);
            //Add user to users directory for testing purpose
        }
    }];
}

#pragma mark - Login User
- (void)loginUserWithEmail:(NSString *)email andPassword:(NSString *)password withBlock:(void(^)(BOOL isSuccess, NSError *error))completionBlock
{
    [firebaseRef authUser:email password:password withCompletionBlock:^(NSError *error, FAuthData *authData) {
        if (error) {
            completionBlock(false,error);
        }
        else {
            authenticationData = authData;
            currentUserEmailId = email;
            NSLog(@"The auth data is....%@",authData);
            
            //Get Profile
            NSString *userId = [self sha1:currentUserEmailId];
            Firebase *usersDirectory = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@/%@/profile",MAIN_URL,USER_DIRECTORY,userId]];
            [usersDirectory observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                NSLog(@"User's profile is.....%@", snapshot.value);
                myProfile = snapshot.value;
                completionBlock(true,nil);
            }];
        }
    }];
}


#pragma mark - Setup User Directory

- (void)setupUserDirectory:(NSDictionary *)userDetail withCompletionBlock:(void(^)(BOOL isSuccess, NSError *error))completionBlock
{
    Firebase *usersDirectory = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@",MAIN_URL,USER_DIRECTORY]];
    Firebase *childRef =  [usersDirectory childByAppendingPath:[self sha1:userDetail[@"emailId"]]];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:userDetail[@"emailId"] forKey:@"emailId"];
    [dictionary setObject:userDetail[@"firstName"] forKey:@"firstName"];
    [dictionary setObject:userDetail[@"lastName"] forKey:@"lastName"];
    NSDictionary *profileDictionary = [NSDictionary dictionaryWithObject:dictionary forKey:@"profile"];

    [childRef setValue:profileDictionary withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error) {
            completionBlock(false, error);
        }
        else {
            completionBlock(true, nil);
        }
    }];
}

-(void)startNewChatToUser:(NSDictionary *)otherUserProfile
{
    NSMutableArray *users = [[NSMutableArray alloc] init];
    [users addObject:myProfile];
    [users addObject:otherUserProfile];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:users forKey:@"users"];
    
    NSString *chatId = [self sha1:[NSString stringWithFormat:@"%@_%@", currentUserEmailId, otherUserProfile[@"emailId"]]];
    
    //Convert mail id to sha1
    NSString *userId = [self sha1:currentUserEmailId];
    Firebase *currentUserPath = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@%@/chats/%@",MAIN_URL,USER_DIRECTORY,userId,chatId]];
    [currentUserPath setValue:dictionary];
    
    NSString *otherUserId = [self sha1:otherUserProfile[@"emailId"]];
    Firebase *otherUserPath = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@%@/chats/%@",MAIN_URL,USER_DIRECTORY,otherUserId,chatId]];
    [otherUserPath setValue:dictionary];
}

-(void)getListOfConversation:(void(^)(BOOL isSuccess, NSArray *conversations))completionBlock
{
    NSString *userId = [self sha1:currentUserEmailId];
    Firebase *firebaseChatsPath = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@%@/chats", MAIN_URL,USER_DIRECTORY,userId]];
   
    [firebaseChatsPath observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSDictionary *dictionary = (NSDictionary *)snapshot.value;
        // NSLog(@"The dictionary is......%@", dictionary);
        NSMutableArray *conversations = [[NSMutableArray alloc] init];
        if ([[dictionary allKeys] count] > 0) {
            for (int i=0; i<[[dictionary allKeys] count]; i++) {
                NSString *key = snapshot.key;
                NSArray *users = [dictionary objectForKey:@"users"];
                
                BOOL isOtherUser = NO;
                int otherUserIndex = -1;
                for (int i=0; i<[users count]; i++) {
                    if (![[users[i] objectForKey:@"emailId"] isEqualToString:currentUserEmailId]) {
                        otherUserIndex = i;
                        isOtherUser = true;
                        break;
                    }
                }
                
                if (isOtherUser) {
                    NSDictionary *dictionary = users[otherUserIndex];
                    NSDictionary *combinedDict = [NSDictionary dictionaryWithObjects:@[key,dictionary] forKeys:@[@"conversationId",@"userDetail"]];
                    [conversations addObject:combinedDict];
                }
            }
        }
        completionBlock(true,conversations);
    }];
    
}

#pragma mark - Messages Method
- (void)sendMessage:(NSString *)msg inConversation:(NSString *)conversationId
{
    Firebase *conversationPath = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@%@",MAIN_URL,MESSAGES_DIRECTORY,conversationId]];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:msg forKey:@"msg"];
    [dictionary setObject:currentUserEmailId forKey:@"sender"];
    [conversationPath.childByAutoId setValue:dictionary];
}

- (void)getMessages:(NSString *)conversationId withObservingBlock:(void(^)(BOOL isSuccess, NSArray *conversations))observingBlock
{
    Firebase *messagePath = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@%@", MAIN_URL,MESSAGES_DIRECTORY,conversationId]];
    [[messagePath queryLimitedToLast:10] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        [messages addObject:snapshot.value];
        observingBlock(true,messages);
    }];
}

#pragma mark - Get Users
- (void)getUserswithObservationBlock:(void(^)(id object))observationBlock
{
    Firebase *usersDirectory = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@",MAIN_URL,USER_DIRECTORY]];
    [usersDirectory observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        //NSLog(@"The snapshot value is.....%@", snapshot.value);
        observationBlock(snapshot.value);
    }];
}

#pragma mark - Common Methods

- (NSString *)sha1:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   result[0], result[1], result[2], result[3], result[4],
                   result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11], result[12],
                   result[13], result[14], result[15],
                   result[16], result[17], result[18], result[19]
                   ];
    return s;
}

@end
