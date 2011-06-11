//
//  fullscreenAppDelegate.h
//  fullscreen
//
//  Created by Sebastian Volland on 28.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface fullscreenAppDelegate : NSObject <NSApplicationDelegate> {
@private
    BOOL isFullscreen;
    
    NSWindow *window;
    NSWindow *fullscreenWindow;
}

@property (assign) IBOutlet NSWindow *window;

- (CGDisplayModeRef) bestMatchForModeWithWidth: (int) width height:(int)height bpp:(int)bpp;
- (size_t) displayBitsPerPixelForMode: (CGDisplayModeRef) mode;

- (IBAction)toggleFullscreen:(id)sender;
- (BOOL)switchFull;
- (BOOL)switchWindow;

@end
