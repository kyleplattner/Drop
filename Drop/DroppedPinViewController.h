//
//  DroppedPinViewController.h
//  Drop
//
//  Created by Kyle Plattner on 5/1/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Drop.h"

@interface DroppedPinViewController : UIViewController

@property (nonatomic, retain) MKMapView* mapView;
@property (nonatomic,retain) Drop *droppedPin;

-(id)initWithNibName:(NSString *)nibName mapView:(MKMapView *)mapView annotation:(Drop*)droppedPin;

@end
