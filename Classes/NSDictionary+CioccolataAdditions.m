//
//  NSDictionary+CioccolataAdditions.m
//  Cioccolata
//
//  Created by Chris Corbyn on 23/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#import "NSDictionary+CioccolataAdditions.h"
#import "CTQueryStringParser.h"


@implementation NSDictionary(CioccolataAdditions)

+ (id)dictionaryByParsingQueryString:(NSString *)queryString withEncoding:(NSStringEncoding)encoding {
	return [[[self alloc] initByParsingQueryString:queryString withEncoding:encoding] autorelease];
}

- (id)initByParsingQueryString:(NSString *)queryString withEncoding:(NSStringEncoding)encoding {
	CTQueryStringParser *parser = [[CTQueryStringParser alloc] init];
	NSDictionary *params = [parser parseQuery:queryString usingEncoding:encoding];
	[parser release];
	
	return [self initWithDictionary:params];
}

@end
