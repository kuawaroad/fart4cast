//
//  WeatherReader.h
//  Fart4Cast2
//
//  Created by George Uno on 4/20/12.
//  Copyright (c) 2012 Kuawa Road Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WeatherDataModel;

@interface WeatherReader : NSObject {
    //IVARS
}

// class, returns a DFDM by calling API and verifying data
+(WeatherDataModel *)loadWeatherData;
+(WeatherDataModel *)loadWeatherDataForLocation:(NSString *)location;
// data verification
+(BOOL)isValidLocation:(NSString *)location;

@end
