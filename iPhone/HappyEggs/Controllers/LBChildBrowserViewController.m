//
//  LBChildBrowserViewController.m
//  Lynchburg
//
//  Created by Max on 05.03.13.
//  Copyright (c) 2013 eKreative. All rights reserved.
//

#import "LBChildBrowserViewController.h"

@interface LBChildBrowserViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIWebView *currentWebPage;
@property (nonatomic, copy) NSString *currentURL;
@end

@implementation LBChildBrowserViewController

#pragma mark - Lazy instantiation
- (void)setCurrentURL:(NSString *)currentURL
{
    _currentURL = currentURL;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.trackedViewName = CHILD_BROWSER;
    [self loadWebview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action methods

- (IBAction)doneClick:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)refreshScreen:(UIBarButtonItem *)sender
{
    [self loadWebview];
}

- (IBAction)openURLOnSafari:(UIBarButtonItem *)sender
{
    NSURL *url = [NSURL URLWithString:_currentURL];
    if ( [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:UNSUPORTED_SCHEME_ERROR delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - Webview methods
- (void)loadWebview
{
    self.spinner.hidden = NO;
    [_spinner startAnimating];
    NSURL *url = [NSURL URLWithString:_currentURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.currentWebPage.delegate = self;
    self.currentWebPage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.currentWebPage.scalesPageToFit = YES;
    [self.currentWebPage loadRequest:request];    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.spinner.hidden = YES;
    [self.spinner stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.spinner.hidden = YES;
    [self.spinner stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:WEBVIEW_LOADING_ERROR delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

@end
