//
//  DroppedPinViewController.m
//  Drop
//
//  Created by Kyle Plattner on 5/1/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "DroppedPinViewController.h"
#import "DroppedPinModel.h"

@interface DroppedPinViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
-(NSString *)findFiles;
@end

@implementation DroppedPinViewController

-(id)initWithNibName:(NSString *)nibName mapView:(MKMapView *)mapView annotation:(DroppedPinModel*)droppedPin {
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        _mapView = mapView;
        _droppedPin = droppedPin;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_label setText:[self findFiles]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)findFiles {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory  error:nil];
    
    NSLog(@"files array %@", filePathsArray);
    
    return [NSString stringWithFormat:@"%@", filePathsArray];
}

@end
