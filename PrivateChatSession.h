//
//  PrivateChatSession.h
//  offlineChattr
//
//  Created by Patrik Boras on 02/05/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PrivateChatEntry, PrivateKey, PublicKey;

@interface PrivateChatSession : NSManagedObject

@property (nonatomic, retain) NSString * opponent;
@property (nonatomic, retain) NSString * sessionID;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * initiator;
@property (nonatomic, retain) NSSet *chatToMessage;
@property (nonatomic, retain) PrivateKey *chatToPrivateKey;
@property (nonatomic, retain) PublicKey *chatToPublicKey;
@end

@interface PrivateChatSession (CoreDataGeneratedAccessors)

- (void)addChatToMessageObject:(PrivateChatEntry *)value;
- (void)removeChatToMessageObject:(PrivateChatEntry *)value;
- (void)addChatToMessage:(NSSet *)values;
- (void)removeChatToMessage:(NSSet *)values;

@end
