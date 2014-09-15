//
//  PrivateChatEntry.h
//  offlineChattr
//
//  Created by Patrik Boras on 04/05/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PrivateChatSession;

@interface PrivateChatEntry : NSManagedObject

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * senderName;
@property (nonatomic, retain) NSNumber * seen;
@property (nonatomic, retain) PrivateChatSession *messageToChat;

@end
