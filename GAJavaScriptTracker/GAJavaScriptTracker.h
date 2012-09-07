//
//  GAJavaScriptTracker.h
//  GAJavaScriptTracker
//
//  Created by Dominik Pich on 25.06.12.
//  Copyright © 2012 doo GmbH / Dominik Pich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

/** @file GAJavaScriptTracker.h */

/**
 * provides a Google Analytics Tracker for OSX by wrapping the original (slightly modified to allow offline usage) google analytics javascript. It contains a private Webview that executes the script in the background.
 */
@interface GAJavaScriptTracker : NSObject

/**
 * This method tries to find a tracker for the specified Google Analytics account ID (the string that begins with "UA-") in an internal List. If no tracker for that ID is up, it inits a new one
 * @param accountID the Google Analytics ID to use for the tracker
 * @return the cached tracker or a new instance configured with the ID
 */
+ (id)trackerWithAccountID:(NSString *)accountID;

/**
 * starts this tracker
 */
-(void)start;

/**
 * stops this tracker, flushing any calls left
 */
-(void)stop;

/**
 * the Google Analytics account ID for this tracker
 * @return account ID
 */
@property(readonly) NSString *accountID;

/**
 * is the tracker running?
 * @return BOOL with the state
 */
@property(readonly,getter = isRunning) BOOL running;

/**
 * Defines wether or not to use batching of requests. size<=1 = no batching
 * There will be no network activity until one batch is full.
 * @return the number of request in each batch.
 * @warning batching will influence the timestamp and can modify the results in Google Analytics if the batch size is chosen too large!
 */
@property(nonatomic) NSUInteger batchSize;

/**
 * the max interval for dispatching batches
 * @return the maxium time to wait between network requests (if a batch gets filled)
 * @warning batching will influence the timestamp and can modify the results in Google Analytics if the time interval is chosen too large!
 */
@property(nonatomic) NSTimeInterval batchInterval;

#pragma mark -

/**
 * If the debug flag is set, debug messages will be written to the log. It is useful for debugging calls to the Google Analytics SDK.
 * @warning By default, the debug flag is disabled.
 **/
@property(readwrite) BOOL debug;

/**
 * a visible that can be used webview INSTEAD of the internal/invisble one used normally. For debug purposes
 * @return a webview for debugging. NIL in 'normal' mode/when not set
 * @warning Don't set in production mode or while the tracker is running
 */
@property(nonatomic, strong) WebView *debugwebview;

/**
 * If the dryRun flag is set, hits will not be sent to Google Analytics. It is useful for testing and debugging calls to the Google Analytics SDK.
 * @warning By default, the dryRun flag is disabled.
 */
@property(readwrite) BOOL dryRun;

/**
 * If the anonymizeIp flag is set, the SDK will anonymize information sent to  Google Analytics by setting the last octet of the IP address to zero prior to its storage and/or submission.
 * @warning By default, the anonymizeIp flag is disabled.
 * @warning Currently only takes effect if the the tracker has not been started yet.
 */
@property(readwrite) BOOL anonymizeIp;

#pragma mark -

/**
 * Track a page view.
 * @warning Note that trackPageview will prepend a '/' character if pageURL doesn't start with one.
 * @param pageURL the 'url' (any string... for an osx this could be /doo/wizard/welcome, /doo/mainWindow/allDocuments or /doo/preferences/generalTab)
 * @param error when this is not NIL it is filled with an NSError detailing the reason when the function returns NO
 * @return Returns YES on success or NO on error (sets |error| on failure)
 */
- (BOOL)trackPageview:(NSString *)pageURL
            withError:(NSError **)error;

/**
 * Track an event 
 * @param category category of the event (required)
 * @param action action that generated event (required)
 * @param label label that describes this event (specify nil for no label)
 * @param value an integer value for the event (-1 or any negative integer stand for no value.)
 * @param error when this is not NIL it is filled with an NSError detailing the reason when the function returns NO
 * @return Returns YES on success or NO on error (sets |error| on failure)
 */
- (BOOL)trackEvent:(NSString *)category
            action:(NSString *)action
             label:(NSString *)label
             value:(NSInteger)value
         withError:(NSError **)error;

@end
