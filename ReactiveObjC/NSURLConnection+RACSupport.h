//
//  NSURLConnection+RACSupport.h
//  ReactiveObjC
//
//  Created by Justin Spahr-Summers on 2013-10-01.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import <TargetConditionals.h>

#if !TARGET_OS_WATCH
#if __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_11 || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0 || __TVOS_VERSION_MIN_REQUIRED < __TVOS_9_0

#import <Foundation/Foundation.h>

@class RACTwoTuple<__covariant First, __covariant Second>;
@class RACSignal<__covariant ValueType>;

NS_ASSUME_NONNULL_BEGIN

@interface NSURLConnection (RACSupport)

/// Lazily loads data for the given request in the background.
///
/// request - The URL request to load. This must not be nil.
///
/// Returns a signal which will begin loading the request upon each subscription,
/// then send a tuple of the received response and downloaded data, and complete
/// on a background thread. If any errors occur, the returned signal will error
/// out.
+ (RACSignal<RACTwoTuple<NSURLResponse *, NSData *> *> *)rac_sendAsynchronousRequest:(NSURLRequest *)request;

@end

NS_ASSUME_NONNULL_END

#endif 
#endif
