//
//  PrivateKey.h
//  offlineChattr
//
//  Created by Patrik Boras on 02/05/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PrivateChatSession;

@interface PrivateKey : NSManagedObject

@property (nonatomic, retain) NSNumber * privateKey;
@property (nonatomic, retain) NSNumber * sharedSecret;
@property (nonatomic, retain) PrivateChatSession *privateKeyToChat;

@end
