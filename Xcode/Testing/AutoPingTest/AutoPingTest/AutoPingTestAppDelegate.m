//
//  AutoPingTestAppDelegate.m
//  AutoPingTest
//
//  Created by Robbie Hanson on 4/13/11.
//  Copyright 2011 Deusty, LLC. All rights reserved.
//

#import "AutoPingTestAppDelegate.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

#define MY_JID      @"robbie@robbiehanson.com/rsrc"
#define MY_PASSWORD @""

@implementation AutoPingTestAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	DDLogVerbose(@"%@: %@", [self class], THIS_METHOD);
	
	xmppStream = [[XMPPStream alloc] init];
	[xmppStream setMyJID:[XMPPJID jidWithString:MY_JID]];
	
	xmppAutoPing = [[XMPPAutoPing alloc] init];
	xmppAutoPing.pingInterval = 15;
	xmppAutoPing.pingTimeout = 5;
	xmppAutoPing.targetJID = nil;
	
	[xmppAutoPing activate:xmppStream];
	
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppAutoPing addDelegate:self delegateQueue:dispatch_get_main_queue()];
	
	NSError *error = nil;
	
	if (![xmppStream connect:&error])
	{
		DDLogError(@"%@: Error connecting: %@", [self class], error);
	}
}

- (void)goOnline:(NSTimer *)aTimer
{
	DDLogVerbose(@"%@: %@", [self class], THIS_METHOD);
	
	[xmppStream sendElement:[XMPPPresence presence]];
}

- (void)goOffline:(NSTimer *)aTimer
{
	DDLogVerbose(@"%@: %@", [self class], THIS_METHOD);
	
	[xmppStream sendElement:[XMPPPresence presenceWithType:@"unavailable"]];
}

- (void)changeAutoPingInterval:(NSTimer *)aTimer
{
	DDLogVerbose(@"%@: %@", [self class], THIS_METHOD);
	
	xmppAutoPing.pingInterval = 30;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", [self class], THIS_METHOD);
	
	NSError *error = nil;
	
	if (![xmppStream authenticateWithPassword:MY_PASSWORD error:&error])
	{
		DDLogError(@"%@: Error authenticating: %@", [self class], error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", [self class], THIS_METHOD);
	
	[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(goOnline:) userInfo:nil repeats:NO];
	[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(goOffline:) userInfo:nil repeats:NO];
	[NSTimer scheduledTimerWithTimeInterval:35 target:self selector:@selector(changeAutoPingInterval:) userInfo:nil repeats:NO];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", [self class], THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", [self class], THIS_METHOD);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender
{
	DDLogVerbose(@"%@: %@", [self class], THIS_METHOD);
}

- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender
{
	DDLogVerbose(@"%@: %@", [self class], THIS_METHOD);
}

- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender
{
	DDLogVerbose(@"%@: %@", [self class], THIS_METHOD);
}

@end
