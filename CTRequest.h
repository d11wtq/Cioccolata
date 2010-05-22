//
//  CTRequest.h
//  Cioccolata
//
//  Created by Chris Corbyn on 24/04/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

/*!
 @header	CTRequest
 @abstract	A FastCGI web-application framework for Objective-C
 */


/*!
 * @class		CTRequest
 * @toc			CTRequest
 * @abstract	An HTTP request received from the client.
 */
@interface CTRequest : NSObject {
	NSDictionary *env;
	NSURL *url;
	NSString *path;
	NSString *query;
	NSDictionary *get;
}

/*!
 * @method
 * @tocgroup	Request data accessors
 * @abstract	The full list of environment variables available to the web application.
 * 
 * @result		Returns an NSDictionary containing the environment verbatim.
 */
@property (readonly) NSDictionary *env;

/*!
 * @method
 * @tocgroup	Request data accessors
 * @abstract	The absolute URL as derived from the FastCGI environment.
 * @discussion	You should be aware that CGI does not provide a mechanism for determing if the request is HTTPS or HTTP.
 * 
 * @result		An NSURL that can be introspected.
 */
@property (readonly) NSURL *url;

/*!
 * @method
 * @tocgroup	Request data accessors
 * @abstract	The path portion of the request URI.
 * 
 * @result		Returns an NSString containing the URL-decoded path.
 */
@property (readonly) NSString *path;

/*!
 * @method
 * @tocgroup	Request data accessors
 * @abstract	The query string portion of the request URI.
 * 
 * @result		Returns an NSString containing the query string verbatim.
 */
@property (readonly) NSString *query;

/*!
 * @method
 * @tocgroup	Request data accessors
 * @abstract	The full list of GET parameters.
 * 
 * @result		Returns an NSDictionary containing the URL-decoded GET parameters.
 */
@property (readonly) NSDictionary *get;


#pragma mark -
#pragma mark Initialization methods

/*!
 * @method
 * @tocgroup	Initialization Methods
 * @abstract	Initialize a new request based on the given request.
 */
- (id)initWithRequest:(CTRequest *)request;

/*!
 * @method
 * @tocgroup	Initialization Methods
 * @abstract	Initialize a request using the given environment variables.
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

#pragma mark -
#pragma mark Request data accessors

/*!
 * @method
 * tocgroup		Request data accessors
 * @abstract	Get a parameter from the request, searching GET, then POST.
 * 
 * @param		paramName The name of the paramater to return.
 * 
 * @result		Usually returns an NSString or an NSDictionary.  Returns nil if the parameter does not exist.
 */
- (id)param:(NSString *)paramName;

/*!
 * @method
 * @tocgroup	Request data accessors
 * @abstract	Get a parameter from the request, specifying where the parameter should be expected.
 * 
 * @param		paramName The name of the parameter to return
 * @param		method The HTTP method used to send the parameter, GET or POST.
 * 
 * @result		Usually returns an NSString or an NSDictionary.  Returns nil if the parameter does not exist.
 */
- (id)param:(NSString *)paramName method:(NSString *)method;

#pragma mark -
#pragma mark Utility methods

/*!
 * @method
 * @tocgroup	Utility methods
 * @abstract	Parse a query string formatted according to RFC 2396.
 * 
 * @param		The RFC 2396 formatted query string.
 * 
 * @result		Returns an NSDictionary containing the parameters parsed from the string.
 */
- (NSDictionary *)parseQuery:(NSString *)queryString;

@end
