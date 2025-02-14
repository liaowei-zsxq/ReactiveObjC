//
//  UIActionSheet+RACSignalSupport.h
//  ReactiveObjC
//
//  Created by Dave Lee on 2013-06-22.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import <TargetConditionals.h>

#if !TARGET_OS_OSX && !TARGET_OS_WATCH
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0

#import <UIKit/UIKit.h>

@class RACDelegateProxy;
@class RACSignal<__covariant ValueType>;

NS_ASSUME_NONNULL_BEGIN

@interface UIActionSheet (RACSignalSupport)

/// A delegate proxy which will be set as the receiver's delegate when any of the
/// methods in this category are used.
@property (nonatomic, strong, readonly) RACDelegateProxy *rac_delegateProxy;

/// Creates a signal for button clicks on the receiver.
///
/// When this method is invoked, the `rac_delegateProxy` will become the
/// receiver's delegate. Any previous delegate will become the -[RACDelegateProxy
/// rac_proxiedDelegate], so that it receives any messages that the proxy doesn't
/// know how to handle. Setting the receiver's `delegate` afterward is
/// considered undefined behavior.
///
/// Returns a signal which will send the index of the specific button clicked.
/// The signal will complete when the receiver is deallocated.
- (RACSignal<NSNumber *> *)rac_buttonClickedSignal;

@end

NS_ASSUME_NONNULL_END

#endif 
#endif
