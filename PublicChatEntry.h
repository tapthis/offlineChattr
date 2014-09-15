//
//  PublicChatEntry.h
//  offlineChattr
//
//  Created by Patrik Boras on 03/05/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PublicChatEntry : NSManagedObject

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * senderName;
@property (nonatomic, retain) NSNumber * timestamp;

@end
