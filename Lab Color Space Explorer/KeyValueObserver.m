//
//  KeyValueObserver.m
//  Lab Color Space Explorer
//
//  Created by Daniel Eggert on 01/12/2013.
//  Copyright (c) 2013 objc.io. All rights reserved.
//

#import "KeyValueObserver.h"
#import <objc/runtime.h>

@interface NSObject (KeyValueObserverToken)

@property (nonatomic,strong) NSMutableArray *keyValueObservers;

@end

@implementation NSObject (KeyValueObserverToken)

- (NSMutableArray *)keyValueObservers
{
    NSMutableArray *observers = objc_getAssociatedObject(self, @"keyValueObservers");
    if (observers == nil) {
        observers = [NSMutableArray array];
        self.keyValueObservers = observers;
    }
    return observers;
}

- (void)setKeyValueObservers:(NSMutableArray *)keyValueObservers
{
    objc_setAssociatedObject(self, @"keyValueObservers", keyValueObservers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface KeyValueObserver ()
@property (nonatomic, weak) id observedObject;
@property (nonatomic, copy) NSString* keyPath;
@end

static NSMutableArray *gKeyValueObservers = nil;

@implementation KeyValueObserver

- (id)initWithObject:(id)object keyPath:(NSString*)keyPath target:(id)target selector:(SEL)selector options:(NSKeyValueObservingOptions)options;
{
    if (object == nil) {
        return nil;
    }
    NSParameterAssert(target != nil);
    NSParameterAssert([target respondsToSelector:selector]);
    self = [super init];
    if (self) {
        self.target = target;
        self.selector = selector;
        self.observedObject = object;
        self.keyPath = keyPath;
        [object addObserver:self forKeyPath:keyPath options:options context:(__bridge void *)(self)];
    }
    return self;
}

+ (void)observeObject:(id)object keyPath:(NSString*)keyPath target:(id)target selector:(SEL)selector;
{
    [self observeObject:object keyPath:keyPath target:target selector:selector options:0];
}

+ (void)observeObject:(id)object keyPath:(NSString*)keyPath target:(id)target selector:(SEL)selector options:(NSKeyValueObservingOptions)options;
{
    KeyValueObserver *observer = [[self alloc] initWithObject:object keyPath:keyPath target:target selector:selector options:options];
    if (observer) {
        [[target keyValueObservers] addObject:observer];
    }
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if (context == (__bridge void *)(self)) {
        [self didChange:change];
    }
}

- (void)didChange:(NSDictionary *)change;
{
    id strongTarget = self.target;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [strongTarget performSelector:self.selector withObject:change];
#pragma clang diagnostic pop
}

- (void)dealloc;
{
    [self.observedObject removeObserver:self forKeyPath:self.keyPath];
}

@end
