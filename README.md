##recent changes
I fixed a crucial bug that prevented the framework from actually calling out to the google analytics server. This bug occurred on almost all 10.6 installations but not on 10.8 and was the result of a very slight change in the behaviour of cocoa's WebView class between OS releases which I mist.

#about
Objective-C Cocoa Wrapper for javascript google analytics tracking.</br><br/>
Google has no mac SDK for google analytics tracking. It has an android SDK but no source. It has an iOS SDK but no source either. It's all precompiled for arm and I  didn't see any way to use it on the mac. So I was left with the Javascript Tracker available for embedding in any website and which can be used in any custom scenario.<br/></br>
The Framework -which I wrote for my work at <b>[@doo](twitter://@doo)</b>- provides the GAJavaScriptTracker objective-c class that wraps this javascript in an easy to use interface which tries to emulate the GATracker iOS Class from Google.<br/><br/>
It does so with the helper class GAJSWebViewEngine, a slightly modified GoogleAnalytics javascript from Google and a basic html file which loads the JS.<br/><br/>
NOTE: this class is not feature complete. It is specifically tailored to suit the needs for GA in the <b>[doo app](http://www.doo.net)</b> and is also intended as Demo of how to use a JS SDK from Cocoa.</br>
(If Google ever decides to port their iOS SDK to the mac, im all for it :) till then this approach works fine.)

##how to use
The Framework is accompanied by a small demo app which you can use to test the available features of the tracker:<br/>

--

###The Tracker has the following Properties and methods

+ +(id)trackerWithAccountID:(NSString *)accountID;

        This method tries to find a tracker for the specified Google Analytics account ID (the string that begins with "UA-") in an internal List. If no tracker for that ID is up, it inits a new one 

+ -(void)start;

		starts this tracker

+ -(void)stop;

		stops this tracker, flushing any calls left

+ @property(readonly) NSString *accountID;
		
		the account ID

+ @property(readonly,getter = isRunning) BOOL running;
	
		is the tracker running?

+ @property(nonatomic) NSUInteger batchSize;

		use batching of requests. size<=1 = no batching
		It defaults to 0.

+ @property(nonatomic) NSTimeInterval batchInterval;
	
		the max interval for dispatching batches. It defaults to 0.

+ @property(readwrite) BOOL debug;

        If the debug flag is set, debug messages will be written to the log.
        It is useful for debugging calls to the Google Analytics SDK.
        By default, the debug flag is disabled.
	
+ @property(readwrite) BOOL dryRun;

        If the dryRun flag is set, hits will not be sent to Google Analytics.
        It is useful for testing and debugging calls to the Google Analytics SDK.
        By default, the dryRun flag is disabled.

+ @property(readwrite) BOOL anonymizeIp;

		If the anonymizeIp flag is set, the SDK will anonymize information sent to Google Analytics by setting the last octet of the IP address to zero prior to its storage and/or submission.
		 By default, the anonymizeIp flag is disabled. Currently only takes effect if the the tracker has not been started yet.

####
The two methods below result in requests to Google Analytics. Either directly or -if batching is enabled- via queued Javascript calls.

+ -(BOOL)trackPageview:(NSString *)pageURL withError:(NSError **)error;

		Track a page view. Returns YES on success or NO on error.
		Note that trackPageview will prepend a '/' character if pageURL doesn't start with one.

+ -(BOOL)trackEvent:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSInteger)value withError:(NSError **)error;

		Track an event. The category and action are required. The label and value are optional (specify nil for no label and -1 or any negative integer for no value). Returns YES on success or NO on error.

##config
configurable via additional preprocessor macros, when building the framework from source:

- DEFAULT\_BATCH\_INTERVAL :: float

		default value: 5.0
	
- FREE\_WEBVIEW\_AFTER\_BATCH :: bool

		default value: 0
    
- DEBUG_WEBVIEW_ENGINE :: bool

	    default value: 0
