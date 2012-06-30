//
//  QRAppDelegate.h
//  GAJavaScriptTracker
//
//  Created by Dominik Pich on 25.06.12.
//  Copyright © 2012 doo GmbH / Dominik Pich. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface GAJSAppDelegate : NSObject <NSApplicationDelegate>

@property(nonatomic, strong) IBOutlet WebView *debugwebview;

@property NSNumber *trackerRunning;

- (IBAction)start:(id)sender;
- (IBAction)trackPage:(id)sender;
- (IBAction)trackPage2:(id)sender;
- (IBAction)trackClick:(id)sender;
- (IBAction)stop:(id)sender;

@end
