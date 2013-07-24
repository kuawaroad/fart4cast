//
//  WeatherDataModel.h
//  Fart4Cast2
//
//  Created by George Uno on 4/20/12.
//  Copyright (c) 2012 Kuawa Road Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherDataModel : NSObject {
    // iVars - bits of weather data, make properties too
    int _currentTemp;
    int _celsiusCurrent;
    NSString *_conditionsString;
    NSString *_windString;
    NSString *_humidityString;
    NSString *_locationString;
    NSString *_postalCode;
    NSString *_imageString;
    NSMutableArray *_forecastArray;
}

@property (nonatomic,assign) int currentTemp;
@property (nonatomic,assign) int celsiusCurrent;
@property (nonatomic,retain) NSString *conditionsString;
@property (nonatomic,retain) NSString *windString;
@property (nonatomic,retain) NSString *humidityString;
@property (nonatomic,retain) NSString *locationString;
@property (nonatomic,retain) NSString *postalCode;
@property (nonatomic,retain) NSString *imageString;
@property (nonatomic,retain) NSMutableArray *forecastArray;

@end
