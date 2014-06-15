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
#import "Reachability.h"

static const NSString *baseURL = @"http://api.openweathermap.org/data/2.5/weather?units=metric&id=";
static const NSString *baseIconURL = @"http://openweathermap.org/img/w/";
static const NSString *baseForecastURL = @"http://api.openweathermap.org/data/2.5/forecast/daily?units=metric&id=";
static const NSString *daysNumberString = @"&cnt=";
static const NSString *baseFindURL = @"http://api.openweathermap.org/data/2.5/find?units=metric&type=like&q=";

@interface WTNetworkManager () <NSURLSessionDataDelegate, NSURLSessionTaskDelegate, NSURLSessionDelegate>

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDataTask *currentTask;
@property (nonatomic) Reachability *reachability;

@end

@implementation WTNetworkManager

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kReachabilityChangedNotification object:nil];
        
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
        
    }
    return self;
}

- (void)requestDataForArray:(NSArray *)cities {
    
    for (City *city in cities) {
        [self requestDataForCityId:city.id];
    }
}

- (void)requestDataForCityId:(NSNumber *)cityId {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:[baseURL stringByAppendingString:cityId.stringValue]];
    self.currentTask = [self.session dataTaskWithURL:url
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
                                                   [self requestIconWithId:notesJSON[@"weather"][0][@"icon"] completionHandler:^(NSData *data){
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [[WTDBStorage sharedInstance] insertOrUpdateObjectWithDictionary:notesJSON];
                                                       });
                                                   }];
                                               }
                                           }
                                       }
                                       [self stopActivityIndicator];
                                   }];
    [self.currentTask resume];
}

- (void)requestIconWithId:(NSString *)iconId completionHandler:(void(^)(NSData *data))completionHandler {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    void(^iconCompletionHandler)(NSData *data) = [completionHandler copy];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filePath = [APP_DELEGATE.documentsDirectory stringByAppendingPathComponent:[iconId stringByAppendingString:@".png"]];
    BOOL isFileExists = [fileManager fileExistsAtPath:filePath];
    
    if (!isFileExists) {
        NSURL *url = [NSURL URLWithString:[baseIconURL stringByAppendingString:[iconId stringByAppendingString:@".png"]]];
        NSURLSessionDownloadTask *dataTask = [self.session downloadTaskWithURL:url
                                                             completionHandler:^(NSURL *location,
                                                                                 NSURLResponse *response,
                                                                                 NSError *error) {
                                                                 NSData *imageData = [NSData dataWithContentsOfURL:location];
                                                                 if ([fileManager createFileAtPath:filePath contents:imageData attributes:nil] && iconCompletionHandler != NULL) {
                                                                     iconCompletionHandler(imageData);
                                                                 }
                                                                 [self stopActivityIndicator];
                                                             }];
        [dataTask resume];
    }
}

- (void)requestDailyForecastForCityId:(NSNumber *)cityId
                           daysNumber:(NSInteger)daysNumber
                    completionHandler:(void(^)(NSArray *list))completionHandler {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    void(^forecastCompletionHandler)(NSArray *list) = [completionHandler copy];
    
    NSString *urlString = [baseForecastURL stringByAppendingString:cityId.stringValue];
    if (daysNumber) {
        urlString = [NSString stringWithFormat:@"%@%@%li", urlString, daysNumberString, daysNumber];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    self.currentTask = [self.session dataTaskWithURL:url
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
                                                   forecastCompletionHandler(array);
                                               }
                                           }
                                       }
                                       [self stopActivityIndicator];
                                   }];
    [self.currentTask resume];
}

- (void)requestCitiesByString:(NSString *)string completionHandler:(void(^)(NSArray *list))completionHandler {
    
    [self.currentTask cancel];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    void(^findCitiesCompletionHandler)(NSArray *list) = [completionHandler copy];
    
    NSString *urlString = [baseFindURL stringByAppendingString:[string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:urlString];
    self.currentTask = [self.session dataTaskWithURL:url
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
                                                   findCitiesCompletionHandler(array);
                                               }
                                           }
                                       }
                                       [self stopActivityIndicator];
                                   }];
    [self.currentTask resume];
}

- (void)stopActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
}
#pragma mark - Notifications

- (void)networkChanged:(NSNotification *)notification {
    
    NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
    if (remoteHostStatus == NotReachable) {
        DLog(@"not reachable");
    }
    else if (remoteHostStatus == ReachableViaWiFi) {
        DLog(@"wifi");
    }
    else if (remoteHostStatus == ReachableViaWWAN) {
        DLog(@"carrier");
    }
}

#pragma mark - Getters and Setters

- (BOOL)isOnline {
    
    NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
    if (remoteHostStatus == NotReachable) {
        return NO;
    }
    return YES;
}

@end
