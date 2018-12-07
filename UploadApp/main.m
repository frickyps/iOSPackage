//
//  main.m
//  UploadApp
//
//  Created by 方世沛 on 2018/11/30.
//  Copyright © 2018 方世沛. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    NSApplication *app = [NSApplication sharedApplication];
    id delegate = [[AppDelegate alloc] init];
    app.delegate=delegate;
    return NSApplicationMain(argc, argv);
}
