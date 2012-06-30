//
//  GAJSEngine.h
//  GAJavaScriptTracker
//
//  Created by Dominik Pich
//  Copyright © 2012 doo GmbH / Dominik Pich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface GAJSWebViewEngine : NSObject

//webview for base html and JS Context
@property(nonatomic, readonly) WebView *webView;
@property(nonatomic, strong) WebView *debugwebview;

//name of html -- which must reside in our bundle
@property(nonatomic, copy) NSString *htmlName;

//dictionary with content to insert into the html.
// the keys are strings that are in the original html file as %key%
// the content for each key should be html
@property(nonatomic, copy) NSDictionary *htmlVariables;

//the Javascript calls are batched when this is > 1
@property(nonatomic, assign) NSUInteger batchSize;

//the max interval for dispatching batches
@property(nonatomic) NSTimeInterval batchInterval;

//enqueues JavaScript to be executed when batch is full
- (void)runJS:(NSString *)aJSString;

//loads a JS file and executes it  when batch is full
- (void)loadJSLibraryFromBundle:(NSString*)libraryName;
- (void)loadJSLibraryFromURL:(NSURL*)url;


//flushes all JS left
- (void)flushJS;

@end

//config of agent
#ifndef DEFAULT_BATCH_INTERVAL
    #define DEFAULT_BATCH_INTERVAL 5.0f
#endif
#ifndef FREE_WEBVIEW_AFTER_BATCH
    #define FREE_WEBVIEW_AFTER_BATCH 0
#endif
#ifndef DEBUG_WEBVIEW_ENGINE
    #define DEBUG_WEBVIEW_ENGINE 1 
#endif