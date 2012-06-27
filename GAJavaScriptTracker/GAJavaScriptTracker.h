//
//  GAJavaScriptTracker.h
//  GAJavaScriptTracker
//
//  Created by Dominik Pich on 25.06.12.
//  Copyright © 2012 doo GmbH / Dominik Pich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

//
// GAJavaScriptTracker
//
@interface GAJavaScriptTracker : NSObject

// This method tries to find a tracker for the specified Google Analytics account ID (the string that begins with "UA-") in an internal List. If no tracker for that ID is up, it inits a new one 
+ (id)trackerWithAccountID:(NSString *)accountID;

//starts this tracker
-(void)start;

//stops this tracker, flushing any calls left
-(void)stop;

//the account ID
@property(readonly) NSString *accountID;

//is the tracker running?
@property(readonly,getter = isRunning) BOOL running;

//use batching of requests. size<=1 = no batching
@property(nonatomic) NSUInteger batchSize;

//the max interval for dispatching batches
@property(nonatomic) NSTimeInterval batchInterval;

#pragma mark -

// If the debug flag is set, debug messages will be written to the log.
// It is useful for debugging calls to the Google Analytics SDK.
// By default, the debug flag is disabled.
@property(readwrite) BOOL debug;

// If the dryRun flag is set, hits will not be sent to Google Analytics.
// It is useful for testing and debugging calls to the Google Analytics SDK.
// By default, the dryRun flag is disabled.
@property(readwrite) BOOL dryRun;

// If the anonymizeIp flag is set, the SDK will anonymize information sent to
// Google Analytics by setting the last octet of the IP address to zero prior
// to its storage and/or submission.
// By default, the anonymizeIp flag is disabled.
// Currently only takes effect if the the tracker has not been started yet.
@property(readwrite) BOOL anonymizeIp;

#pragma mark -

// Track a page view. Returns YES on success or NO on error (with |error|
// set to the specific error, or nil). You may pass NULL for |error| if you
// don't care about the error.  Note that trackPageview will prepend a '/'
// character if pageURL doesn't start with one.
- (BOOL)trackPageview:(NSString *)pageURL
            withError:(NSError **)error;

// Track an event. The category and action are required. The label and
// value are optional (specify nil for no label and -1 or any negative integer
// for no value). Returns YES on success or NO on error (with |error|
// set to the specific error, or nil). You may pass NULL for |error| if you
// don't care about the error.
- (BOOL)trackEvent:(NSString *)category
            action:(NSString *)action
             label:(NSString *)label
             value:(NSInteger)value
         withError:(NSError **)error;

@end