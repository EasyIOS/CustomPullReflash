//
//  InfiniteView.m
//  mcapp
//
//  Created by zhuchao on 14/11/21.
//  Copyright (c) 2014年 zhuchao. All rights reserved.
//

#import "InfiniteView.h"

@implementation InfiniteView

- (id)initWithFrame:(CGRect)frame with:(UIScrollView *)scrollView
{
    self = [super initWithFrame:frame with:scrollView];
    if (self) {
        
        scrollView.infiniteScrollingView.frame = CGRectMake(0, scrollView.superview.height, scrollView.superview.width, SVInfiniteScrollingViewHeight);
        @weakify(scrollView);
        [[RACObserve(scrollView, contentSize) filter:^BOOL(id value) {
            @strongify(scrollView);
            NSLog(@"%f",scrollView.bounds.size.height);
            return scrollView.contentSize.height>scrollView.bounds.size.height && scrollView.bounds.size.height >0;
        }] subscribeNext:^(id x) {
            @strongify(scrollView);
            scrollView.infiniteScrollingView.frame = CGRectMake(0, scrollView.contentSize.height, scrollView.infiniteScrollingView.width, SVInfiniteScrollingViewHeight);
        }];
        
        self.backgroundColor = [UIColor clearColor];
        
        @weakify(self);
        [RACObserve(scrollView.infiniteScrollingView, state) subscribeNext:^(id x) {
            @strongify(self);
            CGFloat moveY = scrollView.MoveYForInfinite;
            switch (scrollView.infiniteScrollingView.state) {
                case SVInfiniteScrollingStateEnded:
                case SVInfiniteScrollingStateStopped:
                    [self resetScrollViewContentInset:scrollView];
                    self.progress = 0;
                    [self setNeedsDisplay];
                    [self.layer removeAnimationForKey:@"rotateAnimation"];
                    break;
                case SVInfiniteScrollingStateTriggered:
                    self.progress = 1;
                    [self setNeedsDisplay];
                    break;
                case SVInfiniteScrollingStatePulling:
                    if (moveY > SVInfiniteScrollingViewHeight) moveY = SVInfiniteScrollingViewHeight;
                    self.progress = moveY/ SVInfiniteScrollingViewHeight;
                    [self setNeedsDisplay];
                    break;
                case SVInfiniteScrollingStateLoading:
                    [self setScrollViewContentInsetForInfiniteScrolling:scrollView];
                    [CATransaction begin];
                    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                    [CATransaction commit];
                    CABasicAnimation* rotate =  [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
                    rotate.removedOnCompletion = FALSE;
                    rotate.fillMode = kCAFillModeForwards;
                    [rotate setToValue: [NSNumber numberWithFloat: M_PI / 2]];
                    rotate.repeatCount = HUGE_VALF;
                    rotate.duration = 0.25;
                    rotate.cumulative = TRUE;
                    rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                    [self.layer addAnimation:rotate forKey:@"rotateAnimation"];
                    break;
            }
        }];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithString:@"#f06292"].CGColor);
    CGFloat startAngle = -M_PI/3;
    CGFloat step = 11*M_PI/6 * self.progress;
    CGContextAddArc(context, self.bounds.size.width/2, self.bounds.size.height/2, self.bounds.size.width/2-3, startAngle, startAngle+step, 0);
    CGContextStrokePath(context);
}
@end
