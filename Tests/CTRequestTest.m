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

- (void)testRequestMethodIsInferredFromRequestMethodVariable {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"PUT", @"REQUEST_METHOD", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"PUT", req.method, @"Request method should be copied from REQUEST_METHOD");
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
	GHAssertEqualStrings(@"/a/b c", req.url.path, @"Path should be available in URL");
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
	GHAssertEqualStrings(@"q=a%20b&c=3", req.url.query, @"Query string should be taken from environment");
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

- (void)testGETParametersWithEmptyBracesAppendNumericalKeysToDictionary {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q[]=a&c=3&q[]=b", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	NSDictionary *q = [req param:@"q"];
	GHAssertEqualStrings(@"a", [q objectForKey:[NSNumber numberWithInt:0]], @"Parameter q should be a dictionary with key 0 = a");
	GHAssertEqualStrings(@"b", [q objectForKey:[NSNumber numberWithInt:1]], @"Parameter q should be a dictionary with key 1 = b");
	[req release];
}

- (void)testGETParametersCanExpresslySetNumericalKeysInDictionary {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q[]=a&q[7]=b&q[]=c", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	NSDictionary *q = [req param:@"q"];
	GHAssertEqualStrings(@"a", [q objectForKey:[NSNumber numberWithInt:0]], @"Parameter q should be a dictionary with key 0 = a");
	GHAssertEqualStrings(@"b", [q objectForKey:[NSNumber numberWithInt:7]], @"Parameter q should be a dictionary with key 7 = b");
	GHAssertEqualStrings(@"c", [q objectForKey:[NSNumber numberWithInt:8]], @"Parameter q should be a dictionary with key 8 = c");
	[req release];
}

- (void)testMultiDimensionalDictionariesCanBeUsedInQueryString {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q[a][][2]=a&q[a][0][]=b", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	NSDictionary *q = [req param:@"q"];
	NSDictionary *q_A = [q objectForKey:@"a"];
	NSDictionary *q_A_0 = [q_A objectForKey:[NSNumber numberWithInt:0]];
	
	GHAssertEqualStrings(@"a", [q_A_0 objectForKey:[NSNumber numberWithInt:2]], @"Parameter q should be a dictionary with key [a][0][2] = a");
	GHAssertEqualStrings(@"b", [q_A_0 objectForKey:[NSNumber numberWithInt:3]], @"Parameter q should be a dictionary with key [a][0][3] = b");
	[req release];
}

- (void)testSpuriousOpeningBraceInQueryStringIsAccepted {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q[foo[]=a", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	NSDictionary *q = [req param:@"q"];
	GHAssertEqualStrings(@"a", [q objectForKey:@"foo["], @"Parameter q should be a dictionary with key foo[ = a");
	[req release];
}

- (void)testSpuriousTrailingClosingBraceInQueryStringIsIgnored {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q[foo]]=a", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	NSDictionary *q = [req param:@"q"];
	GHAssertEqualStrings(@"a", [q objectForKey:@"foo"], @"Parameter q should be a dictionary with key foo = a");
	[req release];
}

- (void)testSpuriousLeadingAndTrailingBracesInQueryStringAreAccepted {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"]q]=a", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"a", [req param:@"]q]"], @"Parameter ]q] should be 'a'");
	[req release];
}

- (void)testGETParametersCanBeAccesedAsADictionary {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q=a%20b&c=3", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"a b", [req.get objectForKey:@"q"], @"Parameter q should be URL-decoded a%20b");
	GHAssertEqualStrings(@"3", [req.get objectForKey:@"c"], @"Parameter c should be 3");
	[req release];
}

- (void)testHostIsInferredFromServerName {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"www.cute-little-puppy-dogs.com", @"SERVER_NAME", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"www.cute-little-puppy-dogs.com", req.host, @"Host should be inferred from SEREVR_NAME");
	[req release];
}

- (void)testHostIsCorrectInURL {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"www.cute-little-puppy-dogs.com", @"SERVER_NAME", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"www.cute-little-puppy-dogs.com", req.url.host, @"Host should be inferred from SEREVR_NAME");
	[req release];
}

- (void)testPortIsInferredFromServerPort {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"80", @"SERVER_PORT", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSInteger) 80, req.port, @"Port should be inferred from SERVER_PORT");
	[req release];
}

- (void)testStandardPortIsLeftOutOfURL {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"80", @"SERVER_PORT", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertNil(req.url.port, @"Standard port should be left out of URL");
	[req release];
}

- (void)testNonStandardPortIsAddedToURL {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"8080", @"SERVER_PORT", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSInteger) 8080, [req.url.port integerValue], @"Standard port should included in URL");
	[req release];
}

- (void)testIsSSLCheckIsInferredFromHTTPSEvnironmentVariable {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	CTRequest *reqNonSSL = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertFalse(reqNonSSL.isSSL, @"SSL should be off since HTTPS is not set");
	[reqNonSSL release];
	
	[dict setObject:@"on" forKey:@"HTTPS"];
	CTRequest *reqSSL = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertTrue(reqSSL.isSSL, @"SSL should be on since HTTPS = on");
	[reqSSL release];
}

- (void)testPort443IsConsideredNonStandardIfNotSSL {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"443", @"SERVER_PORT", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSInteger) 443, [req.url.port integerValue], @"Port should be included in URL since 443 is a non-standard port when not SSL");
	[req release];
}

- (void)testPort443IsConsideredStandardForSSL {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"443", @"SERVER_PORT", @"on", @"HTTPS", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertNil(req.url.port, @"Port should not be included in URL since 443 is a standard port when SSL");
	[req release];
}

- (void)testPort80IsConsideredNonStandardForSSL {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"80", @"SERVER_PORT", @"on", @"HTTPS", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSInteger) 80, [req.url.port integerValue], @"Port should be included in URL since 80 is a non-standard port when SSL");
	[req release];
}

- (void)testURLSchemeIsHTTPSWhenSSLIsOn {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"on", @"HTTPS", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"https", req.url.scheme, @"URL scheme should be HTTPS since SSL is on");
	[req release];
}

- (void)testIPAdressIsInferredFromRemoteAddr {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"187.76.141.2", @"REMOTE_ADDR", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"187.76.141.2", req.ip, @"IP should be taken from REMOTE_ADDR");
	[req release];
}

- (void)testHTTPHeadersAreReturned {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"test", @"HTTP_X_TEST", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"test", [req headerWithName:@"X-Test"], @"Header value should be inferred from HTTP_X_TEST");
	[req release];
}

- (void)testCharsetIsInferredFromContentTypeHeader {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=utf-8", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"utf-8", [req charsetName], @"Charset name should be inferred from HTTP_CONTENT_TYPE");
	[req release];
}

@end
