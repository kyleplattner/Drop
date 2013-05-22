//
//  LogInViewController.m
//  Drop
//
//  Created by Kyle Plattner on 5/9/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.

#import "LogInViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LogInViewController ()
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"loginBkg.png"]]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]]];
    _fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginFieldsBkg.png"]];
    [self.logInView addSubview:self.fieldsBackground];
    [self.logInView sendSubviewToBack:self.fieldsBackground];
    [self.logInView.signUpLabel setHidden:YES];
    [self.logInView.usernameField setTextColor:[UIColor colorWithRed:0.200 green:0.196 blue:0.188 alpha:1.000]];
    [self.logInView.passwordField setTextColor:[UIColor colorWithRed:0.200 green:0.196 blue:0.188 alpha:1.000]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.logInView.logo setFrame:CGRectMake(66.0f, 70.0f, 400.0f, 180.0f)];
    [self.logInView.usernameField setFrame:CGRectMake(140.0f, 290.0f, 250.0f, 50.0f)];
    [self.logInView.passwordField setFrame:CGRectMake(140.0f, 340.0f, 250.0f, 50.0f)];
    [self.fieldsBackground setFrame:CGRectMake(140.0f, 288.0f, 255.0f, 100.0f)];
    [self.logInView.logInButton setFrame:CGRectMake(272.0f, 420.0f, 108.0f, 40.0f)];
    [self.logInView.signUpButton setFrame:CGRectMake(152.0f, 420.0f, 108.0f, 40.0f)];
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"registerButton.png"] forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"loginButton.png"] forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"registerButton.png"] forState:UIControlStateHighlighted];
    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"loginButton.png"] forState:UIControlStateHighlighted];
    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.logInButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateHighlighted];
    [self.logInView.logInButton setTitle:@"" forState:UIControlStateHighlighted];
    [self.logInView.signUpButton setShowsTouchWhenHighlighted:YES];
    [self.logInView.logInButton setShowsTouchWhenHighlighted:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
