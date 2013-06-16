//
//  MapViewDelegate.h
//  Drop
//
//  Created by Kyle Plattner on 5/1/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "DropboxDelegate.h"
#import "Drop.h"

@interface MapViewDelegate : NSObject <MKMapViewDelegate, UIPopoverControllerDelegate>

@property (nonatomic, weak, readonly) MKMapView* mapView;
@property (nonatomic, weak, readonly) UIViewController* view;
@property (nonatomic, retain) UIPopoverController* popoverController;
@property (nonatomic, retain) Drop* droppedPin;
@property (nonatomic, strong) NSMutableArray *allPosts;
@property (nonatomic, strong) NSMutableArray *annotations;

- (id)initWithMapView:(MKMapView*)mapView viewController:(UIViewController*)view;
- (void)queryForAllPosts;
- (void)linkDropboxFileForDrop:(Drop*)drop;

@end
