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

+ (id)dictionaryByParsingQueryString:(NSString *)queryString {
	return [[[self alloc] initByParsingQueryString:queryString] autorelease];
}

- (id)initByParsingQueryString:(NSString *)queryString {
	CTQueryStringParser *parser = [[CTQueryStringParser alloc] init];
	NSDictionary *params = [parser parseQuery:queryString];
	[parser release];
	
	return [self initWithDictionary:params];
}

@end
