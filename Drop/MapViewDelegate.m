//
//  MapViewDelegate.m
//  Drop
//
//  Created by Kyle Plattner on 5/1/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "MapViewDelegate.h"
#import "DroppedPinViewController.h"
#import "KioskDropboxPDFBrowserViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "Drop.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface MapViewDelegate ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL mapPinsPlaced;
@property (nonatomic, strong) NSMutableArray *allPosts;
@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, copy) NSString *className;
@end

@implementation MapViewDelegate

-(id)initWithMapView:(MKMapView*)mapView viewController:(UIViewController*)view {
    self = [super init];
    if (self) {
        _mapView = mapView;
        _view = view;
        _annotations = [[NSMutableArray alloc] initWithCapacity:100];
		_allPosts = [[NSMutableArray alloc] initWithCapacity:100];
        _className = kParsePostsClassKey;
        [self startStandardUpdates];
        [self queryForAllPosts];
    }
    return self;
}

-(void)dealloc {
    [_locationManager stopUpdatingLocation];
    self.mapPinsPlaced = NO;
}

- (void)mapView:(MKMapView *)MapView didSelectAnnotationView:(MKAnnotationView *)view {
    Drop *drop = view.annotation;
    DroppedPinViewController *droppedPinView = [[DroppedPinViewController alloc]initWithNibName:@"DroppedPinViewController" mapView:self.mapView annotation:(Drop*)view.annotation];
    if (self.popoverController == nil) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:droppedPinView];
        popover.delegate = self;
        self.popoverController = popover;
    } else {
        [_popoverController setContentViewController:droppedPinView animated:YES];
    }
    [_popoverController setPopoverContentSize:CGSizeMake(430, 400)];
    CGPoint annotationPoint = [self.mapView convertCoordinate:view.annotation.coordinate toPointToView:self.mapView];
    CGRect box = CGRectMake(annotationPoint.x, annotationPoint.y, 5, 5);
    [_popoverController presentPopoverFromRect:box inView:_mapView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
	}
    
	if ([annotation isKindOfClass:[Drop class]]) {
        static NSString* const kIdentifier = @"Annotation";
        MKPinAnnotationView* view = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:kIdentifier];
		if (!view) {
			view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kIdentifier];
		}
		else {
			view.annotation = annotation;
		}
        if ([[[PFUser currentUser] username] isEqualToString:[[PFUser currentUser] username]]) {
            view.pinColor = MKPinAnnotationColorGreen;
        } else {
            view.pinColor = MKPinAnnotationColorRed;
        }
		view.animatesDrop = YES;
		return view;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for(MKPinAnnotationView *eachView in views) {
        [eachView setAnimatesDrop:YES];
        [eachView setDraggable:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [_mapView deselectAnnotation:self.droppedPin animated:YES];
    _popoverController = nil;
}

- (void)linkDropboxFileForDrop:(Drop*)drop {
    DropboxDelegate* dropBoxDelegate = [[DropboxDelegate alloc] init];
    dropBoxDelegate.view = self.view;
    dropBoxDelegate.drop = drop;
    KioskDropboxPDFBrowserViewController *browser = [[KioskDropboxPDFBrowserViewController alloc] init];
    [browser setDelegate:dropBoxDelegate];
    UIStoryboard *iPhoneStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    UIStoryboard *iPadStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:[NSBundle mainBundle]];
    [KioskDropboxPDFBrowserViewController displayDropboxBrowserInPhoneStoryboard:iPhoneStoryboard displayDropboxBrowserInPadStoryboard:iPadStoryboard onView:_view withPresentationStyle:UIModalPresentationFormSheet withTransitionStyle:UIModalTransitionStyleFlipHorizontal withDelegate:dropBoxDelegate];
}

#pragma mark modal view controller delegate methods

-(void)dismissPopover {
    [_mapView deselectAnnotation:self.droppedPin animated:YES];
    [_popoverController dismissPopoverAnimated:YES];
}

#pragma mark - Fetch map pins

- (void)queryForAllPosts {
	PFQuery *query = [PFQuery queryWithClassName:_className];
	if ([self.allPosts count] == 0) {
		query.cachePolicy = kPFCachePolicyCacheThenNetwork;
	}
    
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//	PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:appDelegate.currentLocation.coordinate.latitude longitude:appDelegate.currentLocation.coordinate.longitude];
//	[query whereKey:kParseLocationKey nearGeoPoint:point withinMiles:9999];
//	[query includeKey:kParseUserKey];
    
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (error) {
			NSLog(@"%@", [error localizedDescription]); // todo why is this ever happening?
		} else {
			NSMutableArray *newPosts = [[NSMutableArray alloc] initWithCapacity:100];
			// (Cache the objects we make for the search in step 2:)
			NSMutableArray *allNewPosts = [[NSMutableArray alloc] initWithCapacity:100];
			for (PFObject *object in objects) {
				Drop *drop = [[Drop alloc] initWithDrop:object];
				[allNewPosts addObject:drop];
				BOOL found = NO;
				for (Drop *currentDrop in _allPosts) {
					if ([drop equalToDrop:currentDrop]) {
						found = YES;
					}
				}
				if (!found) {
					[newPosts addObject:drop];
				}
			}
            
			NSMutableArray *postsToRemove = [[NSMutableArray alloc] initWithCapacity:100];
			for (Drop *currentPost in _allPosts) {
				BOOL found = NO;
				for (Drop *allNewPost in allNewPosts) {
					if ([currentPost equalToDrop:allNewPost]) {
						found = YES;
					}
				}
				if (!found) {
					[postsToRemove addObject:currentPost];
				}
			}

			[_mapView removeAnnotations:postsToRemove];
			[_mapView addAnnotations:newPosts];
			[_allPosts addObjectsFromArray:newPosts];
			[_allPosts removeObjectsInArray:postsToRemove];
            
			self.mapPinsPlaced = YES;
		}
	}];
}

#pragma mark - CLLocationManagerDelegate methods and helpers

- (void)startStandardUpdates {
	if (nil == _locationManager) {
		_locationManager = [[CLLocationManager alloc] init];
	}
    
	_locationManager.delegate = self;
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
	// Set a movement threshold for new events.
	_locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    
	[_locationManager startUpdatingLocation];
    
	CLLocation *currentLocation = _locationManager.location;
	if (currentLocation) {
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		appDelegate.currentLocation = currentLocation;
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	switch (status) {
		case kCLAuthorizationStatusAuthorized:
			NSLog(@"kCLAuthorizationStatusAuthorized");
			// Re-enable the post button if it was disabled before.
			[_locationManager startUpdatingLocation];
			break;
		case kCLAuthorizationStatusDenied:
			NSLog(@"kCLAuthorizationStatusDenied");
        {{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"AnyWall can’t access your current location.\n\nTo view nearby posts or create a post at your current location, turn on access for AnyWall to your location in the Settings app under Location Services." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alertView show];
            // Disable the post button.
        }}
			break;
		case kCLAuthorizationStatusNotDetermined:
			NSLog(@"kCLAuthorizationStatusNotDetermined");
			break;
		case kCLAuthorizationStatusRestricted:
			NSLog(@"kCLAuthorizationStatusRestricted");
			break;
	}
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
	NSLog(@"%s", __PRETTY_FUNCTION__);
    
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.currentLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"Error: %@", [error description]);
    
	if (error.code == kCLErrorDenied) {
		[_locationManager stopUpdatingLocation];
	} else if (error.code == kCLErrorLocationUnknown) {
		// todo: retry?
		// set a timer for five seconds to cycle location, and if it fails again, bail and tell the user.
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
		                                                message:[error description]
		                                               delegate:nil
		                                      cancelButtonTitle:nil
		                                      otherButtonTitles:@"Ok", nil];
		[alert show];
	}
}


@end
