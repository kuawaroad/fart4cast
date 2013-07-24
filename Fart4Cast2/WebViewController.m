//
//  WebViewController.m
//  Fart4Cast2
//
//  Created by Lion on 5/11/12.
//  Copyright (c) 2012 Kuawa Road Productions. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize urlString;
@synthesize webView;
@synthesize activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSURL *destination = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:destination cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:20.0];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
}

- (void)viewDidUnload
{
    self.webView.delegate = nil;
    [self setWebView:nil];
    [self setActivityIndicator:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    self.webView.delegate = nil;
    [webView release];
    [activityIndicator release];
    [super dealloc];
}
- (IBAction)closeTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Network Error!" message:[NSString stringWithFormat:@"An error occured while attempting to connect to the internet.  Please check your connection and try again. Error:%@",error.localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [alertView show];
}


@end
