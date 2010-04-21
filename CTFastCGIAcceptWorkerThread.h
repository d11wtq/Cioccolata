//
//  CTFastCGIAcceptWorkerThread.h
//  Cioccolata
//
//  Created by Chris Corbyn on 21/04/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//


@interface CTFastCGIAcceptWorkerThread : NSThread {
	NSInteger count;
}

- (id)initWithCount:(NSInteger)c;

@end
