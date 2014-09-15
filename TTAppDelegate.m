//
//  TTAppDelegate.m
//  offlineChattr
//
//  Created by Patrik Boras on 26/04/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import "TTAppDelegate.h"
#import "PrivateChatSession.h"

@implementation TTAppDelegate



@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    NSShadow *shadow = [[NSShadow alloc] init];
//    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
//    shadow.shadowOffset = CGSizeMake(0, 1);
//    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
//                                                           [UIColor darkGrayColor], NSForegroundColorAttributeName,
//                                                           shadow, NSShadowAttributeName,
//                                                           [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0], NSFontAttributeName, nil]];
    
    UITextField *lagFreeField = [[UITextField alloc] init];
    [self.window addSubview:lagFreeField];
    [lagFreeField becomeFirstResponder];
    [lagFreeField resignFirstResponder];
    [lagFreeField removeFromSuperview];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Core Data - save context

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    //    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"OSIANDER.sqlite"];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"tapthisOfflineChat.sqlite"];
    //added options
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setValue:[NSNumber numberWithBool:YES]
               forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setValue:[NSNumber numberWithBool:YES]
               forKey:NSInferMappingModelAutomaticallyOption];
    //added options
    
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error in persistentStoreCoordinator %@, %@", error, [error userInfo]);
        //        abort();
    }
    
    return __persistentStoreCoordinator;
}

- (void) deleteAllObjects: (NSString *) entityDescription  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
    	[self.managedObjectContext deleteObject:managedObject];
    	NSLog(@"%@ object deleted",entityDescription);
    }
    if (![self.managedObjectContext save:&error]) {
    	NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
}

-(BOOL)checkIfPublicMessageExists:(NSString*)message sender:(NSString*)sender timestamp:(NSNumber*)timestamp{
    
	NSManagedObjectContext* managedObjectContext = self.managedObjectContext;
    
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"PublicChatEntry" inManagedObjectContext: managedObjectContext];
	[fetchRequest setEntity:entity];
    
    // getting everything, except ebooks!
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((message LIKE[c] %@) AND (senderName LIKE[c] %@) AND (timestamp == %@))",message,sender,timestamp];
    [fetchRequest setPredicate:predicate];

	
	// Create the sort descriptors array.
    
    NSSortDescriptor *orderDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSArray *sortDescriptors;
    sortDescriptors = [[NSArray alloc] initWithObjects:orderDescriptor,  nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    if (mutableFetchResults == nil || [mutableFetchResults count] <= 0) {
        // Handle the error.
//        NSLog(@"fetchedresults error: %@",mutableFetchResults);
        
        return NO;
    }else{
        //        NSLog(@"fetchedresults %@",mutableFetchResults);
        
//        NSLog(@"fetched results: %@",mutableFetchResults);
        return YES;
    }

}

-(BOOL)checkIfPrivateMessageExists:(NSString*)message sender:(NSString*)sender timestamp:(NSNumber*)timestamp sessionID:(NSString*)sessionID{
    
	NSManagedObjectContext* managedObjectContext = self.managedObjectContext;
    NSMutableArray *mutableFetchResults ;
    if([message length] > 0){
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PrivateChatEntry" inManagedObjectContext: managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // getting everything, except ebooks!
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((messageToChat.sessionID LIKE[c] %@) AND (message LIKE[c] %@) AND (senderName LIKE[c] %@) AND (timestamp == %@))",sessionID, message,sender,timestamp];
        [fetchRequest setPredicate:predicate];
        NSLog(@"private msg predicate: (messageToChat.sessionID LIKE[c] %@) AND (message LIKE[c] %@) AND (senderName LIKE[c] %@) AND (timestamp == %@))",sessionID, message,sender,timestamp);
        
        // Create the sort descriptors array.
        
        NSSortDescriptor *orderDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
        NSArray *sortDescriptors;
        sortDescriptors = [[NSArray alloc] initWithObjects:orderDescriptor,  nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSError *error = nil;
        mutableFetchResults = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    }
    

    if (mutableFetchResults == nil || [mutableFetchResults count] <= 0) {
        // Handle the error.
                NSLog(@"fetchedresults private message error: %@",mutableFetchResults);
        
        return NO;
    }else{
                NSLog(@"fetchedresults private messagee %@",mutableFetchResults);
        
        //        NSLog(@"fetched results: %@",mutableFetchResults);
        return YES;
    }
    
}


-(BOOL)checkIfPrivateSessionExists:(NSString*)receiver sessionID:(NSString*)sessionID{
    
	NSManagedObjectContext* managedObjectContext = self.managedObjectContext;
    
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"PrivateChatSession" inManagedObjectContext: managedObjectContext];
	[fetchRequest setEntity:entity];
    

    // getting everything, except ebooks!
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((opponent LIKE[c] %@) AND (sessionID LIKE[c] %@))",receiver,sessionID];
    [fetchRequest setPredicate:predicate];
    
	
	// Create the sort descriptors array.
    
    NSSortDescriptor *orderDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sessionID" ascending:YES];
    NSArray *sortDescriptors;
    sortDescriptors = [[NSArray alloc] initWithObjects:orderDescriptor,  nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    if (mutableFetchResults == nil || [mutableFetchResults count] <= 0) {
        // Handle the error.
//                NSLog(@"fetchedresults error: %@",mutableFetchResults);
        
        return NO;
    }else{
//                NSLog(@"fetchedresults %@",mutableFetchResults);
        
        //        NSLog(@"fetched results: %@",mutableFetchResults);
        return YES;
    }
    
}

-(NSMutableArray*)getPrivateChatSession:(NSString*)sessionID{
    
	NSManagedObjectContext* managedObjectContext = self.managedObjectContext;
    
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"PrivateChatSession" inManagedObjectContext: managedObjectContext];
	[fetchRequest setEntity:entity];
    
    
    // getting everything, except ebooks!
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((sessionID LIKE[c] %@) AND (chatToPrivateKey.sharedSecret > 0))",sessionID];
    [fetchRequest setPredicate:predicate];
    
	
	// Create the sort descriptors array.
    
    NSSortDescriptor *orderDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sessionID" ascending:YES];
    NSArray *sortDescriptors;
    sortDescriptors = [[NSArray alloc] initWithObjects:orderDescriptor,  nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
//    NSLog(@"1337: %@",mutableFetchResults);
    return mutableFetchResults;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}





@end
