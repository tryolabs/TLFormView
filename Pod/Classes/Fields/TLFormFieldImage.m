//
//  TLFormFieldImage.m
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormFieldImage.h"
#import "TLFormField+Protected.h"



NSString * const TLFormFieldNoImageName = @"tlformfieldnoimage.png";



@implementation TLFormFieldImage {
    UIImageView *imageView;
    NSLayoutConstraint *imageViewHeight;
    //The reference used to store the image (get/set)value
    id imageRefValue;
    NSURLSessionDownloadTask *imageDownloadTask;
    
}

- (void)setupField:(BOOL)editing {
    [super setupField:editing];
    
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:imageView];
    
    imageViewHeight = [NSLayoutConstraint constraintWithItem:imageView
                                                   attribute:NSLayoutAttributeHeight
                                                   relatedBy:0
                                                      toItem:nil
                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                  multiplier:1.0 constant:0];
    
    UIButton *tapRecognizer = [[UIButton alloc] init];
    tapRecognizer.translatesAutoresizingMaskIntoConstraints = NO;
    [tapRecognizer addTarget:self action:@selector(imageSelectedAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:tapRecognizer];
    
    NSDictionary *views;
    
    if (editing) {
        UIView *title = [self titleView];
        [self addSubview:title];
        
        UILabel *titleLabel = (UILabel *) [title viewWithTag:TLFormFieldTitleLabelTag];
        titleLabel.textColor = [UIColor grayColor];
        
        //Set the vertical hugging priority to "requiered" so the title label allways take the minimum space requiered
        [title setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
        views = NSDictionaryOfVariableBindings(imageView, tapRecognizer, title);
        
        //Size the title to the top of the field taking all the widht
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-np-[title]-np-|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        //Constraint the imageView to the size of the super view
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title][imageView]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-np-[imageView]-np-|"
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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //If the image is too big the "scale to aspect fit" scale the image in one dimention but not the other. This fix the case where the image fit the width but not the height.
    //TODO: Add the same logic for the width is trivial, the thing is how this affect all the possible layouts. This may need other approach
    if (imageView.image) {
        UIImage *image = imageView.image;
        CGFloat multiplier = (CGRectGetWidth(imageView.bounds) / image.size.width);
        CGFloat scaledHeight = multiplier * image.size.height;
        
        [self removeConstraint:imageViewHeight];
        
        if (scaledHeight < imageView.bounds.size.height) {
            [imageViewHeight setConstant:scaledHeight];
            [self addConstraint:imageViewHeight];
        }
    }
}

- (void)setValue:(id)fieldValue {
    
    imageRefValue = fieldValue;
    
    //Update the image and invalidate the layout
    void (^updateImage)(UIImage *) = ^(UIImage *newImage) {
        imageView.image = newImage;
        [imageView setNeedsLayout];
    };
    
    if (!fieldValue)
        updateImage([UIImage imageNamed:TLFormFieldNoImageName]);
    
    else if ([fieldValue isKindOfClass:[UIImage class]])
        updateImage(fieldValue);
    
    //If the value is an URL
    else if ([fieldValue isKindOfClass:[NSURL class]]) {
        
        //Show a spinner on the image view while download the image
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
        
        void (^downloadCompleteHandler)(NSURL *, NSURLResponse *, NSError *) = ^(NSURL *location, NSURLResponse *response, NSError *error){
            
            UIImage *image;
            
            if (!error) {
                //We need to add the extension to the file name so get it from the 'fieldValue' and append it to the tmp file
                NSString *finalPath = [[location path] stringByAppendingPathExtension:[fieldValue pathExtension]];
                
                //Try to rename the file
                NSError *error;
                [[NSFileManager defaultManager] moveItemAtPath:[location path] toPath:finalPath error:&error];
                
                if (!error)
                    image = [UIImage imageWithContentsOfFile:finalPath];
                else {
                    NSLog(@"TLFormView: Error moving tmp file at url: %@ - Error: %@", location, error);
                    image = [UIImage imageNamed:TLFormFieldNoImageName];
                }
                
            } else {
                NSLog(@"TLFormView: Error getting image with url: %@ - Error: %@", fieldValue, error);
                image = [UIImage imageNamed:TLFormFieldNoImageName];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner removeFromSuperview];
                updateImage(image);
            });
            
        };
        
        //Cancel any previous request before start a new one
        [imageDownloadTask cancel];
        imageDownloadTask = [[NSURLSession sharedSession] downloadTaskWithRequest:[NSURLRequest requestWithURL:fieldValue] completionHandler:downloadCompleteHandler];
        [imageDownloadTask resume];
    }
}

- (id)getValue {
    return imageRefValue;
}

- (void)imageSelectedAction {
    [self.formDelegate didSelectField:self];
}

@end
