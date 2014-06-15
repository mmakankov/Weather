//
//  WTAddViewController.m
//  Weather
//
//  Created by mmakankov on 15/06/14.
//  Copyright (c) 2014 mmakankov. All rights reserved.
//

#import "WTAddViewController.h"
#import "WTCityCell.h"
#import "WTNetworkManager.h"
#import "WTDBStorage.h"

@interface WTAddViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSArray *cities;

@end

@implementation WTAddViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemClicked:)];
    self.navigationItem.rightBarButtonItem = addItem;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CityCell";
    WTCityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (WTCityCell *)configureCell:(WTCityCell *)cell atIndexPath:(NSIndexPath*)indexPath {
    
    NSDictionary *cityDictionary = self.cities[indexPath.row];
    cell.cityLabel.text = cityDictionary[@"name"];
    cell.countryLabel.text = cityDictionary[@"sys"][@"country"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}

#pragma mark -  Actions

- (void)addItemClicked:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath) {
        [[WTDBStorage sharedInstance] insertOrUpdateObjectWithDictionary:self.cities[indexPath.row]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [[WTNetworkManager sharedInstance] requestCitiesByString:searchText completionHandler:^(NSArray *list){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (list.count) {
                self.cities = list;
                [self.tableView reloadData];
            }
        });
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
}

#pragma mark - Notification Responders

- (void)keyboardWillShowNotification:(NSNotification*)notification
{
    [self animateViewFrameChangeForNotification:notification];
}

- (void)keyboardWillHideNotification:(NSNotification*)notification
{
    [self animateViewFrameChangeForNotification:notification];
}

- (void)animateViewFrameChangeForNotification:(NSNotification*)notification
{
    NSValue *begin = notification.userInfo[UIKeyboardFrameBeginUserInfoKey];
    NSValue *end = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    float delta = begin.CGRectValue.origin.y - end.CGRectValue.origin.y;
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.size.height -= delta;
                         self.view.frame = frame;
                     } completion:nil];
}

@end
