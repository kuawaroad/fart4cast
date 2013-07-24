//
//  ViewController.h
//  Fart4Cast2
//
//  Created by George Uno on 4/20/12.
//  Copyright (c) 2012 Kuawa Road Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionsViewController.h"

@interface ViewController : UIViewController <OptionsScreenDelegate, UIAccelerometerDelegate>
{
    //UILabel *_currentTempLabel;
    //UILabel *_currentConditionsLabel;
}

@property (nonatomic,retain) IBOutlet UILabel *timeLabel;
@property (nonatomic,retain) IBOutlet UILabel *monthLabel;
@property (nonatomic,retain) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UILabel *weekdayLabel;

@property (nonatomic,retain) IBOutlet UILabel *locationLabel;
@property (nonatomic,retain) IBOutlet UILabel *currentTempLabel;
@property (nonatomic,retain) IBOutlet UILabel *lowTempLabel;
@property (nonatomic,retain) IBOutlet UILabel *highTempLabel;
@property (nonatomic,retain) IBOutlet UILabel *currentConditionsLabel;
@property (nonatomic,retain) IBOutlet UIImageView *conditionsImageView;
@property (nonatomic,retain) IBOutlet UIImageView *sunOrMoonImageView;

@property (nonatomic,retain) IBOutlet UIImageView *day1ConditionImage;
@property (nonatomic,retain) IBOutlet UIImageView *day2ConditionImage;
@property (nonatomic,retain) IBOutlet UIImageView *day3ConditionImage;

@property (nonatomic,retain) IBOutlet UIImageView *day1SunImage;
@property (nonatomic,retain) IBOutlet UIImageView *day2SunImage;
@property (nonatomic,retain) IBOutlet UIImageView *day3SunImage;

@property (nonatomic,retain) IBOutlet UILabel *day1ConditionLabel;
@property (nonatomic,retain) IBOutlet UILabel *day2ConditionLabel;
@property (nonatomic,retain) IBOutlet UILabel *day3ConditionLabel;

@property (nonatomic,retain) IBOutlet UILabel *day1WeekdayLabel;
@property (nonatomic,retain) IBOutlet UILabel *day2WeekdayLabel;
@property (nonatomic,retain) IBOutlet UILabel *day3WeekdayLabel;

@property (nonatomic,retain) IBOutlet UILabel *day1HighLabel;
@property (nonatomic,retain) IBOutlet UILabel *day2HighLabel;
@property (nonatomic,retain) IBOutlet UILabel *day3HighLabel;

@property (nonatomic,retain) IBOutlet UILabel *day1LowLabel;
@property (nonatomic,retain) IBOutlet UILabel *day2LowLabel;
@property (nonatomic,retain) IBOutlet UILabel *day3LowLabel;

@property (nonatomic,retain) UIAcceleration *lastAcceleration;
@property (nonatomic,assign) BOOL shakeDetected;

- (IBAction)infoButtonTapped:(id)sender;
- (IBAction)soundButtonTapped:(id)sender;

@end
