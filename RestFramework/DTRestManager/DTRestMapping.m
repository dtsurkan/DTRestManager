//
//  DTRestMapping.m
//  VBSoapFrameworkExample
//
//  Created by Dmitriy Tsurkan on 5/27/15.
//  Copyright (c) 2015 DmitriyTsurkan. All rights reserved.
//

#import "DTRestMapping.h"
#import <objc/runtime.h>
#import "VBObjectUtilities.h"
#import "VBValueTransformers.h"
#import "DTAttributeMapping.h"

@interface DTRestMapping ()

@property (strong, nonatomic) Class                     objectClass;
@property (strong, nonatomic) id                        destinationObject;
@property (strong, nonatomic) VBISO8601DateFormatter    *preferredDateFormatter;
@property (strong, nonatomic) NSMutableArray            *defaultDateFormatters;
@property (strong, nonatomic) NSMutableArray            *propertyMapping;
@property (strong, nonatomic) NSMutableArray            *relationshipMapping;

@end


@implementation DTRestMapping

+ (instancetype)mappingForClass:(Class)objectClass{
    return [[self alloc] initWithClass:objectClass];
}

- (id)initWithClass:(Class)objectClass
{
    self = [super init];
    if (self) {
        _objectClass = objectClass;
        _destinationObject = [[objectClass alloc] init];
        _propertyMapping = [NSMutableArray array];
        _relationshipMapping = [NSMutableArray array];
    }
    return self;
}

- (void)addAttributeMappingsFromDictionary:(NSDictionary *)keyPathToAttributeNames{
    for (NSString *attributeKeyPath in keyPathToAttributeNames) {
        [self addPropertyMapping:[DTAttributeMapping
                                  attributeMappingFromKeyPath:attributeKeyPath
                                  toKeyPath:[keyPathToAttributeNames objectForKey:attributeKeyPath]]];
    }
}

- (void)addAttributeMappingsFromArray:(NSArray *)arrayOfAttributeNamesOrMappings{
    for (NSString *attributeKeyPath in arrayOfAttributeNamesOrMappings) {
        [self addPropertyMapping:[DTAttributeMapping
                                  attributeMappingFromKeyPath:attributeKeyPath
                                  toKeyPath:attributeKeyPath]];
    }
}

- (void)addRelationshipMappingWithSourceKeyPath:(NSString *)sourceKeyPath
                                      toKeyPath:(NSString *)toKeyPath
                                        mapping:(DTRestMapping *)mapping{
    [self addPropertyMapping:[DTRelationshipMapping
                              relationshipMappingFromKeyPath:sourceKeyPath
                              toKeyPath:toKeyPath
                              withMapping:mapping]];
}

- (void)addPropertyMapping:(DTAttributeMapping *)propertyMapping{
    if (propertyMapping.class == [DTRelationshipMapping class]) {
        [_relationshipMapping addObject:propertyMapping];
    }else{
        [_propertyMapping addObject:propertyMapping];
    }
}

- (id)mapData:(id)data{
    if ([[data class] isSubclassOfClass:[NSArray class]]) {
        NSMutableArray *mapDataList = [NSMutableArray array];
        for (int ii=0; ii<[data count]; ii++) {
            [mapDataList addObject:[self mapItem:data[ii]]];
        }
        return mapDataList;
    }else if ([[data class] isSubclassOfClass:[NSDictionary class]]){
        return [self mapItem:data];
    }
    return nil;
}

- (id)mapItem:(id)item{
    id destinationObject = [[_objectClass alloc] init];
    for (DTAttributeMapping *attributeMapping in _propertyMapping) {
        id value = [item valueForKeyPath:attributeMapping.sourceKeyPath];
        Class type = [self classForKeyPath:attributeMapping.destinationKeyPath];
        if (type && NO == [[value class] isSubclassOfClass:type]) {
            value = [self transformValue:value atKeyPath:attributeMapping.sourceKeyPath toType:type];
        }
        if (value) {
            [destinationObject setValue:value forKeyPath:attributeMapping.destinationKeyPath];
        }
    }
    for (DTRelationshipMapping *attributeMapping in _relationshipMapping) {
        id value = [item valueForKeyPath:attributeMapping.sourceKeyPath];
        Class type = [self classForKeyPath:attributeMapping.destinationKeyPath];
        if (type && NO == [[value class] isSubclassOfClass:type]) {
            value = [attributeMapping.mapping mapData:value];
        }else if (type && [type isSubclassOfClass:[NSArray class]]){
            value = [attributeMapping.mapping mapData:value];
        }
        if (value) {
            [destinationObject setValue:value forKeyPath:attributeMapping.destinationKeyPath];
        }
    }
    return destinationObject;
}

- (id)transformValue:(id)value atKeyPath:(NSString *)keyPath toType:(Class)destinationType{
    VBDateToStringValueTransformer *transformer = [[VBDateToStringValueTransformer alloc]
                                                   initWithDateToStringFormatter:self.preferredDateFormatter
                                                   stringToDateFormatters:self.dateFormatters];
    id transformedValue = VBTransformedValueWithClass(value, destinationType, transformer);
    if (transformedValue != value) return transformedValue;
    return nil;
}

- (Class)classForKeyPath:(NSString *)keyPath
{
    NSArray *components = [keyPath componentsSeparatedByString:@"."];
    Class propertyClass = _objectClass;
    for (NSString *property in components) {
        propertyClass = [self classForPropertyNamed:property ofClass:_objectClass];
        if (! propertyClass) break;
    }
    return propertyClass;
}

- (Class)classForPropertyNamed:(NSString *)propertyName ofClass:(Class)objectClass
{
    NSDictionary *classInspection = [self propertyInspectionForClass:objectClass];
    NSDictionary *propertyInspection = [classInspection objectForKey:propertyName];
    return [propertyInspection objectForKey:@"keyValueCodingClass"];
}

- (NSDictionary *)propertyInspectionForClass:(Class)objectClass{
    NSMutableDictionary *inspection = [NSMutableDictionary dictionary];
    unsigned int outCount = 0;
    objc_property_t *propList = class_copyPropertyList(objectClass, &outCount);
    
    for (typeof(outCount) i = 0; i < outCount; i++) {
        objc_property_t *prop = propList + i;
        const char *propName = property_getName(*prop);
        if (strcmp(propName, "_mapkit_hasPanoramaID") != 0) {
            const char *attr = property_getAttributes(*prop);
            if (attr) {
                Class aClass = VBKeyValueCodingClassFromPropertyAttributes(attr);
                if (aClass) {
                    NSString *propNameString = [[NSString alloc] initWithCString:propName encoding:NSUTF8StringEncoding];
                    if (propNameString) {
                        NSDictionary *propertyInspection = @{ @"name": propNameString,
                                                              @"keyValueCodingClass": aClass};
                        [inspection setObject:propertyInspection forKey:propNameString];
                    }
                }
            }
        }
    }
    return inspection;
}

- (NSFormatter *)preferredDateFormatter
{
    if (!_preferredDateFormatter) {
        VBISO8601DateFormatter *iso8601Formatter = [[VBISO8601DateFormatter alloc] init];
        iso8601Formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        iso8601Formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        iso8601Formatter.includeTime = YES;
        _preferredDateFormatter = iso8601Formatter;
    }
    
    return _preferredDateFormatter;
}

- (NSArray *)dateFormatters
{
    if (_defaultDateFormatters.count) {
        return _defaultDateFormatters;
    }
    _defaultDateFormatters = [[NSMutableArray alloc] init];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    [self addDefaultDateFormatter:numberFormatter];
    
    VBISO8601DateFormatter *isoFormatter = [[VBISO8601DateFormatter alloc] init];
    isoFormatter.parsesStrictly = YES;
    [self addDefaultDateFormatter:isoFormatter];
    
    [self addDefaultDateFormatterForString:@"MM/dd/yyyy" inTimeZone:nil];
    [self addDefaultDateFormatterForString:@"yyyy-MM-dd'T'HH:mm:ss'Z'" inTimeZone:nil];
    [self addDefaultDateFormatterForString:@"yyyy-MM-dd" inTimeZone:nil];
    return _defaultDateFormatters;
}

- (void)addDefaultDateFormatter:(id)dateFormatter
{
    [_defaultDateFormatters insertObject:dateFormatter atIndex:0];
}

- (void)addDefaultDateFormatterForString:(NSString *)dateFormatString inTimeZone:(NSTimeZone *)nilOrTimeZone
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = dateFormatString;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    if (nilOrTimeZone) {
        dateFormatter.timeZone = nilOrTimeZone;
    } else {
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    }
    
    [self addDefaultDateFormatter:dateFormatter];
}



static BOOL VBIsMutableTypeTransformation(id value, Class destinationType)
{
    if ([destinationType isEqual:[NSMutableArray class]]) return YES;
    else if ([destinationType isEqual:[NSMutableDictionary class]]) return YES;
    else if ([destinationType isEqual:[NSMutableString class]]) return YES;
    else if ([destinationType isEqual:[NSMutableSet class]]) return YES;
    else if ([destinationType isEqual:[NSMutableOrderedSet class]]) return YES;
    else return NO;
}

id VBTransformedValueWithClass(id value, Class destinationType, NSValueTransformer *dateToStringValueTransformer);
id VBTransformedValueWithClass(id value, Class destinationType, NSValueTransformer *dateToStringValueTransformer)
{
    Class sourceType = [value class];
    
    if ([value isKindOfClass:destinationType]) {
        // No transformation necessary
        return value;
    } else if ([destinationType isSubclassOfClass:[NSDictionary class]]) {
        return [NSMutableDictionary dictionaryWithObject:[NSMutableDictionary dictionary] forKey:value];
    } else if (VBClassIsCollection(destinationType) && !VBObjectIsCollection(value)) {
        // Call ourself recursively with an array value to transform as appropriate
        return VBTransformedValueWithClass(@[ value ], destinationType, dateToStringValueTransformer);
    } else if (VBIsMutableTypeTransformation(value, destinationType)) {
        return [value mutableCopy];
    } else if ([sourceType isSubclassOfClass:[NSString class]] && [destinationType isSubclassOfClass:[NSDate class]]) {
        // String -> Date
        return [dateToStringValueTransformer transformedValue:value];
    } else if ([destinationType isSubclassOfClass:[NSString class]] && [value isKindOfClass:[NSDate class]]) {
        // NSDate -> NSString
        // Transform using the preferred date formatter
        return [dateToStringValueTransformer reverseTransformedValue:value];
    } else if ([destinationType isSubclassOfClass:[NSData class]]) {
        return [NSKeyedArchiver archivedDataWithRootObject:value];
    } else if ([sourceType isSubclassOfClass:[NSString class]]) {
        if ([destinationType isSubclassOfClass:[NSURL class]]) {
            // String -> URL
            return [NSURL URLWithString:(NSString *)value];
        } else if ([destinationType isSubclassOfClass:[NSDecimalNumber class]]) {
            // String -> Decimal Number
            return [NSDecimalNumber decimalNumberWithString:(NSString *)value];
        } else if ([destinationType isSubclassOfClass:[NSNumber class]]) {
            // String -> Number
            NSString *lowercasedString = [(NSString *)value lowercaseString];
            NSSet *trueStrings = [NSSet setWithObjects:@"true", @"t", @"yes", @"y", nil];
            NSSet *booleanStrings = [trueStrings setByAddingObjectsFromSet:[NSSet setWithObjects:@"false", @"f", @"no", @"n", nil]];
            if ([booleanStrings containsObject:lowercasedString]) {
                // Handle booleans encoded as Strings
                return [NSNumber numberWithBool:[trueStrings containsObject:lowercasedString]];
            } else if ([(NSString *)value rangeOfString:@"."].location != NSNotFound) {
                // String -> Floating Point Number
                // Only use floating point if needed to avoid losing precision
                // on large integers
                return [NSNumber numberWithDouble:[(NSString *)value doubleValue]];
            } else {
                // String -> Signed Integer
                return [NSNumber numberWithLongLong:[(NSString *)value longLongValue]];
            }
        }
    } else if ([value isEqual:[NSNull null]]) {
        // Transform NSNull -> nil for simplicity
        return nil;
    } else if ([sourceType isSubclassOfClass:[NSSet class]]) {
        // Set -> Array
        if ([destinationType isSubclassOfClass:[NSArray class]]) {
            return [(NSSet *)value allObjects];
        }
    } else if ([sourceType isSubclassOfClass:[NSOrderedSet class]]) {
        // OrderedSet -> Array
        if ([destinationType isSubclassOfClass:[NSArray class]]) {
            return [value array];
        }
    } else if ([sourceType isSubclassOfClass:[NSArray class]]) {
        // Array -> Set
        if ([destinationType isSubclassOfClass:[NSSet class]]) {
            return [NSSet setWithArray:value];
        }
        // Array -> OrderedSet
        if ([destinationType isSubclassOfClass:[NSOrderedSet class]]) {
            return [[NSOrderedSet class] orderedSetWithArray:value];
        }
    } else if ([sourceType isSubclassOfClass:[NSNumber class]] && [destinationType isSubclassOfClass:[NSDate class]]) {
        // Number -> Date
        return [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)value doubleValue]];
    } else if ([sourceType isSubclassOfClass:[NSNumber class]] && [destinationType isSubclassOfClass:[NSDecimalNumber class]]) {
        // Number -> Decimal Number
        return [NSDecimalNumber decimalNumberWithDecimal:[value decimalValue]];
    } else if ( ([sourceType isSubclassOfClass:NSClassFromString(@"__NSCFBoolean")] ||
                 [sourceType isSubclassOfClass:NSClassFromString(@"NSCFBoolean")] ) &&
               [destinationType isSubclassOfClass:[NSString class]]) {
        return ([value boolValue] ? @"true" : @"false");
    } else if ([destinationType isSubclassOfClass:[NSString class]] && [value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    
    return nil;
}

@end
