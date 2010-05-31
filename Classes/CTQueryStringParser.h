//
//  CTQueryStringParser.h
//  Cioccolata
//
//  Created by Chris Corbyn on 23/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

/*!
 * @privatesection
 */

/*!
 * Parses encoded HTTP request query strings into multi-dimensional NSDictionary objects.
 */
@interface CTQueryStringParser : NSObject {

}


/*!
 * Produce an NSDictionary from the given query string.
 * 
 * @param	The query string, without the leading question mark.
 * 
 * @return	An NSDictionary, possibly multi-dimensional depending on the contents of the string.
 */
- (NSDictionary *)parseQuery:(NSString *)queryString;

#pragma mark -
#pragma mark Internal parsing methods

- (void)parseKeysFromEncodedString:(NSString *)string intoArray:(NSMutableArray *)array indexCatalog:(NSMutableDictionary *)indexCatalog;

- (void)copyValue:(id)value toDictionary:(NSMutableDictionary *)dictionary usingKeys:(NSArray *)keys;

@end
