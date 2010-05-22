//
//  CTRequestTest.m
//  Cioccolata
//
//  Created by Chris Corbyn on 21/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#import "CTRequestTest.h"
#import "CTRequest.h"

@implementation CTRequestTest

- (void)testEnvironmentIsReadFromDictionary {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"x", @"Y", @"z", @"A", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"x", [req.env objectForKey:@"Y"], @"Dictionary should provide enviornment");
	GHAssertEqualStrings(@"z", [req.env objectForKey:@"A"], @"Dictionary should provide enviornment");
	[req release];
}

- (void)testPathIsInferredFromScriptName {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"/a/b c", @"SCRIPT_NAME", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"/a/b c", req.path, @"Path should be read and decoded");
	[req release];
}

- (void)testPathIsCorrectInURL {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"/a/b c", @"SCRIPT_NAME", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"/a/b c", [req.url path], @"Path should be available in URL");
	[req release];
}

- (void)testQueryStringIsInferredFromEnvironment {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q=a%20b&c=3", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"q=a%20b&c=3", req.query, @"Query string should be taken from environment");
	[req release];
}

- (void)testQueryStringIsCorrectInURL {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q=a%20b&c=3", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"q=a%20b&c=3", [req.url query], @"Query string should be taken from environment");
	[req release];
}

- (void)testEmptyQueryString {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"", [req query], @"Empty query string should be handled gracefully");
	[req release];
}

- (void)testGETParametersAreParsedFromQueryString {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q=a%20b&c=3", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"a b", [req param:@"q"], @"Parameter q should be URL-decoded a%20b");
	GHAssertEqualStrings(@"3", [req param:@"c"], @"Parameter c should be 3");
	[req release];
}

- (void)testGETParametersCanHaveNamedDictionaryKeys {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q[foo]=a&c=3&q[bar]=b", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	NSDictionary *q = [req param:@"q"];
	GHAssertEqualStrings(@"a", [q objectForKey:@"foo"], @"Parameter q should be a dictionary with key foo = a");
	GHAssertEqualStrings(@"b", [q objectForKey:@"bar"], @"Parameter q should be a dictionary with key bar = b");
	[req release];
}

@end
