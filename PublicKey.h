//
//  PublicKey.h
//  offlineChattr
//
//  Created by Patrik Boras on 02/05/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PrivateChatSession;

@interface PublicKey : NSManagedObject

@property (nonatomic, retain) NSNumber * generator;
@property (nonatomic, retain) NSNumber * modulo;
@property (nonatomic, retain) NSNumber * publicKey;
@property (nonatomic, retain) NSNumber * receiverPublicKey;
@property (nonatomic, retain) PrivateChatSession *publicKeyToChat;

@end
