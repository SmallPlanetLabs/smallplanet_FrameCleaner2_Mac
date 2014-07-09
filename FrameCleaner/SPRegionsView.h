//
//  SPRegionsView.h
//  FrameCleaner
//
//  Created by Quinn McHenry on 7/9/14.
//  Copyright (c) 2014 Small Planet. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SPRegionsView : NSView

@property (nonatomic, strong) NSMutableArray *regions;

- (void)reset;

@end