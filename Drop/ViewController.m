//
//  ViewController.m
//  Drop
//
//  Created by Kyle Plattner on 4/28/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import "Drop.h"
#import "NPReachability.h"
#import "GIKPopoverBackgroundView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) UIViewController *searchView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) UIPopoverController *searchResultsPopover;
@property (nonatomic, retain) NSMutableArray *filteredDrops;
@property (nonatomic, retain) NSMutableArray *allDrops;
- (void)logInUser;
- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer;
- (void)setupMap;
- (void)setupSearchBar;
- (void)populateArrayForSearching;
- (void)loadSearchPopover;
- (void)selectAnnotation:(Drop*)annotation;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMap];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(populateArrayForSearching) name:@"ReloadAnnoationsNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logInUser) name:@"TryLoginNotification" object:nil];
    [self performSelector:@selector(logInUser) withObject:nil afterDelay:1];
    [self setupSearchBar];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(void)setupMap {
    _mapViewDelegate = [[MapViewDelegate alloc] initWithMapView:_mapView viewController:self];
    [_mapView setDelegate:_mapViewDelegate];
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [_mapView setMapType:MKMapTypeHybrid];
    [_mapView setShowsUserLocation:YES];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 2.0;
    [self.mapView addGestureRecognizer:longPress];
}

-(void)setupSearchBar {
    _filteredDrops = [[NSMutableArray alloc] initWithCapacity:100];
    _allDrops = [[NSMutableArray alloc] initWithCapacity:100];
    [self performSelector:@selector(populateArrayForSearching) withObject:nil afterDelay:2];
    [_searchBar setDelegate:self];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    _searchView = [[UIViewController alloc] init];
    [_searchView.view addSubview:_tableView];
    [_searchView setContentSizeForViewInPopover:CGSizeMake(300, 500)];
    [_searchBar setAlpha:0];
}

- (void)populateArrayForSearching {
    [_filteredDrops removeAllObjects];
    for (Drop *drop in _mapView.annotations) {
        if([drop isKindOfClass:[Drop class]]) {
            [_filteredDrops addObject:drop];
        }
    }
    [_tableView reloadData];
    _allDrops = _filteredDrops;
    if([_allDrops count] > 0) {
        [UIView animateWithDuration:.5 animations:^{
            [_logo setAlpha:0];
            [_searchBar setAlpha:1];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)logInUser {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
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
    [_mapView setCenterCoordinate:[drop coordinate] animated:YES];
    [self performSelector:@selector(selectAnnotation:) withObject:drop afterDelay:1.5];
    [_searchResultsPopover dismissPopoverAnimated:YES];
    _searchResultsPopover = nil;
    [_searchBar resignFirstResponder];
    [_searchBar setText:@""];
    [self populateArrayForSearching];
}

-(void)selectAnnotation:(Drop*)annotation {
    [_mapView selectAnnotation:annotation animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _filteredDrops.count;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0) {
        _filteredDrops = _allDrops;
        [_searchBar resignFirstResponder];
        [_searchResultsPopover dismissPopoverAnimated:YES];
        _searchResultsPopover = nil;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename contains[cd] %@ OR username contains[cd] %@", searchText, searchText];
        NSMutableArray *filtered = [NSMutableArray arrayWithArray:[_allDrops filteredArrayUsingPredicate:predicate]];
        _filteredDrops = filtered;
        [_tableView reloadData];
        if(!_searchResultsPopover) {
            [self loadSearchPopover];
        }
    }
}

-(void)loadSearchPopover {
    if ([_allDrops count] > 0) {
        _searchResultsPopover = [[UIPopoverController alloc] initWithContentViewController:_searchView];
        [_searchView.view setFrame:CGRectMake((self.view.frame.size.width / 2) - 386, 0, 200, 500)];
        [_tableView setFrame:_searchView.view.frame];
        [_searchResultsPopover setPopoverBackgroundViewClass:[GIKPopoverBackgroundView class]];
        [_searchResultsPopover setDelegate:self];
        [_searchResultsPopover presentPopoverFromRect:_searchBar.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    _searchResultsPopover = nil;
    [_searchBar resignFirstResponder];
    [_searchBar setText:@""];
}

@end
