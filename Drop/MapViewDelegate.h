//
//  MapViewDelegate.h
//  Drop
//
//  Created by Kyle Plattner on 5/1/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "DroppedPinModel.h"
#import "DropboxDelegate.h"
#import "Drop.h"

@interface MapViewDelegate : NSObject <MKMapViewDelegate, UIPopoverControllerDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak, readonly) MKMapView* mapView;
@property (nonatomic, weak, readonly) UIViewController* view;
@property (nonatomic, retain) UIPopoverController* popoverController;
@property (nonatomic, retain) DroppedPinModel* droppedPin;
//@property (nonatomic, retain) DropboxDelegate* dropBoxDelegate; 

- (id)initWithMapView:(MKMapView*)mapView viewController:(UIViewController*)view;
- (void)startStandardUpdates;
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
- (void)linkDropboxFileForDrop:(Drop*)drop;

@end
