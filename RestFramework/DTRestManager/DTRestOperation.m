//
//  DTRestOperation.m
//  VBSoapFrameworkExample
//
//  Created by Dmitriy Tsurkan on 5/27/15.
//  Copyright (c) 2015 DmitriyTsurkan. All rights reserved.
//

#import "DTRestOperation.h"
#import "DTRestManager.h"
#import "DTRestMapping.h"

@interface DTRestOperation ()

@property (strong,nonatomic) NSDictionary *collection;
@property (copy) void (^success)(id result, NSError* error);

@end


@implementation DTRestOperation

- (instancetype)initWithCollection:(NSDictionary *)collection success:(void (^)(id result, NSError* error))success{
    if (self = [super init]){
        _collection = [NSDictionary dictionaryWithDictionary:collection];
        _success = success;
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        if (self.isCancelled){
            return;
        }
        @try {
            NSError *error;
            DTRequest *request = _collection[kRequestManagerKey];
            NSString *response = [request requestByType:request.requestType error:&error];
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _success(response, error);
                });
                [self cancel];
                return;
            }
            if (self.isCancelled){
                return;
            }
            
            DTRestParser *parser = _collection[kParserManagerKey];
            if (parser.class == [NSNull class]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _success(response, nil);
                });
                [self cancel];
                return;
            }
            
            id parseResult = [parser parseString:response];
            if (self.isCancelled){
                return;
            }else if (!parseResult){
                dispatch_async(dispatch_get_main_queue(), ^{
                    _success(response, [[NSError alloc] initWithDomain:@"Parser error"
                                                                  code:9999
                                                              userInfo:@{@"NSLocalizedDescription": @"Impossibly parse response"}]);
                });
                [self cancel];
                return;
            }
            
            
            DTRestMapping *mapping = _collection[kMappingManagerKey];
            if (mapping.class == [NSNull class]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _success(parseResult, error);
                });
                [self cancel];
                return;
            }
            
            id mapResult = [mapping mapData:parseResult];
            if (self.isCancelled){
                return;
            }else if (!mapResult){
                dispatch_async(dispatch_get_main_queue(), ^{
                    _success(parseResult, [[NSError alloc] initWithDomain:@"Mapping error"
                                                                     code:9999
                                                                 userInfo:@{@"NSLocalizedDescription": @"Impossibly mapping data"}]);
                });
                [self cancel];
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _success(mapResult, error);
            });

        }
        @catch(NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _success(nil, [[NSError alloc] initWithDomain:exception.reason code:9999 userInfo:exception.userInfo]);
            });
            [self cancel];
            return;
        }
    }
}

@end
