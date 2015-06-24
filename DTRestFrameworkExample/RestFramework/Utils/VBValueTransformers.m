//
//  RKValueTransformers.m
//  RestKit
//
//  Created by Blake Watters on 11/26/12.
//  Copyright (c) 2012 RestKit. All rights reserved.
//

#import "VBValueTransformers.h"

// Implementation lives in RKObjectMapping.m at the moment
NSDate *VBDateFromStringWithFormatters(NSString *dateString, NSArray *formatters);
NSDate *VBDateFromStringWithFormatters(NSString *dateString, NSArray *formatters)
{
    NSDate *date = nil;
    for (NSFormatter *dateFormatter in formatters) {
        BOOL success;
        @synchronized(dateFormatter) {
            if ([dateFormatter isKindOfClass:[NSDateFormatter class]]) {
            }
            NSString *errorDescription = nil;
            success = [dateFormatter getObjectValue:&date forString:dateString errorDescription:&errorDescription];
        }
        
        if (success && date) {
            if ([dateFormatter isKindOfClass:[NSDateFormatter class]]) {
            } else if ([dateFormatter isKindOfClass:[NSNumberFormatter class]]) {
                NSNumber *formattedNumber = (NSNumber *)date;
                date = [NSDate dateWithTimeIntervalSince1970:[formattedNumber doubleValue]];
            }
            
            break;
        }
    }
    
    return date;
}


@implementation VBDateToStringValueTransformer

+ (Class)transformedValueClass
{
    return [NSDate class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)initWithDateToStringFormatter:(NSFormatter *)dateToStringFormatter stringToDateFormatters:(NSArray *)stringToDateFormatters
{
    self = [self init];
    if (self) {
        self.dateToStringFormatter = dateToStringFormatter;
        self.stringToDateFormatters = stringToDateFormatters;
    }
    return self;
}

- (id)transformedValue:(id)value
{
    return VBDateFromStringWithFormatters(value, self.stringToDateFormatters);
}

- (id)reverseTransformedValue:(id)value
{
    return [self.dateToStringFormatter stringForObjectValue:value];
}

@end
