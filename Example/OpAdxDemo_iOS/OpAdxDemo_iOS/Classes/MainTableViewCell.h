//
//  MainTableViewCell.h
//  OpAdxDemo_iOS
//
//  Created by Luan Chen on 2025/12/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainItem : NSObject

@property (nonatomic, strong) NSString *format;
@property (nonatomic, strong) NSString *placementId;
- (instancetype)initWithFormat:(NSString *)format placementId:(NSString *)placementId;

@end


@interface MainTableViewCell : UITableViewCell

- (void)configureWithItem:(MainItem *)item;

@end


NS_ASSUME_NONNULL_END
