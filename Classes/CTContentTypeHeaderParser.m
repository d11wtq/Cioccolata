//
//  CTContentTypeHeaderParser.m
//  Cioccolata
//
//  Created by Chris Corbyn on 26/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#import "CTContentTypeHeaderParser.h"


@implementation CTContentTypeHeaderParser

+ (id)parserWithContentTypeHeader:(NSString *)headerString {
	return [[[self alloc] initWithContentTypeHeader:headerString] autorelease];
}

- (id)initWithContentTypeHeader:(NSString *)headerString {
	self = [self init];
	if (!self) {
		return nil;
	}
	
	NSMutableCharacterSet *alphaNumSet = [NSMutableCharacterSet alphanumericCharacterSet];
	
	NSMutableCharacterSet *mimeTypeSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"/-."];
	[mimeTypeSet formUnionWithCharacterSet:alphaNumSet];
	
	NSMutableCharacterSet *charsetSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"-_."];
	[charsetSet formUnionWithCharacterSet:alphaNumSet];
	
	// Initialize a case-insensitive scanner
	NSScanner *scanner = [NSScanner scannerWithString:headerString];
	[scanner setCaseSensitive:NO];
	
	// Scan everything up to the first parameter
	[scanner scanUpToString:@";" intoString:&mimeType];
	
	// Ignore quotes as well as whitespace
	[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"\r\n\t \""]];
	
	// Skip past the charset attribute declaration
	if ([scanner scanUpToString:@"charset=" intoString:NULL] && [scanner scanString:@"charset=" intoString:NULL]) {
		[scanner scanCharactersFromSet:charsetSet intoString:&charset];
	}
	
	[mimeType retain];
	[charset retain];
	
	return self;
}

- (NSString *)mimeType {
	return mimeType;
}

- (NSString *)charset {
	return charset;
}

- (void)dealloc {
	[mimeType release];
	[charset release];
	[super dealloc];
}

@end
