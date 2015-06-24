//
//  DTAttributeMapping.h
//  VBSoapFrameworkExample
//
//  Created by Dmitriy Tsurkan on 5/27/15.
//  Copyright (c) 2015 DmitriyTsurkan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DTRestMapping;

@interface DTAttributeMapping : NSObject

@property (nonatomic, copy, readwrite) NSString *sourceKeyPath;
@property (nonatomic, copy, readwrite) NSString *destinationKeyPath;

+ (instancetype)attributeMappingFromKeyPath:(NSString *)sourceKeyPath toKeyPath:(NSString *)destinationKeyPath;

@end

@interface DTRelationshipMapping : DTAttributeMapping

@property (nonatomic, strong, readwrite) DTRestMapping *mapping;

+ (instancetype)relationshipMappingFromKeyPath:(NSString *)sourceKeyPath
                                     toKeyPath:(NSString *)destinationKeyPath
                                   withMapping:(DTRestMapping *)mapping;

@end