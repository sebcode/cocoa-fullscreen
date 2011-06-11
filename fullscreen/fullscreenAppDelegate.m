//
//  fullscreenAppDelegate.m
//  fullscreen
//
//  Created by Sebastian Volland on 28.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "fullscreenAppDelegate.h"
#import "FullscreenWindow.h"

@implementation fullscreenAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    isFullscreen = NO;
    
    [window center];
}

- (IBAction)toggleFullscreen:(id)sender
{
    if (isFullscreen) {
        [self switchWindow];
        isFullscreen = NO;
    } else {
        [self switchFull];
        isFullscreen = YES;
    }
}

- (BOOL)switchWindow
{
    CGRestorePermanentDisplayConfiguration();    
    CGReleaseAllDisplays();
    
    NSRect newFrame = [fullscreenWindow frameRectForContentRect:
                       [window contentRectForFrameRect:[window frame]]];
    
    [fullscreenWindow setFrame:newFrame display:YES animate:YES];
    
    NSView *contentView = [[[fullscreenWindow contentView] retain] autorelease];
    [fullscreenWindow setContentView:[[[NSView alloc] init] autorelease]];
    
    [window setContentView:contentView];
    [window makeKeyAndOrderFront:nil];
    
    [fullscreenWindow close];
    fullscreenWindow = nil;
    
    return YES;
}

- (BOOL)switchFull
{
    int width = 640;
    int height = 480;
    int bpp = 16;
    
    CGError err;
    CGDisplayConfigRef newConfig;
    
    CGDisplayModeRef displayMode = [self bestMatchForModeWithWidth:width height:height bpp:bpp];

    err = CGCaptureAllDisplays();
    if (err) {
        return NO;
    }
    
    err = CGBeginDisplayConfiguration(&newConfig);
    if (err) {
        return NO;
    }
    
    err = CGConfigureDisplayWithDisplayMode(newConfig, kCGDirectMainDisplay, displayMode, NULL);
    if (err) {
        return NO;
    }
    
    err = CGCompleteDisplayConfiguration(newConfig, kCGConfigureForAppOnly);
    if (err) {
        return NO;
    }
    
    [window orderOut:nil];
    
    NSRect rect = [window frame];
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size.width = width;
    rect.size.height = height;
    
    fullscreenWindow = [[FullscreenWindow alloc]
                        initWithContentRect:rect
                        styleMask:NSBorderlessWindowMask
                        backing:NSBackingStoreBuffered
                        defer:YES
                        screen:nil];
        
    NSView *contentView = [[[window contentView] retain] autorelease];
    [window setContentView:[[[NSView alloc] init] autorelease]];
    
    [fullscreenWindow setHidesOnDeactivate:YES];
    [fullscreenWindow setLevel:NSFloatingWindowLevel];
    [fullscreenWindow setContentView:contentView];
    [fullscreenWindow setTitle:[window title]];
    [fullscreenWindow makeKeyAndOrderFront:nil];
    
    [fullscreenWindow setFrame:
      [fullscreenWindow frameRectForContentRect:[[fullscreenWindow screen] frame]]
        display:YES
        animate:NO];
    
    int windowLevel = CGShieldingWindowLevel();
    [fullscreenWindow setLevel:windowLevel];
    [fullscreenWindow makeKeyAndOrderFront:nil];
    
    return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    CGRestorePermanentDisplayConfiguration();
    
    return YES;
}

// the following is modified code from http://lukassen.wordpress.com/2010/01/18/taming-snow-leopard-cgdisplaybestmodeforparameters-deprecation/

- (size_t) displayBitsPerPixelForMode: (CGDisplayModeRef) mode
{    
    size_t depth = 0;
    
    CFStringRef pixEnc = CGDisplayModeCopyPixelEncoding(mode);
    if(CFStringCompare(pixEnc, CFSTR(IO32BitDirectPixels), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
        depth = 32;
    } else if(CFStringCompare(pixEnc, CFSTR(IO16BitDirectPixels), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
        depth = 16;
    } else if(CFStringCompare(pixEnc, CFSTR(IO8BitIndexedPixels), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
        depth = 8;
    }
    
    return depth;
}

- (CGDisplayModeRef) bestMatchForModeWithWidth: (int)width height:(int)height bpp:(int)bpp
{    
    bool exactMatch = false;
    
    CGDisplayModeRef displayMode;
    
    CFArrayRef allModes = CGDisplayCopyAllDisplayModes(kCGDirectMainDisplay, NULL);
    
    for (int i = 0; i < CFArrayGetCount(allModes); i++)    {
        CGDisplayModeRef mode = (CGDisplayModeRef)CFArrayGetValueAtIndex(allModes, i);
                
        if ([self displayBitsPerPixelForMode: mode] != bpp) {
            continue;
        }
        
        if ((CGDisplayModeGetWidth(mode) == width)
            && (CGDisplayModeGetHeight(mode) == height)) {
            
            displayMode = mode;
            exactMatch = true;
            break;
        }
    }
    
    if (!exactMatch) {
        for (int i = 0; i < CFArrayGetCount(allModes); i++) {
            CGDisplayModeRef mode = (CGDisplayModeRef)CFArrayGetValueAtIndex(allModes, i);
            
            if ([self displayBitsPerPixelForMode: mode] >= bpp) {
                continue;   
            }
            
            if ((CGDisplayModeGetWidth(mode) >= width)
                && (CGDisplayModeGetHeight(mode) >= height)) {
                
                displayMode = mode;
                break;
            }
        }
    }
    
    return displayMode;
}

@end
