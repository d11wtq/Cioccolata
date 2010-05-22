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
	// TODO: Move this to a category on NSDictionary -dictionaryByParsingQueryString:withEncoding:
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	NSArray *pairs = [queryString componentsSeparatedByString:@"&"];
	
	for (NSString *pair in pairs) {
		NSRange eqRange = [pair rangeOfString:@"="];
		
		NSString *encodedKey;
		NSString *key;
		NSMutableArray *subKeys = [NSMutableArray array];
		id value;
		
		// Parameter does not have an explicit value
		if (eqRange.location == NSNotFound) {
			encodedKey = pair;
			value = @"";
		} else {
			encodedKey = [pair substringToIndex:eqRange.location];
			if ([pair length] > eqRange.location + 1) {
				value = [[pair substringFromIndex:eqRange.location + 1] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
			} else {
				value = @"";
			}
		}
		
		NSRange braceOpen = [encodedKey rangeOfString:@"["];
		
		// Parameter contains braces; parse out the key(s)
		if (NSNotFound != braceOpen.location) {
			key = [[encodedKey substringToIndex:braceOpen.location] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
			do {
				if ([encodedKey length] <= braceOpen.location + 1) {
					break;
				}
				
				encodedKey = [encodedKey substringFromIndex:braceOpen.location + 1];
				
				NSRange braceClose = [encodedKey rangeOfString:@"]"];
				if (NSNotFound == braceClose.location) {
					break;
				}
				
				[subKeys addObject:[[encodedKey substringToIndex:braceClose.location] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
				
				braceOpen = [encodedKey rangeOfString:@"["];
			} while (NSNotFound != braceOpen.location);
		} else {
			key = [encodedKey stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		}
		
		// If adding to a dictionary
		if ([subKeys count] > 0) {
			
			// Consider consolidating the main key into a "keys" array
			id existingDictionary = [params objectForKey:key];
			if (![existingDictionary isKindOfClass:[NSDictionary class]]) {
				existingDictionary = [NSMutableDictionary dictionary];
				[params setObject:existingDictionary forKey:key];
			}
			
			// existingDictionary = params.q
			
			NSInteger index = 0, count = [subKeys count];
			
			for (id subKey in subKeys) {
				if (++index == count) {
					break; // The end key is a node
				}
				
				id subDictionary = [existingDictionary objectForKey:subKey];
				if (![subDictionary isKindOfClass:[NSDictionary class]]) {
					subDictionary = [NSMutableDictionary dictionary];
					[existingDictionary setObject:subDictionary forKey:subKey];
				}
				
				existingDictionary = subDictionary;
			}
			
			// existingDictionary = params.q.foo
			
			[existingDictionary setObject:value forKey:[subKeys lastObject]];
		} else {
			[params setObject:value forKey:key];
		}
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
