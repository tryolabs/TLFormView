//
//  UIView+Glow.m
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "UIView+Glow.h"

@implementation UIView (Glow)

- (void)setShowGlow:(BOOL)showGlow {
    if (showGlow) {
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowRadius = 4.0f;
        self.layer.shadowOpacity = .9;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.masksToBounds = NO;
    } else {
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowRadius = 4.0f;
        self.layer.shadowOpacity = 0.0;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.masksToBounds = NO;
    }
}

@end
