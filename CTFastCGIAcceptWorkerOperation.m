//
//  CTFastCGIAcceptWorkerOperation.m
//  Cioccolata
//
//  Created by Chris Corbyn on 22/04/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#include <fcgi_config.h>

#import "CTFastCGIAcceptWorkerOperation.h"
#import	 "CTRequest.h"
#import	 "CTRequest+FCGX.h"

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
	
	FCGX_Request cgiRequest;
	FCGX_InitRequest(&cgiRequest, 0, 0);
	
	for (;;) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NSLock *acceptLock = [[NSLock alloc] init];
		
		[acceptLock lock];
		accept = FCGX_Accept_r(&cgiRequest);
		[acceptLock unlock];
		[acceptLock release];
		
		if (0 > accept) {
			NSLog(@"FastCGI Worker unable to accept requests; terminating");
			break;
		}
		
		CTRequest *httpRequest = [[CTRequest alloc] initWithFCGXRequest:cgiRequest];
		
		/*
		 SomethingDispatcher
		 -> FilterChain
		 -> FrontController
		 -> Controller
		 -> Template
		 -> Response
		 */
		
		FCGX_FPrintF(cgiRequest.out,
					 "Content-Type: text/plain\r\n"
					 "\r\n");
		
		FCGX_FPrintF(cgiRequest.out, "Hello World! I'm thread #%d\n", count);
		
		NSDictionary *env = [httpRequest env];
		for (NSString *key in env) {
			// FIXME: Is it safe to assume that all HTTP requests use US-ASCII?
			FCGX_FPrintF(cgiRequest.out, "%s => %s\n",
						 [key cStringUsingEncoding:NSASCIIStringEncoding],
						 [[env objectForKey:key] cStringUsingEncoding:NSASCIIStringEncoding]);
		}
		
		FCGX_Finish_r(&cgiRequest);
		
		[pool drain];
	}
}

@end
