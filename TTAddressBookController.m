//
//  TTAddressBookController.m
//  offlineChattr
//
//  Created by Patrik Boras on 30/04/14.
//  Copyright (c) 2014 tapthis. All rights reserved.
//

#import "TTAddressBookController.h"
#import "TTOneLabelTableViewCell.h"
#import "PublicChatEntry.h"
#import "TTAppDelegate.h"

@interface TTAddressBookController ()<NSFetchedResultsControllerDelegate>{
    TTAppDelegate *appDelegate;
    NSFetchedResultsController *fetchedResultsController;
    UITableView *_tableview;
}

@property (nonatomic,retain) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TTAddressBookController

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
    
    self.title = @"Private Nachricht an:";
    
    _tableview = self.tableView;
    
    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor clearColor]];
    _tableview.tableFooterView = [[UIView alloc] init];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //    NSLog(@"section Count: %d",[[fetchedResultsController sections] count]);
//    return [[fetchedResultsController sections] count];
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    return [_apiResults count];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    //    NSLog(@"row Count: %d",[sectionInfo numberOfObjects]);
	return [[fetchedResultsController sections]count];
//    [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return 44;;
}


- (UITableViewCell *)tableView:(UITableView *)_atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier =[NSString stringWithFormat:@"TTOneLabelTableViewCell"];
    
    TTOneLabelTableViewCell *cell = (TTOneLabelTableViewCell*)[_atableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TTOneLabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self configureAddCell:cell atIndexPath:indexPath];
    
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

- (void)configureAddCell:(TTOneLabelTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //    TTproductItem *colResult = (TTproductItem*)[_apiResults objectAtIndex:indexPath.row];
    @try {
        PublicChatEntry *cartItem = [fetchedResultsController objectAtIndexPath:indexPath];
        
        //    NSMutableArray *colResult = [_apiResults objectAtIndex:indexPath.row];
        //    NSLog(@"data Column: %@",colResult);
        
        cell.mainLabel.text = cartItem.senderName;
    }
    @catch (NSException *exception) {
        cell.mainLabel.text = @"berrechne...";
    }
    
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PublicChatEntry *cartItem = [fetchedResultsController objectAtIndexPath:indexPath];
    
    [_sessionController createPrivatChatsession:cartItem.senderName];
    
//    [self.tabBarController setSelectedIndex:1];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"PublicChatEntry" inManagedObjectContext: managedObjectContext];
	[fetchRequest setEntity:entity];
    
    // getting everything, except ebooks!
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(senderName != %@)",appDelegate.localName];
        [fetchRequest setPredicate:predicate];
	
	
	// Create the sort descriptors array.
    
    NSSortDescriptor *orderDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSArray *sortDescriptors;
    sortDescriptors = [[NSArray alloc] initWithObjects:orderDescriptor,  nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    
	// Create and initialize the fetch results controller.
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"senderName" cacheName:nil];
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
	[_tableview beginUpdates];
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	//UITableView *tableView = tableView;
    
    
    
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
            //            NSLog(@"sollte zeile einfuegen in %@",newIndexPath);
			[_tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
            //            NSLog(@"sollte zeile löschen in %@",indexPath);
			[_tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            //            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            
			break;
			
		case NSFetchedResultsChangeUpdate:
            //            NSLog(@"sollte zeile reloaden in %@",indexPath);
            [_tableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            //            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            //            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeMove:
			[_tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
    
    
}



- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[_tableview insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[_tableview deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    
    
	[_tableview endUpdates];
    
    
}

@end
