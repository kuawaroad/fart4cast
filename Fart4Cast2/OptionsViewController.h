//
//  OptionsViewController.h
//  Fart4Cast2
//
//  Created by George Uno on 4/24/12.
//  Copyright (c) 2012 Kuawa Road Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

// DELEGATE PROTOCOL METHODS
@protocol OptionsScreenDelegate <NSObject>
-(void)optionsScreenDidSaveChanges;
@end

@interface OptionsViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>

- (IBAction)cancelTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;
- (IBAction)facebookTapped:(id)sender;
- (IBAction)twitterTapped:(id)sender;
- (IBAction)mailButtonTapped:(id)sender;

@property (retain, nonatomic) IBOutlet UISegmentedControl *unitsSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *soundFXSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *fahrenheitSwitch;

@property (retain, nonatomic) IBOutlet UITextField *locationTextField;
@property (nonatomic,strong) id <OptionsScreenDelegate> delegate;

@end
