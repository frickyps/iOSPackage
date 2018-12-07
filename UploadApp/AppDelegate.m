//
//  AppDelegate.m
//  UploadApp
//
//  Created by 方世沛 on 2018/11/30.
//  Copyright © 2018 方世沛. All rights reserved.
//

#import "AppDelegate.h"
#import "FPBaseViewController.h" 


@interface AppDelegate ()
@property (nonatomic, strong) FPBaseViewController *baseViewController;

@property (nonatomic, strong) NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.baseViewController = [[FPBaseViewController alloc] init];
    NSUInteger style =  NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable;
    float w = 720;//[[NSScreen mainScreen] frame].size.width/2;
    float h = 500;//[[NSScreen mainScreen] frame].size.height/2;
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, w, h) styleMask:style backing:NSBackingStoreBuffered defer:YES];
//    self.window.backgroundColor = NSColor.redColor;
    self.window.title = @"自动化打包";
    [self.window makeKeyAndOrderFront:self];
    [self.window center];
    [self.window setContentViewController:self.baseViewController];
    
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
