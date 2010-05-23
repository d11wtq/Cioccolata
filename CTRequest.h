//
//  CTRequest.h
//  Cioccolata
//
//  Created by Chris Corbyn on 24/04/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//


/*!
 * An HTTP request received from the client.
 */
@interface CTRequest : NSObject {
	NSDictionary *env;
	NSURL *url;
	NSString *path;
	NSString *query;
	NSDictionary *get;
}


/*!
 * The full list of environment variables available to the web application.
 */
@property (readonly) NSDictionary *env;

/*!
 * The absolute URL as derived from the FastCGI environment.
 * 
 * You should be aware that CGI does not provide a mechanism for determing if the request is HTTPS or HTTP.
 */
@property (readonly) NSURL *url;

/*!
 * The path portion of the request URI.
 */
@property (readonly) NSString *path;

/*!
 * The query string portion of the request URI.
 */
@property (readonly) NSString *query;

/*!
 * The full list of GET parameters, which may be multi-dimensional in structure.
 */
@property (readonly) NSDictionary *get;


#pragma mark -
#pragma mark Initialization methods

/*!
 * Initialize a new request based on the given request.
 */
- (id)initWithRequest:(CTRequest *)request;

/*!
 * Initialize a request using the given environment variables.
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;


#pragma mark -
#pragma mark Request data accessors

/*!
 * @brief	Get a parameter from the request, searching GET, then POST.
 * 
 * @param	paramName The name of the paramater to return.
 * 
 * @return	Usually an NSString or an NSDictionary.  Returns nil if the parameter does not exist.
 */
- (id)param:(NSString *)paramName;

/*!
 * @brief	Get a parameter from the request, specifying where the parameter should be expected.
 * 
 * @param	paramName The name of the parameter to return
 * @param	method The HTTP method used to send the parameter, GET or POST.
 * 
 * @return	Usually an NSString or an NSDictionary.  Returns nil if the parameter does not exist.
 */
- (id)param:(NSString *)paramName method:(NSString *)method;

@end
