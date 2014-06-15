//
//  WTNetworkManager.m
//  Weather
//
//  Created by mmakankov on 15/06/14.
//  Copyright (c) 2014 mmakankov. All rights reserved.
//

#import "WTNetworkManager.h"
#import "City.h"
#import "WTDBStorage.h"

static const NSString *baseURL = @"http://api.openweathermap.org/data/2.5/weather?units=metric&q=";
static const NSString *baseIconURL = @"http://openweathermap.org/img/w/";

static const NSString *baseForecastURL = @"http://api.openweathermap.org/data/2.5/forecast/daily?units=metric&cnt=3&q=";

@interface WTNetworkManager ()

@property (nonatomic) NSURLSession *session;

@end

@implementation WTNetworkManager

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initUniqueInstance];
    });
    
    return sharedInstance;
}

- (instancetype)initUniqueInstance {
    
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (void)requestDataForArray:(NSArray *)cities {
    
    for (City *city in cities) {
        [self requestDataForCityName:city.name];
    }
}

- (void)requestDataForCityName:(NSString *)cityName {
    
    NSURL *url = [NSURL URLWithString:[baseURL stringByAppendingString:cityName]];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url
                                                 completionHandler:^(NSData *data,
                                                                     NSURLResponse *response,
                                                                     NSError *error) {
                                                     if (!error) {
                                                         NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                                                         if (httpResp.statusCode == 200) {
                                                             
                                                             NSError *jsonError;
                                                             
                                                             NSDictionary *notesJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                       options:NSJSONReadingAllowFragments
                                                                                                                         error:&jsonError];
                                                             
                                                             
                                                             if (!jsonError) {
                                                                 [self requestIconWithId:notesJSON[@"weather"][0][@"icon"]];
                                                                 [[WTDBStorage sharedInstance] insertOrUpdateObjectWithDictionary:notesJSON];
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                                 });
                                                             }
                                                         }
                                                     }
                                                 }];
    [dataTask resume];
}

- (void)requestIconWithId:(NSString *)iconId {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filePath = [APP_DELEGATE.documentsDirectory stringByAppendingPathComponent:[iconId stringByAppendingString:@".png"]];
    BOOL isFileExists = [fileManager fileExistsAtPath:filePath];
    
    if (!isFileExists) {
        NSURL *url = [NSURL URLWithString:[baseIconURL stringByAppendingString:[iconId stringByAppendingString:@".png"]]];
        NSURLSessionDownloadTask *dataTask = [self.session downloadTaskWithURL:url
                                                             completionHandler:^(NSURL *location,
                                                                                 NSURLResponse *response,
                                                                                 NSError *error) {
                                                                 [fileManager createFileAtPath:filePath contents:[NSData dataWithContentsOfURL:location] attributes:nil];
                                                             }];
        [dataTask resume];
    }
}

- (void)requestDailyForecastForCityName:(NSString *)cityName
                             daysNumber:(NSInteger)daysNumber
                      complitionHandler:(void(^)(NSArray *list))complitionHandler {
    
    void(^forecastComplitionHandler)(NSArray *list) = [complitionHandler copy];
    
    NSURL *url = [NSURL URLWithString:[baseForecastURL stringByAppendingString:cityName]];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url
                                                 completionHandler:^(NSData *data,
                                                                     NSURLResponse *response,
                                                                     NSError *error) {
                                                     if (!error) {
                                                         NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                                                         if (httpResp.statusCode == 200) {
                                                             
                                                             NSError *jsonError;
                                                             
                                                             NSDictionary *notesJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                       options:NSJSONReadingAllowFragments
                                                                                                                         error:&jsonError];
                                                             
                                                             if (!jsonError) {
                                                                 NSArray *array = notesJSON[@"list"];
                                                                 forecastComplitionHandler(array);
                                                             }
                                                         }
                                                     }
                                                 }];
    [dataTask resume];
}

#pragma mark - Private methods

- (void)startActivityIndicator {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
}

@end
