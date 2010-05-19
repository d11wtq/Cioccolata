//
//  CTFastCGIAcceptLoop.m
//  Cioccolata
//
//  Created by Chris Corbyn on 21/04/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#include <fcgi_config.h>

#import "CTFastCGIAcceptLoop.h"
#import "CTFastCGIAcceptWorkerThread.h"
#import "CTFastCGIAcceptWorkerOperation.h"

#include <fcgiapp.h>

@implementation CTFastCGIAcceptLoop

@synthesize maxConcurrentOperationCount;

- (id)init {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	self.maxConcurrentOperationCount = 0;
	
	return self;
}

- (id)initWithMaxConcurrentOperationCount:(NSInteger)count {
	self = [self init];
	if (!self) {
		return nil;
	}
	
	self.maxConcurrentOperationCount = count;
	
	return self;
}

- (void)acceptRequests {
	NSLog(@"Accepting FastCGI connections");
	
	FCGX_Init(); int c = 0;
	
	for (int i = 0, count = self.maxConcurrentOperationCount - 1; i < count; ++i) {
		++c;
		NSThread *worker = [[CTFastCGIAcceptWorkerThread alloc] initWithCount:c];
		[worker start];
		[worker release];
	}
	
	// Run an operation on the main thread to keep it working
	NSOperation *worker = [[CTFastCGIAcceptWorkerOperation alloc] initWithCount:c];
	[worker main];
	[worker release];
}

@end
