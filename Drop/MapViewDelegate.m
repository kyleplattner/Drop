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
@end

@implementation MapViewDelegate

-(id)initWithMapView:(MKMapView*)mapView viewController:(UIViewController*)view {
    self = [super init];
    if (self) {
        _mapView = mapView;
        _view = view;
        _annotations = [[NSMutableArray alloc] initWithCapacity:100];
		_allPosts = [[NSMutableArray alloc] initWithCapacity:100];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPopover) name:@"DismissPopoverNotification" object:nil];
        [self startStandardUpdates];
        [self queryForAllPosts];
    }
    return self;
}

-(void)dealloc {
    [_locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.mapPinsPlaced = NO;
}

- (void)mapView:(MKMapView *)MapView didSelectAnnotationView:(MKAnnotationView *)view {
    _droppedPin = view.annotation;
    DroppedPinViewController *droppedPinView = [[DroppedPinViewController alloc]initWithNibName:@"DroppedPinViewController" mapView:self.mapView annotation:_droppedPin];
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
            view.pinColor = MKPinAnnotationColorGreen;
		}
		else {
			view.annotation = annotation;
		}
        Drop *drop = view.annotation;
        if([[drop username] isEqualToString:@""]) {
            PFQuery *query = [PFQuery queryWithClassName:kParsePostsClassKey];
            [query includeKey:kParseUserKey];
            PFObject *object = [query getObjectWithId:drop.object.objectId];
            PFUser *user = [object objectForKey:kParseUserKey];
            [object fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if ([[[PFUser currentUser] username] isEqualToString:[user username]]) {
                    view.pinColor = MKPinAnnotationColorGreen;
                } else {
                    view.pinColor = MKPinAnnotationColorRed;
                }
            }];
        } else {
            if ([[[PFUser currentUser] username] isEqualToString:[drop username]]) {
                view.pinColor = MKPinAnnotationColorGreen;
            } else {
                view.pinColor = MKPinAnnotationColorRed;
            }
        }
		view.animatesDrop = YES;
		return view;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for(MKPinAnnotationView *eachView in views) {
        NSLog(@"");
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
	PFQuery *query = [PFQuery queryWithClassName:kParsePostsClassKey];
	if ([self.allPosts count] == 0) {
		query.cachePolicy = kPFCachePolicyCacheThenNetwork;
	}
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (error) {
			NSLog(@"%@", [error localizedDescription]);
		} else {
			NSMutableArray *newPosts = [[NSMutableArray alloc] initWithCapacity:100];
			NSMutableArray *allNewPosts = [[NSMutableArray alloc] initWithCapacity:100];
			for (PFObject *object in objects) {
				Drop *drop = [[Drop alloc] initWithDrop:object];
                if ([drop canUserSeeDrop:drop]) {
                    [allNewPosts addObject:drop];
                } else {
                    NSLog(@"Denied Access");   
                }
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
			[_locationManager startUpdatingLocation];
			break;
		case kCLAuthorizationStatusDenied:
			NSLog(@"kCLAuthorizationStatusDenied");
        {{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Access Location" message:@"Drop can’t access your current location. Turn on access in the Settings app under Location Services." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alertView show];
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

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.currentLocation = newLocation;
}

@end
