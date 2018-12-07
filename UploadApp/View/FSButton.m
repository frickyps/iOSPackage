//
//  FSButton.m
//  UploadApp
//
//  Created by 方世沛 on 2018/11/30.
//  Copyright © 2018 方世沛. All rights reserved.
//

#import "FSButton.h"

@implementation FSButton 

- (void)setBkColor:(NSColor *)bkColor {
    _bkColor = bkColor;
    [self setNeedsDisplay:YES];
}

- (void)setAttrbitute:(NSAttributedString *)attrbitute {
    _attrbitute = attrbitute;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [_bkColor setFill];
    NSRectFill(dirtyRect);
    if (self.attrbitute && self.attrbitute.string.length) {
        CGFloat width = [self.attrbitute.string boundingRectWithSize:NSMakeSize(self.frame.size.width,
                                                                            20)
                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      attributes:@{NSFontNameAttribute:[NSFont systemFontOfSize:14]}].size.width;
        CGFloat x = (self.frame.size.width - width) / 2; 
        [self.attrbitute drawInRect:CGRectMake(x, ((self.frame.size.height/2) - 7), self.frame.size.width, self.frame.size.height)];
    } 
}

@end
