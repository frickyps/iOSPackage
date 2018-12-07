//
//  FSView.m
//  UploadApp
//
//  Created by 方世沛 on 2018/11/30.
//  Copyright © 2018 方世沛. All rights reserved.
//

#import "FSView.h"

@implementation FSView

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [_backgroundColor setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
