//
//  ImageViewController.h
//  jng-image
//
//  Created by Andrew on 18/11/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestImage.h"

@interface ImageViewController : UIViewController {
	UILabel *labelFile, *labelInfo;
	UIImageView *imageView;
	int currentImage;
	NSArray *images;
}

@property (nonatomic, retain) IBOutlet UILabel *labelFile, *labelInfo;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) NSArray *images;

- (id)initWithTestImageNumber:(int)num;
- (IBAction)reloadImage:(id)sender;
- (IBAction)nextImage:(id)sender;
- (IBAction)prevImage:(id)sender;

@end
