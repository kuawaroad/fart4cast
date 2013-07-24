//
//  WeatherReader.m
//  Fart4Cast2
//
//  Created by George Uno on 4/20/12.
//  Copyright (c) 2012 Kuawa Road Productions. All rights reserved.
//

#import "WeatherReader.h"
#import "GDataXMLNode.h"
#import "WeatherDataModel.h"
#import "DailyForecastDataModel.h"

@implementation WeatherReader

+(BOOL)isValidLocation:(NSString *)location {
    NSLog(@"Validating :: %@",location);
    location = [location stringByReplacingOccurrencesOfString:@" " withString:@"%20"]; // make location HTML safe (whitespace = %20)
    NSString *locationURL = [NSString stringWithFormat:@"http://www.google.com/ig/api?weather=%@",location];
    NSMutableData *validationData = [[[NSMutableData alloc] initWithContentsOfURL:[NSURL URLWithString:locationURL]] autorelease];
    if (validationData == nil) {
        NSLog(@"isValidLocation :: Network Error!");
        return FALSE;
    }
    NSError *validationError;
    GDataXMLDocument *testDoc = [[[GDataXMLDocument alloc] initWithData:validationData options:0 error:&validationError] autorelease];
    
    
    NSArray *testArray = [testDoc nodesForXPath:@"//problem_cause/@data" error:nil];
    if (testArray.count > 0) {
        // erroneous XML downloaded.
        return NO;
    } else {
        // the XML was good, location is valid...
        return YES;
    }

}

+(WeatherDataModel *)loadWeatherData {
    
    NSLog(@"loadWeatherData :: NSUSERDEFAULT - %@",[[NSUserDefaults standardUserDefaults] stringForKey:@"UserLocation"]);
    
        // create a weather data model to hold info
    WeatherDataModel *weatherData = [[[WeatherDataModel alloc] init] autorelease];
    
    // make API call...
    NSString *locationString = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserLocation"];
    locationString = [locationString stringByReplacingOccurrencesOfString:@" , " withString:@","];
    locationString = [locationString stringByReplacingOccurrencesOfString:@" ," withString:@","];
    locationString = [locationString stringByReplacingOccurrencesOfString:@", " withString:@","];
    locationString = [locationString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    //NSString *htmlSafeString = [locationString stringByReplacingOccurrencesOfString:@" " withString:@"%20"]; // make location HTML safe (whitespace = %20)
    NSString *weatherAPIURL = [NSString stringWithFormat:@"http://www.google.com/ig/api?weather=%@",locationString];
    
    NSMutableData *downloadedData = [[[NSMutableData alloc] initWithContentsOfURL:[NSURL URLWithString:weatherAPIURL]] autorelease];
        // network error handling
    if (downloadedData == nil) {
        NSLog(@"loadWeatherData :: Network Error!");
        return; // its OK, returning weatherData = CRASH  Returning NULL to viewController = W1N
    }
    NSError *xmlError;
    GDataXMLDocument *xmlDoc = [[[GDataXMLDocument alloc] initWithData:downloadedData options:0 error:&xmlError] autorelease];
    
    
    //NSLog(@"XMLDOC = %@ \nXMLERROR = %@",xmlDoc.rootElement ,xmlError.localizedDescription);
    NSLog(@"XMLDOC :: %@",[xmlDoc nodesForXPath:@"xml_api_reply/weather/current_conditions/condition/@data" error:nil]);
    
    
        
    NSArray *conditionsArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather/current_conditions/condition/@data" error:nil];
    if (conditionsArray.count > 0) {
        GDataXMLElement *conditions = (GDataXMLElement *)[conditionsArray objectAtIndex:0];
        weatherData.conditionsString = conditions.stringValue; //.intValue; // retrieves INT
    }
    
    NSArray *imageArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather/current_conditions/icon/@data" error:nil];
    if (imageArray.count > 0) {
        GDataXMLElement *image = (GDataXMLElement *)[imageArray objectAtIndex:0];
        weatherData.imageString = [[image.stringValue substringFromIndex:19] stringByDeletingPathExtension]; //.intValue; // retrieves INT
    }
    
    NSArray *windArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather/current_conditions/wind_condition/@data" error:nil];
    if (windArray.count > 0) {
        GDataXMLElement *wind = (GDataXMLElement *)[windArray objectAtIndex:0];
        weatherData.windString = wind.stringValue; //.intValue; // retrieves INT
    }
    
    NSArray *humidityArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather/current_conditions/humidity/@data" error:nil];
    if (humidityArray.count > 0) {
        GDataXMLElement *humidity = (GDataXMLElement *)[humidityArray objectAtIndex:0];
        weatherData.humidityString = humidity.stringValue; //.intValue; // retrieves INT
    }
    
    NSArray *temperatureArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather/current_conditions/temp_f/@data" error:nil];
    if (temperatureArray.count > 0) {
        GDataXMLElement *temperature = (GDataXMLElement *)[temperatureArray objectAtIndex:0];
        weatherData.currentTemp = temperature.stringValue.intValue; // retrieves INT
        weatherData.celsiusCurrent = (((temperature.stringValue.intValue - 32) * 5) / 9);
        NSLog(@"CONVERSION %i -> %i",weatherData.currentTemp,weatherData.celsiusCurrent);
    }
    
    NSArray *locationArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather/forecast_information/city/@data" error:nil];
    if (locationArray.count > 0) {
        GDataXMLElement *location = (GDataXMLElement *)[locationArray objectAtIndex:0];
        weatherData.locationString = location.stringValue;  //intValue; // retrieves INT
    }
    
    NSArray *postalCodeArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather/forecast_information/postal_code/@data" error:nil];
    if (postalCodeArray.count > 0) {
        GDataXMLElement *postalCode = (GDataXMLElement *)[postalCodeArray objectAtIndex:0];
        weatherData.postalCode = postalCode.stringValue;  //intValue; // retrieves INT
    }
    
    NSArray *forecastArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather//forecast_conditions" error:nil];
    if (forecastArray.count > 2) {
        NSLog(@"WOOOOOOOOOOOOOOOOOOOT!!!!!!!!!1!");
        
        
    }
        
        
    
    for (int i = 0; i < forecastArray.count; i++) {
        
        DailyForecastDataModel *dailyForecast = [[[DailyForecastDataModel alloc] init] autorelease];
        
        GDataXMLElement *oneDayForecast = (GDataXMLElement *)[forecastArray objectAtIndex:i];
        NSArray *singleDayArray = oneDayForecast.children;
        if (singleDayArray.count > 0) {
            NSLog(@"SDA :: %@",singleDayArray);
            
            GDataXMLElement *oneDayWeekday = (GDataXMLElement *)[singleDayArray objectAtIndex:0];
            NSArray *weekdayArray = [oneDayWeekday nodesForXPath:@"//day_of_week/@data" error:nil];
            if (weekdayArray.count > 0) {
                GDataXMLElement *weekday = (GDataXMLElement *)[weekdayArray objectAtIndex:i];
                dailyForecast.weekday = weekday.stringValue;
            }
            
            GDataXMLElement *oneDayLow = (GDataXMLElement *)[singleDayArray objectAtIndex:1];
            NSArray *lowArray = [oneDayLow nodesForXPath:@"//low/@data" error:nil];
            if (lowArray.count > 0) {
                GDataXMLElement *lowTemp = (GDataXMLElement *)[lowArray objectAtIndex:i];
                dailyForecast.lowTemp = lowTemp.stringValue.intValue;
                dailyForecast.celsiusLow = (((lowTemp.stringValue.intValue - 32) * 5) / 9);
            }
            
            GDataXMLElement *oneDayHigh = (GDataXMLElement *)[singleDayArray objectAtIndex:2];
            NSArray *highArray = [oneDayHigh nodesForXPath:@"//high/@data" error:nil];
            if (highArray.count > 0) {
                GDataXMLElement *highTemp = (GDataXMLElement *)[highArray objectAtIndex:i];
                dailyForecast.highTemp = highTemp.stringValue.intValue;
                dailyForecast.celsiusHigh = (((highTemp.stringValue.intValue - 32) * 5) / 9);
            }
            
            GDataXMLElement *oneDayIcon = (GDataXMLElement *)[singleDayArray objectAtIndex:3];
            NSArray *iconArray = [oneDayIcon nodesForXPath:@"//forecast_conditions/icon/@data" error:nil];
            if (iconArray.count > 0) {
                GDataXMLElement *icon = (GDataXMLElement *)[iconArray objectAtIndex:i];
                NSString *tempString = icon.stringValue;
                NSString *shortString = [[tempString substringFromIndex:19] stringByDeletingPathExtension];
                dailyForecast.iconURL = shortString;
            }
            
            GDataXMLElement *oneDayConditions = (GDataXMLElement *)[singleDayArray objectAtIndex:4];
            NSArray *condArray = [oneDayConditions nodesForXPath:@"//forecast_conditions/condition/@data" error:nil];
            if (condArray.count > 0) {
                GDataXMLElement *conditions = (GDataXMLElement *)[condArray objectAtIndex:i];
                dailyForecast.conditions = conditions.stringValue;
            }
                        // Add the dailyForecast to the forecastArray
            [weatherData.forecastArray addObject:dailyForecast];
            NSLog(@"ECHO!!! %@",[weatherData.forecastArray objectAtIndex:i]);
            
            //dailyForecast = nil; // adding to Array +retainCount, must call release to balance?
        }
        [dailyForecast release];
        
       //NSLog(@"DAILY FORECAST\n D:%@ C:%@ L:%i H:%i I:%@",dailyForecast.weekday, dailyForecast.conditions, dailyForecast.lowTemp, dailyForecast.highTemp, [[dailyForecast.iconURL substringFromIndex:19] stringByDeletingPathExtension]);
        
    }
    
    // FOR LOOP to construct 
    
     /*** TO READ AN ELEMENT FROM XML
     NSArray *tempArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather/" error:nil];
     if (tempArray.count > 0) {
     GDataXMLElement *tempy = (GDataXMLElement *)[tempArray objectAtIndex:0];
     weatherData.property = tempy.stringValue; //.intValue // retrieves INT
     }
     ***/
    
    NSLog(@"TEMP: %i  WX: %@  HUM: %@  WIND: %@",weatherData.currentTemp, weatherData.conditionsString, weatherData.humidityString, weatherData.windString);
    
    return weatherData;
}

+(WeatherDataModel *)loadWeatherDataForLocation:(NSString *)location {
    NSLog(@"loadWeatherDataForLocation :: %@",location);
    /*
    NSLog(@"NSUSERDEFAULT - %@",[[NSUserDefaults standardUserDefaults] stringForKey:@"UserLocation"]);
    // make API call...
    NSString *locationString = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserLocation"];
    locationString = [locationString stringByReplacingOccurrencesOfString:@" , " withString:@","];
    locationString = [locationString stringByReplacingOccurrencesOfString:@" ," withString:@","];
    locationString = [locationString stringByReplacingOccurrencesOfString:@", " withString:@","];
    locationString = [locationString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    //NSString *htmlSafeString = [locationString stringByReplacingOccurrencesOfString:@" " withString:@"%20"]; // make location HTML safe (whitespace = %20)
     */
    location = [location stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *weatherAPIURL = [NSString stringWithFormat:@"http://www.google.com/ig/api?weather=%@",location];
    
    NSMutableData *downloadedData = [[[NSMutableData alloc] initWithContentsOfURL:[NSURL URLWithString:weatherAPIURL]] autorelease];
    NSError *xmlError;
    GDataXMLDocument *xmlDoc = [GDataXMLDocument alloc];
    [xmlDoc setCharacterEncoding:@"ISO-8859-1"];
    [[xmlDoc initWithData:downloadedData options:0 error:&xmlError] autorelease];
    
    if (downloadedData == nil || xmlError != nil) {
        NSLog(@"Network Error! %@",xmlError.localizedDescription);
    }
    
    
    //NSLog(@"XMLDOC = %@ \nXMLERROR = %@",xmlDoc.rootElement ,xmlError.localizedDescription);
    NSLog(@"XML :: %@",[xmlDoc nodesForXPath:@"xml_api_reply/weather/current_conditions/condition/@data" error:nil]);
    
    // create a weather data model to hold info
    WeatherDataModel *weatherData = [[[WeatherDataModel alloc] init] autorelease];
    
    NSArray *conditionsArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather/current_conditions/condition/@data" error:nil];
    if (conditionsArray.count > 0) {
        GDataXMLElement *conditions = (GDataXMLElement *)[conditionsArray objectAtIndex:0];
        weatherData.conditionsString = conditions.stringValue; //.intValue; // retrieves INT
    }
    
    NSArray *imageArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather/current_conditions/icon/@data" error:nil];
    if (imageArray.count > 0) {
        GDataXMLElement *image = (GDataXMLElement *)[imageArray objectAtIndex:0];
        weatherData.imageString = [[image.stringValue substringFromIndex:19] stringByDeletingPathExtension]; //.intValue; // retrieves INT
    }
    
    NSArray *windArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather/current_conditions/wind_condition/@data" error:nil];
    if (windArray.count > 0) {
        GDataXMLElement *wind = (GDataXMLElement *)[windArray objectAtIndex:0];
        weatherData.windString = wind.stringValue; //.intValue; // retrieves INT
    }
    
    NSArray *humidityArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather/current_conditions/humidity/@data" error:nil];
    if (humidityArray.count > 0) {
        GDataXMLElement *humidity = (GDataXMLElement *)[humidityArray objectAtIndex:0];
        weatherData.humidityString = humidity.stringValue; //.intValue; // retrieves INT
    }
    
    NSArray *temperatureArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather/current_conditions/temp_f/@data" error:nil];
    if (temperatureArray.count > 0) {
        GDataXMLElement *temperature = (GDataXMLElement *)[temperatureArray objectAtIndex:0];
        weatherData.currentTemp = temperature.stringValue.intValue; // retrieves INT
    }
    
    NSArray *locationArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather/forecast_information/city/@data" error:nil];
    if (locationArray.count > 0) {
        GDataXMLElement *location = (GDataXMLElement *)[locationArray objectAtIndex:0];
        weatherData.locationString = location.stringValue;  //intValue; // retrieves INT
    }
    
    NSArray *postalCodeArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather/forecast_information/postal_code/@data" error:nil];
    if (postalCodeArray.count > 0) {
        GDataXMLElement *postalCode = (GDataXMLElement *)[postalCodeArray objectAtIndex:0];
        weatherData.postalCode = postalCode.stringValue;  //intValue; // retrieves INT
    }
    
    NSArray *forecastArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather//forecast_conditions" error:nil];
    if (forecastArray.count > 2) {
        NSLog(@"WOOOOOOOOOOOOOOOOOOOT!!!!!!!!!1!");
        
        
    }
    
    
    
    for (int i = 0; i < forecastArray.count; i++) {
        
        DailyForecastDataModel *dailyForecast = [[[DailyForecastDataModel alloc] init] autorelease];
        
        GDataXMLElement *oneDayForecast = (GDataXMLElement *)[forecastArray objectAtIndex:i];
        NSArray *singleDayArray = oneDayForecast.children;
        if (singleDayArray.count > 0) {
            NSLog(@"SDA :: %@",singleDayArray);
            
            GDataXMLElement *oneDayWeekday = (GDataXMLElement *)[singleDayArray objectAtIndex:0];
            NSArray *weekdayArray = [oneDayWeekday nodesForXPath:@"//day_of_week/@data" error:nil];
            if (weekdayArray.count > 0) {
                GDataXMLElement *weekday = (GDataXMLElement *)[weekdayArray objectAtIndex:i];
                dailyForecast.weekday = weekday.stringValue;
            }
            
            GDataXMLElement *oneDayLow = (GDataXMLElement *)[singleDayArray objectAtIndex:1];
            NSArray *lowArray = [oneDayLow nodesForXPath:@"//low/@data" error:nil];
            if (lowArray.count > 0) {
                GDataXMLElement *lowTemp = (GDataXMLElement *)[lowArray objectAtIndex:i];
                dailyForecast.lowTemp = lowTemp.stringValue.intValue;
            }
            
            GDataXMLElement *oneDayHigh = (GDataXMLElement *)[singleDayArray objectAtIndex:2];
            NSArray *highArray = [oneDayHigh nodesForXPath:@"//high/@data" error:nil];
            if (highArray.count > 0) {
                GDataXMLElement *highTemp = (GDataXMLElement *)[highArray objectAtIndex:i];
                dailyForecast.highTemp = highTemp.stringValue.intValue;
            }
            
            GDataXMLElement *oneDayIcon = (GDataXMLElement *)[singleDayArray objectAtIndex:3];
            NSArray *iconArray = [oneDayIcon nodesForXPath:@"//forecast_conditions/icon/@data" error:nil];
            if (iconArray.count > 0) {
                GDataXMLElement *icon = (GDataXMLElement *)[iconArray objectAtIndex:i];
                NSString *tempString = icon.stringValue;
                NSString *shortString = [[tempString substringFromIndex:19] stringByDeletingPathExtension];
                dailyForecast.iconURL = shortString;
            }
            
            GDataXMLElement *oneDayConditions = (GDataXMLElement *)[singleDayArray objectAtIndex:4];
            NSArray *condArray = [oneDayConditions nodesForXPath:@"//forecast_conditions/condition/@data" error:nil];
            if (condArray.count > 0) {
                GDataXMLElement *conditions = (GDataXMLElement *)[condArray objectAtIndex:i];
                dailyForecast.conditions = conditions.stringValue;
            }
            // Add the dailyForecast to the forecastArray
            [weatherData.forecastArray addObject:dailyForecast];
            NSLog(@"ECHO!!! %@",[weatherData.forecastArray objectAtIndex:i]);
            
            //dailyForecast = nil; // adding to Array +retainCount, must call release to balance?
        }
        [dailyForecast release];
        
        //NSLog(@"DAILY FORECAST\n D:%@ C:%@ L:%i H:%i I:%@",dailyForecast.weekday, dailyForecast.conditions, dailyForecast.lowTemp, dailyForecast.highTemp, [[dailyForecast.iconURL substringFromIndex:19] stringByDeletingPathExtension]);
        
    }
    
    // FOR LOOP to construct 
    
    /*** TO READ AN ELEMENT FROM XML
     NSArray *tempArray = [xmlDoc nodesForXPath:@"xml_api_reply/weather/" error:nil];
     if (tempArray.count > 0) {
     GDataXMLElement *tempy = (GDataXMLElement *)[tempArray objectAtIndex:0];
     weatherData.property = tempy.stringValue; //.intValue // retrieves INT
     }
     ***/
    
    NSLog(@"TEMP: %i  WX: %@  HUM: %@  WIND: %@",weatherData.currentTemp, weatherData.conditionsString, weatherData.humidityString, weatherData.windString);
    
    return weatherData;
}


@end
