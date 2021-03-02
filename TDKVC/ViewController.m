//
//  ViewController.m
//  TDKVC
//
//  Created by xzkj on 2021/3/2.
//

#import "ViewController.h"
#import "TDPerson.h"
#import "NSObject+TDKVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    TDPerson * person = [TDPerson new];
    NSArray * test = [person td_valueForKey:@"test"];
    [person td_setValue:@"土豆" forKey:@"name"];
    NSString * name = [person td_valueForKey:@"name"];
    NSLog(@"sdfsdf");
    // Do any additional setup after loading the view.
}


@end
