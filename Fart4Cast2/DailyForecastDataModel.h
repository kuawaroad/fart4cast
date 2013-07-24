//
//  DailyForecastDataModel.h
//  Fart4Cast2
//
//  Created by George Uno on 4/20/12.
//  Copyright (c) 2012 Kuawa Road Productions. All rights reserved.
//
//  ONE DAY'S FORECAST INFORMATION FROM GOOGLE WEATHER API

#import <Foundation/Foundation.h>

@interface DailyForecastDataModel : NSObject {
    int _lowTemp;
    int _highTemp;
    int _celsiusLow;
    int _celsiusHigh;
    NSString *_weekday;
    NSString *_conditions;
    NSString *_icon;
    NSString *_iconURL;
}

@property (nonatomic, assign) int lowTemp;
@property (nonatomic, assign) int highTemp;
@property (nonatomic, assign) int celsiusLow;
@property (nonatomic, assign) int celsiusHigh;
@property (nonatomic, retain) NSString *weekday;
@property (nonatomic, retain) NSString *conditions;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, retain) NSString *iconURL;

@end
