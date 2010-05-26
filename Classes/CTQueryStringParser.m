//
//  CTQueryStringParser.m
//  Cioccolata
//
//  Created by Chris Corbyn on 23/05/10.
//  Copyright 2010 Chris Corbyn. All rights reserved.
//

#import "CTQueryStringParser.h"

/*
 FIXME: I'm pretty sure this can be greatly improved with NSScanner
 */

@implementation CTQueryStringParser

- (NSDictionary *)parseQuery:(NSString *)queryString usingEncoding:(NSStringEncoding)encoding {
	NSMutableDictionary *maxIndicesCatalog = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	NSArray *pairs = [queryString componentsSeparatedByString:@"&"];
	
	for (NSString *pair in pairs) {
		NSRange eqRange = [pair rangeOfString:@"="];
		
		NSMutableString *encodedKey = [NSMutableString stringWithCapacity:pair.length];
		NSMutableArray *keys = [NSMutableArray array];
		NSString *value;
		
		// Parameter does not have an explicit value
		if (eqRange.location == NSNotFound) {
			[encodedKey setString:pair];
			value = @"";
		} else {
			[encodedKey setString:[pair substringToIndex:eqRange.location]];
			if ([pair length] > eqRange.location + 1) {
				value = [[pair substringFromIndex:eqRange.location + 1] stringByReplacingPercentEscapesUsingEncoding:encoding];
			} else {
				value = @"";
			}
		}
		
		[self parseKeysFromEncodedString:encodedKey intoArray:keys usingEncoding:encoding indexCatalog:maxIndicesCatalog];
		
		[self copyValue:value toDictionary:params usingKeys:keys];
	}
	
	return params;
}

- (void)parseKeysFromEncodedString:(NSMutableString *)string intoArray:(NSMutableArray *)array
					 usingEncoding:(NSStringEncoding)encoding indexCatalog:(NSMutableDictionary *)indexCatalog {
	NSRange braceOpen = [string rangeOfString:@"["];
	
	// Parameter contains braces; parse out the key(s)
	if (NSNotFound != braceOpen.location) {
		[array addObject:[[string substringToIndex:braceOpen.location]
						 stringByReplacingPercentEscapesUsingEncoding:encoding]];
		
		do {
			[string deleteCharactersInRange:NSMakeRange(0, braceOpen.location + 1)];
			
			NSRange braceClose = [string rangeOfString:@"]"];
			if (NSNotFound == braceClose.location) {
				break;
			}
			
			id thisKey = [[string substringToIndex:braceClose.location]
						  stringByReplacingPercentEscapesUsingEncoding:encoding];
			
			if ([thisKey isEqual:@""]) {
				NSNumber *currentMaxIndex = [indexCatalog objectForKey:array];
				if (nil == currentMaxIndex) {
					currentMaxIndex = [NSNumber numberWithInt:0];
				} else {
					currentMaxIndex = [NSNumber numberWithInt:[currentMaxIndex integerValue] + 1];
				}
				
				[indexCatalog setObject:currentMaxIndex forKey:array];
				
				thisKey = currentMaxIndex;
			} else if ([thisKey isEqual:[NSString stringWithFormat:@"%d", [thisKey integerValue]]]) { // Is Integer
				thisKey = [NSNumber numberWithInt:[thisKey integerValue]];
				
				NSNumber *currentMaxIndex = [indexCatalog objectForKey:array];
				if ((nil == currentMaxIndex) || [thisKey integerValue] > [currentMaxIndex integerValue]) {
					[indexCatalog setObject:thisKey forKey:array];
				}
			}
			
			[array addObject:thisKey];
			
			[string deleteCharactersInRange:NSMakeRange(0, braceClose.location + 1)];
			
			braceOpen = [string rangeOfString:@"["];
		} while (NSNotFound != braceOpen.location);
	} else {
		[array addObject:[string stringByReplacingPercentEscapesUsingEncoding:encoding]];
	}
}

- (void)copyValue:(NSString *)value toDictionary:(NSMutableDictionary *)dictionary usingKeys:(NSArray *)keys {
	NSMutableDictionary *currentContainer = dictionary;
	NSInteger index = 0, count = [keys count];
	
	for (id key in keys) {
		if (++index == count) {
			break; // The last key is always a node, set after the loop
		}
		
		// Insert a child if not already present
		id childContainer = [currentContainer objectForKey:key];
		if (![childContainer isKindOfClass:[NSDictionary class]]) {
			childContainer = [NSMutableDictionary dictionary];
			[currentContainer setObject:childContainer forKey:key];
		}
		
		// Walk deeper
		currentContainer = childContainer;
	}
	
	// Finally apply the value inside it's designated container
	[currentContainer setObject:value forKey:[keys lastObject]];
}

@end
