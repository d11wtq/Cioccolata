//
//  CTRequest.m
//  Cioccolata
//
//  Created by Chris Corbyn on 24/04/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#import "CTRequest.h"
#import "NSDictionary+CioccolataAdditions.h"


@implementation CTRequest

@synthesize env;
@synthesize url;
@synthesize host;
@synthesize path;
@synthesize query;
@synthesize get;

/*- (id)init {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	host = @"127.0.0.1";
	path = @"/";
	query = @"";
	
	return self;
}*/

- (id)initWithRequest:(CTRequest *)request {
	return [self initWithDictionary:request.env];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
	self = [self init];
	if (!self) {
		return nil;
	}
	
	env = [[NSDictionary alloc] initWithDictionary:dictionary];
	
	host = [env objectForKey:@"SERVER_NAME"];
	if (nil == host) {
		NSLog(@"WARNING: FastCGI application loaded without SERVER_NAME, falling back to 127.0.0.1");
		host = @"127.0.0.1";
	}
	
	path = [env objectForKey:@"SCRIPT_NAME"];
	if (nil == path) {
		NSLog(@"WARNING: FastCGI application loaded without SCRIPT_NAME, falling back to /");
		path = @"/";
	} else if ([path isEqual:@""]) {
		path = @"/";
	}
	
	query = [env objectForKey:@"QUERY_STRING"];
	if (nil == query) {
		query = @"";
	}
	
	NSString *queryWithLeadingQuestionMark = @"";
	if (![query isEqual:@""]) {
		queryWithLeadingQuestionMark = [NSString stringWithFormat:@"?%@", query];
	}
	
	NSString *uri = [NSString stringWithFormat:@"%@%@",
					 [path stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
					 queryWithLeadingQuestionMark];
	
	url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@%@", host, uri]];
	
	get = [[NSDictionary alloc] initByParsingQueryString:query withEncoding:NSASCIIStringEncoding];
	
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

- (void)dealloc {
	[env release];
	[url release];
	[host release];
	[path release];
	[query release];
	[get release];
	[super dealloc];
}

@end
