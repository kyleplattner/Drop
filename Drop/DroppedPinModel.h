//
//  DroppedPinModel.h
//  Drop
//
//  Created by Kyle Plattner on 5/1/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//
 
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol MapAnnotationDelegate <NSObject>
-(MKAnnotationView *)mapView:(MKMapView *)MapView viewForAnnotation:(id <MKAnnotation>)annotation;
@optional
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
@end

@interface DroppedPinModel : NSObject <MKAnnotation, MapAnnotationDelegate>
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;
- (id)initWithLocation:(CLLocationCoordinate2D)coordinate;
@end
