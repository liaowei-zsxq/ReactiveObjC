//
//  UIControl+RACSignalSupport.m
//  ReactiveObjC
//
//  Created by Josh Abernathy on 4/17/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "UIControl+RACSignalSupport.h"

#if !TARGET_OS_OSX && !TARGET_OS_WATCH

#import "RACEXTScope.h"
#import "RACCompoundDisposable.h"
#import "RACDisposable.h"
#import "RACSignal.h"
#import "RACSubscriber.h"
#import "NSObject+RACDeallocating.h"
#import "NSObject+RACDescription.h"

@implementation UIControl (RACSignalSupport)

- (RACSignal *)rac_signalForControlEvents:(UIControlEvents)controlEvents {
	@weakify(self);

	return [[RACSignal
		createSignal:^(id<RACSubscriber> subscriber) {
			@strongify(self);

			[self addTarget:subscriber action:@selector(sendNext:) forControlEvents:controlEvents];

			RACDisposable *disposable = [RACDisposable disposableWithBlock:^{
				[subscriber sendCompleted];
			}];
			[self.rac_deallocDisposable addDisposable:disposable];

			return [RACDisposable disposableWithBlock:^{
				@strongify(self);
				[self.rac_deallocDisposable removeDisposable:disposable];
				[self removeTarget:subscriber action:@selector(sendNext:) forControlEvents:controlEvents];
			}];
		}]
		setNameWithFormat:@"%@ -rac_signalForControlEvents: %lx", RACDescription(self), (unsigned long)controlEvents];
}

@end

#endif
