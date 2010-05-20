//
//  CTRequest.h
//  Cioccolata
//
//  Created by Chris Corbyn on 24/04/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//


/**
 * An HTTP request.
 */
@interface CTRequest : NSObject {
	NSDictionary *env;
	NSString *path;
}

@property (readonly) NSDictionary *env;
@property (readonly) NSString *path;


/**
 * Initialize a new request based on the given request.
 */
- (id)initWithRequest:(CTRequest *)request;

/**
 * Initialize a request using the given environment variables.
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
