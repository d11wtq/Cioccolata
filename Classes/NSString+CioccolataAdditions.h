//
//  NSString+CioccolataAdditions.h
//  Cioccolata
//
//  Created by Chris Corbyn on 31/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//


@interface NSString(CioccolataAdditions)

/*!
 * @brief	Returns the URL-encoded form of the string, according to RFC 3986.
 *			Percent encoding, using UTF-8 is used, except on the space character which use a "+" character.
 *			NOTE: If you need %20 instead of +, use -rawURLEncodedString.
 * 
 * @returns	The encoded string, in the UTF-8 encoding.
 */
- (NSString *)URLEncodedString;

/*!
 * @brief	Returns the URL-encoded form of the string, using %20 for spaces.
 * 
 * @returns	The encoded string, in the UTF-8 encoding.
 */
- (NSString *)rawURLEncodedString;

/*!
 * Returns the URL-decoded form of the string, according to RFC 3986.
 * 
 * @returns	The decoded string, assuming UTF-8 encoding.
 */
- (NSString *)URLDecodedString;

@end
