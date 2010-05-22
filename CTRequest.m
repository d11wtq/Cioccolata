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
		NSMutableArray *keys = [NSMutableArray array];
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
			[keys addObject:[[encodedKey substringToIndex:braceOpen.location]
							 stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
			
			do {
				if ([encodedKey length] <= braceOpen.location + 1) {
					break;
				}
				
				encodedKey = [encodedKey substringFromIndex:braceOpen.location + 1];
				
				NSRange braceClose = [encodedKey rangeOfString:@"]"];
				if (NSNotFound == braceClose.location) {
					break;
				}
				
				[keys addObject:[[encodedKey substringToIndex:braceClose.location] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
				
				braceOpen = [encodedKey rangeOfString:@"["];
			} while (NSNotFound != braceOpen.location);
		} else {
			[keys addObject:[encodedKey stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
		}
		
		NSMutableDictionary *currentContainer = params;
		
		NSInteger index = 0, count = [keys count];
		
		for (id key in keys) {
			if (++index == count) {
				break; // The last key is always a node, set after the loop
			}
			
			// Insert a child if not already present
			id childContainer = [currentContainer objectForKey:key];
			if (![childContainer isKindOfClass:[NSDictionary class]]) {
				childContainer = [NSMutableDictionary dictionary];
				[currentContainer setObject:childContainer forKey:key];
			}
			
			// Walk deeper
			currentContainer = childContainer;
		}
		
		// Finally apply the value inside it's designated container
		[currentContainer setObject:value forKey:[keys lastObject]];
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
