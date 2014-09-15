//
//  TTPrivateOverviewTableViewCell.h
//  offlineChattr
//
//  Created by Patrik Boras on 01/05/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTPrivateOverviewTableViewCell : UITableViewCell

@property (nonatomic,strong)IBOutlet UILabel *opponent;
@property (nonatomic,strong)IBOutlet UIButton *actionButton;
@property (nonatomic,strong)IBOutlet UILabel *statusLabel;
@property (nonatomic,strong)IBOutlet UIView *statusBack;
@property (nonatomic,strong)NSString *sessionID;

@end
