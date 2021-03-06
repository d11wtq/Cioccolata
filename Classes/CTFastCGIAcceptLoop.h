//
//  CTFastCGIAcceptLoop.h
//  Cioccolata
//
//  Created by Chris Corbyn on 21/04/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//


/*!
 * @brief	Listens for incoming requests via fastcgi and dispatches them to the front controller.
 *			Requests are dispatched via NSOperationQueue, which means each request is processed in its own thread.
 */
@interface CTFastCGIAcceptLoop : NSObject {
	NSInteger maxConcurrentOperationCount;
}


#pragma mark -
#pragma mark Handling concurrent request threads

/*!
 * The number of threads that are initialized.
 */
@property NSInteger maxConcurrentOperationCount;

#pragma mark -
#pragma mark Initialization

/*!
 * @brief	Initialize the accept loop specifying the maximum number of simultaneous requests to process.
 *			The default value is 100.
 */
- (id)initWithMaxConcurrentOperationCount:(NSInteger)count;

#pragma mark -
#pragma mark Handling fastcgi requests


/*!
 * Begins listening for requests to dispatch, with maxConcurrentOperationCount worker threads.
 */
- (void)acceptRequests;

@end
