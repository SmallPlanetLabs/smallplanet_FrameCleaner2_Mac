//
//  SPBorderedView.m
//  FrameCleaner
//
//  Created by Quinn McHenry on 7/9/14.
//  Copyright (c) 2014 Small Planet. All rights reserved.
//

#import "SPBorderedView.h"

@implementation SPBorderedView

- (CGRect) cgrect {
    return NSRectToCGRect(self.frame);
}

- (BOOL) containsPoint:(CGPoint)point withInset:(CGFloat)inset {
    return (CGRectContainsPoint(CGRectInset(NSRectToCGRect(self.frame),inset,inset), point));
}

- (CGFloat) area {
    return self.frame.size.width * self.frame.size.height;
}

- (CGFloat) areaWithPoint:(CGPoint)point {
    CGRect pointRect = CGRectZero;
    pointRect.origin = point;
    pointRect.size = CGSizeMake(1.f,1.f);
    
    CGRect frame = self.cgrect;
    CGRect newFrame = (CGRectIsNull(frame) ? pointRect : CGRectUnion(frame, pointRect));
    return newFrame.size.width * newFrame.size.height;
}

- (CGFloat) maxSideWithPoint:(CGPoint)point {
    CGRect pointRect = CGRectZero;
    pointRect.origin = point;
    pointRect.size = CGSizeMake(1.f,1.f);
    
    CGRect frame = self.cgrect;
    CGRect newFrame = (CGRectIsNull(frame) ? pointRect : CGRectUnion(frame, pointRect));
    return (newFrame.size.width > newFrame.size.height ? newFrame.size.width : newFrame.size.height);
}

- (NSString *) description {
    CGRect frame = self.cgrect;
    return [NSString stringWithFormat:@"Region frame {%f,%f; %f,%f}", frame.origin.x,frame.origin.y,frame.size.width,frame.size.height];
}

- (void) expandFrameBy:(CGFloat)pixels toMaxSize:(CGSize)size {
    NSRect frame = self.frame;
    frame.origin.x -= pixels;
    frame.origin.x = (frame.origin.x < 0.f ? 0.f: frame.origin.x);
    frame.origin.y -= pixels;
    frame.origin.y = (frame.origin.y < 0.f ? 0.f: frame.origin.y);
    frame.size.width += 2.f*pixels;
    frame.size.width = (frame.size.width > size.width ? size.width : frame.size.width);
    frame.size.height += 2.f*pixels;
    frame.size.height = (frame.size.height > size.height ? size.height : frame.size.height);
    self.frame = frame;
}

- (void) setFrameBounds:(CGRect)frame {
    _frame = NSRectFromCGRect(frame);
}

- (CGRect) unionWithFrame:(CGRect)rect {
    return CGRectUnion(self.cgrect, rect);
}

- (CGFloat) unionAreaWithFrame:(CGRect)rect {
    CGRect total = CGRectUnion(self.cgrect, rect);
    return total.size.width * total.size.height;
}

- (void) mergeWithRegion:(SPBorderedView *)region {
    _frame = NSRectFromCGRect(CGRectUnion(self.cgrect, [region cgrect]));
}

- (NSInteger) overlapCount:(SPBorderedView *)region {
    CGPoint p1 = CGPointMake(self.frame.origin.x, self.frame.origin.y);
    CGPoint p2 = CGPointMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height);
    CGPoint p3 = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y + self.frame.size.height);
    CGPoint p4 = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y);
    
    NSInteger count = 0;
    if (CGRectContainsPoint([region cgrect], p1)) count++;
    if (CGRectContainsPoint([region cgrect], p2)) count++;
    if (CGRectContainsPoint([region cgrect], p3)) count++;
    if (CGRectContainsPoint([region cgrect], p4)) count++;
    return count;
}

- (BOOL) overlaps:(SPBorderedView *)region {
    return ([self overlapCount:region] > 0);
}

- (void) reduceIfOverlaps:(SPBorderedView *)region {
    NSRect frame = self.frame;
    CGPoint p1 = CGPointMake(self.frame.origin.x, self.frame.origin.y);
    CGPoint p2 = CGPointMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height);
    CGPoint p3 = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y + self.frame.size.height);
    CGPoint p4 = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y);
    
    if (CGRectContainsPoint([region cgrect], p1) && CGRectContainsPoint([region cgrect], p2)) {
        CGFloat diff = CGRectGetMaxX([region cgrect]) - CGRectGetMinX(self.cgrect);
        frame.origin.x += diff;
        frame.size.width -= diff;
    }
    if (CGRectContainsPoint([region cgrect], p2) && CGRectContainsPoint([region cgrect], p3)) {
        CGFloat diff = CGRectGetMaxY(frame) - CGRectGetMinY([region cgrect]);
        frame.size.height -= diff;
    }
    if (CGRectContainsPoint([region cgrect], p3) && CGRectContainsPoint([region cgrect], p4)) {
        CGFloat diff = CGRectGetMaxX(frame) - CGRectGetMinX([region cgrect]);
        frame.size.width -= diff;
    }
    if (CGRectContainsPoint([region cgrect], p4) && CGRectContainsPoint([region cgrect], p1)) {
        CGFloat diff = CGRectGetMaxY([region cgrect]) - CGRectGetMinY(self.cgrect);
        frame.origin.y += diff;
        frame.size.height -= diff;
    }
    self.frame = frame;
}

- (NSRect) splitByRemovingRect:(NSRect)remove {
    // returns NSRect of new region to add as a result of split
    NSRect newFrame = NSMakeRect(-1,-1,0,0);
    CGRect rect2 = NSRectToCGRect(remove);
    CGRect frame = NSRectToCGRect(self.frame);

    CGPoint p1 = CGPointMake(rect2.origin.x, rect2.origin.y);
    CGPoint p2 = CGPointMake(rect2.origin.x, CGRectGetMaxY(rect2));
    CGPoint p3 = CGPointMake(CGRectGetMaxX(rect2), CGRectGetMaxY(rect2));
    CGPoint p4 = CGPointMake(CGRectGetMaxX(rect2), rect2.origin.y);
    
    if (CGRectContainsPoint(frame, p1)) {
        newFrame = NSMakeRect(frame.origin.x, rect2.origin.y, rect2.origin.x - frame.origin.x, CGRectGetMaxY(frame) - rect2.origin.y);
        frame.size.height -= newFrame.size.height;
    }
    if (CGRectContainsPoint(frame, p2)) {
        newFrame = NSMakeRect(frame.origin.x,frame.origin.y, rect2.origin.x-frame.origin.x, CGRectGetMaxY(rect2)-frame.origin.y);
        frame.size.height = CGRectGetMaxY(frame) - CGRectGetMaxY(rect2);
        frame.origin.y = CGRectGetMaxY(rect2);
    }
    if (CGRectContainsPoint(frame, p3)) {
        newFrame = NSMakeRect(CGRectGetMaxX(rect2),frame.origin.y, CGRectGetMaxX(frame)-CGRectGetMaxX(rect2), CGRectGetMaxY(rect2)-frame.origin.y);
        frame.size.height = CGRectGetMaxY(frame) - CGRectGetMaxY(rect2);
        frame.origin.y = CGRectGetMaxY(rect2);
    }
    if (CGRectContainsPoint(frame, p4)) {
        newFrame = NSMakeRect(CGRectGetMaxX(rect2), rect2.origin.y, CGRectGetMaxX(frame)-CGRectGetMaxX(rect2), CGRectGetMaxY(frame) - rect2.origin.y);
        frame.size.height -= newFrame.size.height;
        self.frame = frame;
    }
    self.frame = frame;
    
    return newFrame;
}

- (void) addPoint:(CGPoint)point
{
    CGRect pointRect = CGRectZero;
    pointRect.origin = point;
    pointRect.size = CGSizeMake(1.f,1.f);
    
    self.frame = (CGRectIsNull(NSRectToCGRect(self.frame)) ? pointRect : CGRectUnion(NSRectToCGRect(self.frame), pointRect));
    self.numberOfPoints++;
    self.needsDisplay = YES;
}

#pragma mark -

- (id) initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        CALayer *layer = [CALayer layer];
        layer.frame = self.frame;
        layer.borderColor = [NSColor redColor].CGColor;
        layer.borderWidth = 1.f;
        self.layer = layer;
        [self setWantsLayer:YES];
        self.data = [NSMutableArray array];
        self.numberOfPoints = 0;
    }
    return self;
}

@end
