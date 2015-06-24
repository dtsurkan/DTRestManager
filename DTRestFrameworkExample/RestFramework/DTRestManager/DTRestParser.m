//
//  DTRestParser.m
//  VBSoapFrameworkExample
//
//  Created by Dmitriy Tsurkan on 5/27/15.
//  Copyright (c) 2015 DmitriyTsurkan. All rights reserved.
//

#import "DTRestParser.h"
#import "UNIRest.h"

@implementation DTRestParser

- (id)parseString:(NSString *)jsonString {
    if (!jsonString.length) {
        return @{};
    }
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return json;
}

@end
