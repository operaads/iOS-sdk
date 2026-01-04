//
//  OpAdxNativeAdView.swift
//  OperaAdxSDK
//
//  Created by Opera Software on 2025.
//  Copyright © 2025 Opera Norway AS. All rights reserved.
//


import UIKit
import OpAdxSdk

@objc public class OpAdxNativeAdView: UIView {
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let starRatingLabel = UILabel()
    private let callToActionButton = UIButton()
    private let mediaView = OpAdxMediaView()
    private let iconView = UIImageView()
    
    // MARK: - Properties
    private var starRatingConstraints: [NSLayoutConstraint] = []
    private var titleConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Public API
    
    /// 获取交互视图，用于注册广告点击
    public var interactionViews: OpAdxInteractionViews {
        return OpAdxInteractionViews(
            mediaView: mediaView,
            titleView: titleLabel,
            bodyView: bodyLabel,
            callToActionView: callToActionButton,
            iconView: iconView
        )
    }
    
    /// 配置广告内容
    /// - Parameter nativeAd: 原生广告数据
    public func configure(with nativeAd: OpAdxNativeAd) {
        titleLabel.text = nativeAd.title()
        bodyLabel.text = nativeAd.descriptionStr()
        
        // 配置星级评分
        if let rating = nativeAd.starRating() {
            starRatingLabel.text = String(format: "★ %.1f", rating)
            starRatingLabel.isHidden = false
        } else {
            starRatingLabel.isHidden = true
        }
        
        // 配置行动按钮
        if let ctaText = nativeAd.callToAction() {
            callToActionButton.setTitle(ctaText, for: .normal)
            callToActionButton.isHidden = false
        } else {
            callToActionButton.isHidden = true
        }
        
        // 更新布局约束
        updateTitleLabelConstraints()
    }
    
    /// 清理视图状态
    public func clearContent() {
        titleLabel.text = nil
        bodyLabel.text = nil
        starRatingLabel.text = nil
        starRatingLabel.isHidden = true
        callToActionButton.setTitle(nil, for: .normal)
        callToActionButton.isHidden = true
        updateTitleLabelConstraints()
    }
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupNativeAdView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupNativeAdView()
    }
    
    // MARK: - Setup
    private func setupNativeAdView() {
        setupAppearance()
        addSubviews()
        setupConstraints()
    }
    
    private func setupAppearance() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 8
        
        // 标题标签
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        
        // 正文标签
        bodyLabel.font = .systemFont(ofSize: 14)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 2
        
        // 星级评分标签
        starRatingLabel.font = .systemFont(ofSize: 12)
        starRatingLabel.textColor = .systemYellow
        starRatingLabel.isHidden = true
        
        // 行动按钮
        callToActionButton.backgroundColor = .systemBlue
        callToActionButton.setTitleColor(.white, for: .normal)
        callToActionButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        callToActionButton.layer.cornerRadius = 4
        callToActionButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        
        // 媒体视图
        mediaView.backgroundColor = .systemGray4
        mediaView.contentMode = .scaleAspectFill
        mediaView.clipsToBounds = true
        
        // 图标视图
        iconView.backgroundColor = .systemGray3
        iconView.layer.cornerRadius = 4
        iconView.clipsToBounds = true
        iconView.contentMode = .scaleAspectFill
    }
    
    private func addSubviews() {
        addSubview(mediaView)
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(bodyLabel)
        addSubview(starRatingLabel)
        addSubview(callToActionButton)
    }
    
    private func setupConstraints() {
        // 禁用自动转换
        [mediaView, iconView, titleLabel, bodyLabel, starRatingLabel, callToActionButton]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        // 基本约束
        let baseConstraints = [
            // 图标
            iconView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            iconView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 12),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            // 媒体视图
            mediaView.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12),
            mediaView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mediaView.heightAnchor.constraint(greaterThanOrEqualTo: mediaView.widthAnchor,
                                            multiplier: 0.5),
            
            // 正文
            bodyLabel.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 12),
            bodyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            bodyLabel.trailingAnchor.constraint(equalTo: callToActionButton.leadingAnchor,
                                              constant: -8),
            bodyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            // 行动按钮
            callToActionButton.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 12),
            callToActionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            callToActionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            callToActionButton.heightAnchor.constraint(equalToConstant: 36),callToActionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ]
        
        NSLayoutConstraint.activate(baseConstraints)
        
        // 初始化标题约束
        updateTitleLabelConstraints()
    }
    
    private func updateTitleLabelConstraints() {
        // 移除旧的约束
        NSLayoutConstraint.deactivate(titleConstraints)
        titleConstraints.removeAll()
        
        // 设置新的标题约束
        if starRatingLabel.isHidden {
            // 无星级评分时，标题居中于图标
            titleConstraints = [
                titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12-24),
                titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor)
            ]
        } else {
            // 有星级评分时，标题在图标顶部
            titleConstraints = [
                titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12-24),
                titleLabel.topAnchor.constraint(equalTo: iconView.topAnchor),
                titleLabel.heightAnchor.constraint(equalToConstant: 20),
                
                // 星级评分在标题下方
                starRatingLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                starRatingLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                starRatingLabel.bottomAnchor.constraint(equalTo: iconView.bottomAnchor),
                starRatingLabel.heightAnchor.constraint(equalToConstant: 16)
            ]
        }
        
        NSLayoutConstraint.activate(titleConstraints)
        
        // 更新布局
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        // 确保隐私图标在最上层
//        if hasAdChoiceView {
//            bringSubviewToFront(subviews.last!)
//        }
    }
}
