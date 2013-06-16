//
//  SettingsViewController.m
//  Drop
//
//  Created by Kyle Plattner on 5/4/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "SettingsViewController.h"
#import "BButton.h"
#import <Parse/Parse.h>
#import "SignUpViewController.h"
#import "LogInViewController.h"

@interface SettingsViewController () {
    DBRestClient *restClient;
}

@property (weak, nonatomic) IBOutlet BButton *dropBoxButton;

- (IBAction)setupButtonPressed:(id)sender;
- (IBAction)logOutButtonPressed:(id)sender;
- (IBAction)unlinkDropboxButtonPressed:(id)sender;
- (void)setupDelegate:(NSNotification*)notification;

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupButtonPressed:) name:@"DropboxNotification" object:nil];
    if ([[DBSession sharedSession] isLinked]) {
        [_dropBoxButton setTitle:@"Browse Dropbox" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setupButtonPressed:(id)sender {
    if (![[DBSession sharedSession] isLinked]) {
        //Dropbox is not setup
        [[DBSession sharedSession] linkFromController:self];
        NSLog(@"Logging into Dropbox...");
        [_dropBoxButton setTitle:@"Browse Dropbox" forState:UIControlStateNormal];
    } else {
        KioskDropboxPDFBrowserViewController *browser = [[KioskDropboxPDFBrowserViewController alloc] init];
        [browser setDelegate:self];
        UIStoryboard *iPhoneStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
        UIStoryboard *iPadStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:[NSBundle mainBundle]];
        [KioskDropboxPDFBrowserViewController displayDropboxBrowserInPhoneStoryboard:iPhoneStoryboard
                                                displayDropboxBrowserInPadStoryboard:iPadStoryboard
                                                                              onView:self
                                                               withPresentationStyle:UIModalPresentationFormSheet
                                                                 withTransitionStyle:UIModalTransitionStyleFlipHorizontal
                                                                        withDelegate:self];
    }
}

- (IBAction)logOutButtonPressed:(id)sender {
    [self unlinkDropboxButtonPressed:nil];
    [PFUser logOut];
    [_viewController performSelector:@selector(logInUser) withObject:nil afterDelay:1];
}

- (IBAction)unlinkDropboxButtonPressed:(id)sender {
    [[DBSession sharedSession] unlinkAll];
    [[DBSession sharedSession] linkFromController:_viewController];
}

- (void)setupDelegate:(NSNotification*)notification {
    _viewController = [notification object];
}


- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)removeDropboxBrowser {
    //This is where you can handle the cancellation of selection, ect.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshLibrarySection {
    NSLog(@"Final Filename: %@", [KioskDropboxPDFRootViewController fileName]);
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        [self logOutButtonPressed:nil];
    }
}

@end
