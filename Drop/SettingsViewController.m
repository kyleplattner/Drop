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

@property (nonatomic, weak, readonly) ViewController *viewController;
@property (weak, nonatomic) IBOutlet BButton *dropBoxButton;

- (IBAction)setupButtonPressed:(id)sender;
- (IBAction)logOutButtonPressed:(id)sender;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupDelegate:) name:@"TransferDelegateNotification" object:nil];
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
    [PFUser logOut];
    LogInViewController *loginViewController = [[LogInViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton;
    loginViewController.delegate = _viewController;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [navController.navigationBar setHidden:YES];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
    signUpViewController.delegate = _viewController;
    signUpViewController.fields = PFSignUpFieldsDefault;
    loginViewController.signUpController = signUpViewController;
    [signUpViewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [signUpViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:navController animated:YES completion:nil];
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

@end
