//
//  WebViewController.h
//  Fart4Cast2
//
//  Created by Lion on 5/11/12.
//  Copyright (c) 2012 Kuawa Road Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic,strong) NSString *urlString;
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)closeTapped:(id)sender;
@end
