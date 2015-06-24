//
//  DTRestParser.h
//  VBSoapFrameworkExample
//
//  Created by Dmitriy Tsurkan on 5/27/15.
//  Copyright (c) 2015 DmitriyTsurkan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTRestParser : NSObject

- (id)parseString:(NSString *)jsonString;

@end
