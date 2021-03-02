//
//  NSObject+TDKVC.h
//  TDKVC
//
//  Created by xzkj on 2021/3/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (TDKVC)

-(void)td_setValue:(nullable id)value forKey:(NSString *)key;

- (nullable id)td_valueForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
