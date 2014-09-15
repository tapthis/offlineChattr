//
//  TTPrivateChatsViewController.m
//  offlineChattr
//
//  Created by Patrik Boras on 01/05/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import "TTPrivateChatsViewController.h"
#import "TTAppDelegate.h"
#import "TTPrivateOverviewTableViewCell.h"
#import "TTPrivateChatDetailViewController.h"
#import "PrivateChatSession.h"
#import "PrivateKey.h"
#import "PublicKey.h"

@interface TTPrivateChatsViewController ()<NSFetchedResultsControllerDelegate>{
    TTAppDelegate *appDelegate;
    NSFetchedResultsController *fetchedResultsController;

}

@property (nonatomic,retain) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TTPrivateChatsViewController

@synthesize fetchedResultsController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (TTAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.title = @"Unterhaltungen";
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    
    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor clearColor]];
    self.tableView.tableFooterView = [[UIView alloc] init];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"PrivateChatSession" inManagedObjectContext: managedObjectContext];
	[fetchRequest setEntity:entity];
    
    // getting everything, except ebooks!
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(((opponent LIKE[c] %@) OR (initiator LIKE[c] %@)) AND (chatToPrivateKey.sharedSecret > 0))",[appDelegate localName],[appDelegate localName]];
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
	
    @try {
        NSError *error = nil;
        NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
        if (mutableFetchResults == nil) {
            // Handle the error.
            NSLog(@"pcs fetchedresults error!");
            
        }else{
            //        NSLog(@"fetchedresults %@",mutableFetchResults);
            
            NSLog(@"pcs fetched results: %@",[mutableFetchResults valueForKeyPath:@"chatToPrivateKey.sharedSecret"]);
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"cant fetch private sesssions!!");
    }
    
    
    
	return fetchedResultsController;
}



/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	//UITableView *tableView = tableView;
    
    
    
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
            //            NSLog(@"sollte zeile einfuegen in %@",newIndexPath);
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
            //            NSLog(@"sollte zeile löschen in %@",indexPath);
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            //            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            
			break;
			
		case NSFetchedResultsChangeUpdate:
            //            NSLog(@"sollte zeile reloaden in %@",indexPath);
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            //            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            //            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeMove:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
    
    
}



- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    
    
	[self.tableView endUpdates];
    
    
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
//    return [[fetchedResultsController sections] count];
}


// Customize the appearance of table view cells.
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44;
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
    
    NSString *CellIdentifier =[NSString stringWithFormat:@"TTPrivateOverviewTableViewCell"];
    
    TTPrivateOverviewTableViewCell *cell = (TTPrivateOverviewTableViewCell*)[_atableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TTPrivateOverviewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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

- (void)configureChatCell:(TTPrivateOverviewTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //    TTproductItem *colResult = (TTproductItem*)[_apiResults objectAtIndex:indexPath.row];
    PrivateChatSession *chatItem = (PrivateChatSession*)[fetchedResultsController objectAtIndexPath:indexPath];

    //    NSMutableArray *colResult = [_apiResults objectAtIndex:indexPath.row];
    //    NSLog(@"data Column: %@",colResult);
    if([chatItem.initiator isEqualToString:[appDelegate localName]]){
        cell.opponent.text = chatItem.opponent;
    }else{
        cell.opponent.text = chatItem.initiator;
    }
    
    cell.sessionID = chatItem.sessionID;

    PrivateKey *pk = (PrivateKey*)chatItem.chatToPrivateKey;
    
    if(pk.sharedSecret > 0){
        cell.statusBack.backgroundColor = [UIColor greenColor];
        cell.statusLabel.text = @"verbunden";
    }else{
        cell.statusBack.backgroundColor = [UIColor orangeColor];
        cell.statusLabel.text = @"verbinde...";
    }
    

}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TTPrivateChatDetailViewController *pc = [segue destinationViewController];
    
    NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
    PrivateChatSession *privateSession = (PrivateChatSession*)[fetchedResultsController objectAtIndexPath:selectedRowIndex];
    
    pc.privateSessionID = privateSession.sessionID;
    pc.privateSession = privateSession;
}


@end
