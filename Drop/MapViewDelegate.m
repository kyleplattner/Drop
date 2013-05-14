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

@implementation MapViewDelegate

-(id)initWithMapView:(MKMapView*)mapView viewController:(UIViewController*)view {
    self = [super init];
    if (self) {
        _mapView = mapView;
        _view = view;
    }
    return self;
}

- (void)mapView:(MKMapView *)MapView didSelectAnnotationView:(MKAnnotationView *)view {
    DroppedPinViewController *droppedPinView = [[DroppedPinViewController alloc]initWithNibName:@"DroppedPinViewController" mapView:self.mapView annotation:(DroppedPinModel*)view.annotation];
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
    static NSString* const kIdentifier = @"Annotation";
    MKPinAnnotationView* view = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:kIdentifier];
    [view setAnnotation:annotation];
//    view.animatesDrop = YES;
//    view.draggable = YES;
//    view.pinColor = MKPinAnnotationColorGreen;
    return view;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    if (![[DBSession sharedSession] isLinked]) {
        //Dropbox is not setup
        [[DBSession sharedSession] linkFromController:_view];
    } else {
        _dropBoxDelegate = [[DropboxDelegate alloc] init];
        _dropBoxDelegate.view = self.view;
        KioskDropboxPDFBrowserViewController *browser = [[KioskDropboxPDFBrowserViewController alloc] init];
        [browser setDelegate:_dropBoxDelegate];
        UIStoryboard *iPhoneStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
        UIStoryboard *iPadStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:[NSBundle mainBundle]];
        [KioskDropboxPDFBrowserViewController displayDropboxBrowserInPhoneStoryboard:iPhoneStoryboard
                                                displayDropboxBrowserInPadStoryboard:iPadStoryboard
                                                                              onView:_view
                                                               withPresentationStyle:UIModalPresentationFormSheet
                                                                 withTransitionStyle:UIModalTransitionStyleFlipHorizontal
                                                                        withDelegate:_dropBoxDelegate];
    }
    for(MKPinAnnotationView *eachView in views) {
//        [eachView setAnimatesDrop:YES];
//        [eachView setDraggable:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [_mapView deselectAnnotation:self.droppedPin animated:YES];
    _popoverController = nil;
}

#pragma mark modal view controller delegate methods

-(void)dismissPopover {
    [_mapView deselectAnnotation:self.droppedPin animated:YES];
    [_popoverController dismissPopoverAnimated:YES];
}

@end
