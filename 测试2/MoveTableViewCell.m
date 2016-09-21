//
//  MoveTableViewCell.m
//  测试2
//
//  Created by linxun on 15/12/25.
//  Copyright © 2015年 linxun. All rights reserved.
//

#import "MoveTableViewCell.h"

@implementation MoveTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 添加move视图
        self.moveView = [[UIView alloc] initWithFrame:CGRectMake(20, 15, 160, 120)];
        [self addSubview:self.moveView];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
