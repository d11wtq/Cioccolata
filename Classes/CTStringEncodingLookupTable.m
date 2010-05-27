//
//  CTStringEncodingLookupTable.m
//  Cioccolata
//
//  Created by Chris Corbyn on 27/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#import "CTStringEncodingLookupTable.h"


@implementation CTStringEncodingLookupTable

- (id)initWithDefaultEncoding:(NSStringEncoding)encoding {
	self = [self init];
	if (!self) {
		return nil;
	}
	
	NSNumber *asciiEncoding =     [NSNumber numberWithUnsignedInteger:NSASCIIStringEncoding];
	NSNumber *iso8859_1Encoding = [NSNumber numberWithUnsignedInteger:NSISOLatin1StringEncoding];
	NSNumber *iso8859_2Encoding = [NSNumber numberWithUnsignedInteger:NSISOLatin2StringEncoding];
	NSNumber *utf8Encoding =      [NSNumber numberWithUnsignedInteger:NSUTF8StringEncoding];
	NSNumber *shiftJisEncoding =  [NSNumber numberWithUnsignedInteger:NSShiftJISStringEncoding];
	NSNumber *unicodeEncoding =   [NSNumber numberWithUnsignedInteger:NSUnicodeStringEncoding];
	NSNumber *cp1251Encoding =    [NSNumber numberWithUnsignedInteger:NSWindowsCP1251StringEncoding];
	NSNumber *cp1252Encoding =    [NSNumber numberWithUnsignedInteger:NSWindowsCP1252StringEncoding];
	NSNumber *cp1253Encoding =    [NSNumber numberWithUnsignedInteger:NSWindowsCP1253StringEncoding];
	NSNumber *cp1254Encoding =    [NSNumber numberWithUnsignedInteger:NSWindowsCP1254StringEncoding];
	NSNumber *cp1250Encoding =    [NSNumber numberWithUnsignedInteger:NSWindowsCP1250StringEncoding];
	NSNumber *macRomanEncoding =  [NSNumber numberWithUnsignedInteger:NSMacOSRomanStringEncoding];
	NSNumber *eucJpEncoding =     [NSNumber numberWithUnsignedInteger:NSJapaneseEUCStringEncoding];
	NSNumber *iso2022Encoding =   [NSNumber numberWithUnsignedInteger:NSISO2022JPStringEncoding];
	NSNumber *utf16BeEncoding =   [NSNumber numberWithUnsignedInteger:NSUTF16BigEndianStringEncoding];
	NSNumber *utf16LeEncoding =   [NSNumber numberWithUnsignedInteger:NSUTF16LittleEndianStringEncoding];
	NSNumber *utf32Encoding =     [NSNumber numberWithUnsignedInteger:NSUTF32StringEncoding];
	NSNumber *utf32BeEncoding =   [NSNumber numberWithUnsignedInteger:NSUTF32BigEndianStringEncoding];
	NSNumber *utf32LeEncoding =   [NSNumber numberWithUnsignedInteger:NSUTF32LittleEndianStringEncoding];
	
	lookupTable = [[NSDictionary alloc] initWithObjectsAndKeys:asciiEncoding, @"us-ascii",
				   asciiEncoding, @"ascii",
				   asciiEncoding, @"iso646-us",
				   asciiEncoding, @"us",
				   asciiEncoding, @"ibm367",
				   asciiEncoding, @"cp367",
				   
				   utf8Encoding, @"utf-8",
				   
				   unicodeEncoding, @"utf-16",
				   unicodeEncoding, @"iso-10646-ucs-2",
				   
				   iso8859_1Encoding, @"iso-8859-1",
				   iso8859_1Encoding, @"iso_8859-1",
				   iso8859_1Encoding, @"latin1",
				   iso8859_1Encoding, @"ibm819",
				   iso8859_1Encoding, @"cp819",
				   
				   iso8859_2Encoding, @"iso-8859-2",
				   iso8859_2Encoding, @"iso_8859-2",
				   iso8859_2Encoding, @"latin2",
				   
				   cp1250Encoding, @"windows-1250",
				   cp1251Encoding, @"windows-1251",
				   cp1252Encoding, @"windows-1252",
				   cp1253Encoding, @"windows-1253",
				   cp1254Encoding, @"windows-1254",
				   
				   iso2022Encoding, @"iso-2022-jp",
				   
				   shiftJisEncoding, @"shift_jis",
				   shiftJisEncoding, @"ms_kanji",
				   
				   eucJpEncoding, @"euc-jp",
				   
				   utf16BeEncoding, @"utf-16be",
				   utf16LeEncoding, @"utf-16le",
				   
				   utf32Encoding, @"utf-32",
				   utf32BeEncoding, @"utf-32be",
				   utf32LeEncoding, @"utf-32le",
				   
				   macRomanEncoding, @"macintosh",
				   macRomanEncoding, @"mac",
				   
				   nil];
	
	defaultEncoding = encoding;
	
	return self;
}

- (NSStringEncoding)encodingForCharsetName:(NSString *)charsetName {
	NSNumber *encoding = [lookupTable objectForKey:[charsetName lowercaseString]];
	return (encoding != nil) ? [encoding unsignedIntegerValue] : defaultEncoding;
	
}

- (void)dealloc {
	[lookupTable release];
	[super dealloc];
}

@end
