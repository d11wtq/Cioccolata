//
//  CTRequest.h
//  Cioccolata
//
//  Created by Chris Corbyn on 24/04/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#include <fcgi_config.h>
#include <fcgiapp.h>

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
 * Initialize a request based on the given request.
 */
- (id)initWithRequest:(CTRequest *)request;

- (id)initWithEnv:(NSDictionary *)env;

@end
