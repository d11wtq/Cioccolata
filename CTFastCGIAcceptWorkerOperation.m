//
//  CTFastCGIAcceptWorkerOperation.m
//  Cioccolata
//
//  Created by Chris Corbyn on 22/04/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#include <fcgi_config.h>

#import "CTFastCGIAcceptWorkerOperation.h"

#include <fcgiapp.h>

@implementation CTFastCGIAcceptWorkerOperation

- (id)initWithCount:(NSInteger)c {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	count = c;
	
	return self;
}

- (void)main {
	int accept = 0;
	
	FCGX_Request request;
	FCGX_InitRequest(&request, 0, 0);
	
	for (;;) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NSLock *acceptLock = [[NSLock alloc] init];
		
		[acceptLock lock];
		accept = FCGX_Accept_r(&request);
		[acceptLock unlock];
		[acceptLock release];
		
		if (0 > accept) {
			NSLog(@"FastCGI Worker unable to accept requests; terminating");
			break;
		}
		
		FCGX_FPrintF(request.out,
					 "Content-Type: text/plain\r\n"
					 "\r\n");
		
		FCGX_FPrintF(request.out, "Hello World! I'm thread #%d\n", count);
		
		[self dumpEnv:request];
		
		FCGX_Finish_r(&request);
		
		[pool drain]; // Request finished, autoreleased objects not needed
	}
}

- (void)dumpEnv:(FCGX_Request)request {
	NSLog(@"Dumping env");
	
	FCGX_FPrintF(request.out, "%s:\n", "Request Environment");
	for( ; *(request.envp) != NULL; request.envp++) {
		NSLog(@"In env loop");
		FCGX_FPrintF(request.out, "%s\n", *(request.envp));
	}
}

@end
