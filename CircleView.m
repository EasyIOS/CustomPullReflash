//
//  CircleView.m
//  Demo8
//
//  Created by Leon on 11/15/13.
//  Copyright (c) 2013 Leon. All rights reserved.
//

#import "CircleView.h"

@implementation CircleView

- (id)initWithFrame:(CGRect)frame with:(UIScrollView *)scrollView
{
    self = [super initWithFrame:frame with:scrollView];
    if (self) {
        
        [RACObserve(self, alignInset)
         subscribeNext:^(NSNumber* alignInset) {
             CGFloat yOrigin =0;
             if (alignInset.boolValue) {
                 yOrigin = - SVPullToRefreshViewHeight;
             }else{
                 yOrigin = - scrollView.pullToRefreshView.originalTopInset -SVPullToRefreshViewHeight;
             }
             scrollView.pullToRefreshView.frame = CGRectMake(0, yOrigin, scrollView.superview.width, SVPullToRefreshViewHeight);
         }];
        
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        @weakify(self);
        [RACObserve(scrollView.pullToRefreshView, state) subscribeNext:^(id x) {
            @strongify(self);
            CGFloat moveY = scrollView.MoveYForPullToRefresh;
            switch (scrollView.pullToRefreshView.state) {
                case SVPullToRefreshStateStopped:
                    [self resetScrollViewContentInset:scrollView];
                    self.progress = 0;
                    [self setNeedsDisplay];
                    [self.layer removeAnimationForKey:@"rotateAnimation"];
                    break;
                case SVPullToRefreshStatePulling:
                    if (moveY > SVPullToRefreshViewHeight)
                        moveY = SVPullToRefreshViewHeight;
                    self.progress = moveY / SVPullToRefreshViewHeight;
                    [self setNeedsDisplay];
                    break;
                case SVPullToRefreshStateTriggered:
                    self.progress = 1;
                    [self setNeedsDisplay];
                    break;
                case SVPullToRefreshStateLoading:
                    [self setScrollViewContentInsetForLoading:scrollView];
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
    CGFloat startAngle = -M_PI/4;
    CGFloat step = 11*M_PI/6 * self.progress;
    CGContextAddArc(context, self.bounds.size.width/2, self.bounds.size.height/2, self.bounds.size.width/2-3, startAngle, startAngle+step, 0);
    CGContextStrokePath(context);
}

@end
