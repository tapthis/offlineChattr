//
//  TTSessionController.m
//  offlineChattr
//
//  Created by Patrik Boras on 26/04/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import "TTSessionController.h"
#import "TTAppDelegate.h"
#import "PublicChatEntry.h"
#import "PrivateChatSession.h"
#import "PrivateChatEntry.h"
#import "PublicKey.h"
#import "PrivateKey.h"


@interface TTSessionController (){ // Class extension
    TTAppDelegate *appDelegate;
    BOOL importing;
    BOOL newStuffThere;
}
@property (nonatomic, strong) MCPeerID *peerID;
//@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *serviceAdvertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *serviceBrowser;

// Connected peers are stored in the MCSession
// Manually track connecting and disconnected peers
@property (nonatomic, strong) NSMutableOrderedSet *connectingPeersOrderedSet;
@property (nonatomic, strong) NSMutableOrderedSet *disconnectedPeersOrderedSet;
@end

@implementation TTSessionController

static NSString * const TTSessionServiceType = @"offlinechattr";

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _peerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
        
        _connectingPeersOrderedSet = [[NSMutableOrderedSet alloc] init];
        _disconnectedPeersOrderedSet = [[NSMutableOrderedSet alloc] init];
        
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        
        // Register for notifications
        [defaultCenter addObserver:self
                          selector:@selector(startServices)
                              name:UIApplicationWillEnterForegroundNotification
                            object:nil];
        
        [defaultCenter addObserver:self
                          selector:@selector(stopServices)
                              name:UIApplicationDidEnterBackgroundNotification
                            object:nil];
        
        [self startServices];
        
        _displayName = self.session.myPeerID.displayName;
        appDelegate = (TTAppDelegate *)[[UIApplication sharedApplication] delegate];
        
//        [self performSelector:@selector(sendLocalMessages) withObject:nil afterDelay:5];

    }
    
    return self;
}

#pragma mark - Memory management

- (void)dealloc
{
    // Unregister for notifications on deallocation.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Nil out delegates
    _session.delegate = nil;
    _serviceAdvertiser.delegate = nil;
    _serviceBrowser.delegate = nil;
}

#pragma mark - Override property accessors

- (NSArray *)connectedPeers
{
    return self.session.connectedPeers;
}

- (NSArray *)connectingPeers
{
    return [self.connectingPeersOrderedSet array];
}

- (NSArray *)disconnectedPeers
{
    return [self.disconnectedPeersOrderedSet array];
}

#pragma mark - Private methods

- (void)setupSession
{
    // Create the session that peers will be invited/join into.
    _session = [[MCSession alloc] initWithPeer:self.peerID];
    self.session.delegate = self;
    
    // Create the service advertiser
    _serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID
                                                           discoveryInfo:nil
                                                             serviceType:TTSessionServiceType];
    self.serviceAdvertiser.delegate = self;
    
    // Create the service browser
    _serviceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID
                                                       serviceType:TTSessionServiceType];
    self.serviceBrowser.delegate = self;
}

- (void)teardownSession
{
    [self.session disconnect];
    [self.connectingPeersOrderedSet removeAllObjects];
    [self.disconnectedPeersOrderedSet removeAllObjects];
}

- (void)startServices
{
    [self setupSession];
    [self.serviceAdvertiser startAdvertisingPeer];
    [self.serviceBrowser startBrowsingForPeers];
}

- (void)stopServices
{
    [self.serviceBrowser stopBrowsingForPeers];
    [self.serviceAdvertiser stopAdvertisingPeer];
    [self teardownSession];
}

- (void)updateDelegate
{
    [self.delegate sessionDidChangeState];
}

- (NSString *)stringForPeerConnectionState:(MCSessionState)state
{
    switch (state) {
        case MCSessionStateConnected:
            return @"Connected";
            
        case MCSessionStateConnecting:
            return @"Connecting";
            
        case MCSessionStateNotConnected:
            return @"Not Connected";
    }
}

-(void)sendLocalMessages:(BOOL)newStuff{
    if(newStuff){
        [self sendPublicMessages];
        [self sendPrivateSessions];
        [self sendPrivateMessages];
        importing = NO;
    }

    
    //    [_tvChat setText:[_tvChat.text stringByAppendingString:[NSString stringWithFormat:@"I wrote:\n%@\n\n", _txtMessage.text]]];
    //    [_txtMessage setText:@""];
    //    [_txtMessage resignFirstResponder];
//    [self performSelector:@selector(sendLocalMessages) withObject:nil afterDelay:5];
}

-(void)sendPrivateSessions{
    NSManagedObjectContext* managedObjectContext = appDelegate.managedObjectContext;
    // Retrieve the entity from the local store -- much like a table in a database
    
//    dispatch_queue_t backgroundQueue = dispatch_queue_create("de.tapthis.myqueue", 0);
    
//    dispatch_async(backgroundQueue, ^{
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PrivateChatSession" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
//        request.resultType = NSDictionaryResultType;
        [request setEntity:entity];
        
        // Set the predicate -- much like a WHERE statement in a SQL database
        //    NSString *pred = [NSString stringWithFormat:@"(branchID LIKE '%@')",branchID];
        //    NSLog(@"predicate is: %@",pred);
        //    NSPredicate *predicate = [NSPredicate predicateWithFormat:pred];
        //    [request setPredicate:predicate];
        
        // Set the sorting -- mandatory, even if you're fetching a single record/object
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sessionID" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
        
        // Request the data -- NOTE, this assumes only one match, that
        // yourIdentifyingQualifier is unique. It just grabs the first object in the array.
        NSError *error3 = nil;
        NSMutableArray *entitiInformation = [[NSMutableArray alloc]initWithArray:[managedObjectContext executeFetchRequest:request error:&error3]];
        NSError *error = nil;
    
    
        
        NSMutableArray *privateSessions = [[NSMutableArray alloc]init];
    
        if([entitiInformation count] > 0){
            for(PrivateChatSession *item in entitiInformation){
//                NSLog(@"item is: %@",item);
                int generator;
                int modulo;
                int initiatorPublicKey;
                int receiverPublicKey;
                PublicKey *pk = (PublicKey *)item.chatToPublicKey;
                if(![item.opponent isEqualToString:[appDelegate localName]]){
                    //                NSLog(@"publickeys: %@",pk);
                    generator = [pk.generator integerValue];
                    modulo = [pk.modulo integerValue];
                    initiatorPublicKey = [pk.publicKey integerValue];
                }else{
                    receiverPublicKey = [pk.receiverPublicKey integerValue];
                }
                
                NSMutableDictionary *foo = [[NSMutableDictionary  alloc]initWithObjectsAndKeys:@"private",@"type",item.opponent,@"receiver",item.initiator,@"initiator",item.timestamp, @"timestamp",item.sessionID,@"sessionID",[NSString stringWithFormat:@"%d",generator],@"gen",[NSString stringWithFormat:@"%d",modulo],@"mod",[NSString stringWithFormat:@"%@",[NSNumber numberWithInt:initiatorPublicKey]],@"publicKey",[NSString stringWithFormat:@"%d",receiverPublicKey],@"aPublic",nil];
                
                
                //            NSMutableDictionary *foo = [[NSMutableDictionary  alloc]initWithObjectsAndKeys:@"private",@"type",item.opponent,@"receiver",item.sessionID,@"sessionID",generator,@"gen",modulo,@"mod",initiatorPublicKey,@"publicKey",receiverPublicKey,@"aPublic", nil];
                //            [item setObject:@"private" forKey:@"type"];
                
                //            [item setValue:@"private" forKey:@"type"];
                //            [item addObject:[[NSMutableArray alloc]initWithObjects:@"private",@"type", nil]];
                [privateSessions addObject:foo];
            }
            
            //        NSLog(@"private sessions: %@", privateSessions);
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:privateSessions options:NSJSONWritingPrettyPrinted error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            NSData *dataToSend = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *allPeers = self.connectedPeers;
            
//        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error2;
            [self.session sendData:dataToSend
                           toPeers:allPeers
                          withMode:MCSessionSendDataReliable
                             error:&error2];
            
            if (error2) {
                NSLog(@"%@", [error2 localizedDescription]);
            }
//                    });

        }
        
//    });
}

-(void)sendPublicMessages{
    NSManagedObjectContext* managedObjectContext = appDelegate.managedObjectContext;
    // Retrieve the entity from the local store -- much like a table in a database
    
//    dispatch_queue_t backgroundQueue = dispatch_queue_create("de.tapthis.myqueue", 0);
    
//    dispatch_async(backgroundQueue, ^{
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PublicChatEntry" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
//        request.resultType = NSDictionaryResultType;
        [request setEntity:entity];
        
        // Set the predicate -- much like a WHERE statement in a SQL database
        //    NSString *pred = [NSString stringWithFormat:@"(branchID LIKE '%@')",branchID];
        //    NSLog(@"predicate is: %@",pred);
        //    NSPredicate *predicate = [NSPredicate predicateWithFormat:pred];
        //    [request setPredicate:predicate];
        
        // Set the sorting -- mandatory, even if you're fetching a single record/object
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
        
        // Request the data -- NOTE, this assumes only one match, that
        // yourIdentifyingQualifier is unique. It just grabs the first object in the array.
        NSError *error3 = nil;
        NSMutableArray *entitiInformation = [[NSMutableArray alloc]initWithArray:[managedObjectContext executeFetchRequest:request error:&error3]];
    
        NSMutableArray *publicSessions = [[NSMutableArray alloc]init];
    
    if([entitiInformation count] > 0){
        for(PublicChatEntry *pe in entitiInformation){
            if([pe.message length] > 0){
                NSMutableDictionary *foo = [[NSMutableDictionary  alloc]initWithObjectsAndKeys:@"public",@"type",pe.senderName,@"senderName",pe.message,@"message",pe.timestamp,@"timestamp",nil];
                
                [publicSessions addObject:foo];
                
            }
        }
        //    NSLog(@"public sessions: %@",publicSessions);
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:publicSessions options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSData *dataToSend = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *allPeers = self.connectedPeers;
        
//        dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error2;
        [self.session sendData:dataToSend
                       toPeers:allPeers
                      withMode:MCSessionSendDataReliable
                         error:&error2];
        
        if (error2) {
            NSLog(@"%@", [error2 localizedDescription]);
        }else{
            newStuffThere = NO;
        }
//            });

    }
//        });
    
}

-(void)sendPrivateMessages{
    NSManagedObjectContext* managedObjectContext = appDelegate.managedObjectContext;
    // Retrieve the entity from the local store -- much like a table in a database
    
        dispatch_queue_t backgroundQueue = dispatch_queue_create("de.tapthis.myqueue", 0);
    
        dispatch_async(backgroundQueue, ^{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PrivateChatEntry" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //        request.resultType = NSDictionaryResultType;
    [request setEntity:entity];
    
    // Set the predicate -- much like a WHERE statement in a SQL database
    //    NSString *pred = [NSString stringWithFormat:@"(branchID LIKE '%@')",branchID];
    //    NSLog(@"predicate is: %@",pred);
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:pred];
    //    [request setPredicate:predicate];
    
    // Set the sorting -- mandatory, even if you're fetching a single record/object
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    // Request the data -- NOTE, this assumes only one match, that
    // yourIdentifyingQualifier is unique. It just grabs the first object in the array.
    NSError *error3 = nil;
    NSMutableArray *entitiInformation = [[NSMutableArray alloc]initWithArray:[managedObjectContext executeFetchRequest:request error:&error3]];
    
    NSMutableArray *publicSessions = [[NSMutableArray alloc]init];
    
    if([entitiInformation count] > 0){
        for(PrivateChatEntry *pe in entitiInformation){
            PrivateChatSession *ps = pe.messageToChat;
            NSMutableDictionary *foo = [[NSMutableDictionary  alloc]initWithObjectsAndKeys:@"privateMsg",@"type",ps.sessionID,@"sessionID", pe.senderName,@"senderName",pe.message,@"message",pe.timestamp,@"timestamp",nil];
            //            [item setObject:@"private" forKey:@"type"];
            
            //            [item setValue:@"private" forKey:@"type"];
            //            [item addObject:[[NSMutableArray alloc]initWithObjects:@"private",@"type", nil]];
            if([pe.message length] > 0){
                [publicSessions addObject:foo];
            }
            
        }
        //    NSLog(@"public sessions: %@",publicSessions);
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:publicSessions options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSData *dataToSend = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *allPeers = self.connectedPeers;
        
//        dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error2;
        [self.session sendData:dataToSend
                       toPeers:allPeers
                      withMode:MCSessionSendDataReliable
                         error:&error2];
        
        if (error2) {
            NSLog(@"%@", [error2 localizedDescription]);
        }else{
            newStuffThere = NO;
        }
//                });

    }
            });

}

#pragma mark - MCSessionDelegate protocol conformance

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"Peer [%@] changed state to %@", peerID.displayName, [self stringForPeerConnectionState:state]);
    
    switch (state)
    {
        case MCSessionStateConnecting:
        {
            [self.connectingPeersOrderedSet addObject:peerID];
            [self.disconnectedPeersOrderedSet removeObject:peerID];
            break;
        }
            
        case MCSessionStateConnected:
        {
            [self.connectingPeersOrderedSet removeObject:peerID];
            [self.disconnectedPeersOrderedSet removeObject:peerID];
            break;
        }
            
        case MCSessionStateNotConnected:
        {
            [self.connectingPeersOrderedSet removeObject:peerID];
            [self.disconnectedPeersOrderedSet addObject:peerID];
            break;
        }
    }
    
    [self updateDelegate];
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    
    // Decode the incoming data to a UTF8 encoded string

    

    dispatch_queue_t backgroundQueue = dispatch_queue_create("de.tapthis.myqueue", 0);
    
    
//    dispatch_async(backgroundQueue, ^{
    
        NSManagedObjectContext* managedObjectContext = [appDelegate managedObjectContext];

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"receiving : %@",json);
        if([json count] > 0){
            for(NSDictionary *newMessage in json){
                NSString *theType = [NSString stringWithFormat:@"%@",[newMessage valueForKey:@"type"]];
                NSLog(@"received: %@",theType);
                if([theType isEqualToString:@"public"]){
                    
                    NSString *msg = [newMessage valueForKey:@"message"];
                    NSString *snd = [newMessage valueForKey:@"senderName"];
                    NSNumber *tmstp = [NSNumber numberWithInt:[[newMessage valueForKey:@"timestamp"]integerValue]];
                    importing = YES;
                    if(![appDelegate checkIfPublicMessageExists:msg sender:snd timestamp:tmstp]){
                        NSLog(@"creating public message after receiving..");
                        PublicChatEntry *newpublicChatEntry = (PublicChatEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"PublicChatEntry" inManagedObjectContext:managedObjectContext];
                        newpublicChatEntry.message = msg;
                        newpublicChatEntry.senderName = snd;
                        newpublicChatEntry.timestamp = tmstp;
                        newStuffThere = YES;
                    }
                }else if([theType isEqualToString:@"privateMsg"]){
                    NSLog(@"private message: %@",newMessage);
                    NSString *msg = [newMessage valueForKey:@"message"];
                    NSString *snd = [newMessage valueForKey:@"senderName"];
                    NSString *sessID = [newMessage valueForKey:@"sessionID"];
                    NSNumber *tmstp = [NSNumber numberWithInt:[[newMessage valueForKey:@"timestamp"]integerValue]];
                    importing = YES;
                    if(![appDelegate checkIfPrivateMessageExists:msg sender:snd timestamp:tmstp sessionID:sessID]){
                        NSLog(@"creating private message after receiving..");
                        PrivateChatEntry *newprivateChatEntry = (PrivateChatEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"PrivateChatEntry" inManagedObjectContext:managedObjectContext];
                        newprivateChatEntry.message = msg;
                        newprivateChatEntry.senderName = snd;
                        newprivateChatEntry.timestamp = tmstp;
                        
                        PrivateChatSession *ps = (PrivateChatSession*)[[appDelegate getPrivateChatSession:sessID]firstObject];
                        NSLog(@"found matching private session: %@",ps);
                        newprivateChatEntry.messageToChat = ps;
                        
                        newStuffThere = YES;
                    }
                }else if ([theType isEqualToString:@"private"]){
                    
                    
                    NSString *opponent = [newMessage valueForKey:@"receiver"];
                    NSString *initiator = [newMessage valueForKey:@"initiator"];
                    NSString *generator = [newMessage valueForKey:@"gen"];
                    NSString *mod = [newMessage valueForKey:@"mod"];
                    NSString *publicKey = [newMessage valueForKey:@"publicKey"];
                    NSString *sessionID = [newMessage valueForKey:@"sessionID"];
                    NSString *aPublic = [newMessage valueForKey:@"aPublic"];
                    NSNumber *tmstp = [NSNumber numberWithInt:[[newMessage valueForKey:@"timestamp"]integerValue]];
                    
                    
                    NSLog(@"checking if session exists- opponent: %@ sessioID: %@",opponent,sessionID);
                    
                    importing = YES;
                    if(![appDelegate checkIfPrivateSessionExists:opponent sessionID:sessionID]){
                        NSLog(@"creating private session after receiving..");
                        @try {
                            PrivateChatSession *newprivateChatSesison = (PrivateChatSession *)[NSEntityDescription insertNewObjectForEntityForName:@"PrivateChatSession" inManagedObjectContext:managedObjectContext];
                            newprivateChatSesison.sessionID = sessionID;
                            newprivateChatSesison.opponent = opponent;
                            newprivateChatSesison.initiator = initiator;
                            newprivateChatSesison.timestamp = tmstp;
                            
                            PublicKey *newPublicKey = (PublicKey *)[NSEntityDescription insertNewObjectForEntityForName:@"PublicKey" inManagedObjectContext:managedObjectContext];
                            newPublicKey.generator = [NSNumber numberWithInt:[generator integerValue]];
                            newPublicKey.modulo = [NSNumber numberWithInt:[mod integerValue]];
                            newPublicKey.publicKey = [NSNumber numberWithInt:[publicKey integerValue]];
                            
                            if([opponent isEqualToString:[appDelegate localName]] && generator != nil && mod != nil && publicKey != nil){
                                NSLog(@"new session request");
                                int receiverSecretKeyValue = [self generateRandomNumber] % MAX_RANDOM_NUMBER;
                                int receiverPublicKeyValue = [self powermod:[newPublicKey.generator integerValue] power:receiverSecretKeyValue modulus:[newPublicKey.modulo integerValue]];
                                
                                newPublicKey.receiverPublicKey = [NSNumber numberWithInt:receiverPublicKeyValue];
                                
                                newprivateChatSesison.chatToPublicKey = newPublicKey;
                                
                                PrivateKey *newPrivateKey = (PrivateKey *)[NSEntityDescription insertNewObjectForEntityForName:@"PrivateKey" inManagedObjectContext:managedObjectContext];
                                newPrivateKey.privateKey = [NSNumber numberWithInt:receiverSecretKeyValue];
                                
                                int sharedSecretKeyValue = [self powermod:[publicKey integerValue] power:receiverSecretKeyValue modulus:[mod integerValue]];
                                newPrivateKey.sharedSecret = [NSNumber numberWithInt:sharedSecretKeyValue];
                                
                                newprivateChatSesison.chatToPrivateKey = newPrivateKey;
                                NSLog(@"gen: %@, mod: %@, pub: %@, receiverPublic: %@, receiverSecret: %@, sk1: %@",newPublicKey.generator,newPublicKey.modulo,newPublicKey.publicKey,newPublicKey.receiverPublicKey, newPrivateKey.privateKey, newPrivateKey.sharedSecret);
                                
                            }
                            
                            newStuffThere = YES;
                        }
                        @catch (NSException *exception) {
                            NSLog(@"error in creating private session after receiving..");
                        }
                        
                        
                    }else{
                        if([initiator isEqualToString:[appDelegate localName]] && generator != nil && mod != nil && publicKey != nil){
                            NSLog(@"session confirmation");
                            if([aPublic length] > 0){
                                NSMutableArray *fooBar = [appDelegate getPrivateChatSession:sessionID];
                                if( [fooBar count] == 1){
                                    @try {
                                        PrivateChatSession *ps = (PrivateChatSession*)[fooBar firstObject];
                                        
                                        PublicKey *pubk = (PublicKey*)ps.chatToPublicKey;
                                        pubk.receiverPublicKey = [NSNumber numberWithInt:[aPublic integerValue]];
                                        
                                        PrivateKey *privk = (PrivateKey*)ps.chatToPrivateKey;
                                        NSLog(@"found private key: %@",privk);
                                        
                                        int sharedSecretKeyValue = [self powermod:[pubk.receiverPublicKey integerValue] power:[privk.privateKey integerValue] modulus:[pubk.modulo integerValue]];
                                        
                                        //                                        [self powermod:[aPublic integerValue] power:[privk.privateKey integerValue] modulus:[mod integerValue]];
                                        
                                        privk.sharedSecret = [NSNumber numberWithInt:sharedSecretKeyValue];
                                        
                                        NSLog(@"XX gen: %@, mod: %@, pub: %@, receiverPublic: %@, receiverSecret: %@, sk1: %@",pubk.generator,pubk.modulo,pubk.publicKey,pubk.receiverPublicKey, privk.privateKey, privk.sharedSecret);
                                        
                                        newStuffThere = YES;
                                    }
                                    @catch (NSException *exception) {
                                        NSLog(@"cant update local private session...");
                                    }
                                    
                                };
                                
                                
                                
                            }
                            
                            
                            
                        }
                    }
                }
                
            }
        
        }
        
    
    
    
        dispatch_async(dispatch_get_main_queue(), ^{

            NSError *error = nil;
            if (![managedObjectContext save:&error]) {
                NSLog(@"error saving new pce item in managedObjectContext! %@",[error localizedDescription]);
            }else{
                if(newStuffThere){
                    importing = NO;
//                    [self sendLocalMessages:newStuffThere];
                    //                    [self performSelector:@selector(importDone) withObject:nil afterDelay:.1];
                }
                
            }


        });
//    });

    NSLog(@"didReceiveData from %@",peerID.displayName);
}

-(void)importDone{
    [self sendLocalMessages:YES];

}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"didStartReceivingResourceWithName [%@] from %@ with progress [%@]", resourceName, peerID.displayName, progress);
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"didFinishReceivingResourceWithName [%@] from %@", resourceName, peerID.displayName);
    
    // If error is not nil something went wrong
    if (error)
    {
        NSLog(@"Error [%@] receiving resource from %@ ", [error localizedDescription], peerID.displayName);
    }
    else
    {
        // No error so this is a completed transfer.  The resources is located in a temporary location and should be copied to a permenant location immediately.
        // Write to documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *copyPath = [NSString stringWithFormat:@"%@/%@", [paths firstObject], resourceName];
        if (![[NSFileManager defaultManager] copyItemAtPath:[localURL path] toPath:copyPath error:nil])
        {
            NSLog(@"Error copying resource to documents directory");
        }
        else
        {
            // Get a URL for the path we just copied the resource to
            NSURL *url = [NSURL fileURLWithPath:copyPath];
            NSLog(@"url = %@", url);
        }
    }
}

// Streaming API not utilized in this sample code
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"didReceiveStream %@ from %@", streamName, peerID.displayName);
}

#pragma mark - MCNearbyServiceBrowserDelegate protocol conformance

// Found a nearby advertising peer
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSString *remotePeerName = peerID.displayName;
    
    NSLog(@"Browser found %@", remotePeerName);
    
    MCPeerID *myPeerID = self.session.myPeerID;
    
    BOOL shouldInvite = ([myPeerID.displayName compare:remotePeerName] == NSOrderedDescending);
    
    if (shouldInvite)
    {
        NSLog(@"Inviting %@", remotePeerName);
        [browser invitePeer:peerID toSession:self.session withContext:nil timeout:30.0];
    }
    else
    {
        NSLog(@"Not inviting %@", remotePeerName);
    }
    
    [self updateDelegate];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"lostPeer %@", peerID.displayName);
    
    [self.connectingPeersOrderedSet removeObject:peerID];
    [self.disconnectedPeersOrderedSet addObject:peerID];
    
    [self updateDelegate];
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"didNotStartBrowsingForPeers: %@", error);
}

#pragma mark - MCNearbyServiceAdvertiserDelegate protocol conformance

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    NSLog(@"didReceiveInvitationFromPeer %@", peerID.displayName);
    
    invitationHandler(YES, self.session);
    
    [self.connectingPeersOrderedSet addObject:peerID];
    [self.disconnectedPeersOrderedSet removeObject:peerID];
    
    [self updateDelegate];
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"didNotStartAdvertisingForPeers: %@", error);
}

#pragma mark - dh
-(void)createPrivatChatsession:(NSString*)opponent{
    int sessionInt = [self generateRandomNumber] % MAX_RANDOM_NUMBER;
    NSString *sessionID = [NSString stringWithFormat:@"TT%@",[NSNumber numberWithInt:sessionInt]];
    
    int generatorValue = [self generatePrimeNumber];
    int modulusValue = [self generatePrimeNumber];
    
    if (generatorValue > modulusValue)
    {
        int swap = generatorValue;
        generatorValue = modulusValue;
        modulusValue = swap;
    }
    
    //generate keys
    int senderSecretKeyValue = [self generateRandomNumber] % MAX_RANDOM_NUMBER;
    int senderPublicKeyValue = [self powermod:generatorValue power:senderSecretKeyValue modulus:modulusValue];
    
//    int receiverPublicKeyValue;
    
//    int sharedSecretKeyValue = [self powermod:receiverPublicKeyValue power:senderSecretKeyValue modulus:modulusValue];
    
    
//    dispatch_queue_t backgroundQueue = dispatch_queue_create("de.tapthis.myqueue", 0);
    
//    dispatch_async(backgroundQueue, ^{
    
        NSManagedObjectContext* managedObjectContext = [appDelegate managedObjectContext];
        
        if(![appDelegate checkIfPrivateSessionExists:opponent sessionID:sessionID]){
            
            PrivateChatSession *newprivateChatSession = (PrivateChatSession *)[NSEntityDescription insertNewObjectForEntityForName:@"PrivateChatSession" inManagedObjectContext:managedObjectContext];
            newprivateChatSession.opponent = opponent;
            newprivateChatSession.sessionID = sessionID;
            newprivateChatSession.timestamp = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
            newprivateChatSession.initiator = [appDelegate localName];
            
            PublicKey *newPublicKey = (PublicKey *)[NSEntityDescription insertNewObjectForEntityForName:@"PublicKey" inManagedObjectContext:managedObjectContext];
            newPublicKey.generator = [NSNumber numberWithInt:generatorValue];
            newPublicKey.modulo = [NSNumber numberWithInt:modulusValue];
            newPublicKey.publicKey = [NSNumber numberWithInt:senderPublicKeyValue];
            
            
            newprivateChatSession.chatToPublicKey = newPublicKey;
            
            PrivateKey *newPrivateKey = (PrivateKey *)[NSEntityDescription insertNewObjectForEntityForName:@"PrivateKey" inManagedObjectContext:managedObjectContext];
            newPrivateKey.privateKey = [NSNumber numberWithInt:senderSecretKeyValue];
            
            newprivateChatSession.chatToPrivateKey = newPrivateKey;
            
            
            
        }
        
//        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            if (![managedObjectContext save:&error]) {
                NSLog(@"error saving new privchat item in managedObjectContext! %@",[error localizedDescription]);
            }
            [self sendLocalMessages:YES];
//        });
//
//        
//    });
}

- (int) powermod:(int)base power:(int)power modulus:(int)modulus {
	long long result = 1;
	for (int i = 31; i >= 0; i--) {
		result = (result*result) % modulus;
		if ((power & (1 << i)) != 0) {
			result = (result*base) % modulus;
		}
	}
	return (int)result;
}

- (int) generateRandomNumber {
	return (arc4random() % MAX_RANDOM_NUMBER);
}

- (int) numTrailingZeros:(int)n {
	int tmp = n;
	int result = 0;
	for(int i=0; i<32; i++){
		if((tmp & 1) == 0){
			result++;
			tmp = tmp >> 1;
		} else {
			break;
		}
	}
	return result;
}

- (int) generatePrimeNumber {
	
	int result = [self generateRandomNumber] % MAX_PRIME_NUMBER;
	
	//ensure it is an odd number
	if ((result & 1) == 0) {
		result += 1;
	}
	
	// keep incrementally checking odd numbers until we find
	// an integer of high probablity of primality
	while (true) {
		if([self millerRabinPrimalityTest:result trials:5] == YES){
			//printf("\n%d - PRIME", result);
			return result;
		}
		else {
			//printf("\n%d - COMPOSITE", result);
			result += 2;
		}
	}
}

- (BOOL) millerRabinPass:(int)a modulus:(int)n {
	int d = n - 1;
	int s = [self numTrailingZeros:d];
	
	d >>= s;
	int aPow = [self powermod:a power:d modulus:n];
	if (aPow == 1) {
		return YES;
	}
	for (int i = 0; i < s - 1; i++) {
		if (aPow == n - 1) {
			return YES;
		}
		aPow = [self powermod:aPow power:2 modulus:n];
	}
	if (aPow == n - 1) {
		return YES;
	}
	return NO;
}

// 5 is a reasonably high amount of trials even for large primes
- (BOOL) millerRabinPrimalityTest:(int)n trials:(int)trials {
	/*
     // check the obvious cases first
     if (n <= 1) {
     return NO;
     }
     else if (n == 2) {
     return YES;
     }
     
     int a = 0;
     for (int i=0; i<trials; i++)
     {
     a = (arc4random() % (n-3)) + 2; // gets random value in [2..n-1]
     
     if ([self millerRabinPass:a modulus:n] == NO)
     {
     // n composite
     return NO;
     }
     }
     
     // n is probably prime
     return YES;
	 */
	
	if (n <= 1) {
		return NO;
	}
	else if (n == 2) {
		return YES;
	}
	else if ([self millerRabinPass:2 modulus:n] && (n <= 7 || [self millerRabinPass:7 modulus:n]) && (n <= 61 || [self millerRabinPass:61 modulus:n])) {
		return YES;
	}
	else {
		return NO;
	}
}



@end
