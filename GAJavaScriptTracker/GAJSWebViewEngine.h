//
//  GAJSEngine.h
//  GAJavaScriptTracker
//
//  Created by Dominik Pich
//  Copyright © 2012 doo GmbH / Dominik Pich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

/**
 * internal JS 'engine' that controls an invisible webview for the trackers. Could be used for other stuff too though, I guess :D
 * @warning Direclty using JavaScriptCore is no option for GA (and many other scripts) as you dont get the website's context (youll miss the window & the document objects and the DOM)
*/
@interface GAJSWebViewEngine : NSObject

/**
 * the invisible webview for the base html and JS Context
 */
@property(nonatomic, readonly) WebView *webView;

/**
 * can be set for debugging purposes. This webview then replaces the internal one 
 */
@property(nonatomic, strong) WebView *debugwebview;

/**
 * name of html
 * @warning the file must reside in our bundle
 */
@property(nonatomic, copy) NSString *htmlName;

/**
 * dictionary with content to insert into the html. The keys are strings that are in the original html file as %key%. The content for each key should be html
 */
@property(nonatomic, copy) NSDictionary *htmlVariables;

/**
 * the Javascript calls are batched when this is > 1
 */
@property(nonatomic, assign) NSUInteger batchSize;

/**
 * the max interval for dispatching batches
 */
@property(nonatomic) NSTimeInterval batchInterval;

/**
 * enqueues JavaScript to be executed when batch is full
 * @param aJSString the javascript string that's gonna be executed
 */
- (void)runJS:(NSString *)aJSString;

/**
 * loads a JS file from our Bundle and executes it when batch is full
 * @param libraryName the name of the library from our bundle to load
 */
- (void)loadJSLibraryFromBundle:(NSString*)libraryName;

/**
 * loads a JS file from the specified |url| and executes it when batch is full
 * @param url the URL that points to the library file
 */
- (void)loadJSLibraryFromURL:(NSURL*)url;

/**
 * flushes all JS left (immediately sends the latest batch)
 */
- (void)flushJS;

@end

//config of webview
#ifndef DEFAULT_BATCH_INTERVAL
    #define DEFAULT_BATCH_INTERVAL 5.0f
#endif
#ifndef FREE_WEBVIEW_AFTER_BATCH
    #define FREE_WEBVIEW_AFTER_BATCH 0
#endif
#ifndef DEBUG_WEBVIEW_ENGINE
    #define DEBUG_WEBVIEW_ENGINE 1 
#endif