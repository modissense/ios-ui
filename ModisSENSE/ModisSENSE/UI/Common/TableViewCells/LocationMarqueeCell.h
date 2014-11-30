//
//  UITableViewCellFixedMarqueeCell.h
//  Agrotypos
//
//  Created by Panagiotis Kokkinakis on 1/30/13.
//  Copyright (c) 2013 mac1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoScrollLabel.h"

@interface LocationMarqueeCell : UITableViewCell {
    @private
    AutoScrollLabel *iMarqueeLabel;
}

@property (nonatomic, readonly, strong) AutoScrollLabel *marqueeLabel;

@end
