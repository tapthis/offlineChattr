//
//  TTPrivateChatDetailViewController.h
//  offlineChattr
//
//  Created by Patrik Boras on 02/05/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrivateChatSession.h"

@interface TTPrivateChatDetailViewController : UIViewController

@property(nonatomic,strong)PrivateChatSession *privateSession;
@property(nonatomic,strong)NSString *privateSessionID;

@end
