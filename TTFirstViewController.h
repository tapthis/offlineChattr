//
//  TTFirstViewController.h
//  offlineChattr
//
//  Created by Patrik Boras on 26/04/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSessionController.h"

@interface TTFirstViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,TTSessionControllerDelegate>

@property (nonatomic, strong) TTSessionController *sessionController;

@end
