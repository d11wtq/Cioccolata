//
//  CTContentTypeHeaderParser.h
//  Cioccolata
//
//  Created by Chris Corbyn on 26/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

/*! @privatesection */

/*!
 * Parses the components out of a content-type header string.
 */
@interface CTContentTypeHeaderParser : NSObject {
	NSString *mimeType;
	NSString *charset;
}

+ (id)parserWithContentTypeHeader:(NSString *)headerString;
- (id)initWithContentTypeHeader:(NSString *)headerString;

- (NSString *)mimeType;
- (NSString *)charset;

@end
