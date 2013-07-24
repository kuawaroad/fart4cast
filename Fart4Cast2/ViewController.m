//
//  ViewController.m
//  Fart4Cast2
//
//  Created by George Uno on 4/20/12.
//  Copyright (c) 2012 Kuawa Road Productions. All rights reserved.
//

#import "ViewController.h"
#import "WeatherReader.h"
#import "WeatherDataModel.h"
#import "DailyForecastDataModel.h"
#import "OptionsViewController.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
// forward method declarations
-(void)loadSoundEffect:(NSString *)soundFileName;
-(void)unloadSoundEffect;
-(void)playSoundEffect;
@end

@implementation ViewController {
    // iVars
    WeatherDataModel *weatherData;
    SystemSoundID soundID;
    SystemSoundID beepID;
    BOOL sunUp;
}
@synthesize weekdayLabel;
@synthesize timeLabel, monthLabel, dateLabel, locationLabel, lowTempLabel, highTempLabel, conditionsImageView, sunOrMoonImageView, currentTempLabel, currentConditionsLabel, day1ConditionImage, day2ConditionImage, day3ConditionImage;

@synthesize day1ConditionLabel,day1LowLabel,day1HighLabel,day1WeekdayLabel, day1SunImage;
@synthesize day2ConditionLabel,day2LowLabel, day2HighLabel, day2WeekdayLabel, day2SunImage;
@synthesize day3ConditionLabel,day3LowLabel,day3HighLabel,day3WeekdayLabel, day3SunImage;

@synthesize lastAcceleration;
@synthesize shakeDetected;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)updateTimeAndDate {
    NSDate *rightNow = [NSDate dateWithTimeIntervalSinceNow:0]; //86400 = 24hr
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    [timeFormatter setDateStyle:NSDateFormatterNoStyle];
    
    NSDateFormatter *weekdayFormatter = [[NSDateFormatter alloc] init];
    [weekdayFormatter setTimeStyle:NSDateFormatterNoStyle];
    [weekdayFormatter setDateStyle:NSDateFormatterFullStyle];
    NSString *fullDateString = [weekdayFormatter stringFromDate:rightNow];
    NSString *dayOfWeekString = [fullDateString substringToIndex:[fullDateString rangeOfString:@","].location];
    NSLog(@"Weekday::%@",dayOfWeekString);
    self.weekdayLabel.text = dayOfWeekString;
        //NSLog(@"***TIME STRING ::: %@||%@",[dateFormatter stringFromDate:rightNow],[timeFormatter stringFromDate:rightNow]);
    
    self.timeLabel.font = [UIFont fontWithName:@"Crystal" size:28.0];
    self.timeLabel.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:.9];
    self.timeLabel.text = [timeFormatter stringFromDate:rightNow];
    
    NSString *tempDateString = [dateFormatter stringFromDate:rightNow];
    
    int dateLength = 0;
    // check the 5th character of APR_27,_2012 - it's either a # or , (single digit day)
    NSString *fifthCharacter = [NSString stringWithFormat:@"%c",[tempDateString characterAtIndex:5]];
    if ([fifthCharacter isEqualToString:@","]) {
        // Single digit date...
        dateLength = 1;
    } else {
        dateLength = 2;
    }
    
    NSRange monthRange = NSMakeRange(0, 3);
    NSRange dateRange = NSMakeRange(4, dateLength);
    self.monthLabel.text = [[fullDateString substringWithRange:monthRange] capitalizedString];
    self.dateLabel.text = [tempDateString substringWithRange:dateRange];
    
    NSMutableString *timeString = [NSMutableString stringWithFormat:@"%@",[timeFormatter stringFromDate:rightNow]];
    if (timeString.length < 8) { // if the string is 6 characters (single digit time)
        [timeString insertString:@"0" atIndex:0]; // add a 0
        NSLog(@"Ammended String :: %@",timeString);
    }
    
    if (timeString.length == 8) {
        // string is 7 chars, ready for scanning
        // if char @ index == A
        NSLog(@"String Length = %i",timeString.length);
        NSLog(@"Charcter @ Index = %c",[timeString characterAtIndex:6]);
        int hourTime = [[timeString substringToIndex:2] intValue];
        
        if ([timeString characterAtIndex:6] == 'A') {
            NSLog(@"*** AM TIME ***");
            if (hourTime == 12 || hourTime <= 4) {
                // morning 12-459am
                self.sunOrMoonImageView.image = [UIImage imageNamed:@"moon.png"];
                sunUp = NO;
            } else {
                // morning 5-1159am
                self.sunOrMoonImageView.image = [UIImage imageNamed:@"sun.png"];
                sunUp = YES;
            }
        } else {
            // PM Time
            NSLog(@"*** PM TIME *** %i",hourTime);
            if (hourTime == 12 || hourTime <= 6) {
                // sun 12-659pm
                self.sunOrMoonImageView.image = [UIImage imageNamed:@"sun.png"];
                sunUp = YES;
            } else {
                // moon 7-1159pm
                self.sunOrMoonImageView.image = [UIImage imageNamed:@"moon.png"];
                sunUp = NO;
            }
        }
        
    } else {
        NSLog(@"TIME STRING TOO SHORT!");
    }
    
    
}

-(void)getDataAndUpdateUI
{
    NSLog(@"Updating UI");
    weatherData = [WeatherReader loadWeatherData];
    if (weatherData != NULL) {
        [weatherData retain];
        
        self.currentConditionsLabel.text = weatherData.conditionsString;
        self.locationLabel.text = weatherData.locationString;
        self.conditionsImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",weatherData.imageString]];

            // load sound effect randomly from SoundFX.plist array
        NSString *soundPlistPath = [[NSBundle mainBundle] pathForResource:@"SoundFX.plist" ofType:nil];
        NSDictionary *plistDictionary = [[[NSDictionary alloc] initWithContentsOfFile:soundPlistPath] autorelease];
        NSArray *soundFXArray = [[NSArray alloc] initWithArray:[plistDictionary objectForKey:@"Root"]];
        NSString *soundFile = [soundFXArray objectAtIndex:arc4random() % soundFXArray.count];
        [self loadSoundEffect:soundFile];
        
            // load beep sound effect
        [self loadHighBeep];
        
        DailyForecastDataModel *forecastModel0 = (DailyForecastDataModel *)[weatherData.forecastArray objectAtIndex:0];
        
        DailyForecastDataModel *forecastModel1 = (DailyForecastDataModel *)[weatherData.forecastArray objectAtIndex:1];
        self.day1ConditionImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",forecastModel1.iconURL]];
        self.day1ConditionLabel.text = forecastModel1.conditions;
        self.day1WeekdayLabel.text = forecastModel1.weekday;
        
        
        DailyForecastDataModel *forecastModel2 = (DailyForecastDataModel *)[weatherData.forecastArray objectAtIndex:2];
        self.day2ConditionImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",forecastModel2.iconURL]];
        self.day2ConditionLabel.text = forecastModel2.conditions;
        self.day2WeekdayLabel.text = forecastModel2.weekday;
        
        
        DailyForecastDataModel *forecastModel3 = (DailyForecastDataModel *)[weatherData.forecastArray objectAtIndex:3];
        self.day3ConditionImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",forecastModel3.iconURL]];
        self.day3ConditionLabel.text = forecastModel3.conditions;
        self.day3WeekdayLabel.text = forecastModel3.weekday;
        
        
        // FAHRENHEIT OR CELSIUS - true = F / false = C
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UnitsOfMeasure"] == TRUE) {
            // FAHRENHEIT
            self.currentTempLabel.text = [NSString stringWithFormat:@"%i˚f",weatherData.currentTemp];
            self.highTempLabel.text = [NSString stringWithFormat:@"%i",forecastModel0.highTemp];
            self.lowTempLabel.text = [NSString stringWithFormat:@"%i",forecastModel0.lowTemp]; // WAS @"%i˚F"
            self.day1HighLabel.text = [NSString stringWithFormat:@"%i",forecastModel1.highTemp];
            self.day1LowLabel.text = [NSString stringWithFormat:@"%i",forecastModel1.lowTemp];
            self.day2HighLabel.text = [NSString stringWithFormat:@"%i",forecastModel2.highTemp];
            self.day2LowLabel.text = [NSString stringWithFormat:@"%i",forecastModel2.lowTemp];
            self.day3HighLabel.text = [NSString stringWithFormat:@"%i",forecastModel3.highTemp];
            self.day3LowLabel.text = [NSString stringWithFormat:@"%i",forecastModel3.lowTemp];
        } else {
            self.currentTempLabel.text = [NSString stringWithFormat:@"%i˚c",weatherData.celsiusCurrent];
            self.highTempLabel.text = [NSString stringWithFormat:@"%i",forecastModel0.celsiusHigh];
            self.lowTempLabel.text = [NSString stringWithFormat:@"%i",forecastModel0.celsiusLow]; // WAS @"%i˚F"
            self.day1HighLabel.text = [NSString stringWithFormat:@"%i",forecastModel1.celsiusHigh];
            self.day1LowLabel.text = [NSString stringWithFormat:@"%i",forecastModel1.celsiusLow];
            self.day2HighLabel.text = [NSString stringWithFormat:@"%i",forecastModel2.celsiusHigh];
            self.day2LowLabel.text = [NSString stringWithFormat:@"%i",forecastModel2.celsiusLow];
            self.day3HighLabel.text = [NSString stringWithFormat:@"%i",forecastModel3.celsiusHigh];
            self.day3LowLabel.text = [NSString stringWithFormat:@"%i",forecastModel3.celsiusLow];
        }
        
        
        if (sunUp == YES) {
            day1SunImage.image = [UIImage imageNamed:@"sun.png"];
            day2SunImage.image = [UIImage imageNamed:@"sun.png"];
            day3SunImage.image = [UIImage imageNamed:@"sun.png"];
        } else {
            day1SunImage.image = [UIImage imageNamed:@"moon.png"];
            day2SunImage.image = [UIImage imageNamed:@"moon.png"];
            day3SunImage.image = [UIImage imageNamed:@"moon.png"];
        }
        
        NSLog(@"DISPLAYING WEATHER ICON: %@.png",weatherData.imageString);
        NSLog(@"SOUND PLAYED: %@",soundFile);
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PlaySFX"]) {
            [self playSoundEffect];
        }
        NSLog(@"FAHRENHEIT??? = %i",[[NSUserDefaults standardUserDefaults] boolForKey:@"UnitsOfMeasure"]);
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"UnitsOfMeasure"]) {
            // IF FAHRENHEIT != TRUE, set labels to metric
           
        }
        
    } // end if weather data != null
    else {
        NSLog(@"Weather Data == NULL");
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Data Retrieval Failed!" message:@"Weather data couldn't be downloaded because of a network error.  Please check your internet connection and location and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alertView show];
    }
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateTimeAndDate];
    
    [self getDataAndUpdateUI];
    
    [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(updateTimeAndDate) userInfo:nil repeats:YES];
    
}

#pragma mark - Sound Effect

-(void)loadSoundEffect:(NSString *)soundFileName {
    NSString *path = [[NSBundle mainBundle] pathForResource:soundFileName ofType:nil];
    
    NSURL *fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
    if (fileURL == nil) {
        NSLog(@"!!! BAD PATH:%@",path);
        return;
    }
    OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);
    if (error != kAudioServicesNoError) {
        NSLog(@"!!! SOUND ERROR:%ld AT:%@",error,path);
        return;
    }
}

-(void)unloadSoundEffect {
    AudioServicesDisposeSystemSoundID(soundID);
    soundID = 0;
}

-(void)playSoundEffect
{
    AudioServicesPlaySystemSound(soundID);
}


- (void)viewDidUnload
{
    [self setWeekdayLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self unloadSoundEffect];
    [self unloadHighBeep];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder]; // listen for shakes
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [self resignFirstResponder]; // stop listening for shakes
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait); // return YES if the interface is Portrait
    } else {
        return (UIInterfaceOrientationIsPortrait(interfaceOrientation));
    }
}

- (IBAction)infoButtonTapped:(id)sender {
    [self playHighBeep];
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        OptionsViewController *optionsView = [[[OptionsViewController alloc] initWithNibName:@"OptionsViewController_iPhone" bundle:nil] autorelease];
        optionsView.delegate = self;
        [self presentViewController:optionsView animated:YES completion:nil];
    } else {
        OptionsViewController *optionsView = [[[OptionsViewController alloc] initWithNibName:@"OptionsViewController_iPad" bundle:nil]autorelease];
        optionsView.delegate = self;
        [self presentViewController:optionsView animated:YES completion:nil];
    }
}

- (IBAction)soundButtonTapped:(id)sender {
    [self playRandomFart];
}

-(void)optionsScreenDidSaveChanges {
    [self getDataAndUpdateUI];
}

-(void)loadHighBeep {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"highBeep.mp3" ofType:nil];
    
    NSURL *fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
    if (fileURL == nil) {
        NSLog(@"!!! HIGHBEEP.mp3 BAD PATH:%@",path);
        return;
    }
    OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &beepID);
    if (error != kAudioServicesNoError) {
        NSLog(@"!!! SOUND ERROR:%ld AT:%@",error,path);
        return;
    }
}

-(void)unloadHighBeep 
{
    AudioServicesDisposeSystemSoundID(beepID);
    beepID = 0;
}

-(void)playHighBeep
{
    AudioServicesPlaySystemSound(beepID);
}

/*
@synthesize timeLabel, monthLabel, dateLabel, locationLabel, lowTempLabel, highTempLabel, conditionsImageView, backgroundImageView, currentTempLabel, currentConditionsLabel, day1ConditionImage, day2ConditionImage, day3ConditionImage;

@synthesize day1ConditionLabel,day1LowLabel,day1HighLabel,day1WeekdayLabel;
@synthesize day2ConditionLabel,day2LowLabel, day2HighLabel, day2WeekdayLabel;
@synthesize day3ConditionLabel,day3LowLabel,day3HighLabel,day3WeekdayLabel;*/

- (void)dealloc {
    [timeLabel release];
    [monthLabel release];
    [dateLabel release];
    [locationLabel release];
    [lowTempLabel release];
    [highTempLabel release];
    [conditionsImageView release];
    [sunOrMoonImageView release];
    [currentTempLabel release];
    [currentConditionsLabel  release];
    [day1ConditionImage release];
    [day1ConditionLabel release];
    [day1HighLabel release];
    [day1LowLabel release];
    [day1WeekdayLabel release];
    
    [day2ConditionImage release];
    [day2ConditionLabel release];
    [day2HighLabel release];
    [day2LowLabel release];
    [day2WeekdayLabel release];
    
    [day3ConditionImage release];
    [day3ConditionLabel release];
    [day3HighLabel release];
    [day3LowLabel release];
    [day3WeekdayLabel release];
    
    [weatherData release];
    
    [weekdayLabel release];
    [super dealloc];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void) accelerometer: (UIAccelerometer *)accelerometer didAccelerate: (UIAcceleration *)acceleration {
    if (self.lastAcceleration) {
        if (!shakeDetected && IsDeviceShaking(self.lastAcceleration, acceleration, 0.7)) {
            shakeDetected = YES;
            //SHAKE DETECTED. WRITE YOUR CODE HERE.
        } else if (shakeDetected && !IsDeviceShaking(self.lastAcceleration, acceleration, 0.2)) {
            shakeDetected = NO;
        }
    }
    self.lastAcceleration = acceleration; 
}

static BOOL IsDeviceShaking(UIAcceleration* last, UIAcceleration* current, double threshold) {
    double deltaX = fabs(last.x - current.x);
    double deltaY = fabs(last.y - current.y);
    double deltaZ = fabs(last.z - current.z);
    return (deltaX > threshold && deltaY > threshold) ||
    (deltaX > threshold && deltaZ > threshold) ||
    (deltaY > threshold && deltaZ > threshold);
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"{motion ended event ");
    
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"{shaken state ");
        //[self playSoundEffect];
        [self playRandomFart];
    }
    else {
        NSLog(@"{not shaken state ");           
    }
}

-(void)playRandomFart
{
    // load sound effect randomly from SoundFX.plist array
    NSString *soundPlistPath = [[NSBundle mainBundle] pathForResource:@"SoundFX.plist" ofType:nil];
    NSDictionary *plistDictionary = [[[NSDictionary alloc] initWithContentsOfFile:soundPlistPath] autorelease];
    NSArray *soundFXArray = [[NSArray alloc] initWithArray:[plistDictionary objectForKey:@"Root"]];
    NSString *soundFile = [soundFXArray objectAtIndex:arc4random() % soundFXArray.count];

    NSURL* soundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:soundFile ofType:nil]];
    
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    [player play];
    NSLog(@"Played Random Fart:%@",soundFile);
}


@end
