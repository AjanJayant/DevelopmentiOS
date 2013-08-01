//
//  ADCustomTableView.m
//  ADCustomTableView
//
//  Created by Anton Domashnev on 11.06.13.
//  Copyright (c) 2013 Anton Domashnev. All rights reserved.
//

#import "ADCustomTableView.h"

@interface ADCustomTableView()

@end

@implementation ADCustomTableView

@synthesize appearanceSpeed = _appearanceSpeed;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.appearanceSpeed = 1;
    }
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset{
    
    [super setContentOffset: contentOffset];
    [self updateVisibleCells];
}

#pragma mark Helpers

- (void)updateOriginXForCell:(UITableViewCell *)cell withCellRect:(CGRect)cellRect originCellRect:(CGRect)originCellRect{
    
    CGRect newFrame = cell.contentView.frame;
    CGFloat selfHeight = self.frame.size.height;
    CGFloat cellWidth = cell.contentView.frame.size.width;
    CGFloat cellHeight = cell.contentView.frame.size.height;
    CGFloat cellOriginY = cellRect.origin.y;
    
    CGFloat newOriginX = (cellOriginY - selfHeight) / (selfHeight - cellHeight / self.appearanceSpeed - selfHeight) * -cellWidth + cellWidth;
    
    if(newOriginX > cellWidth){
        
        newOriginX = cellWidth;
    }
    else if(newOriginX < 0 ||
            CGRectContainsPoint(self.frame, originCellRect.origin)){
        
        newOriginX = 0;
    }
    
    newFrame.origin.x = newOriginX;
    cell.contentView.frame = newFrame;
}

- (void)updateVisibleCells{
    
    for(NSIndexPath *indexPath in self.indexPathsForVisibleRows){
        
        CGRect originRowRect = [self rectForRowAtIndexPath:indexPath];
        CGRect rowRect = [self.superview convertRect:[self rectForRowAtIndexPath:indexPath] fromView:self];
        UITableViewCell *cell = [self cellForRowAtIndexPath: indexPath];
        [self updateOriginXForCell:cell withCellRect:rowRect originCellRect: originRowRect];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
