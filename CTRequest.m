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
@synthesize url;
@synthesize path;
@synthesize query;
@synthesize get;

- (id)init {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	path = @"/";
	query = @"";
	
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
	
	path = [env objectForKey:@"SCRIPT_NAME"];
	if (nil == path) {
		NSLog(@"WARNING: FastCGI application loaded without SCRIPT_NAME, falling back to /");
		path = @"/";
	}
	
	query = [env objectForKey:@"QUERY_STRING"];
	if (nil == query) {
		query = @"";
	}
	
	NSString *uri = [NSString stringWithFormat:@"%@%@%@",
					 [path stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
					 ([query isEqual:@""]) ? @"" : @"?",
					 query];
	
	url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://127.0.0.1%@", uri]];
	
	get = [[self parseQuery:query] retain];
	
	return self;
}

- (id)param:(NSString *)paramName {
	id result = [self param:paramName method:@"GET"];
	if (nil == result) {
		result = [self param:paramName method:@"POST"];
	}
	
	return result;
}

- (id)param:(NSString *)paramName method:(NSString *)method {
	return [self.get objectForKey:paramName];
}

#pragma mark -
#pragma mark Utility methods

- (NSDictionary *)parseQuery:(NSString *)queryString {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	NSArray *pairs = [queryString componentsSeparatedByString:@"&"];
	
	for (NSString *pair in pairs) {
		NSRange eqRange = [pair rangeOfString:@"="];
		
		NSString *key;
		id value;
		
		if (eqRange.location == NSNotFound) {
			key = [pair stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
			value = @"";
		} else {
			key = [[pair substringToIndex:eqRange.location] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
			if ([pair length] > eqRange.location + 1) {
				value = [[pair substringFromIndex:eqRange.location + 1] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
			} else {
				value = @"";
			}
		}
		
		// Parameter already exists, it must be a dictionary
		if (nil != [params objectForKey:key]) {
			id existingValue = [params objectForKey:key];
			if (![existingValue isKindOfClass:[NSDictionary class]]) {
				existingValue = [NSMutableDictionary dictionaryWithObjectsAndKeys:existingValue, [NSNumber numberWithInt:0], nil];
			}
			
			[existingValue setObject:value forKey:[NSNumber numberWithInt:[existingValue count]]];
			
			value = existingValue;
		}
		
		[params setObject:value forKey:key];
	}
	
	return params;
}

- (void)dealloc {
	[env release];
	[url release];
	[path release];
	[query release];
	[get release];
	[super dealloc];
}

@end
