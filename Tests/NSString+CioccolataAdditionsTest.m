//
//  NSString+CioccolataAdditionsTest.m
//  Cioccolata
//
//  Created by Chris Corbyn on 31/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#import "NSString+CioccolataAdditionsTest.h"
#import "NSString+CioccolataAdditions.h"

@implementation NSString_CioccolataAdditionsTest

- (void)testURLDecodedStringDecodesPercentEscapesUsingUTF8 {
	GHAssertEqualStrings(@"\u00E8", [@"%C3%A8" URLDecodedString], @"%C3%A8 should be decoded as Unicode value 00E8 / 232 (è)");
}

- (void)testURLEncodedStringEncodesUTF8UsingPercentEscapes {
	GHAssertEqualStrings(@"%C3%A8", [@"\u00E8" URLEncodedString], @"Unicode value 00E8 / 232 (è) should be encoded as UTF-8 sequence C3A8");
}

- (void)testURLEncodedStringEncodesSpacesAsPlusSigns {
	GHAssertEqualStrings(@"a+b", [@"a b" URLEncodedString], @"Space should be encoded as \"+\"");
}

- (void)testRawURLEncodedStringEncodesSpacesAsPercentEscape {
	GHAssertEqualStrings(@"a%20b", [@"a b" rawURLEncodedString], @"Space should be encoded as %20");
}

@end
