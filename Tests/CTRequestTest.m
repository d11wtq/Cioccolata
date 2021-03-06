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
	GHAssertEqualStrings(@"x", [req.env objectForKey:@"Y"], @"Dictionary should provide environment");
	GHAssertEqualStrings(@"z", [req.env objectForKey:@"A"], @"Dictionary should provide environment");
	[req release];
}

- (void)testRequestMethodIsInferredFromRequestMethodVariable {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"PUT", @"REQUEST_METHOD", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(CTRequestMethodPUT, req.method, @"Request method should be copied from REQUEST_METHOD");
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
	GHAssertEqualStrings(@"a b", [req param:@"q" method:CTRequestMethodGET], @"Parameter q should be URL-decoded a%20b");
	GHAssertEqualStrings(@"3", [req param:@"c" method:CTRequestMethodGET], @"Parameter c should be 3");
	[req release];
}

- (void)testPlusInQueryStringIsDecodedAsSpace {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q=a+b", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"a b", [req param:@"q" method:CTRequestMethodGET], @"Parameter q should be URL-decoded a%20b");
	[req release];
}

- (void)testGETParametersCanHaveNamedDictionaryKeys {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q[foo]=a&c=3&q[bar]=b", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	NSDictionary *q = [req param:@"q" method:CTRequestMethodGET];
	GHAssertEqualStrings(@"a", [q objectForKey:@"foo"], @"Parameter q should be a dictionary with key foo = a");
	GHAssertEqualStrings(@"b", [q objectForKey:@"bar"], @"Parameter q should be a dictionary with key bar = b");
	[req release];
}

- (void)testGETParametersWithEmptyBracesAppendNumericalKeysToDictionary {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q[]=a&c=3&q[]=b", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	NSDictionary *q = [req param:@"q" method:CTRequestMethodGET];
	GHAssertEqualStrings(@"a", [q objectForKey:[NSNumber numberWithInt:0]], @"Parameter q should be a dictionary with key 0 = a");
	GHAssertEqualStrings(@"b", [q objectForKey:[NSNumber numberWithInt:1]], @"Parameter q should be a dictionary with key 1 = b");
	[req release];
}

- (void)testGETParametersCanExpresslySetNumericalKeysInDictionary {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q[]=a&q[7]=b&q[]=c", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	NSDictionary *q = [req param:@"q" method:CTRequestMethodGET];
	GHAssertEqualStrings(@"a", [q objectForKey:[NSNumber numberWithInt:0]], @"Parameter q should be a dictionary with key 0 = a");
	GHAssertEqualStrings(@"b", [q objectForKey:[NSNumber numberWithInt:7]], @"Parameter q should be a dictionary with key 7 = b");
	GHAssertEqualStrings(@"c", [q objectForKey:[NSNumber numberWithInt:8]], @"Parameter q should be a dictionary with key 8 = c");
	[req release];
}

- (void)testMultiDimensionalDictionariesCanBeUsedInQueryString {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q[a][][2]=a&q[a][0][]=b", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	NSDictionary *q = [req param:@"q" method:CTRequestMethodGET];
	NSDictionary *q_A = [q objectForKey:@"a"];
	NSDictionary *q_A_0 = [q_A objectForKey:[NSNumber numberWithInt:0]];
	
	GHAssertEqualStrings(@"a", [q_A_0 objectForKey:[NSNumber numberWithInt:2]], @"Parameter q should be a dictionary with key [a][0][2] = a");
	GHAssertEqualStrings(@"b", [q_A_0 objectForKey:[NSNumber numberWithInt:3]], @"Parameter q should be a dictionary with key [a][0][3] = b");
	[req release];
}

- (void)testSpuriousOpeningBraceInQueryStringIsAccepted {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q[foo[]=a", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	NSDictionary *q = [req param:@"q" method:CTRequestMethodGET];
	GHAssertEqualStrings(@"a", [q objectForKey:@"foo["], @"Parameter q should be a dictionary with key foo[ = a");
	[req release];
}

- (void)testSpuriousTrailingClosingBraceInQueryStringIsIgnored {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"q[foo]]=a", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	NSDictionary *q = [req param:@"q" method:CTRequestMethodGET];
	GHAssertEqualStrings(@"a", [q objectForKey:@"foo"], @"Parameter q should be a dictionary with key foo = a");
	[req release];
}

- (void)testSpuriousLeadingAndTrailingBracesInQueryStringAreAccepted {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"]q]=a", @"QUERY_STRING", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"a", [req param:@"]q]" method:CTRequestMethodGET], @"Parameter ]q] should be 'a'");
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
	GHAssertEqualStrings(@"utf-8", req.charsetName, @"Charset name should be inferred from HTTP_CONTENT_TYPE");
	[req release];
}

- (void)testUppercasedCharsetIsInferredFromContentTypeHeader {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=UTF-8", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"UTF-8", req.charsetName, @"Charset name should be inferred from HTTP_CONTENT_TYPE");
	[req release];
}

- (void)testMimeTypeIsInferredFromContentTypeHeader {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"application/xml", req.mimeType, @"MIME type should be inferred from HTTP_CONTENT_TYPE");
	[req release];
}

- (void)testMimeTypeIsInferredFromContentTypeHeaderWithCharset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=utf-8", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEqualStrings(@"application/xml", req.mimeType, @"MIME type should be inferred from HTTP_CONTENT_TYPE");
	[req release];
}

- (void)testStringEncodingForASCIICharset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=us-ascii", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSASCIIStringEncoding, req.stringEncoding, @"String encoding should be for US-ASCII");
	[req release];
}

- (void)testStringEncodingForUTF8Charset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=utf-8", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSUTF8StringEncoding, req.stringEncoding, @"String encoding should be for UTF-8");
	[req release];
}

- (void)testStringEncodingForLatin1Charset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=iso-8859-1", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSISOLatin1StringEncoding, req.stringEncoding, @"String encoding should be for ISO-8859-1");
	[req release];
}

- (void)testStringEncodingForLatin2Charset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=iso-8859-2", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSISOLatin2StringEncoding, req.stringEncoding, @"String encoding should be for ISO-8859-2");
	[req release];
}

- (void)testStringEncodingForUTF16Charset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=UTF-16", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSUnicodeStringEncoding, req.stringEncoding, @"String encoding should be for unicode");
	[req release];
}

- (void)testStringEncodingForWindows1250Charset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=windows-1250", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSWindowsCP1250StringEncoding, req.stringEncoding, @"String encoding should be for Windows-1250");
	[req release];
}

- (void)testStringEncodingForWindows1251Charset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=windows-1251", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSWindowsCP1251StringEncoding, req.stringEncoding, @"String encoding should be for Windows-1251");
	[req release];
}

- (void)testStringEncodingForWindows1252Charset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=windows-1252", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSWindowsCP1252StringEncoding, req.stringEncoding, @"String encoding should be for Windows-1252");
	[req release];
}

- (void)testStringEncodingForWindows1253Charset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=windows-1253", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSWindowsCP1253StringEncoding, req.stringEncoding, @"String encoding should be for Windows-1253");
	[req release];
}

- (void)testStringEncodingForWindows1254Charset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=windows-1254", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSWindowsCP1254StringEncoding, req.stringEncoding, @"String encoding should be for Windows-1254");
	[req release];
}

- (void)testStringEncodingForISO2022JPCharset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=ISO-2022-JP", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSISO2022JPStringEncoding, req.stringEncoding, @"String encoding should be for ISO-2022-JP");
	[req release];
}

- (void)testStringEncodingForShift_JISCharset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=Shift_JIS", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSShiftJISStringEncoding, req.stringEncoding, @"String encoding should be for Shift_JIS");
	[req release];
}

- (void)testStringEncodingForEUC_JPCharset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=EUC-JP", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSJapaneseEUCStringEncoding, req.stringEncoding, @"String encoding should be for EUC-JP");
	[req release];
}

- (void)testStringEncodingForUTF32Charset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=utf-32", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSUTF32StringEncoding, req.stringEncoding, @"String encoding should be for UTF-32");
	[req release];
}

- (void)testStringEncodingForUTF32BECharset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=utf-32BE", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSUTF32BigEndianStringEncoding, req.stringEncoding, @"String encoding should be for UTF-32BE");
	[req release];
}

- (void)testStringEncodingForUTF32LECharset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=utf-32LE", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSUTF32LittleEndianStringEncoding, req.stringEncoding, @"String encoding should be for UTF-32LE");
	[req release];
}

- (void)testStringEncodingForUTF16BECharset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=utf-16BE", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSUTF16BigEndianStringEncoding, req.stringEncoding, @"String encoding should be for UTF-16BE");
	[req release];
}

- (void)testStringEncodingForUTF16LECharset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=utf-16LE", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSUTF16LittleEndianStringEncoding, req.stringEncoding, @"String encoding should be for UTF-16LE");
	[req release];
}

- (void)testStringEncodingForMacintoshCharset {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/xml; charset=macintosh", @"HTTP_CONTENT_TYPE", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict];
	GHAssertEquals((NSStringEncoding) NSMacOSRomanStringEncoding, req.stringEncoding, @"String encoding should be for mac");
	[req release];
}

- (void)testRequestContentMatchesContentProvidedDuringInitialization {
	uint8_t b[] = {'f', 'o', 'o', 'b', 'a', 'r'};
	NSData *data = [NSData dataWithBytes:b length:6];
	NSDictionary *dict = [NSDictionary dictionary];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict content:data];
	GHAssertTrue([data isEqualToData:req.content], @"Request content should be equal to the data given");
	[req release];
}

- (void)testRequestPostDataIsParsedFromX_Www_Form_UrlEncodedContent {
	char *body = "foo=bar&x=a%20b";
	NSData *data = [NSData dataWithBytes:body length:strlen(body)];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/x-www-form-urlencoded", @"HTTP_CONTENT_TYPE",
						  @"POST", @"REQUEST_METHOD", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict content:data];
	GHAssertEqualStrings(@"bar", [req param:@"foo" method:CTRequestMethodPOST], @"POST var foo should equal 'bar'");
	GHAssertEqualStrings(@"a b", [req param:@"x" method:CTRequestMethodPOST], @"POST var x should equal 'a b'");
	[req release];
}

- (void)testRequestComplexDictionaryPostDataIsParsedFromX_Www_Form_UrlEncodedContent {
	char *body = "q[a][][2]=a&q[a][0][]=b";
	NSData *data = [NSData dataWithBytes:body length:strlen(body)];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/x-www-form-urlencoded", @"HTTP_CONTENT_TYPE",
						  @"POST", @"REQUEST_METHOD", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict content:data];
	NSDictionary *q = [req param:@"q" method:CTRequestMethodPOST];
	NSDictionary *q_A = [q objectForKey:@"a"];
	NSDictionary *q_A_0 = [q_A objectForKey:[NSNumber numberWithInt:0]];
	
	GHAssertEqualStrings(@"a", [q_A_0 objectForKey:[NSNumber numberWithInt:2]], @"Parameter q should be a dictionary with key [a][0][2] = a");
	GHAssertEqualStrings(@"b", [q_A_0 objectForKey:[NSNumber numberWithInt:3]], @"Parameter q should be a dictionary with key [a][0][3] = b");
	[req release];
}

- (void)testPOSTParametersCanBeAccesedAsADictionary {
	char *body = "q=a%20b&c=3";
	NSData *data = [NSData dataWithBytes:body length:strlen(body)];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/x-www-form-urlencoded", @"HTTP_CONTENT_TYPE",
						  @"POST", @"REQUEST_METHOD", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:dict content:data];
	GHAssertEqualStrings(@"a b", [req.post objectForKey:@"q"], @"Parameter q should be URL-decoded a%20b");
	GHAssertEqualStrings(@"3", [req.post objectForKey:@"c"], @"Parameter c should be 3");
	[req release];
}

@end
