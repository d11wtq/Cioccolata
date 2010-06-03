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
	NSString *host;
	NSInteger port;
	NSString *path;
	NSString *query;
	BOOL isSSL;
	NSDictionary *get;
	NSString *ip;
	NSString *method;
	NSString *charsetName;
	NSString *mimeType;
	NSStringEncoding stringEncoding;
	NSData *content;
	/* TODO:
	 post
	 inputStream
	 files
	 cookies
	 session - ?
	 */
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
 * The hostname portion of the URL.
 */
@property (readonly) NSString *host;

/*!
 * The port number on which the user is connected to the HTTP server.
 */
@property (readonly) NSInteger port;

/*!
 * The path portion of the request URI.
 */
@property (readonly) NSString *path;

/*!
 * The query string portion of the request URI.
 */
@property (readonly) NSString *query;

/*!
 * @brief	YES if SSL was automatically detected.
 *			This requires that the HTTP server sets the HTTPS environment variable to "on".
 */
@property (readonly) BOOL isSSL;

/*!
 * The full list of GET parameters, which may be multi-dimensional in structure.
 */
@property (readonly) NSDictionary *get;

/*!
 * @brief	The IP address of the client connecting to the server.
 *			It's important to note that this may not ultimately be the end-user's machine.
 */
@property (readonly) NSString *ip;

/*!
 * @brief	The HTTP request method used to send the request.
 *			One of GET, POST, PUT, DELETE, HEAD, or if implemented, a custom method.
 */
@property (readonly) NSString *method;

/*!
 * @brief	When specified in the request (i.e. during POST, PUT) indicates the charset of the request body.
 *			Note that this will be nil if not set in the request headers.
 * 
 * @see		#stringEncoding
 */
@property (readonly) NSString *charsetName;

/*!
 * @brief	When specified in the request (i.e. during POST, PUT) indicates the content-type of the request body.
 *			Note that this will be nil if not set in the request headers.
 */
@property (readonly) NSString *mimeType;

/*!
 * @brief	Get the appropriate NSStringEncoding for contents of the request body.
 *			If a charset was specified in the content-type header, the encoding is inferred from that, otherwise
 *			the default string encoding is returned.
 */
@property (readonly) NSStringEncoding stringEncoding;

/*!
 * @brief	The bytes from the body, with no interpretation based on the (possible) encoding.
 * 		This allows binary data to be sent in the request.  If you need a string, you can use NSString#initWithData:encoding: where encoding is CTRequest#stringEncoding.
 */
@property (readonly) NSData *content;


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

/*!
 * Initialize a request using the given environment variables and content.
 */
- (id)initWithDictionary:(NSDictionary *)dictionary content:(NSData *)data;


#pragma mark -
#pragma mark Request data accessors

/*!
 * @brief	Get a parameter from the request, searching POST then GET.
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

/*!
 * @brief	Get the value of the request header, or nil if not set.
 *			It's important to note that not all request headers may be exposed via FastCGI.  The web server is ultimately responsible for passing them.
 * 
 * @param	The name of the header.  This is case insensitive.
 * 
 * @return	The value of the header, or nil of not found.
 */
- (NSString *)headerWithName:(NSString *)headerName;


#pragma mark -
#pragma mark Utility methods

/*!
 * Get the NSStringEncoding for the given charset name.
 * 
 * @param	The IANA name of the charset, or an alias of it.
 * 
 * @return	The NSStringEncoding for this charset.
 */
- (NSStringEncoding)stringEncodingFromCharsetName:(NSString *)name;


@end
