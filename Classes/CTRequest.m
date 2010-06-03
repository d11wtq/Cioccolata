//
//  CTRequest.m
//  Cioccolata
//
//  Created by Chris Corbyn on 24/04/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#import "CTRequest.h"
#import "NSDictionary+CioccolataAdditions.h"
#import "NSString+CioccolataAdditions.h"
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
@synthesize post;
@synthesize ip;
@synthesize method;
@synthesize charsetName;
@synthesize mimeType;
@synthesize stringEncoding;
@synthesize content;

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
	
	NSString *uri = [NSString stringWithFormat:@"%@%@", [path rawURLEncodedString], queryWithLeadingQuestionMark];
	
	isSSL = [[env objectForKey:@"HTTPS"] isEqual:@"on"];
	
	NSString *hostWithPort = host;
	if ((isSSL && port != (NSInteger) 443) || (!isSSL && port != (NSInteger) 80)) {
		hostWithPort = [NSString stringWithFormat:@"%@:%d", host, port];
	}
	
	url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@://%@%@", (isSSL ? @"https" : @"http"), hostWithPort, uri]];
	
	get = [[NSDictionary alloc] initByParsingQueryString:query];
	
	ip = [env objectForKey:@"REMOTE_ADDR"];
	
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary content:(NSData *)data {
	self = [self initWithDictionary:dictionary];
	if (!self) {
		return nil;
	}
	
	content = [data retain];
	
	NSRange urlEncodedRange = [[self headerWithName:@"Content-Type"] rangeOfString:@"application/x-www-form-urlencoded"];
	if (urlEncodedRange.location != NSNotFound) {
		NSString *contentString = [[NSString alloc] initWithData:content encoding:self.stringEncoding];
		post = [[NSDictionary alloc] initByParsingQueryString:contentString];
		[contentString release];
	}
	
	return self;
}

- (id)param:(NSString *)paramName {
	id result = [self param:paramName method:CTRequestMethodPOST];
	if (nil == result) {
		result = [self param:paramName method:CTRequestMethodGET];
	}
	
	return result;
}

- (id)param:(NSString *)paramName method:(NSString *)methodName {
	if ([methodName isEqualToString:CTRequestMethodGET]) {
		return [get objectForKey:paramName];
	} else if ([methodName isEqualToString:CTRequestMethodPOST]) {
		return [post objectForKey:paramName];
	} else {
		@throw [NSException exceptionWithName:@"InvalidRequestMethodException" reason:@"Invalid request method" userInfo:nil];
	}
}

- (NSString *)headerWithName:(NSString *)headerName {
	NSString *canonicalizedName = [NSString stringWithFormat:@"HTTP_%@",
								   [[headerName uppercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@"_"]];
	return [env objectForKey:canonicalizedName];
}

- (NSStringEncoding)stringEncodingFromCharsetName:(NSString *)name {
	if (charsetLookupTable == nil) {
		// This will live on the heap forever.  It's a deliberate optimization.
		charsetLookupTable = [[CTStringEncodingLookupTable alloc] initWithDefaultEncoding:NSUTF8StringEncoding];
	}
	
	return [charsetLookupTable encodingForCharsetName:name];
}

- (void)dealloc {
	[env release];
	[url release];
	[get release];
	[post release];
	[charsetName release];
	[mimeType release];
	[content release];
	[super dealloc];
}

@end
