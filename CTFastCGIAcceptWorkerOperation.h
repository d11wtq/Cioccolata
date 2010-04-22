//
//  CTFastCGIAcceptWorkerOperation.h
//  Cioccolata
//
//  Created by Chris Corbyn on 22/04/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.

//
#include <fcgi_config.h>
#include <fcgiapp.h>

@interface CTFastCGIAcceptWorkerOperation : NSOperation {
	NSInteger count;
}

- (id)initWithCount:(NSInteger)c;

- (void)dumpEnv:(FCGX_Request)request;

@end
