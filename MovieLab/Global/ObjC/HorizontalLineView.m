//
//  HorizontalLineView.m
//  PlayMaker
//
//  Created by aarthur on 11/5/15.
//  Copyright © 2015 PlayMaker. All rights reserved.
//

#import "HorizontalLineView.h"

@interface HorizontalLineView()
@property (strong, nonatomic) UIView *horizontalLine;
@property (assign, nonatomic) BOOL usesLayer;

@end

@implementation HorizontalLineView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.xOffset = 0;
        self.yPosition = 0;
        self.strokeWidth = .75;
        self.strokeColor = [UIColor lightGrayColor];
        self.horizontalLine = nil;
        self.distanceFromBottom = -1;
        self.usesLayer = YES;
    }
    return self;
}

/**
 This draws a horizontal line at the specified y position
 **/
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.usesLayer) return;
    
    if (!self.horizontalLine) {
        CGFloat w;
        NSArray *constraints;
        NSLayoutConstraint *height;
        NSDictionary *mappings;
        CALayer *layer;
        
        w = self.frame.size.width - (self.xOffset * 2);
        self.horizontalLine = [[UIView alloc] init];
        self.horizontalLine.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.horizontalLine];
        mappings = @{@"line":self.horizontalLine};
        
        if (self.distanceFromBottom >= 0) {
            constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[line]-(y)-|"
                                                                  options:0
                                                                  metrics:@{@"y":@(self.distanceFromBottom)}
                                                                    views:mappings];
        }else{
            constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(y)-[line]"
                                                                  options:0
                                                                  metrics:@{@"y":@(self.yPosition)}
                                                                    views:mappings];
        }
        [self addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(x)-[line]-(x)-|"
                                                              options:0
                                                              metrics:@{@"x":@(self.xOffset)}
                                                                views:mappings];
        [self addConstraints:constraints];
        
        height = [NSLayoutConstraint constraintWithItem:self.horizontalLine
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1
                                               constant:self.strokeWidth];
        [self.horizontalLine addConstraint:height];
        
        //now draw the line
        layer = self.horizontalLine.layer;
        layer.borderColor = self.strokeColor.CGColor;
        layer.borderWidth = self.strokeWidth;
        layer.shouldRasterize = YES;
        [layer setRasterizationScale:[[UIScreen mainScreen] scale]];
    }
}

@end
