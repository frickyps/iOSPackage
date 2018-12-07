//
//  FSTexrtActionCell.m
//  UploadApp
//
//  Created by 方世沛 on 2018/12/4.
//  Copyright © 2018 方世沛. All rights reserved.
//

#import "FSTexrtActionCell.h"

@implementation FSTexrtActionCell

- (NSRect)adjustedFrameToVerticallyCenterText:(NSRect)frame
{
    // super would normally draw text at the top of the cell
    NSInteger offset = floor((NSHeight(frame)/2 - ([[self font] ascender] + [[self font] descender])));
    return NSInsetRect(frame, 0.0, offset);
}
- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)editor delegate:(id)delegate event:(NSEvent *)event
{
    [super editWithFrame:[self adjustedFrameToVerticallyCenterText:aRect] inView:controlView editor:editor delegate:delegate event:event];
}
- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)editor delegate:(id)delegate start:(NSInteger)start length:(NSInteger)length
{
    [super selectWithFrame:[self adjustedFrameToVerticallyCenterText:aRect] inView:controlView editor:editor delegate:delegate start:start length:length];
}
- (void)drawInteriorWithFrame:(NSRect)frame inView:(NSView *)view
{
    [super drawInteriorWithFrame:
     [self adjustedFrameToVerticallyCenterText:frame] inView:view];
}
 

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
    if (_bgColor) {
        [_bgColor set];
        NSRectFill(cellFrame);
    }
    NSBezierPath *betterBounds = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:_radius?:15 yRadius:_radius?:15];
    [betterBounds addClip];
    if (self.isBezeled) {
        [betterBounds setLineWidth:2];
        [[NSColor whiteColor] setStroke];
        [[NSColor whiteColor] setFill];
        [betterBounds fill];
        [betterBounds stroke];
    }
    [super drawWithFrame:cellFrame inView:controlView];
}





@end
