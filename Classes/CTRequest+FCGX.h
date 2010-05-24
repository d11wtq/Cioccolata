//
//  CTRequest+FGCX.h
//  Cioccolata
//
//  Created by Chris Corbyn on 19/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

/*!
 * @privatesection
 */

#include <fcgi_config.h>
#import "CTRequest.h"
#include <fcgiapp.h>


/*!
 * Adds an initialization method to CTRequest so the FastCGI bootstrap can create a request.
 */
@interface CTRequest(FCGX)

/*!
 * @brief	This method initializes the request using the FCGX_Request struct from libfcgi's fcgiapp.h.
 */
- (id)initWithFCGXRequest:(FCGX_Request)request;

@end
