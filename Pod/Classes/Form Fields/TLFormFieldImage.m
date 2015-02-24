//
//  TLFormFieldImage.m
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormFieldImage.h"
#import "TLFormField+Protected.h"



@implementation TLFormFieldImage {
    UIImageView *imageView;
    //The reference to an image used to get the UIImage that will be loaded
    id imageRefValue;
}

- (void)setupFieldWithInputType:(TLFormFieldInputType)inputType forEdit:(BOOL)editing {
    [super setupFieldWithInputType:inputType forEdit:editing];
    
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:imageView];
    
    UIButton *tapRecognizer = [[UIButton alloc] init];
    tapRecognizer.translatesAutoresizingMaskIntoConstraints = NO;
    [tapRecognizer addTarget:self action:@selector(imageSelectedAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:tapRecognizer];
    
    NSDictionary *views;
    
    if (editing) {
        UIView *title = [self titleView];
        [self addSubview:title];
        
        views = NSDictionaryOfVariableBindings(imageView, tapRecognizer, title);
        
        //Size the title to the top of the field taking all the widht
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[title]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        //Constraint the imageView to the size of the super view
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title][imageView]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        //Constraint the tapRecognizer to the size of the super view
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title][tapRecognizer]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tapRecognizer]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
    } else {
        views = NSDictionaryOfVariableBindings(imageView, tapRecognizer);
        
        //Constraint the imageView to the size of the super view
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        
        //Constraint the tapRecognizer to the size of the super view
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tapRecognizer]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tapRecognizer]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
    }
    
    [self setValue:self.defautValue];
}

- (void)setValue:(id)fieldValue {
    
    imageRefValue = fieldValue;
    
    if (!fieldValue)
        imageView.image = [UIImage imageNamed:@"no_image.jpg"];
    
    //If the value is an string interpret it as an URL
    else if ([fieldValue isKindOfClass:[NSString class]]) {
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        spinner.translatesAutoresizingMaskIntoConstraints = NO;
        [imageView addSubview:spinner];
        [imageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[spinner]-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(spinner)]];
        [imageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[spinner]-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(spinner)]];
        
//        [imageView setImageWithURL:fieldValue placeholderImage:[UIImage imageNamed:@"placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//            [spinner removeFromSuperview];
//        }];
    }
    
    else if ([fieldValue isKindOfClass:[UIImage class]])
        imageView.image = fieldValue;
}

- (id)getValue {
    return imageRefValue;
}

- (void)imageSelectedAction {
    [self.delegate didSelectField:self];
}

@end
