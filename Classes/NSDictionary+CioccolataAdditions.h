//
//  NSDictionary+CioccolataAdditions.h
//  Cioccolata
//
//  Created by Chris Corbyn on 23/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//


/*!
 * Utility methods added to NSDictionary.
 */
@interface NSDictionary(CioccolataAdditions)


/*!
 * Create a dictionary by parsing the components of the given query string.
 * 
 * @param		The encoded query string to parse, without the leading question mark.
 * 
 * @returns		A tree structure based around NSDictionary, containing the parameters in the query string.
 */
+ (NSDictionary *)dictionaryByParsingQueryString:(NSString *)queryString;

/*!
 * Create a dictionary by parsing the components of the given query string.
 *
 * @param		The encoded query string to parse, without the leading question mark.
 * 
 * @returns		A tree structure based around NSDictionary, containing the parameters in the query string.
 */
- (id)initByParsingQueryString:(NSString *)queryString;


@end
