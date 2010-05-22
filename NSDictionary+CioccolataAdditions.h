//
//  NSDictionary+CioccolataAdditions.h
//  Cioccolata
//
//  Created by Chris Corbyn on 23/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//


/*!
 @header	NSDictionary(CioccolataAdditions)
 @abstract	A FastCGI web-application framework for Objective-C
 */


/*!
 * @class		NSDictionary(CioccolataAdditions)
 * @toc			NSDictionary(CioccolataAdditions)
 * @abstract	Utility methods added to NSDictionary.
 */
@interface NSDictionary(CioccolataAdditions)

/*!
 * @method
 * @tocgroup	Initialization methods
 * @abstract	Create a dictionary by parsing the components of the given query string.
 * 
 * @result		Returns a tree structure based around NSDictionary, containing the parameters in the query string.
 */
+ (NSDictionary *)dictionaryByParsingQueryString:(NSString *)queryString withEncoding:(NSStringEncoding)encoding;

/*!
 * @method
 * @tocgroup	Initialization methods
 * @abstract	Create a dictionary by parsing the components of the given query string.
 * 
 * @result		Returns a tree structure based around NSDictionary, containing the parameters in the query string.
 */
- (id)initByParsingQueryString:(NSString *)queryString withEncoding:(NSStringEncoding)encoding;

@end
