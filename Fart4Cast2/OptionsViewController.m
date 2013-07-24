//
//  OptionsViewController.m
//  Fart4Cast2
//
//  Created by George Uno on 4/24/12.
//  Copyright (c) 2012 Kuawa Road Productions. All rights reserved.
//

#import "OptionsViewController.h"
#import "WeatherReader.h"
#import "WeatherDataModel.h"
#import "WebViewController.h"
#import <AudioToolbox/AudioServices.h>


#define kFacebookURL @"https://www.facebook.com/pages/99Pirates/439207346108545?ref=ts"
#define kTwitterURL @"http://www.twitter.com/99pirates"
#define kContactURL @"http://www.99pirates.com/contactus"

@interface OptionsViewController ()
-(void)loadLowBeep;
-(void)loadHighBeep;
-(void)unloadSoundEffects;
-(void)playHighBeep;
-(void)playLowBeep;
@end

@implementation OptionsViewController {
    //iVars
    SystemSoundID highBeep;
    SystemSoundID lowBeep;
}


@synthesize unitsSwitch;
@synthesize soundFXSwitch;
@synthesize fahrenheitSwitch;
@synthesize locationTextField;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor purpleColor];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set initial values from NSUserDefaults...
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.locationTextField.text = [defaults stringForKey:@"UserLocation"];
    self.locationTextField.delegate = self;
    self.soundFXSwitch.on = [defaults boolForKey:@"PlaySFX"];
    self.fahrenheitSwitch.on = [defaults boolForKey:@"UnitsOfMeasure"];
    
    [self loadHighBeep];
    [self loadLowBeep];
    
}

- (void)viewDidUnload
{
    [self setSoundFXSwitch:nil];
    [self setUnitsSwitch:nil];
    [self setFahrenheitSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancelTapped:(id)sender {
    [self playLowBeep];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveTapped:(id)sender {

    [self playHighBeep];
    
    //AlertView variables
    NSString *title = @"";
    NSString *message = @"";
    NSString *cancelButtonTitle = @"";
    NSString *otherButtonTitle = @"";
    // check for differences between entries & defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userLocation = [defaults stringForKey:@"UserLocation"];
    BOOL locationChanged = ![self.locationTextField.text isEqualToString:userLocation];
    BOOL playSFXChanged = (self.soundFXSwitch.on != [defaults boolForKey:@"PlaySFX"]);
    BOOL unitsChanged = (self.fahrenheitSwitch.on != [defaults boolForKey:@"UnitsOfMeasure"]);
    NSString *sfxBOOL;
    NSString *fahrenheitBOOL;
    if (self.soundFXSwitch.on) {
        sfxBOOL = @"YES";
    } else {
        sfxBOOL = @"NO";
    }
    if (self.fahrenheitSwitch.on) {
        fahrenheitBOOL = @"YES";
    } else {
        fahrenheitBOOL = @"NO";
    }
    
    if (locationChanged || playSFXChanged || unitsChanged) {
        title = @"Change Settings?";
        message = [NSString stringWithFormat:@"Are you sure you want to change your settings?\nLocation:%@\nPlay SFX: %@\nFahrenheit: %@",self.locationTextField.text,sfxBOOL,fahrenheitBOOL];
        cancelButtonTitle = @"NO";
        otherButtonTitle = @"YES";
        
        if ([WeatherReader isValidLocation:self.locationTextField.text] == YES && self.locationTextField.text.length > 1) {
            // VALID xml data, save to user defaults and dismiss view
            NSLog(@"Valid Data For Location Found");
            
        } else {
            // bad XML data, show alertview make textfield first responder again
            NSLog(@"BAD DATA, LOCATION NOT VALID!");
            title = @"Invalid Location";
            message = [NSString stringWithFormat:@"No data was found for \"%@\" please check your location & internet connection and try again.",self.locationTextField.text];
            cancelButtonTitle = @"OK";
            otherButtonTitle = nil;
            self.locationTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserLocation"];
        }
        
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle,nil] autorelease];
        [alertView show];
    } else {
        // text entered = UserLocation && switch.on == PlaySFX
        NSLog(@"NOTHING CHANGED, CANCELLING");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    // old IF ELSE logic
    /*
    // if either value has changed...
    if ( locationChanged || playSFXChanged) {
        // if SFXChanged - prompt to save SFX changes
        if (playSFXChanged && !locationChanged) {
            // JUST SFX CHANGED!
            if (soundFXSwitch.on) {
                // PLAY SFX
                title = @"Change Settings?";
                message = @"You've turned on Fart4Cast's sound effects, now even rainy days will make you laugh.";
                cancelButtonTitle = @"NO";
                otherButtonTitle = @"YES";
            } else {
                // MUTE SFX
                title = @"Change Settings?";
                message = @"Are you sure you want to mute the sound effects of Fart4Cast?  The rich reverberations can brighten almost anyone's day.";
                cancelButtonTitle = @"NO";
                otherButtonTitle = @"YES";
            }
        } else if (locationChanged && !playSFXChanged) {
            // JUST LOCATION CHANGED!
            title = @"Change Settings?";
            message = [NSString stringWithFormat:@"Location:%@\nPlay SFX:%@\nFahrenheit:%@",self.locationTextField.text,self.soundFXSwitch.on,self.fahrenheitSwitch.on];
            cancelButtonTitle = @"NO";
            otherButtonTitle = @"YES";
        } else if (locationChanged && playSFXChanged) {
            // BOTH CHANGED
            NSLog(@"BOTH CHANGED!");
            title = @"Change Settings?";
            message = [NSString stringWithFormat:@"Location:%@\nPlay SFX:%@\nFahrenheit:%@",self.locationTextField.text,self.soundFXSwitch.on,self.fahrenheitSwitch.on];
            cancelButtonTitle = @"NO";
            otherButtonTitle = @"YES";
        } else {
            NSLog(@"MULTIPLE CHANGES!");
            title = @"Confirm Changes";
            message = [NSString stringWithFormat:@"Location:%@\nPlay SFX:%@\nFahrenheit:%@",self.locationTextField.text,self.soundFXSwitch.on,self.fahrenheitSwitch.on];
            cancelButtonTitle = @"NO";
            otherButtonTitle = @"YES";
            
        }*/
        
    // else the text must have changed, so prompt to change location instead...
        
    
    
    
}

- (IBAction)facebookTapped:(id)sender 
{
        // show webview with our facebook page
    [self playHighBeep];
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        WebViewController *webView = [[[WebViewController alloc] initWithNibName:@"WebViewController_iPhone" bundle:nil] autorelease];
        webView.urlString = kFacebookURL;
        [self presentViewController:webView animated:YES completion:nil];
    } else {
        WebViewController *webView = [[[WebViewController alloc] initWithNibName:@"WebViewController_iPad" bundle:nil]autorelease];
        [self presentViewController:webView animated:YES completion:nil];
    }
}

- (IBAction)twitterTapped:(id)sender 
{
        // launch twitter app in iOS or webview with twitter feed
    [self playHighBeep];
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        WebViewController *webView = [[[WebViewController alloc] initWithNibName:@"WebViewController_iPhone" bundle:nil] autorelease];
        webView.urlString = kTwitterURL;
        [self presentViewController:webView animated:YES completion:nil];
    } else {
        WebViewController *webView = [[[WebViewController alloc] initWithNibName:@"WebViewController_iPad" bundle:nil]autorelease];
        [self presentViewController:webView animated:YES completion:nil];
    }
}

- (IBAction)mailButtonTapped:(id)sender {
    [self playLowBeep];
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        WebViewController *webView = [[[WebViewController alloc] initWithNibName:@"WebViewController_iPhone" bundle:nil] autorelease];
        webView.urlString = kContactURL;
        [self presentViewController:webView animated:YES completion:nil];
    } else {
        WebViewController *webView = [[[WebViewController alloc] initWithNibName:@"WebViewController_iPad" bundle:nil]autorelease];
        [self presentViewController:webView animated:YES completion:nil];
    }
}


#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Returns pointer to alertView & #index of button pressed (starts at 0 cause its an array)
    if ([alertView.title isEqualToString:@"Change Settings?"]) {
        if (buttonIndex == 0) {
            // NO CLICKED
            NSLog(@"BUTTON INDEX = 0");
            [self.locationTextField becomeFirstResponder];
        } else if (buttonIndex == 1) {
            // YES CLICKED
            NSLog(@"BUTTON INDEX = 1");
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:self.locationTextField.text forKey:@"UserLocation"];
            [defaults setBool:self.soundFXSwitch.on forKey:@"PlaySFX"];
            [defaults setBool:self.fahrenheitSwitch.on forKey:@"UnitsOfMeasure"];
            [defaults synchronize];
            [delegate optionsScreenDidSaveChanges];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else if ([alertView.title isEqualToString:@"Invalid Location"]) {
        self.locationTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserLocation"];
        self.soundFXSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"PlaySFX"];
    }
    
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    // return pressed
    NSLog(@"RETURN PRESSED ON KEYBOARD");
    [self saveTapped:textField];
    return YES;
}

#pragma mark - Sound Effect

-(void)loadLowBeep {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"lowBeep.mp3" ofType:nil];
    
    NSURL *fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
    if (fileURL == nil) {
        NSLog(@"!!!LOWBEEP.mp3 BAD PATH:%@",path);
        return;
    }
    OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &lowBeep);
    if (error != kAudioServicesNoError) {
        NSLog(@"!!! SOUND ERROR:%ld AT:%@",error,path);
        return;
    }
}

-(void)loadHighBeep {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"highBeep.mp3" ofType:nil];
    
    NSURL *fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
    if (fileURL == nil) {
        NSLog(@"!!! HIGHBEEP.mp3 BAD PATH:%@",path);
        return;
    }
    OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &highBeep);
    if (error != kAudioServicesNoError) {
        NSLog(@"!!! SOUND ERROR:%ld AT:%@",error,path);
        return;
    }
}

-(void)unloadSoundEffects 
{
    AudioServicesDisposeSystemSoundID(highBeep);
    highBeep = 0;
    AudioServicesDisposeSystemSoundID(lowBeep);
    lowBeep = 0;
}

-(void)playHighBeep
{
    AudioServicesPlaySystemSound(highBeep);
}

-(void)playLowBeep
{
    AudioServicesPlaySystemSound(lowBeep);
}


- (void)dealloc {
    [soundFXSwitch release];
    [unitsSwitch release];
    [locationTextField release];
    [fahrenheitSwitch release];
    [super dealloc];
}

@end
