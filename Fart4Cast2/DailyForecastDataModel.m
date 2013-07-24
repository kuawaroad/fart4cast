//
//  DailyForecastDataModel.m
//  Fart4Cast2
//
//  Created by George Uno on 4/20/12.
//  Copyright (c) 2012 Kuawa Road Productions. All rights reserved.
//

#import "DailyForecastDataModel.h"

@implementation DailyForecastDataModel

//@synthesize lowTemp, highTemp, weekday, conditions, icon, iconURL;

@synthesize lowTemp = _lowTemp;
@synthesize highTemp = _highTemp;
@synthesize weekday = _weekday;
@synthesize conditions = _conditions;
@synthesize icon = _icon;
@synthesize iconURL = _iconURL;
@synthesize celsiusLow = _celsiusLow;
@synthesize celsiusHigh = _celsiusHigh;

#pragma mark INIT

-(id)init {
    if ((self = [super init])) {
        
    }
    return self;
}


#pragma mark DEALLOC

-(void)dealloc {
    self.lowTemp = INT_MIN;
    self.highTemp = INT_MIN;
    self.celsiusHigh = INT_MIN;
    self.celsiusLow = INT_MIN;
    self.weekday = nil;
    self.conditions = nil;
    self.icon = nil;
    self.iconURL = nil;
    
    [super dealloc];
}

@end
