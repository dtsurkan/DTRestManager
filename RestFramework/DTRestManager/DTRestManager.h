//
//  DTRestManager.h
//  VBSoapFrameworkExample
//
//  Created by Dmitriy Tsurkan on 5/27/15.
//  Copyright (c) 2015 DmitriyTsurkan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTRequest.h"
#import "DTRestParser.h"
#import "DTRestMapping.h"

#define kRequestManagerKey          @"request"
#define kParserManagerKey           @"parser"
#define kMappingManagerKey          @"mapping"

@interface DTRestManager : NSObject

+ (DTRestManager *)defaultManager;

- (void)addRequest:(DTRequest *)request byName:(NSString *)name;
- (void)addParser:(DTRestParser *)parser byName:(NSString *)name;
- (void)addMapping:(DTRestMapping *)mapping byName:(NSString *)name;

- (void)getByName:(NSString *)name
           header:(NSDictionary *)headerParams
           params:(NSDictionary *)params
          success:(void (^)(id result, NSError* error))success;

- (void)getByName:(NSString *)name
           params:(NSDictionary *)params
          success:(void (^)(id result, NSError* error))success;

@end
