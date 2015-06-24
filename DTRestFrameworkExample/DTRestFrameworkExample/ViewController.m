//
//  ViewController.m
//  DTRestFrameworkExample
//
//  Created by Dmitriy Tsurkan on 5/27/15.
//  Copyright (c) 2015 DmitriyTsurkan. All rights reserved.
//

#import "ViewController.h"
#import "TestModel.h"
#import "DTRestManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureGetRequest];
    [self configurePostRequest];
    [self configureDeleteRequest];
    [self configurePutRequest];
}

#pragma mark - Actions
- (IBAction)makeGetRequest:(id)sender {
//    NSDictionary *parameters =  @{@"area": @"москва",
//                                  @"updatedSince": @"2015.05.14"};
    
    NSDictionary *parameters =  @{@"CardNum": @"728013584306"};
    
    [[DTRestManager defaultManager] getByName:@"TestGetRequest" params:parameters success:^(id result, NSError *error) {
        if (error) {
            NSLog(@"%@", error.userInfo);
        } else {
            NSLog(@"%@", result);
        }
    }];
}

- (IBAction)makePostRequest:(id)sender {
    NSDictionary *headerParams = @{@"accept": @"application/json",
                                   @"Content-Type": @"application/json"};
    
    NSDictionary *parameters = @{@"CardNum": @"728013584306", @"LocationId": @"4"};
    
    
    [[DTRestManager defaultManager] getByName:@"TestPostRequest" header:headerParams params:parameters success:^(id result, NSError *error) {
        if (error) {
            NSLog(@"%@", error.userInfo);
        } else {
            NSLog(@"%@", result);
        }
    }];
}

- (IBAction)makePutRequest:(id)sender { }

- (IBAction)makeDeleteRequest:(id)sender {
    NSDictionary *parameters = @{@"CardNum": @"728013584306", @"LocationId": @"4"};
    
     [[DTRestManager defaultManager] getByName:@"TestDeleteRequest" header:nil params:parameters success:^(id result, NSError *error) {
        if (error) {
            NSLog(@"%@", error.userInfo);
        } else {
            NSLog(@"%@", result);
        }
    }];
}

- (void)configureGetRequest {
    NSString *url = @"https://passbook.plas-tek.ru/api/v1/location";
    DTRequest *request = [DTRequest createRequestByType:DTGet withUrl:url];
    DTRestParser *parser = [[DTRestParser alloc] init];
    
    DTRestMapping *mapping = [DTRestMapping mappingForClass:[TestModel class]];
    [mapping addAttributeMappingsFromDictionary:@{@"Address": @"address",
                                                  @"Name":  @"name",
                                                  @"WorkTime": @"workTime",
                                                  @"LocationId": @"locationId"
                                                  }];
    
    
    
    DTRestManager *manager = [DTRestManager defaultManager];
    [manager addRequest:request byName:@"TestGetRequest"];
    [manager addParser:parser byName:@"TestGetRequest"];
    [manager addMapping:mapping byName:@"TestGetRequest"];
}

- (void)configurePostRequest {
    NSString *url = @"https://passbook.plas-tek.ru/api/v1/location";
    DTRequest *request = [DTRequest createRequestByType:DTPost withUrl:url];
    DTRestParser *parser = [[DTRestParser alloc] init];
   
    DTRestManager *manager = [DTRestManager defaultManager];
    [manager addRequest:request byName:@"TestPostRequest"];
    [manager addParser:parser byName:@"TestPostRequest"];
}

- (void)configurePutRequest {

}

- (void)configureDeleteRequest {
    DTRequest *request = [DTRequest createRequestByType:DTDelete withUrl:@"https://passbook.plas-tek.ru/api/v1/location"];
    DTRestParser *parser = [[DTRestParser alloc] init];
    
    DTRestManager *manager = [DTRestManager defaultManager];
    [manager addRequest:request byName:@"TestDeleteRequest"];
    [manager addParser:parser byName:@"TestDeleteRequest"];
}

@end
