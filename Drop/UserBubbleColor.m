//
//  UserBubbleColor.m
//  UserPicker
//
//  Created by Kyle Plattner on 5/27/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "UserBubbleColor.h"

@implementation UserBubbleColor

- (id)initWithGradientTop:(UIColor *)gradientTop gradientBottom:(UIColor *)gradientBottom border:(UIColor *)border {
    if (self = [super init]) {
        self.gradientTop = gradientTop;
        self.gradientBottom = gradientBottom;
        self.border = border;
    }
    return self;
}

@end
