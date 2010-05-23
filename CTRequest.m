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
@synthesize port;
@synthesize path;
@synthesize query;
@synthesize isSSL;
@synthesize get;
@synthesize ip;

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
	
	port = [[env objectForKey:@"SERVER_PORT"] integerValue];
	
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
	
	isSSL = [[env objectForKey:@"HTTPS"] isEqual:@"on"];
	
	NSString *hostWithPort = host;
	if ((isSSL && port != 443) || (!isSSL && port != 80)) {
		hostWithPort = [NSString stringWithFormat:@"%@:%d", host, port];
	}
	
	url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@://%@%@", (isSSL ? @"https" : @"http"), hostWithPort, uri]];
	
	get = [[NSDictionary alloc] initByParsingQueryString:query withEncoding:NSASCIIStringEncoding];
	
	ip = [env objectForKey:@"REMOTE_ADDR"];
	
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

- (NSString *)headerWithName:(NSString *)headerName {
	NSString *canonicalizedName = [NSString stringWithFormat:@"HTTP_%@",
								   [[headerName uppercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@"_"]];
	return [env objectForKey:canonicalizedName];
}

- (void)dealloc {
	[env release];
	[url release];
	[host release];
	[path release];
	[query release];
	[get release];
	[ip release];
	[super dealloc];
}

@end
