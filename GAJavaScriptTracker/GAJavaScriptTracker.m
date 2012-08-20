//
//  GAJavaScriptTracker.m
//  GAJavaScriptTracker
//
//  Created by Dominik Pich on 25.06.12.
//  Copyright © 2012 doo GmbH / Dominik Pich. All rights reserved.
//

#import "GAJavaScriptTracker.h"
#import "GAJSWebViewEngine.h"

static NSString* GAEscapeNSString(NSString* value) {
    if (!value) return nil;
    const char *chars = [value UTF8String];
    NSMutableString *escapedString = [NSMutableString string];
    while (*chars) {
        if (*chars == '\\') {
            [escapedString appendString:@"\\\\"];
        } else if (*chars == '\'') {
            [escapedString appendString:@"\\'"];
        } else {
            [escapedString appendFormat:@"%c", *chars];
        }
        ++chars;
    }
    return escapedString;
}

@implementation GAJavaScriptTracker {
    GAJSWebViewEngine *_JSEngine;
}

@synthesize dryRun=_dryRun;
@synthesize debug=_debug;
@synthesize debugwebview=_debugwebview;
@synthesize accountID=_accountID;
@synthesize anonymizeIp=_anonymizeIp;
@synthesize batchInterval=_batchInterval;
@synthesize batchSize=_batchSize;


// This method tries to find a tracker for the specified Google Analytics account ID (the string that begins with "UA-") in an internal List. If no tracker is up, it inits a new one :D
+ (id)trackerWithAccountID:(NSString *)accountID {
    static NSMutableDictionary *gaJavaScriptTrackerAvailableTrackers = nil;
    
    if(!accountID.length) {
        @throw [NSException exceptionWithName:@"GAJSException"
                                       reason:@"No accountID"
                                     userInfo:nil];
    }
    
    GAJavaScriptTracker *tracker = nil;
    if(!gaJavaScriptTrackerAvailableTrackers) {
        tracker = [[GAJavaScriptTracker alloc] initTrackerWithAccountID:accountID];
        gaJavaScriptTrackerAvailableTrackers = [NSMutableDictionary dictionaryWithObject:tracker forKey:accountID];
    }
    else {
        tracker = [gaJavaScriptTrackerAvailableTrackers objectForKey:accountID];
        if(!tracker)
            [gaJavaScriptTrackerAvailableTrackers setObject:tracker forKey:accountID];
    }
    
    return tracker;
}

// Start the tracker with the specified Google Analytics account ID (the string that begins with "UA-")
- (id)initTrackerWithAccountID:(NSString *)accountID {
    if(!accountID.length) {
        @throw [NSException exceptionWithName:@"GAJSException"
                                       reason:@"No accountID"
                                     userInfo:nil];
    }
    
    self = [super init];
    if(self) {
        _accountID = accountID;
    }
    return self;
}

//starts this tracker
-(void)start {
    assert(!_JSEngine);
    
    if(self.debug)
        NSLog(@"[GAJST] allocate engine");
    
    _JSEngine = [[GAJSWebViewEngine alloc] init];
    if(!_JSEngine) {
        @throw [NSException exceptionWithName:@"GAJSException"
                                       reason:@"Failed to load JavaScriptEngine"
                                     userInfo:nil];
    }
    
    
    id anonymize = @"_gaq.push(['_anonymizeIp']);";
    id str = [NSString stringWithFormat:@"var _gaq = _gaq || [];\n\
              _gaq.push(['_setAccount', '%@']);\n\
              _gaq.push(['_setDomainName', 'none']);\n\
              %@", _accountID, _anonymizeIp ? anonymize : @""];
    
    if(self.debug)
        NSLog(@"[GAJST] Load html and set INITIAL_GA: %@", str);
    
    _JSEngine.htmlName = @"main";
    _JSEngine.htmlVariables = [NSDictionary dictionaryWithObject:str forKey:@"INITIAL_GA"];
    _JSEngine.debugwebview = _debugwebview;
    if(self.debug)
        [_JSEngine runJS:@"alert(_gaq)"];
    
    self.batchSize = _batchSize;
    self.batchInterval = _batchInterval;
    
}

//stops this tracker
-(void)stop {
    assert(_JSEngine);
    
    if(self.debug)
        NSLog(@"[GAJST] flush the engine [if the webview is not loaded, this may loose a batch.]");
    [_JSEngine flushJS];
    
    if(self.debug)
        NSLog(@"[GAJST] release engine");
    
    _JSEngine = nil;
}

//is it running?
- (BOOL)isRunning {
    if(self.debug)
        NSLog(@"[GAJST] checking for engine");
    
    return (_JSEngine!=NULL);
}

- (void)setBatchSize:(NSUInteger)batchSize {
    if(_JSEngine) {
        _JSEngine.batchSize = batchSize;
        batchSize = _JSEngine.batchSize;
    }
    _batchSize = batchSize;
}

- (void)setBatchInterval:(NSTimeInterval)batchInterval {
    if(_JSEngine) {
        _JSEngine.batchSize = batchInterval;
        batchInterval = _JSEngine.batchInterval;
    }
    _batchInterval = batchInterval;
}

- (BOOL)executeScript:(NSString*)js {
    if(self.debug)
        NSLog(@"[GAJST] execute %@", js);
    
    if(!self.dryRun) {
        [_JSEngine runJS:js];
    }
    return YES;
}

#pragma mark -

// Track a page view. Returns YES on success or NO on error (with |error|
// set to the specific error, or nil). You may pass NULL for |error| if you
// don't care about the error.  Note that trackPageview will prepend a '/'
// character if pageURL doesn't start with one.
- (BOOL)trackPageview:(NSString *)pageURL
            withError:(NSError **)error {
    
    if(!pageURL.length) {
        @throw [NSException exceptionWithName:@"GAJSException"
                                       reason:@"No pageURL for trackPageview"
                                     userInfo:nil];
    }
    
    id js = [NSString stringWithFormat:@"_gaq.push(['_trackPageview', '%@'])", GAEscapeNSString(pageURL)];
    return [self executeScript:js];
}

// Track an event. The category and action are required. The label and
// value are optional (specify nil for no label and -1 or any negative integer
// for no value). Returns YES on success or NO on error (with |error|
// set to the specific error, or nil). You may pass NULL for |error| if you
// don't care about the error.
- (BOOL)trackEvent:(NSString *)category
            action:(NSString *)action
             label:(NSString *)label
             value:(NSInteger)value
         withError:(NSError **)error {
    
    if(!category.length) {
        @throw [NSException exceptionWithName:@"GAJSException"
                                       reason:@"No category for trackEvent"
                                     userInfo:nil];
    }
    if(!action.length) {
        @throw [NSException exceptionWithName:@"GAJSException"
                                       reason:@"No action for trackEvent"
                                     userInfo:nil];
    }
    category = GAEscapeNSString(category);
    action = GAEscapeNSString(action);
    label = GAEscapeNSString(label);
    
    id js;
    if(label && value>=0) {
        js = [NSString stringWithFormat:@"_gaq.push(['_trackEvent', '%@', '%@', '%@', %ld])", category, action, label, value];
    }
    else if(label) {
        js = [NSString stringWithFormat:@"_gaq.push(['_trackEvent', '%@', '%@', '%@'])", category, action, label];
    }
    else {
        js = [NSString stringWithFormat:@"_gaq.push(['_trackEvent', '%@', '%@'])", category, action];
    }
    return [self executeScript:js];
}

@end
