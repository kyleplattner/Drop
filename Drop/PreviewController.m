//
//  FVPreviewController.m
//  FieldView
//
//  Created by Kyle Plattner on 5/13/13.
//  Copyright (c) 2013 Precision Planting. All rights reserved.
//

#import "PreviewController.h"

@interface PreviewController ()
@property (assign, readonly) NSInteger items;
@property (strong, readonly) NSURL* fileUrl;
@end

@implementation PreviewController

-(id)initWithItems:(NSInteger)items fileUrl:(NSURL *)fileUrl {
    self = [super init];
    if (self) {
        _items = items;
        _fileUrl = fileUrl;
        [self setDataSource:self];
        [self setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark datasource methods

-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return _items;
}

-(id<QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return _fileUrl;
}
@end
