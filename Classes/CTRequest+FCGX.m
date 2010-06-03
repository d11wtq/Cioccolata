//
//  CTRequest+FGCX.m
//  Cioccolata
//
//  Created by Chris Corbyn on 19/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#import "CTRequest+FCGX.h"


@implementation CTRequest(FCGX)

- (id)initWithFCGXRequest:(FCGX_Request)request {
	NSMutableDictionary *envDict = [[NSMutableDictionary alloc] init];
	
	for( ; *(request.envp) != NULL; request.envp++) {
		NSString *envString = [NSString stringWithCString:*(request.envp) encoding:NSUTF8StringEncoding];
		
		NSRange eqRange = [envString rangeOfString:@"="];
		
		if (eqRange.location == NSNotFound) {
			NSLog(@"Malformed string in request env: ignoring [%@]", envString);
			continue;
		}
		
		NSString *envName = [envString substringToIndex:eqRange.location];
		NSString *envValue;
		
		if ([envString length] <= eqRange.location + 1) {
			envValue = @"";
		} else {
			envValue = [envString substringFromIndex:eqRange.location + 1];
		}
		
		[envDict setObject:envValue forKey:envName];
	}
	
	NSMutableData *data = [[NSMutableData alloc] init];
	
	char charBuf[1024];
	int charsRead;
	while ((charsRead = FCGX_GetStr(charBuf, 1024, request.in)) > 0) {
		[data appendBytes:charBuf length:charsRead];
	}
	
	self = [self initWithDictionary:envDict content:data];
	
	[envDict release];
	[data release];
	
	if (!self) {
		return nil;
	}
	
	return self;
}

@end
