//
//  TTPrivateChatDetailViewController.m
//  offlineChattr
//
//  Created by Patrik Boras on 02/05/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import "TTPrivateChatDetailViewController.h"
#import "TTAppDelegate.h"
#import "TTChatTableViewCell.h"
#import "PrivateChatSession.h"
#import "PrivateKey.h"
#import "PublicKey.h"
#import "PrivateChatEntry.h"
#import "NSData+AES.h"
#import "NSData+Base64.h"
#import "NSString+AES.h"
#import "TTFirstViewController.h"


@interface TTPrivateChatDetailViewController ()<UITextFieldDelegate,UITextViewDelegate, NSFetchedResultsControllerDelegate,UIGestureRecognizerDelegate>{
    TTAppDelegate *appDelegate;
    NSFetchedResultsController *fetchedResultsController;

    __weak IBOutlet NSLayoutConstraint *footerBottomConstraint;

    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UITextView *_messageField;
}
@property (nonatomic,retain) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet UIButton *sendButtonTapped;

@end

@implementation TTPrivateChatDetailViewController

@synthesize fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    appDelegate = (TTAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.title = _privateSession.opponent;
    
    [_messageField becomeFirstResponder];
    _messageField.contentInset = UIEdgeInsetsMake(-6, -4, -4, 0);
    _messageField.alpha = 0.8;
    _messageField.textColor = [UIColor blackColor];
    
    [self registerForKeyboardNotifications];
    UIGestureRecognizer *_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    _tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:_tapRecognizer];

    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    NSInteger numberOfRows = [_tableView numberOfRowsInSection:0];
    if (numberOfRows) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor clearColor]];
    _tableView.tableFooterView = [[UIView alloc] init];

}

#pragma mark - textfield delegates

-(void)textViewDidBeginEditing:(UITextView *)textView{
    [UIView animateWithDuration:0.25 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        _messageField.alpha = 1;
    }
     completion:^(BOOL finished){
                         //do something on finish
                         //                                    [_collectionView scrollCollectionToCenter];
                         
     }];
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if([textView.text isEqualToString:@""]){
        [UIView animateWithDuration:0.25 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            _messageField.alpha = 0.8;

        }
                         completion:^(BOOL finished){
                             //do something on finish
                             //                                    [_collectionView scrollCollectionToCenter];
                             
                         }];

    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"did begin edditing");
    
}

-(IBAction)textFieldDidChange:(id)sender{
    NSLog(@"did change");
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField.returnKeyType==UIReturnKeyNext){
        [textField resignFirstResponder];
        return YES;
    }else if(textField.returnKeyType==UIReturnKeySend){
        [textField resignFirstResponder];
        return YES;
    }else if(textField.returnKeyType==UIReturnKeyDone){
        [textField resignFirstResponder];
        return YES;
    }else{
        return YES;
    }
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    //    [self didTapAnywhere:nil];
    return YES;
}

-(void)didTapAnywhere:(UIGestureRecognizer *)gestureRecognizer{
    if(![gestureRecognizer.view isKindOfClass:[UIBarButtonItem class]] && gestureRecognizer.view.tag != 98){
        [_messageField resignFirstResponder];
    }
    
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"keyboard shown");
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self scrollTableViewToBottom];
    
    [UIView animateWithDuration:0.1 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        footerBottomConstraint.constant = (kbSize.height-self.tabBarController.tabBar.frame.size.height);
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished){
        //do something on finish
        
    }];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView animateWithDuration:0.1 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        footerBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished){
        //do something on finish
    }];
}



#pragma mark - Memory management

- (void)dealloc
{
    // Nil out delegate
//    self.sessionController.delegate = nil;
}

#pragma mark - SessionControllerDelegate protocol conformance

- (void)sessionDidChangeState
{
    // Ensure UI updates occur on the main queue.
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendButtonTapped:(id)sender {
    
    if([_messageField.text length] > 0 && ![_messageField.text isEqualToString:@""]){
        NSManagedObjectContext* managedObjectContext = [appDelegate managedObjectContext];
        
        PrivateChatEntry *newprivateChatEntry = (PrivateChatEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"PrivateChatEntry" inManagedObjectContext:managedObjectContext];
        PrivateKey *pk = _privateSession.chatToPrivateKey;
        
        NSString *plainString = _messageField.text;
        NSString *key = [NSString stringWithFormat:@"%@",pk.sharedSecret]; // should be provided by a user
        NSString *encryptedString = [plainString AES128EncryptWithKey:key];
//        NSString *decryptedString = [encryptedString AES128DecryptWithKey:key];

        //        NSString *bar = [encryptedData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        
//        NSString *myString = [[NSString alloc] initWithData:foo encoding:NSUTF8StringEncoding];
//        NSLog(@"encrypted with key: %@, message: %@ ,data %@",pk.sharedSecret,decryptedString,encryptedString);
//        NSData* encryptedString = [TTEncryption encryptBase64String:_messageField.text keyString:[NSString stringWithFormat:@"%@",pk.sharedSecret] separateLines:YES];
        
        newprivateChatEntry.message = encryptedString;
        newprivateChatEntry.senderName = [appDelegate localName];
        newprivateChatEntry.timestamp = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
        newprivateChatEntry.messageToChat = _privateSession;
        
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"error saving new pce item in managedObjectContext! %@",[error localizedDescription]);
        }else{
//            NSLog(@"saved new message: %@ (%@)",newprivateChatEntry.message,_messageField.text);
        }
        
        [self sendMyMessage];
        _messageField.text = @"";
    }
    
}


#pragma mark - private methods

-(void)sendMyMessage{
    @try {
        UINavigationController *controller = (UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:0];
        TTFirstViewController *firstview = (TTFirstViewController*)[[controller viewControllers]objectAtIndex:0];
        [firstview.sessionController sendLocalMessages:YES];

    }
    @catch (NSException *exception) {
        NSLog(@"cant send private messages after input...: %@",exception);
    }
}


#pragma mark -
#pragma mark Fetched results controller

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
	// Create and configure a fetch request with the Person entity.
    //    TTAppDelegate *delegate = (TTAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSManagedObjectContext* managedObjectContext = appDelegate.managedObjectContext;
    
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"PrivateChatEntry" inManagedObjectContext: managedObjectContext];
	[fetchRequest setEntity:entity];
    
    // getting everything, except ebooks!
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((messageToChat.sessionID LIKE[c] %@))",_privateSessionID];
    [fetchRequest setPredicate:predicate];
	
	
	// Create the sort descriptors array.
    
    NSSortDescriptor *orderDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSArray *sortDescriptors;
    sortDescriptors = [[NSArray alloc] initWithObjects:orderDescriptor,  nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    
	// Create and initialize the fetch results controller.
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	self.fetchedResultsController = aFetchedResultsController;
    
	fetchedResultsController.delegate = self;
	
    
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
//        NSLog(@"fetchedresults error!");
        
    }else{
        //        NSLog(@"fetchedresults %@",mutableFetchResults);
        
        //        NSLog(@"fetched results: %@",mutableFetchResults);
        
    }
    
    
    
	return fetchedResultsController;
}



/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[_tableView beginUpdates];
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	//UITableView *tableView = tableView;
    
    
    
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
            //            NSLog(@"sollte zeile einfuegen in %@",newIndexPath);
			[_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
            //            NSLog(@"sollte zeile löschen in %@",indexPath);
			[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            //            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            
			break;
			
		case NSFetchedResultsChangeUpdate:
            //            NSLog(@"sollte zeile reloaden in %@",indexPath);
            [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            //            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            //            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeMove:
			[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
    
    
}



- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    
    [self scrollTableViewToBottom];
    
	[_tableView endUpdates];
    
    
}

-(void)scrollTableViewToBottom{
    CGSize tableSize = _tableView.contentSize;
    [_tableView setContentOffset:CGPointMake(0, tableSize.height)];
}

#pragma mark -
#pragma mark Table view data source methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //    NSLog(@"section Count: %d",[[fetchedResultsController sections] count]);
    return [[fetchedResultsController sections] count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    return [_apiResults count];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    //    NSLog(@"row Count: %d",[sectionInfo numberOfObjects]);
	return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PrivateChatEntry *cartItem = [fetchedResultsController objectAtIndexPath:indexPath];
    
    //    NSMutableArray *colResult = [_apiResults objectAtIndex:indexPath.row];
    //    NSLog(@"data Column: %@",colResult);
    
    CGFloat mheight = [self sizeForText:cartItem.message].height+24;
    
    return mheight;
}

-(CGSize)sizeForText:(NSString*)text
{
    
    
    CGSize stringSize = [text sizeWithAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]}];
    
    
    return stringSize;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    headerView.backgroundColor = [UIColor colorWithRed: 0.953 green: 0.953 blue: 0.953 alpha: 0.9];
    
    //    headerView.alpha = 0.1;
    
    //    UILabel  *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (12-10)/2, 47, 10)];
    //    dateLabel.backgroundColor = [UIColor clearColor];
    //    dateLabel.textColor=[UIColor blackColor];
    //    dateLabel.font=[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:10.0];
    //    dateLabel.text = @"header...";
    //    [headerView addSubview:dateLabel];
    
    return headerView;
    
}

//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 64;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, -1, 340, 55)];
//    headerView.backgroundColor = [UIColor whiteColor];
//
//    UIColor *sepColor = [UIColor colorWithRed: 0.787 green: 0.787 blue: 0.787 alpha: 1];
//    UIView *sepTop = [[UIView alloc]initWithFrame:CGRectMake(15, 0, 290, 0.5)];
//    sepTop.backgroundColor = sepColor;
//    [headerView addSubview:sepTop];
//
//    UIView *sepBot = [[UIView alloc]initWithFrame:CGRectMake(15, 63, 290, 0.5)];
//    sepBot.backgroundColor = sepColor;
//    [headerView addSubview:sepBot];
//
//    UILabel  *summeLabel = [[UILabel alloc] initWithFrame:CGRectMake(127, (37-18)/2, 58, 18)];
//    summeLabel.backgroundColor = [UIColor clearColor];
//    summeLabel.textColor=[UIColor colorWithRed: 0.451 green: 0.451 blue: 0.451 alpha: 1];
//    summeLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:15.0];
//    summeLabel.text = @"Summe:";
//    [headerView addSubview:summeLabel];
//
//
//    UILabel  *totalPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(summeLabel.frame.origin.x+summeLabel.frame.size.width+5, summeLabel.frame.origin.y, 115, 18)];
//    totalPriceLabel.backgroundColor = [UIColor clearColor];
//    totalPriceLabel.textColor=[UIColor redColor];
//    totalPriceLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:15.0];
//    NSString *formattedPrice = [NSString stringWithFormat:@"%.2f Euro",_totalPrice/100];
//    totalPriceLabel.text = [formattedPrice stringByReplacingOccurrencesOfString:@"." withString:@","];
//    //    CGSize titleWidth = [totalPriceLabel.text sizeWithAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15]}];
//    //    CGRect priceRect = totalPriceLabel.frame;
//    //    priceRect.size.width = titleWidth.width;
//    //    totalPriceLabel.frame = priceRect;
//
//    CGRect summeRect = summeLabel.frame;
//    //    summeRect.origin.x = 320 - (summeRect.size.width+5+titleWidth.width+15);
//    summeLabel.frame = summeRect;
//
//    CGRect priceR = totalPriceLabel.frame;
//    priceR.origin.x = summeLabel.frame.origin.x+summeLabel.frame.size.width+5;
//    totalPriceLabel.frame = priceR;
//
//    UILabel  *vatLabel = [[UILabel alloc] initWithFrame:CGRectMake(summeLabel.frame.origin.x, summeLabel.frame.origin.y+summeLabel.frame.size.height+5, 150, 18)];
//    vatLabel.backgroundColor = [UIColor clearColor];
//    vatLabel.textColor=[UIColor colorWithRed: 0.451 green: 0.451 blue: 0.451 alpha: 1];
//    vatLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:15.0];
//    vatLabel.text = @"inkl. Umsatzsteuer";
//    [headerView addSubview:vatLabel];
//
//
//
//    [headerView addSubview:totalPriceLabel];
//
//    [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
//
//    return headerView;
//
//}

- (UITableViewCell *)tableView:(UITableView *)_atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier =[NSString stringWithFormat:@"TTChatTableViewCell"];
    
    TTChatTableViewCell *cell = (TTChatTableViewCell*)[_atableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TTChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self configureChatCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // fix for separators bug in iOS 7
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // fix for separators bug in iOS 7
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)configureChatCell:(TTChatTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //    TTproductItem *colResult = (TTproductItem*)[_apiResults objectAtIndex:indexPath.row];
    PrivateChatEntry *cartItem = [fetchedResultsController objectAtIndexPath:indexPath];
    
    if(cartItem.seen == nil || !cartItem.seen){
        cartItem.seen = [NSNumber numberWithBool:YES];
    }
    
    PrivateKey *pk = _privateSession.chatToPrivateKey;
    
    //    NSMutableArray *colResult = [_apiResults objectAtIndex:indexPath.row];
    //    NSLog(@"data Column: %@",colResult);
    
//    NSData *messageData = [cartItem.message dataUsingEncoding:NSUTF8StringEncoding];
//    
//    TTEncryption *foo = [[TTEncryption alloc]initWithData:messageData];
//    
//    NSData *decodedData = [foo AES256DecryptWithKey:[NSString stringWithFormat:@"%@",pk.sharedSecret]];
    
//    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
//    NSString* decodedString = [TTEncryption decryptBase64String:_messageField.text keyString:[NSString stringWithFormat:@"%@",pk.sharedSecret]];
    
//    NSData *foo = [[cartItem.message  dataUsingEncoding:NSUTF8StringEncoding] AES256DecryptWithKey:[NSString stringWithFormat:@"%@",pk.sharedSecret]];
    

    NSString *key = [NSString stringWithFormat:@"%@",pk.sharedSecret]; // should be provided by a user
    NSString *encryptedString = cartItem.message;
    NSString *decryptedString = [encryptedString AES128DecryptWithKey:key];

//    NSString *bar = [foo base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
//    NSString *myString = [[NSString alloc] initWithData:foo encoding:NSUTF8StringEncoding];

//    NSLog(@"decrypted with key: %@, message: %@ - data: %@",pk.sharedSecret,decryptedString,encryptedString);

    cell.message.text = decryptedString;
    cell.sender.text = cartItem.senderName;
    
    if(![cartItem.senderName isEqualToString:[appDelegate localName]]){
        
        cell.backgroundColor = [UIColor colorWithRed: 0.898 green: 0.898 blue: 0.918 alpha: 1];
        cell.message.textColor = [UIColor blackColor];
        cell.message.textAlignment = NSTextAlignmentLeft;
        cell.sender.hidden = NO;
    }else{
        cell.backgroundColor = [UIColor colorWithRed: 0 green: 0.6 blue: 1 alpha: .1];
        cell.message.textColor = [UIColor darkGrayColor];
        cell.message.textAlignment = NSTextAlignmentRight;

        cell.sender.hidden = YES;
    }
    
    
    CGRect msgTypeFrame = cell.messageType.frame;
    
    //    msgTypeFrame.origin.x = 0;
    msgTypeFrame.origin.y = 0;
    msgTypeFrame.size.height = [self sizeForText:cartItem.message].height+24;
    cell.messageType.frame = msgTypeFrame;
    cell.messageType.hidden = YES;
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
