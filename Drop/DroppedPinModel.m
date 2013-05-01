//
//  DroppedPinModel.m
//  Drop
//
//  Created by Kyle Plattner on 5/1/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "DroppedPinModel.h"
#import "DroppedPinView.h"
#import <MapKit/MapKit.h>

@implementation DroppedPinModel

- (id)initWithLocation:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        [self setCoordinate:_coordinate];
    }
    return self;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString* const kIdentifier = @"ScoutingAnnotation";
    DroppedPinView* view = (DroppedPinView*)[mapView dequeueReusableAnnotationViewWithIdentifier:kIdentifier];
    if(view) {
        [view setAnnotation:annotation];
        view.canShowCallout = NO;
        view.animatesDrop = NO;
        view.draggable = YES;
        view.pinColor = MKPinAnnotationColorGreen;
    }
    return view;
}

@end
