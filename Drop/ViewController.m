//
//  ViewController.m
//  Drop
//
//  Created by Kyle Plattner on 4/28/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "ViewController.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import <Parse/Parse.h>
#import "Drop.h"
#import "NPReachability.h"
#import "GIKPopoverBackgroundView.h"
#import "SettingsViewController.h"

@interface ViewController ()
@property (nonatomic, retain) SettingsViewController *settingsViewController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchController;
@property (nonatomic, retain) NSMutableArray *filteredDrops;
@property (nonatomic, retain) NSMutableArray *allDrops;
- (IBAction)settingsButtonPressed:(id)sender;
- (void)logInUser;
- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer;
- (void)populateArrayForSearching;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mapViewDelegate = [[MapViewDelegate alloc] initWithMapView:_mapView viewController:self];
    [_mapView setDelegate:_mapViewDelegate];
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [_mapView setMapType:MKMapTypeHybrid];
    [_mapView setShowsUserLocation:YES];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 2.0;
    [self.mapView addGestureRecognizer:longPress];
    _filteredDrops = [[NSMutableArray alloc] initWithCapacity:100];
    _allDrops = [[NSMutableArray alloc] initWithCapacity:100];
    [self performSelector:@selector(logInUser) withObject:nil afterDelay:1];
    [self performSelector:@selector(populateArrayForSearching) withObject:nil afterDelay:2];
    [_searchBar setDelegate:self];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)populateArrayForSearching {
    [_filteredDrops removeAllObjects];
    for (Drop *drop in _mapView.annotations) {
        [_filteredDrops addObject:drop];
    }
    _allDrops = _filteredDrops;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)settingsButtonPressed:(id)sender {
    _settingsViewController = [[SettingsViewController alloc] init];
    [_settingsViewController setViewController:self];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Log Out" message:nil delegate:_settingsViewController cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log out of Drop", @"Log out of Dropbox", nil];
    [alertView show];
}

- (void)logInUser {
    PFUser *currentUser = [PFUser currentUser];
	if (currentUser) {
        if (![[DBSession sharedSession] isLinked]) {
            [[DBSession sharedSession] linkFromController:self];
        }
    } else {
        LogInViewController *loginViewController = [[LogInViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        loginViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton;
        loginViewController.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        [navController.navigationBar setHidden:YES];
        [navController setModalPresentationStyle:UIModalPresentationFormSheet];
        [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
        signUpViewController.delegate = self;
        signUpViewController.fields = PFSignUpFieldsDefault;
        loginViewController.signUpController = signUpViewController;
        [signUpViewController setModalPresentationStyle:UIModalPresentationFormSheet];
        [signUpViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:navController animated:YES completion:nil];
	}
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    if (![[NPReachability sharedInstance] isCurrentlyReachable]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Drop requires an internet connection to drop and share files. Please connect to the internet." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alertView show];
    } else {
        CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
        CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        Drop *drop = [[Drop alloc] initWithCoordinate:touchMapCoordinate];
        [self.mapView addAnnotation:drop];
        [_mapViewDelegate linkDropboxFileForDrop:drop];
    }
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
    [_mapViewDelegate queryForAllPosts];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    if (username && password && username.length && password.length) {
        return YES;
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out your username, password, and email address", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO;
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }
    
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the fields", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reusable"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reusable"];
    }
    
    Drop *drop = [_filteredDrops objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", drop.filename];
    cell.detailTextLabel.text = drop.username;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Drop *drop = [_filteredDrops objectAtIndex:indexPath.row];
    [_mapView selectAnnotation:drop animated:YES];
    [_searchBar resignFirstResponder];
    [_searchController setActive:NO animated:YES];
    [_searchBar setText:@""];
    [self populateArrayForSearching];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _filteredDrops.count;
}
 
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0) {
        _filteredDrops = _allDrops;
        [_searchBar resignFirstResponder];
        [_searchController setActive:NO animated:YES];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename contains[cd] %@ OR username contains[cd] %@", searchText, searchText];
        NSMutableArray *filtered = [NSMutableArray arrayWithArray:[_allDrops filteredArrayUsingPredicate:predicate]];
        _filteredDrops = filtered;
    }
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    [controller setSearchResultsTitle:@"Select a Drop"];
}

@end
