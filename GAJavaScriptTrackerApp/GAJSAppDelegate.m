//
//  QRAppDelegate.m
//  GAJavaScriptTracker
//
//  Created by Dominik Pich on 25.06.12.
//  Copyright © 2012 doo GmbH / Dominik Pich. All rights reserved.
//

#import "GAJSAppDelegate.h"
#import <GAJavaScriptTracker/GAJavaScriptTracker.h>

@implementation GAJSAppDelegate
{
    GAJavaScriptTracker *_tracker;
}

@synthesize trackerRunning=_trackerRunning;
@synthesize debugwebview=_debugwebview;

- (IBAction)start:(id)sender {
    NSString *theId = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountID"];

    NSInteger batchSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"batchSize"];
    NSTimeInterval batchInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:@"batchInterval"];
    
    BOOL debugMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"debugMode"];
    BOOL dryMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"dryMode"];
    BOOL anonymizeIp = [[NSUserDefaults standardUserDefaults] boolForKey:@"anonymizeIp"];
    
    if(!theId.length) {
        NSRunAlertPanel(@"Google Analytics ID missing", @"Google Analytics ID missing. Please enter a valid Google Analytics ID.", @"OK", nil, nil);
        return;
    }
    
    if(_tracker.isRunning) {
        NSRunAlertPanel(@"Tracker already running", @"The Tracker is already running.", @"OK", nil, nil);
        return;
    }
    
    if(!_tracker) {
        _tracker = [GAJavaScriptTracker trackerWithAccountID:theId];
        _tracker.debug = debugMode;
        _tracker.dryRun = dryMode;
        _tracker.anonymizeIp = anonymizeIp;
        _tracker.batchSize = batchSize;
        _tracker.batchInterval = batchInterval;
        _tracker.debugwebview = _debugwebview;
        [_tracker start];
    }
    else {
        [_tracker start];
    }
    self.trackerRunning = [NSNumber numberWithBool:_tracker.running];
}

- (IBAction)trackPage:(id)sender {
    [_tracker trackPageview:self.className withError:nil];
}

- (IBAction)trackClick:(id)sender {
    [_tracker trackEvent:@"MainMenu.xib" action:@"buttons" label:@"trackClick" value:-1 withError:nil];
}

- (IBAction)trackPage2:(id)sender {
    [_tracker trackPageview:[self.className stringByAppendingString:@"2"] withError:nil];
}

- (IBAction)stop:(id)sender {
    if(!_tracker.isRunning) {
        NSRunAlertPanel(@"Tracker already stopped", @"The Tracker is already stopped.", @"OK", nil, nil);
        return;
    }
    [_tracker stop];
    _tracker = nil;
    self.trackerRunning = [NSNumber numberWithBool:NO];
}

@end
