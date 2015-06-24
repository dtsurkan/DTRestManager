//
//  DTRestMapping.h
//  VBSoapFrameworkExample
//
//  Created by Dmitriy Tsurkan on 5/27/15.
//  Copyright (c) 2015 DmitriyTsurkan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VBISO8601DateFormatter.h"

@interface DTRestMapping : NSObject

+ (instancetype)mappingForClass:(Class)objectClass;
- (void)addAttributeMappingsFromDictionary:(NSDictionary *)keyPathToAttributeNames;
- (void)addAttributeMappingsFromArray:(NSArray *)arrayOfAttributeNamesOrMappings;
- (void)addRelationshipMappingWithSourceKeyPath:(NSString *)sourceKeyPath
                                      toKeyPath:(NSString *)toKeyPath
                                        mapping:(DTRestMapping *)mapping;
- (id)mapData:(id)data;

@end
