//
//  UIAlertView+RACSignalSupport.m
//  ReactiveObjC
//
//  Created by Henrik Hodne on 6/16/13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "UIAlertView+RACSignalSupport.h"

#if !TARGET_OS_OSX && !TARGET_OS_WATCH
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0

#import "RACDelegateProxy.h"
#import "RACSignal+Operations.h"
#import "NSObject+RACDeallocating.h"
#import "NSObject+RACDescription.h"
#import <objc/runtime.h>

@implementation UIAlertView (RACSignalSupport)

static void RACUseDelegateProxy(UIAlertView *self) {
	if (self.delegate == self.rac_delegateProxy) return;

	self.rac_delegateProxy.rac_proxiedDelegate = self.delegate;
	self.delegate = (id)self.rac_delegateProxy;
}

- (RACDelegateProxy *)rac_delegateProxy {
	RACDelegateProxy *proxy = objc_getAssociatedObject(self, _cmd);
	if (proxy == nil) {
		proxy = [[RACDelegateProxy alloc] initWithProtocol:@protocol(UIAlertViewDelegate)];
		objc_setAssociatedObject(self, _cmd, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	return proxy;
}

- (RACSignal *)rac_buttonClickedSignal {
	RACSignal *signal = [[[[self.rac_delegateProxy
		signalForSelector:@selector(alertView:clickedButtonAtIndex:)]
		reduceEach:^(UIAlertView *alertView, NSNumber *buttonIndex) {
			return buttonIndex;
		}]
		takeUntil:self.rac_willDeallocSignal]
		setNameWithFormat:@"%@ -rac_buttonClickedSignal", RACDescription(self)];

	RACUseDelegateProxy(self);

	return signal;
}

- (RACSignal *)rac_willDismissSignal {
	RACSignal *signal = [[[[self.rac_delegateProxy
		signalForSelector:@selector(alertView:willDismissWithButtonIndex:)]
		reduceEach:^(UIAlertView *alertView, NSNumber *buttonIndex) {
			return buttonIndex;
		}]
		takeUntil:self.rac_willDeallocSignal]
		setNameWithFormat:@"%@ -rac_willDismissSignal", RACDescription(self)];

	RACUseDelegateProxy(self);

	return signal;
}

@end

#endif 
#endif
