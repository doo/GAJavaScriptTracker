//
//  GAJSEngine.h
//  GAJavaScriptTracker
//
//  Created by Dominik Pich
//  Copyright © 2012 doo GmbH / Dominik Pich. All rights reserved.
//

#import "GAJSWebViewEngine.h"

#define ELog(x,...) /* NSLog */

@interface GAJSWebViewEngine ()
@property(nonatomic, readwrite) WebView *webView;
@end

@implementation GAJSWebViewEngine {
    BOOL _webviewLoaded;
    NSTimer *_batchTimer;
    NSMutableArray *_webViewPendingScripts;
}

@synthesize htmlName=_htmlName;
@synthesize htmlVariables = _htmlVariables;
@synthesize webView=_webView;
@synthesize batchSize=_batchSize;
@synthesize batchInterval=_batchInterval;
@synthesize debugwebview=_debugwebview;

- (WebView*)createWebView {
    WebView *webView; 
    if(!_debugwebview) {
        //alloc
        webView = [[WebView alloc] initWithFrame:CGRectMake(0, 0, 10, 10) frameName:@"GAJSWebViewEngine" groupName:@"GAJS"];
    }else{
        webView = self.debugwebview;
    }

    //set properties
    webView.shouldUpdateWhileOffscreen = YES;
    webView.UIDelegate = self;
    webView.resourceLoadDelegate = self;
    webView.frameLoadDelegate = self;
    
    //get file
    NSURL *file = [[NSBundle bundleForClass:self.class] URLForResource:_htmlName
                                                         withExtension:@"html"];
    if(!file) {
        @throw [NSException exceptionWithName:@"GAJSException"
                                       reason:[NSString stringWithFormat:@"File not found in bundle: %@.html", _htmlName]
                                     userInfo:nil];
    }
    
    //load content
    NSString *library = [NSString stringWithContentsOfURL:file
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];
    
    if(!library.length)  {
        @throw [NSException exceptionWithName:@"GAJSException"
                                       reason:[NSString stringWithFormat:@"File couldnt be read as UTF-8 content / file has no content: %@.js", file.lastPathComponent]
                                     userInfo:nil];
    }

    //update string
    if(_htmlVariables.count)
    {
        for (NSString *key in _htmlVariables.allKeys) {
            id k = [NSString stringWithFormat:@"%%%@%%", key];
            id v = [_htmlVariables objectForKey:key];
            library = [library stringByReplacingOccurrencesOfString:k withString:v];
        }
    }
    
    //load
//    [[webView mainFrame] loadHTMLString:library baseURL:[file URLByDeletingLastPathComponent]];
    NSString *d = NSTemporaryDirectory();
    NSString *p = [[d stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] stringByAppendingPathExtension:@"html"];
    [library writeToFile:p atomically:NO encoding:NSUTF8StringEncoding error:nil];
    id p2 = [[file.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"ga.js"];
    [[NSFileManager defaultManager] copyItemAtPath:p2 toPath:[d stringByAppendingPathComponent:@"ga.js"] error:nil];
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:p]]];
    return webView;
}

- (void)setHtmlName:(NSString *)htmlName {
    _webviewLoaded = NO;
    _webView = nil;
    _htmlName = htmlName;
}

- (void)setBatchSize:(NSUInteger)batchSize {
    if(!batchSize) batchSize = 1;
    
    _batchSize = batchSize;
    if(_webViewPendingScripts.count >= _batchSize) {
        [self sendOffBatchedJS];
    }
    
    [self setupBatching];
}

- (void)setBatchInterval:(NSTimeInterval)batchInterval {
    if(!batchInterval) batchInterval = DEFAULT_BATCH_INTERVAL;
    
    _batchInterval = batchInterval;
    if(_webViewPendingScripts.count >= _batchSize) {
        [self sendOffBatchedJS];
    }
    
    [self setupBatching];
}
#pragma mark -

- (void)batchTimerFired:(NSTimer*)timer {
    [self sendOffBatchedJS];
#if FREE_WEBVIEW_AFTER_BATCH
    [self setNeedsReload];
#endif
}

- (void)sendOffBatchedJS {
    if(_webviewLoaded) {
        for(id aJSString in _webViewPendingScripts) {
            //run it
            NSLog(@"[JSC] Evaluate JS: %@ %@ %@", aJSString, _webView.customUserAgent, _webView.applicationNameForUserAgent);
            NSString *result = [_webView stringByEvaluatingJavaScriptFromString:aJSString];
            if (!result) {
                ELog(@"[JSC] No result returned");
            }
        }
        [_webViewPendingScripts removeAllObjects];
    }
    else {
        
        _webView = [self createWebView];
    }
}

- (void)setupBatching {
    [_batchTimer invalidate];
    _batchTimer = nil;
    if(_batchSize>1) {
        NSTimeInterval interval = _batchInterval>0 ?_batchInterval : DEFAULT_BATCH_INTERVAL;
        _batchTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                       target:self
                                                     selector:@selector(batchTimerFired:)
                                                     userInfo:nil
                                                      repeats:YES];
    }
}
#pragma mark -

- (void)runJS:(NSString *)aJSString
{
    if(!aJSString.length) {
        @throw [NSException exceptionWithName:@"GAJSEngineException"
                                       reason:@"empty JS String for running"
                                     userInfo:nil];
    }
 
    //enqueue it
    if(!_webViewPendingScripts) {
        _webViewPendingScripts = [NSMutableArray array];
    }
    [_webViewPendingScripts addObject:aJSString];

    if(_webViewPendingScripts.count >= _batchSize) {
        [self sendOffBatchedJS];
    }
}

- (void)loadJSLibraryFromBundle:(NSString*)libraryName {
    //find in our bundle
    NSURL *file = [[NSBundle bundleForClass:self.class] URLForResource:libraryName
                                          withExtension:@"js"];
    if(!file) {
        @throw [NSException exceptionWithName:@"GAJSException"
                                       reason:[NSString stringWithFormat:@"File not found in bundle: %@.js", libraryName]
                                     userInfo:nil];
    }
    
    [self loadJSLibraryFromURL:file];
}

- (void)loadJSLibraryFromURL:(NSURL*)url {
    //load content
    NSString *library = [NSString stringWithContentsOfURL:url
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];
    
    if(!library.length)  {
        @throw [NSException exceptionWithName:@"GAJSException"
                                       reason:[NSString stringWithFormat:@"File couldnt be read as UTF-8 content / file has no content: %@.js", url.lastPathComponent]
                                     userInfo:nil];
    }
    
    ELog(@"[JSC] loading library %@...", url.lastPathComponent);
    [self runJS:library];  
}

- (void)flushJS {
    if(_webViewPendingScripts.count >= 1) {
        [self sendOffBatchedJS];
    }
}

#pragma mark -

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    ELog(@"did load webview");
    _webviewLoaded = YES;

    if(_webViewPendingScripts.count >= _batchSize) {
        [self sendOffBatchedJS];
    }
}

#if DEBUG_WEBVIEW_ENGINE
- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    ELog(@"[javascript-alert] %@", message);
}

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource {
    ELog(@"[request] %@", request);
    return request;
}

- (void)webView:(WebView *)sender resource:(id)identifier didReceiveResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)dataSource {
    ELog(@"[response] %@", response);
}
#endif

@end
