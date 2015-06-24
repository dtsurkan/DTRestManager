//
//  DTRestOperation.h
//  VBSoapFrameworkExample
//
//  Created by Dmitriy Tsurkan on 5/27/15.
//  Copyright (c) 2015 DmitriyTsurkan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTRestOperation : NSOperation

- (instancetype)initWithCollection:(NSDictionary *)collection success:(void (^)(id result, NSError* error))success;

@end
