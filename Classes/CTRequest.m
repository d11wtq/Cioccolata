//
//  CTRequest.m
//  Cioccolata
//
//  Created by Chris Corbyn on 24/04/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#import "CTRequest.h"
#import "NSDictionary+CioccolataAdditions.h"
#import "CTContentTypeHeaderParser.h"
#import "CTStringEncodingLookupTable.h"

static CTStringEncodingLookupTable *charsetLookupTable = nil;

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
@synthesize method;
@synthesize charsetName;
@synthesize mimeType;
@synthesize stringEncoding;

- (id)initWithRequest:(CTRequest *)request {
	return [self initWithDictionary:request.env];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
	self = [self init];
	if (!self) {
		return nil;
	}
	
	env = [dictionary retain];
	
	NSString *contentType = [self headerWithName:@"Content-Type"];
	if (nil != contentType) {
		CTContentTypeHeaderParser *parser = [CTContentTypeHeaderParser parserWithContentTypeHeader:contentType];
		charsetName = [parser.charset copy];
		mimeType = [parser.mimeType copy];
	}
	
	stringEncoding = [self stringEncodingFromCharsetName:charsetName];
	
	method = [env objectForKey:@"REQUEST_METHOD"];
	
	host = [env objectForKey:@"SERVER_NAME"];
	if (nil == host) {
		host = @"127.0.0.1";
	}
	
	port = (NSInteger) [[env objectForKey:@"SERVER_PORT"] integerValue];
	
	path = [env objectForKey:@"SCRIPT_NAME"];
	if (nil == path) {
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
					 [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
					 queryWithLeadingQuestionMark];
	
	isSSL = [[env objectForKey:@"HTTPS"] isEqual:@"on"];
	
	NSString *hostWithPort = host;
	if ((isSSL && port != (NSInteger) 443) || (!isSSL && port != (NSInteger) 80)) {
		hostWithPort = [NSString stringWithFormat:@"%@:%d", host, port];
	}
	
	url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@://%@%@", (isSSL ? @"https" : @"http"), hostWithPort, uri]];
	
	get = [[NSDictionary alloc] initByParsingQueryString:query withEncoding:NSUTF8StringEncoding];
	
	ip = [env objectForKey:@"REMOTE_ADDR"];
	
	return self;
}

- (id)param:(NSString *)paramName {
	id result = [self param:paramName method:@"POST"];
	if (nil == result) {
		result = [self param:paramName method:@"GET"];
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

- (NSStringEncoding)stringEncodingFromCharsetName:(NSString *)name {
	if (charsetLookupTable == nil) {
		// This way live on the heap forever.  It's a deliberate optimization.
		charsetLookupTable = [[CTStringEncodingLookupTable alloc] initWithDefaultEncoding:NSUTF8StringEncoding];
	}
	
	return [charsetLookupTable encodingForCharsetName:name];
}

- (void)dealloc {
	[env release];
	[url release];
	[host release];
	[path release];
	[query release];
	[get release];
	[ip release];
	[method release];
	[charsetName release];
	[mimeType release];
	[super dealloc];
}

@end
