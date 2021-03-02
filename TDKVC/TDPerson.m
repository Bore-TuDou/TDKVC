//
//  TDPerson.m
//  TDKVC
//
//  Created by xzkj on 2021/3/2.
//

#import "TDPerson.h"

@interface TDPerson ()

{
    NSString * _name;
}

@end

@implementation TDPerson

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(int)countOfTest{
    return 2;
}

- (id)objectInTestAtIndex:(NSNumber *)index
{
    NSArray * array = @[@"2",@"3"];
    return [array objectAtIndex:index.intValue];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
