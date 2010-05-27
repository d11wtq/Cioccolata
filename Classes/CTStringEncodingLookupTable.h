//
//  CTStringEncodingLookupTable.h
//  Cioccolata
//
//  Created by Chris Corbyn on 27/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

/*! @privatesection */


/*!
 * Maps IANA charset names to NSStringEncoding values.
 */
@interface CTStringEncodingLookupTable : NSObject {
	NSDictionary *lookupTable;
	NSStringEncoding defaultEncoding;
}

- (id)initWithDefaultEncoding:(NSStringEncoding)encoding;
- (NSStringEncoding)encodingForCharsetName:(NSString *)charsetName;

@end
