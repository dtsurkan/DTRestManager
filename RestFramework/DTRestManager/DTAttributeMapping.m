//
//  DTAttributeMapping.m
//  VBSoapFrameworkExample
//
//  Created by Dmitriy Tsurkan on 5/27/15.
//  Copyright (c) 2015 DmitriyTsurkan. All rights reserved.
//

#import "DTAttributeMapping.h"

@implementation DTAttributeMapping

+ (instancetype)attributeMappingFromKeyPath:(NSString *)sourceKeyPath toKeyPath:(NSString *)destinationKeyPath {
    DTAttributeMapping *attributeMapping = [self new];
    attributeMapping.sourceKeyPath = sourceKeyPath;
    attributeMapping.destinationKeyPath = destinationKeyPath;
    return attributeMapping;
}

@end

@implementation DTRelationshipMapping

+ (instancetype)relationshipMappingFromKeyPath:(NSString *)sourceKeyPath
                                     toKeyPath:(NSString *)destinationKeyPath
                                   withMapping:(DTRestMapping *)mapping{
    DTRelationshipMapping *attributeMapping = [self new];
    attributeMapping.sourceKeyPath = sourceKeyPath;
    attributeMapping.destinationKeyPath = destinationKeyPath;
    attributeMapping.mapping = mapping;
    return attributeMapping;
}

@end
