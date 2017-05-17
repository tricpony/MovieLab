//
//  HorizontalLineView.h
//  PlayMaker
//
//  Created by aarthur on 11/5/15.
//  Copyright © 2015 PlayMaker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HorizontalLineView : UIView
@property (assign, nonatomic) CGFloat yPosition;
@property (assign, nonatomic) CGFloat distanceFromBottom;
@property (assign, nonatomic) CGFloat xOffset;
@property (assign, nonatomic) CGFloat strokeWidth;
@property (strong, nonatomic) UIColor *strokeColor;

@end
