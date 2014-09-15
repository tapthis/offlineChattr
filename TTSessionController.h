//
//  TTSessionController.h
//  offlineChattr
//
//  Created by Patrik Boras on 26/04/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#define MAX_RANDOM_NUMBER 2147483648
#define MAX_PRIME_NUMBER   2147483648


@protocol TTSessionControllerDelegate;

@interface TTSessionController : NSObject <MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate>

@property (nonatomic, weak) id<TTSessionControllerDelegate> delegate;

@property (nonatomic, strong) MCSession *session;
@property (nonatomic, readonly) NSArray *connectedPeers;
@property (nonatomic, readonly) NSArray *connectingPeers;
@property (nonatomic, readonly) NSArray *disconnectedPeers;
@property (nonatomic, readonly) NSString *displayName;

// Helper method for human readable printing of MCSessionState. This state is per peer.
- (NSString *)stringForPeerConnectionState:(MCSessionState)state;
-(void)sendLocalMessages:(BOOL)newStuff;
-(void)createPrivatChatsession:(NSString*)opponent;

@end

// Delegate methods for SessionController
@protocol TTSessionControllerDelegate <NSObject>

// Session changed state - connecting, connected and disconnected peers changed
- (void)sessionDidChangeState;


@end
