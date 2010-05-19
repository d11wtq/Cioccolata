//
//  CTRequest+FGCX.h
//  Cioccolata
//
//  Created by Chris Corbyn on 19/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#include <fcgi_config.h>
#include <fcgiapp.h>

#import "CTRequest.h"


@interface CTRequest(FCGX)

/**
 * This method initializes the request using the FCGX_Request struct from libfcgi's fcgiapp.h.
 * 
 * It is not public.
 */
- (id)initWithFCGXRequest:(FCGX_Request)request;

@end
