//
//  DTRestManager.m
//  VBSoapFrameworkExample
//
//  Created by Dmitriy Tsurkan on 5/27/15.
//  Copyright (c) 2015 DmitriyTsurkan. All rights reserved.
//

#import "DTRestManager.h"
#import "DTRestOperation.h"

@interface DTRestManager ()

@property (strong, nonatomic) NSDictionary              *globalHeaderParams;
@property (strong, nonatomic) NSDictionary              *globalParams;
@property (strong, nonatomic) NSMutableDictionary       *collectionRequests;
@property (strong, nonatomic) NSOperationQueue          *operationsQueue;

@end


@implementation DTRestManager

static DTRestManager *restManager = nil;

+ (DTRestManager *)defaultManager {
    if (restManager) {
        return restManager;
    }
    restManager = [[DTRestManager alloc] init];
    return restManager;
}

- (instancetype)init {
    self = [super init];
    _operationsQueue = [NSOperationQueue new];
    _operationsQueue.maxConcurrentOperationCount = 10;
    _collectionRequests = [NSMutableDictionary dictionary];
    return self;
}

- (void)dealloc {
    [_operationsQueue cancelAllOperations];
    _operationsQueue = nil;
    _collectionRequests = nil;
}

- (NSDictionary *)collectionForName:(NSString *)name {
    NSDictionary *collection = [_collectionRequests objectForKey:name];
    if (!collection) {
        collection = @{kRequestManagerKey: [NSNull null],
                       kParserManagerKey: [NSNull null],
                       kMappingManagerKey: [NSNull null]};
        [_collectionRequests setObject:collection forKey:name];
    }
    return collection;
}

- (void)addRequest:(DTRequest *)request byName:(NSString *)name{
    NSMutableDictionary *collection = [NSMutableDictionary dictionaryWithDictionary:[self collectionForName:name]];
    [collection setObject:request forKey:kRequestManagerKey];
    [_collectionRequests setObject:collection forKey:name];
}

- (void)addParser:(DTRestParser *)parser byName:(NSString *)name {
    NSMutableDictionary *collection = [NSMutableDictionary dictionaryWithDictionary:[self collectionForName:name]];
    [collection setObject:parser forKey:kParserManagerKey];
    [_collectionRequests setObject:collection forKey:name];
}

- (void)addMapping:(DTRestMapping *)mapping byName:(NSString *)name {
    NSMutableDictionary *collection = [NSMutableDictionary dictionaryWithDictionary:[self collectionForName:name]];
    [collection setObject:mapping forKey:kMappingManagerKey];
    [_collectionRequests setObject:collection forKey:name];
}

#pragma mark - Requests
- (void)getByName:(NSString *)name
           header:(NSDictionary *)headerParams
           params:(NSDictionary *)params
          success:(void (^)(id result, NSError* error))success {
    NSMutableDictionary *collection = [NSMutableDictionary
                                       dictionaryWithDictionary:[_collectionRequests objectForKey:name]];
    if (!collection || collection.count == 0 || [collection[kRequestManagerKey] class] == [NSNull class]) {
        [NSException raise:@"Request error" format:@"No request collection name \"%@\"", name];
    }
    
    NSDictionary *joinHeaderParams = [self joinHeaderGlobalParamsWithParams:headerParams];
    NSDictionary *joinParams = [self joinGlobalParamsWithParams:params];
    
    DTRequest *request = [collection[kRequestManagerKey] copy];
    [request createRequestWithHeaderParams:joinHeaderParams withParams:joinParams];
    
    [collection setObject:request forKey:kRequestManagerKey];
    
    DTRestOperation *operation = [[DTRestOperation alloc] initWithCollection:collection success:success];
    [_operationsQueue addOperation:operation];
}

- (void)getByName:(NSString *)name
           params:(NSDictionary *)params
          success:(void (^)(id result, NSError* error))success {
    [self getByName:name header:nil params:params success:success];
}

#pragma mark - Extra Params
- (NSDictionary *)joinHeaderGlobalParamsWithParams:(NSDictionary *)params {
    if (_globalHeaderParams) {
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:_globalHeaderParams];
        [data addEntriesFromDictionary:params];
        return data;
    }
    return [NSDictionary dictionaryWithDictionary:params];
}

- (NSDictionary *)joinGlobalParamsWithParams:(NSDictionary *)params{
    if (_globalParams) {
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:_globalParams];
        [data addEntriesFromDictionary:params];
        return data;
    }
    return [NSDictionary dictionaryWithDictionary:params];
}
@end
