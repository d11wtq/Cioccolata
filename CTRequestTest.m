//
//  CTRequestTest.m
//  Cioccolata
//
//  Created by Chris Corbyn on 19/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#import "CTRequestTest.h"
#import "CTRequest.h"

@implementation CTRequestTest

- (void)testPathIsReadFromEnv {
	NSDictionary *envDict = [NSDictionary dictionaryWithObjectsAndKeys:@"REQUEST_URI", @"/path/to/resource?query=string", nil];
	CTRequest *req = [[CTRequest alloc] initWithDictionary:envDict];
	STAssertEquals(@"/path/to/resource", req.path, @"Resource path should be deduced from URI");
	[req release];
}

@end
