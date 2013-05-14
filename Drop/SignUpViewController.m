//
//  SignUpViewController.m
//  Drop
//
//  Created by Kyle Plattner on 5/9/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SignUpViewController ()
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation SignUpViewController

@synthesize fieldsBackground;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"loginBkg.png"]]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]]];
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"registerPageButton.png"] forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"registerPageButton.png"] forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton setShowsTouchWhenHighlighted:YES];
    [self.signUpView.signUpButton setTitle:@"" forState:UIControlStateNormal];
    [self.signUpView.signUpButton setTitle:@"" forState:UIControlStateHighlighted];
    [self setFieldsBackground:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"registerFieldsBkg.png"]]];
    [self.signUpView insertSubview:fieldsBackground atIndex:1];
    [self.signUpView.usernameField setTextColor:[UIColor colorWithRed:0.200 green:0.196 blue:0.188 alpha:1.000]];
    [self.signUpView.passwordField setTextColor:[UIColor colorWithRed:0.200 green:0.196 blue:0.188 alpha:1.000]];
    [self.signUpView.emailField setTextColor:[UIColor colorWithRed:0.200 green:0.196 blue:0.188 alpha:1.000]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.signUpView.usernameField setFrame:CGRectMake(140.0f, 263.0f, 250.0f, 50.0f)];
    [self.signUpView.passwordField setFrame:CGRectMake(140.0f, 313.0f, 250.0f, 50.0f)];
    [self.signUpView.emailField setFrame:CGRectMake(140.0f, 363.0f, 250.0f, 50.0f)];
    [self.signUpView.dismissButton setFrame:CGRectMake(475.0f, 0.0f, 87.5f, 45.5f)];
    [self.signUpView.logo setFrame:CGRectMake(66.5f, 70.0f, 400.0f, 180.5f)];
    [self.signUpView.signUpButton setFrame:CGRectMake(210.0f, 435.0f, 108.0f, 40.0f)];
    [self.fieldsBackground setFrame:CGRectMake(140.0f, 260.0f, 250.0f, 150.0f)];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
