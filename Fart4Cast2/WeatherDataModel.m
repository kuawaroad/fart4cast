//
//  WeatherDataModel.m
//  Fart4Cast2
//
//  Created by George Uno on 4/20/12.
//  Copyright (c) 2012 Kuawa Road Productions. All rights reserved.
//

#import "WeatherDataModel.h"
#import "DailyForecastDataModel.h"

@implementation WeatherDataModel {
    //iVars
}

//@synthesize currentTemp, conditionsString, windString, humidityString, forecastArray;

@synthesize currentTemp = _currentTemp;
@synthesize celsiusCurrent = _celsiusCurrent;
@synthesize conditionsString = _conditionsString;
@synthesize windString = _windString;
@synthesize humidityString = _humidityString;
@synthesize forecastArray = _forecastArray;
@synthesize locationString = _locationString;
@synthesize imageString = _imageString;
@synthesize postalCode = _postalCode;

#pragma mark INIT

-(id)init {
    if ((self = [super init])) {
        _forecastArray = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}


#pragma mark DEALLOC

-(void)dealloc {
    self.currentTemp = INT_MIN;
    self.celsiusCurrent = INT_MIN;
    self.conditionsString = nil;
    self.windString = nil;
    self.humidityString = nil;
    self.forecastArray = nil;
    self.locationString = nil;
    self.postalCode = nil;
    self.imageString = nil;
    [super dealloc];
}

@end
