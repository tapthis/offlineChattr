//
//  TTChatTableViewCell.h
//  offlineChattr
//
//  Created by Patrik Boras on 26/04/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTChatTableViewCell : UITableViewCell

@property (nonatomic,strong)IBOutlet UILabel *message;
@property (nonatomic,strong)IBOutlet UIView *messageType;
@property (nonatomic,strong)IBOutlet UILabel *sender;
//@property (nonatomic,strong)IBOutlet NSString *date;

@end
