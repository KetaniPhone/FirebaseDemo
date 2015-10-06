//
//  FirebaseManager.h
//  HushChat
//
//  Created by Hiren on 10/2/15.
//  Copyright (c) 2015 openxcell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>

#define FirebaseSharedManager [FirebaseManager sharedInstance]

@interface FirebaseManager : NSObject
{
     Firebase *firebaseRef;
}

+ (FirebaseManager*)sharedInstance;

- (void)createUserAccount:(NSString *)email andPassword:(NSString *)password withCompletionBlock:(void(^)(BOOL isSuccess, NSError *error))completionBlock;

//When user Signup
- (void)setupUserDirectory:(NSDictionary *)userDetail withCompletionBlock:(void(^)(BOOL isSuccess, NSError *error))completionBlock;

//
- (void)getUserswithObservationBlock:(void(^)(id object))observationBlock;

- (void)loginUserWithEmail:(NSString *)email andPassword:(NSString *)password withBlock:(void(^)(BOOL isSuccess, NSError *error))completionBlock;

- (void)startNewChatToUser:(NSString *)emailId;

- (void)getListOfConversation:(void(^)(BOOL isSuccess, NSArray *conversations))completionBlock;

- (void)sendMessage:(NSString *)msg inConversation:(NSString *)conversationId;

- (void)getMessages:(NSString *)conversationId withObservingBlock:(void(^)(BOOL isSuccess, NSArray *conversations))observingBlock;

@end
