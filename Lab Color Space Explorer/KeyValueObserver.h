//
//  KeyValueObserver.h
//  Lab Color Space Explorer
//
//  Created by Daniel Eggert on 01/12/2013.
//  Copyright (c) 2013 objc.io. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface KeyValueObserver : NSObject

@property (nonatomic, weak) id target;
@property (nonatomic) SEL selector;

/// Create a Key-Value Observing helper object.
///
/// As long as the returned token object is retained, the KVO notifications of the @c object
/// and @c keyPath will cause the given @c selector to be called on @c target.
/// @a object and @a target are weak references.
/// Once the token object gets dealloc'ed, the observer gets removed.
///
/// The @c selector should conform to
/// @code
/// - (void)nameDidChange:(NSDictionary *)change;
/// @endcode
/// The passed in dictionary is the KVO change dictionary (c.f. @c NSKeyValueChangeKindKey, @c NSKeyValueChangeNewKey etc.)
///
/// 
///
/// Example:
///
/// @code
///   [KeyValueObserver observeObject:user
///                                                   keyPath:@"name"
///                                                    target:self
///                                                  selector:@selector(nameDidChange:)];
/// @endcode
+ (void)observeObject:(id)object keyPath:(NSString*)keyPath target:(id)target selector:(SEL)selector;

/// Create a key-value-observer with the given KVO options
+ (void)observeObject:(id)object keyPath:(NSString*)keyPath target:(id)target selector:(SEL)selector options:(NSKeyValueObservingOptions)options;

@end
