//
//  TTAppDelegate.h
//  offlineChattr
//
//  Created by Patrik Boras on 26/04/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TTSessionController.h"


@interface TTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@property (nonatomic,strong) NSString *localName;

-(BOOL)checkIfPublicMessageExists:(NSString*)message sender:(NSString*)sender timestamp:(NSNumber*)timestamp;
-(BOOL)checkIfPrivateMessageExists:(NSString*)message sender:(NSString*)sender timestamp:(NSNumber*)timestamp sessionID:(NSString*)sessionID;
-(BOOL)checkIfPrivateSessionExists:(NSString*)receiver sessionID:(NSString*)sessionID;
-(NSMutableArray*)getPrivateChatSession:(NSString*)sessionID;

@end
