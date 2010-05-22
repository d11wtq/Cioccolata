//
//  NSDictionary+CioccolataAdditionsTest.m
//  Cioccolata
//
//  Created by Chris Corbyn on 23/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#import "NSDictionary+CioccolataAdditionsTest.h"
#import "NSDictionary+CioccolataAdditions.h"


@implementation NSDictionary_CioccolataAdditionsTest

- (void)testGETParametersAreParsedFromQueryString {
	NSDictionary *dict = [NSDictionary dictionaryByParsingQueryString:@"q=a%20b&c=3" withEncoding:NSASCIIStringEncoding];
	GHAssertEqualStrings(@"a b", [dict objectForKey:@"q"], @"Parameter q should be URL-decoded a%20b");
	GHAssertEqualStrings(@"3", [dict objectForKey:@"c"], @"Parameter c should be 3");
}

- (void)testGETParametersCanHaveNamedDictionaryKeys {
	NSDictionary *dict = [NSDictionary dictionaryByParsingQueryString:@"q[foo]=a&c=3&q[bar]=b" withEncoding:NSASCIIStringEncoding];
	NSDictionary *q = [dict objectForKey:@"q"];
	GHAssertEqualStrings(@"a", [q objectForKey:@"foo"], @"Parameter q should be a dictionary with key foo = a");
	GHAssertEqualStrings(@"b", [q objectForKey:@"bar"], @"Parameter q should be a dictionary with key bar = b");
}

- (void)testGETParametersWithEmptyBracesAppendNumericalKeysToDictionary {
	NSDictionary *dict = [NSDictionary dictionaryByParsingQueryString:@"q[]=a&c=3&q[]=b" withEncoding:NSASCIIStringEncoding];
	NSDictionary *q = [dict objectForKey:@"q"];
	GHAssertEqualStrings(@"a", [q objectForKey:[NSNumber numberWithInt:0]], @"Parameter q should be a dictionary with key 0 = a");
	GHAssertEqualStrings(@"b", [q objectForKey:[NSNumber numberWithInt:1]], @"Parameter q should be a dictionary with key 1 = b");
}

- (void)testGETParametersCanExpresslySetNumericalKeysInDictionary {
	NSDictionary *dict = [NSDictionary dictionaryByParsingQueryString:@"q[]=a&q[7]=b&q[]=c" withEncoding:NSASCIIStringEncoding];
	NSDictionary *q = [dict objectForKey:@"q"];
	GHAssertEqualStrings(@"a", [q objectForKey:[NSNumber numberWithInt:0]], @"Parameter q should be a dictionary with key 0 = a");
	GHAssertEqualStrings(@"b", [q objectForKey:[NSNumber numberWithInt:7]], @"Parameter q should be a dictionary with key 7 = b");
	GHAssertEqualStrings(@"c", [q objectForKey:[NSNumber numberWithInt:8]], @"Parameter q should be a dictionary with key 8 = c");
}

@end
