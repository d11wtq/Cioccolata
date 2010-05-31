//
//  NSString+CioccolataAdditions.m
//  Cioccolata
//
//  Created by Chris Corbyn on 31/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#import "NSString+CioccolataAdditions.h"


@implementation NSString(CioccolataAdditions)

- (NSString *)URLEncodedString {
	return [[self rawURLEncodedString] stringByReplacingOccurrencesOfString:@"%20" withString:@"+"];
}

- (NSString *)rawURLEncodedString {
	return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)URLDecodedString {
	return [[self stringByReplacingOccurrencesOfString:@"+" withString:@"%20"]
			stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
