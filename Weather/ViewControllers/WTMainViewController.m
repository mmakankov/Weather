//
//  WTMainViewController.m
//  Weather
//
//  Created by mmakankov on 14/06/14.
//  Copyright (c) 2014 mmakankov. All rights reserved.
//

#import "WTMainViewController.h"
#import <CoreData/CoreData.h>
#import "WTDBStorage.h"
#import "City.h"
#import "WTMainCell.h"
#import "WTDetailsViewController.h"
#import "WTNetworkManager.h"
#import "Reachability.h"

@interface WTMainViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation WTMainViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kReachabilityChangedNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Cities";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemClicked:)];
    self.navigationItem.rightBarButtonItem = addItem;
    
    NSError *error;
	if (![self.fetchedResultsController performFetch:&error]) {
		DLog(@"Unresolved error %@, %@", error, error.userInfo);
	}
    [[WTNetworkManager sharedInstance] requestDataForArray:self.fetchedResultsController.fetchedObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_fetchedResultsController.sections[section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    WTMainCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (WTMainCell *)configureCell:(WTMainCell *)cell atIndexPath:(NSIndexPath*)indexPath {
    
    cell.cityLabel.text = ((City *)[self.fetchedResultsController objectAtIndexPath:indexPath]).name;
    cell.temperatureLabel.text = [NSString stringWithFormat:@"%@°", ((City *)[self.fetchedResultsController objectAtIndexPath:indexPath]).temperature];
    
    cell.iconImageView.image = [UIImage imageWithContentsOfFile:[APP_DELEGATE.documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", ((City *)[self.fetchedResultsController objectAtIndexPath:indexPath]).iconId]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"pushDetailsViewController" sender:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[WTDBStorage sharedInstance] removeObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushDetailsViewController"]) {
        WTDetailsViewController *detailsController = [segue destinationViewController];
        detailsController.currentCity = sender;
    }
    else if ([segue.identifier isEqualToString:@"pushAddViewController"]) {
        
    }
}

#pragma mark -  Actions

- (void)addItemClicked:(id)sender {
    if ([WTNetworkManager sharedInstance].isOnline) {
        [self performSegueWithIdentifier:@"pushAddViewController" sender:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Network is not available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - NSFetchedResultsController methods

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    WTDBStorage *dbStorage = [WTDBStorage sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityNameCity
                                              inManagedObjectContext:dbStorage.context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:dbStorage.context sectionNameKeyPath:nil cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(WTMainCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - Notifications

- (void)networkChanged:(NSNotification *)notification {
    
    if ([WTNetworkManager sharedInstance].isOnline) {
        [[WTNetworkManager sharedInstance] requestDataForArray:self.fetchedResultsController.fetchedObjects];
    }
}
@end
