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
    //The reference used to store the image (get/set)value
    id imageRefValue;
    NSURLSessionDownloadTask *imageDownloadTask;
    
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

- (void)setValue:(id)fieldValue {
    
    imageRefValue = fieldValue;
    
    if (!fieldValue)
        imageView.image = [UIImage imageNamed:TLFormFieldNoImageName];
    
    else if ([fieldValue isKindOfClass:[UIImage class]])
        imageView.image = fieldValue;
    
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
                imageView.image = image;
                [imageView setNeedsLayout];
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
    [self.delegate didSelectField:self];
}

@end
