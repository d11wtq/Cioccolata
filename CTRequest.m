//
//  CTRequest.m
//  Cioccolata
//
//  Created by Chris Corbyn on 24/04/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#import "CTRequest.h"


@implementation CTRequest

@synthesize env;
@synthesize path;

- (id)init {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	env = [NSDictionary dictionary];
	path = @"/";
	
	return self;
}

- (id)initWithRequest:(CTRequest *)request {
	return [self initWithDictionary:request.env];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
	self = [self init];
	if (!self) {
		return nil;
	}
	
	env = [[NSDictionary alloc] initWithDictionary:dictionary];
	
	return self;
}

- (void)dealloc {
	[env release];
	[super dealloc];
}

@end
