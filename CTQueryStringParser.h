//
//  CTQueryStringParser.h
//  Cioccolata
//
//  Created by Chris Corbyn on 23/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//


@interface CTQueryStringParser : NSObject {
	NSMutableDictionary *maxIndicesCatalog;
}

- (NSDictionary *)parseQuery:(NSString *)queryString usingEncoding:(NSStringEncoding)encoding;

- (void)parseKeysFromEncodedString:(NSString *)string intoArray:(NSMutableArray *)array usingEncoding:(NSStringEncoding)encoding;
- (void)copyValue:(id)value toDictionary:(NSMutableDictionary *)dictionary usingKeys:(NSArray *)keys;

@end
