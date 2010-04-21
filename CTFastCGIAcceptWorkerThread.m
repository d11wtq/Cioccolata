//
//  CTFastCGIAcceptWorkerThread.m
//  Cioccolata
//
//  Created by Chris Corbyn on 22/04/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#import "CTFastCGIAcceptWorkerThread.h"
#import "CTFastCGIAcceptWorkerOperation.h"

@implementation CTFastCGIAcceptWorkerThread

- (id)initWithCount:(NSInteger)c {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	count = c;
	
	return self;
}

- (void)main {
	NSOperation *worker = [[CTFastCGIAcceptWorkerOperation alloc] initWithCount:count];
	[worker main];
	[worker release];
}

@end
