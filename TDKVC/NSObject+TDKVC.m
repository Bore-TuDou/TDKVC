//
//  NSObject+TDKVC.m
//  TDKVC
//
//  Created by xzkj on 2021/3/2.
//

#import "NSObject+TDKVC.h"
#import <objc/runtime.h>

@implementation NSObject (TDKVC)

-(void)td_setValue:(nullable id)value forKey:(NSString *)key{
    
    //如果key为空则直接返回
    if(!key || key.length <= 0) return;
    
    //    2、找setter方法，顺序是：setXXX、_setXXX、 setIsXXX
    // key 要大写
    NSString *Key = key.capitalizedString;
    // key 要大写
    NSString *setKey = [NSString stringWithFormat:@"set%@:", Key];
    NSString *_setKey = [NSString stringWithFormat:@"_set%@:", Key];
    NSString *setIsKey = [NSString stringWithFormat:@"setIs%@:", Key];
    //1.按照博客中的第一步实现方法  先按照顺序找set方法
    if([self td_performSelectorWithMethodName:setKey value:value]){
        NSLog(@"******%@******",setKey);
        return;
    }else if([self td_performSelectorWithMethodName:_setKey value:value]){
        NSLog(@"******%@******",_setKey);
        return;
    }else if([self td_performSelectorWithMethodName:setIsKey value:value]){
        NSLog(@"******%@******",setIsKey);
        return;
    }
    //2.没有找到set方法判断accessInstanceVariablesDirectly方法是否返回YES
    //应为accessInstanceVariablesDirectly是类方法所以用self.class调用
    if(![self.class accessInstanceVariablesDirectly]){
        @throw [NSException exceptionWithName:@"TDUnknownKeyException" reason:@"****[%@ valueForUndefinedKey:]: this class is not key value coding-compliant for the key name.****" userInfo:nil];
    }
    
    //3.返回YES则按照顺序依次查找_<key> _is<Key> <key> is<Key>成员变量
    //找到则设值
    //获取成员变量数组
    NSMutableArray *mArray = [self getIvarListName];
    NSString *_key = [NSString stringWithFormat:@"_%@",key];
    NSString *_isKey = [NSString stringWithFormat:@"_is%@",Key];
    NSString *isKey = [NSString stringWithFormat:@"is%@",Key];
    if ([mArray containsObject:_key]) {
        // 4.2 获取相应的 ivar
       Ivar ivar = class_getInstanceVariable([self class], _key.UTF8String);
        // 4.3 对相应的 ivar 设置值
       object_setIvar(self , ivar, value);
       return;
    }else if ([mArray containsObject:_isKey]) {
       Ivar ivar = class_getInstanceVariable([self class], _isKey.UTF8String);
       object_setIvar(self , ivar, value);
       return;
    }else if ([mArray containsObject:key]) {
       Ivar ivar = class_getInstanceVariable([self class], key.UTF8String);
       object_setIvar(self , ivar, value);
       return;
    }else if ([mArray containsObject:isKey]) {
       Ivar ivar = class_getInstanceVariable([self class], isKey.UTF8String);
       object_setIvar(self , ivar, value);
       return;
    }
    
    // 4:如果找不到相关实例
    @throw [NSException exceptionWithName:@"LGUnknownKeyException" reason:[NSString stringWithFormat:@"****[%@ %@]: this class is not key value coding-compliant for the key name.****",self,NSStringFromSelector(_cmd)] userInfo:nil];
    
}

- (nullable id)td_valueForKey:(NSString *)key{
    
    // 1:刷选key 判断非空
    if (key == nil  || key.length == 0) {
        return nil;
    }

    // 2:找到相关方法 get<Key> <key> countOf<Key>  objectIn<Key>AtIndex
    // key 要大写
    NSString *Key = key.capitalizedString;
    // 拼接方法
    NSString *getKey = [NSString stringWithFormat:@"get%@",Key];
    NSString *countOfKey = [NSString stringWithFormat:@"countOf%@",Key];
    NSString *objectInKeyAtIndex = [NSString stringWithFormat:@"objectIn%@AtIndex:",Key];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self respondsToSelector:NSSelectorFromString(getKey)]) {
        return [self performSelector:NSSelectorFromString(getKey)];
    }else if ([self respondsToSelector:NSSelectorFromString(key)]){
        return [self performSelector:NSSelectorFromString(key)];
    }else if ([self respondsToSelector:NSSelectorFromString(countOfKey)]){
        //集合类型NSArray、NSSet
        //根据文档中显示数组中查找是否实现了objectInKeyAtIndex方法或者是<key>AtIndexes方法
        //如果是集合则查看是否实现了enumeratorOf<Key>方法或者是memberOf<Key>方法
        //这里只拿objectInKeyAtIndex方法做示例
        if ([self respondsToSelector:NSSelectorFromString(objectInKeyAtIndex)]) {
            int num = (int)[self performSelector:NSSelectorFromString(countOfKey)];
            NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:1];
            for (int j = 0; j<num; j++) {
                id objc = [self performSelector:NSSelectorFromString(objectInKeyAtIndex) withObject:@(j)];
                [mArray addObject:objc];
            }
            return mArray;
        }
    }
#pragma clang diagnostic pop
    
    // 3:判断是否能够直接赋值实例变量
    if (![self.class accessInstanceVariablesDirectly] ) {
        @throw [NSException exceptionWithName:@"LGUnknownKeyException" reason:[NSString stringWithFormat:@"****[%@ valueForUndefinedKey:]: this class is not key value coding-compliant for the key name.****",self] userInfo:nil];
    }
    
    // 4.找相关实例变量进行赋值
    // 4.1 定义一个收集实例变量的可变数组
    NSMutableArray *mArray = [self getIvarListName];
    // _<key> _is<Key> <key> is<Key>
    // _name -> _isName -> name -> isName
    NSString *_key = [NSString stringWithFormat:@"_%@",key];
    NSString *_isKey = [NSString stringWithFormat:@"_is%@",Key];
    NSString *isKey = [NSString stringWithFormat:@"is%@",Key];
    if ([mArray containsObject:_key]) {
        Ivar ivar = class_getInstanceVariable([self class], _key.UTF8String);
        return object_getIvar(self, ivar);;
    }else if ([mArray containsObject:_isKey]) {
        Ivar ivar = class_getInstanceVariable([self class], _isKey.UTF8String);
        return object_getIvar(self, ivar);;
    }else if ([mArray containsObject:key]) {
        Ivar ivar = class_getInstanceVariable([self class], key.UTF8String);
        return object_getIvar(self, ivar);;
    }else if ([mArray containsObject:isKey]) {
        Ivar ivar = class_getInstanceVariable([self class], isKey.UTF8String);
        return object_getIvar(self, ivar);;
    }

    return @"";
}



#pragma mark - 相关工具方法
//查询是否含有某个方法如果有则调用否则返回NO
-(BOOL)td_performSelectorWithMethodName:(NSString *)methodName value:(id)value{
    if([self respondsToSelector:NSSelectorFromString(methodName)]){
        //如果存在该方法
//去除内存泄漏警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        //方法调用
        [self performSelector:NSSelectorFromString(methodName) withObject:value];
#pragma clang diagnostic pop
        return YES;
    }
    return NO;
}

-(NSMutableArray *)getIvarListName{
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:1];
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i<count; i++) {
        Ivar ivar = ivars[i];
        const char *ivarNameChar = ivar_getName(ivar);
        NSString *ivarName = [NSString stringWithUTF8String:ivarNameChar];
        NSLog(@"ivarName == %@",ivarName);
        [mArray addObject:ivarName];
    }
    free(ivars);
    return mArray;
}

@end
