//
//  VBRequest.m
//  VBSoapFrameworkExample
//
//  Created by Dmitriy Tsurkan on 5/27/15.
//  Copyright (c) 2015 DmitriyTsurkan. All rights reserved.
//

#import "DTRequest.h"
#import "UIApplication+DTNetworkIndicatorManager.h"

@interface DTRequest ()

@property (strong, nonatomic) UNIHTTPRequest            *uniRequestBody;
@property (copy, nonatomic) NSString                    *requestUrl;

@end


@implementation DTRequest

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    DTRequest *copy = [[[self class] allocWithZone:zone] init];
    copy->_requestType = _requestType;
    copy->_requestUrl = _requestUrl;
    copy->_uniRequestBody = _uniRequestBody;
    return copy;
}


+ (DTRequest *)createRequestByType:(DTRequestType)requestType withUrl:(NSString *)url {
    DTRequest *dtRequest = [[DTRequest alloc] init];
    [dtRequest createRequesByType:requestType withUrl:url];
    return dtRequest;
}

- (void)createRequesByType:(DTRequestType)requestType withUrl:(NSString *)url {
    _requestType = requestType;
    _requestUrl = url;
}

- (void)createRequestWithHeaderParams:(NSDictionary *)headerParams
                           withParams:(NSDictionary *)params {
    
    switch (_requestType) {
        case 0: {
            [self makePostRequestWithHeaderParams:headerParams withParams:params];
            break;
        }
        case 1: {
            [self makeGetRequestWithHeaderParams:headerParams withParams:params];
            break;
        }
        case 2: {
            [self makePutRequestWithHeaderParams:headerParams withParams:params];
            break;
        }
        case 3: {
            [self makeDeleteRequestWithHeaderParams:headerParams withParams:params];
            break;
        }
            
        default:
            break;
    }
}

- (void)makePostRequestWithHeaderParams:(NSDictionary *)headerParams
                             withParams:(NSDictionary *)params {
    [[UIApplication sharedApplication] showIndicator];
    _uniRequestBody = [UNIRest postEntity:^(UNIBodyRequest *unibodyRequest) {
        [unibodyRequest setUrl:_requestUrl];
        [unibodyRequest setHeaders:headerParams];
        [unibodyRequest setBody:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil]];
    }];
}

- (void)makePutRequestWithHeaderParams:(NSDictionary *)headerParams
                             withParams:(NSDictionary *)params {
    [[UIApplication sharedApplication] showIndicator];
    _uniRequestBody = [UNIRest putEntity:^(UNIBodyRequest *unibodyRequest) {
        [unibodyRequest setUrl:_requestUrl];
        [unibodyRequest setHeaders:headerParams];
        [unibodyRequest setBody:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil]];
    }];
}

- (void)makeGetRequestWithHeaderParams:(NSDictionary *)headerParams
                            withParams:(NSDictionary *)params {
    [[UIApplication sharedApplication] showIndicator];
    _uniRequestBody = [UNIRest get:^(UNISimpleRequest *simpleRequest) {
        [simpleRequest setUrl:_requestUrl];
        [simpleRequest setHeaders:headerParams];
        [simpleRequest setParameters:params];
    }];
}

- (void)makeDeleteRequestWithHeaderParams:(NSDictionary *)headerParams
                               withParams:(NSDictionary *)params {
    [[UIApplication sharedApplication] showIndicator];
    _uniRequestBody = [UNIRest deleteEntity:^(UNIBodyRequest *unibodyRequest) {
        [unibodyRequest setUrl:_requestUrl];
        [unibodyRequest setHeaders:headerParams];
        [unibodyRequest setBody:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil]];
    }];
}

- (NSString *)requestByType:(DTRequestType)requestType error:(NSError **)error {
    __block NSString *response = @"";
    __block NSError *errorResponse;
    switch (requestType) {
        case 0: {
            response = [self post:&errorResponse];
            break;
        }
        case 1: {
            response = [self get:&errorResponse];
            break;
        }
        case 2: {
            response = [self put:&errorResponse];
            break;
        }
        case 3: {
            response = [self deleteResponse:&errorResponse];
            break;
        }
        default:
            break;
    }
    return response;
}

#pragma mark - HTTP REQUESTS
- (NSString *)post:(NSError **)error {
    __block NSString *response = @"";
    __block NSError *errorResponse;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [_uniRequestBody asStringAsync:^(UNIHTTPStringResponse *stringResponse, NSError *errorRequest) {
        [[UIApplication sharedApplication] hideIndicator];
        if (stringResponse.code != 200) {
            errorRequest = [[NSError alloc] initWithDomain:@"Request error"
                                                      code:stringResponse.code
                                                  userInfo:@{@"NSLocalizedDescription": @"Bad request"}];
        }
        
        response = stringResponse.body;
        errorResponse = errorRequest;
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    *error = errorResponse;
    return response;
}

- (NSString *)get:(NSError **)error {
    __block NSString *response = @"";
    __block NSError *errorResponse;

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [_uniRequestBody asStringAsync:^(UNIHTTPStringResponse *stringResponse, NSError *errorRequest) {
        [[UIApplication sharedApplication] hideIndicator];
        if (stringResponse.code != 200) {
            errorRequest = [[NSError alloc] initWithDomain:@"Request error"
                                                      code:stringResponse.code
                                                  userInfo:@{@"NSLocalizedDescription": @"Bad request"}];
        }
        response = stringResponse.body;
        errorResponse = errorRequest;
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    *error = errorResponse;
    return response;
}

- (NSString *)put:(NSError **)error {
    __block NSString *response = @"";
    __block NSError *errorResponse;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [_uniRequestBody asStringAsync:^(UNIHTTPStringResponse *stringResponse, NSError *errorRequest) {
        [[UIApplication sharedApplication] hideIndicator];
        if (stringResponse.code != 200) {
            errorRequest = [[NSError alloc] initWithDomain:@"Request error"
                                                      code:stringResponse.code
                                                  userInfo:@{@"NSLocalizedDescription": @"Bad request"}];
        }
        response = stringResponse.body;
        errorResponse = errorRequest;
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    *error = errorResponse;
    return response;
}

- (NSString *)deleteResponse:(NSError **)error {
    __block NSString *response = @"";
    __block NSError *errorResponse;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [_uniRequestBody asStringAsync:^(UNIHTTPStringResponse *stringResponse, NSError *errorRequest) {
        [[UIApplication sharedApplication] hideIndicator];
        if (stringResponse.code != 200) {
            errorRequest = [[NSError alloc] initWithDomain:@"Request error"
                                                      code:stringResponse.code
                                                  userInfo:@{@"NSLocalizedDescription": @"Bad request"}];
        }
        response = stringResponse.body;
        errorResponse = errorRequest;
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    *error = errorResponse;
    return response;
}


@end
