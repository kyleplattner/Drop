//
//  PreviewController.h
//  FieldView
//
//  Created by Kyle Plattner on 5/13/13.
//  Copyright (c) 2013 Precision Planting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@interface PreviewController : QLPreviewController<QLPreviewControllerDataSource, QLPreviewControllerDelegate>
-(id)initWithItems:(NSInteger)items fileUrl:(NSURL*)fileUrl;
@end
