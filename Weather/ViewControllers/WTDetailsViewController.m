//
//  WTDetailsViewController.m
//  Weather
//
//  Created by mmakankov on 14/06/14.
//  Copyright (c) 2014 mmakankov. All rights reserved.
//

#import "WTDetailsViewController.h"
#import "City.h"
#import "WTCityCell.h"
#import "WTNetworkManager.h"

@interface WTDetailsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSInteger daysNumber;
@property (nonatomic) NSArray *dailyForecast;

@end

@implementation WTDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.daysNumber = 3;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = self.currentCity.name;
    self.daysNumber = 3;
    
    self.temperatureLabel.text = self.currentCity.temperature.stringValue;
    self.weatherLabel.text = self.currentCity.weather;
    self.descriptionLabel.text = self.currentCity.weatherDescription;
    self.windLabel.text = self.currentCity.windSpeed.stringValue;
    self.iconLabel.image = [UIImage imageWithContentsOfFile:[APP_DELEGATE.documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", self.currentCity.iconId]]];
    
    [[WTNetworkManager sharedInstance] requestDailyForecastForCityName:self.currentCity.name
                                                            daysNumber:self.daysNumber
                                                     complitionHandler:^(NSArray *list){
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             self.dailyForecast = list;
                                                             [self.tableView reloadData];
                                                         });
                                                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dailyForecast.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    WTCityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (WTCityCell *)configureCell:(WTCityCell *)cell atIndexPath:(NSIndexPath*)indexPath {
    
    NSDictionary *dayDictionary = self.dailyForecast[indexPath.row];
    
    NSNumber *dateTime = dayDictionary[@"dt"];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:dateTime.integerValue]
                                                          dateStyle:NSDateFormatterMediumStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    
    cell.cityLabel.text = dateString;
    NSNumber *dayTemp = dayDictionary[@"temp"][@"day"];
    cell.temperatureLabel.text = dayTemp.stringValue;
    cell.iconImageView.image = [UIImage imageWithContentsOfFile:[APP_DELEGATE.documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", dayDictionary[@"weather"][0][@"icon"]]]];
    
    return cell;
}

@end
