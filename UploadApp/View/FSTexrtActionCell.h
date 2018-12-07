//
//  FSTexrtActionCell.h
//  UploadApp
//
//  Created by 方世沛 on 2018/12/4.
//  Copyright © 2018 方世沛. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTexrtActionCell : NSTextFieldCell
@property (nonatomic, strong) NSColor *bgColor;
@property (nonatomic, assign) CGFloat radius;
@end

NS_ASSUME_NONNULL_END
