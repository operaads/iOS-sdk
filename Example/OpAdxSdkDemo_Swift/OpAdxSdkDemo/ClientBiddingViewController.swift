//
//  ClientBiddingViewController.swift
//  OpAdxSdkDemo
//
//  Client-side bidding test page
//  Demonstrates how to use C2S bidding API for header bidding
//

import UIKit
import OpAdxSdk

class ClientBiddingViewController: UIViewController {

    // MARK: - Properties

    /// 存储多个广告及其出价信息
    private var loadedAds: [(ad: OpAdxInterstitialAd, bid: AdBid?, placementId: String)] = []

    /// 测试用的 Placement IDs（使用不同的广告位进行竞价）
    private let testPlacementIds = [
        AdConfig.getPlacementId(adFormat: .interstitial, forceVideo: false),
        AdConfig.getPlacementId(adFormat: .interstitial, forceVideo: true),
        AdConfig.getPlacementId(adFormat: .rewarded, forceVideo: false)
    ]

    /// 获胜广告索引
    private var winnerIndex: Int?

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    private let loadAdsButton = UIButton(type: .system)
    private let runAuctionButton = UIButton(type: .system)
    private let showWinnerButton = UIButton(type: .system)
    private let clearButton = UIButton(type: .system)

    private let statusLabel = UILabel()
    private let logTextView = UITextView()

    private let bidsTableView = UITableView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updateButtonStates()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .white
        title = "Client Bidding Test"

        // Title
        titleLabel.text = "🎯 Client-Side Bidding (C2S)"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center

        // Description
        descriptionLabel.text = "加载多个广告源，在客户端进行竞价，通知获胜者和失败者"
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center

        // Buttons
        setupButton(loadAdsButton, title: "1️⃣ Load Multiple Ads", color: .systemBlue, action: #selector(loadMultipleAds))
        setupButton(runAuctionButton, title: "2️⃣ Run Auction", color: .systemOrange, action: #selector(runAuction))
        setupButton(showWinnerButton, title: "3️⃣ Show Winner", color: .systemGreen, action: #selector(showWinner))
        setupButton(clearButton, title: "🗑️ Clear All", color: .systemRed, action: #selector(clearAll))

        // Status
        statusLabel.text = "准备就绪"
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textAlignment = .center
        statusLabel.textColor = .darkGray
        statusLabel.numberOfLines = 0

        // Bids Table
        bidsTableView.delegate = self
        bidsTableView.dataSource = self
        bidsTableView.register(BidTableViewCell.self, forCellReuseIdentifier: "BidCell")
        bidsTableView.layer.borderColor = UIColor.lightGray.cgColor
        bidsTableView.layer.borderWidth = 1
        bidsTableView.layer.cornerRadius = 8
        bidsTableView.isScrollEnabled = false

        // Log Text View
        logTextView.isEditable = false
        logTextView.font = .systemFont(ofSize: 12)
        logTextView.backgroundColor = .systemGray6
        logTextView.layer.borderColor = UIColor.lightGray.cgColor
        logTextView.layer.borderWidth = 1
        logTextView.layer.cornerRadius = 8
        logTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleLabel, descriptionLabel, loadAdsButton, runAuctionButton,
         showWinnerButton, clearButton, statusLabel, bidsTableView, logTextView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupButton(_ button: UIButton, title: String, color: UIColor, action: Selector) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            loadAdsButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            loadAdsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            loadAdsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            loadAdsButton.heightAnchor.constraint(equalToConstant: 44),

            runAuctionButton.topAnchor.constraint(equalTo: loadAdsButton.bottomAnchor, constant: 12),
            runAuctionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            runAuctionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            runAuctionButton.heightAnchor.constraint(equalToConstant: 44),

            showWinnerButton.topAnchor.constraint(equalTo: runAuctionButton.bottomAnchor, constant: 12),
            showWinnerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            showWinnerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            showWinnerButton.heightAnchor.constraint(equalToConstant: 44),

            clearButton.topAnchor.constraint(equalTo: showWinnerButton.bottomAnchor, constant: 12),
            clearButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            clearButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            clearButton.heightAnchor.constraint(equalToConstant: 44),

            statusLabel.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            bidsTableView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            bidsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bidsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bidsTableView.heightAnchor.constraint(equalToConstant: 200),

            logTextView.topAnchor.constraint(equalTo: bidsTableView.bottomAnchor, constant: 20),
            logTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            logTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            logTextView.heightAnchor.constraint(equalToConstant: 300),
            logTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Actions

    /// 步骤 1: 加载多个广告（C2S Bidding）
    @objc private func loadMultipleAds() {
        loadedAds.removeAll()
        winnerIndex = nil
        bidsTableView.reloadData()
        clearLogs()

        statusLabel.text = "正在加载 \(testPlacementIds.count) 个广告..."
        addLog("🎯 开始加载 \(testPlacementIds.count) 个 Client Bidding 广告")
        addLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        for (index, placementId) in testPlacementIds.enumerated() {
            addLog("📍 Placement #\(index): \(placementId)")

            // 创建插屏广告实例
            let ad = OpAdxInterstitialAd(
                placementId: placementId,
                auctionType: .clientBidding
            )

            // 🔑 关键：使用 loadC2SBid() 方法进行 client bidding
            ad.loadC2SBid(
                placementId: placementId,
                listener: AdLoadListener(
                    index: index,
                    placementId: placementId,
                    onSuccess: { [weak self] loadedAd in
                        self?.handleAdLoaded(loadedAd as! OpAdxInterstitialAd, index: index, placementId: placementId)
                    },
                    onFailure: { [weak self] error in
                        self?.handleAdLoadFailed(error, index: index, placementId: placementId)
                    }
                )
            )
        }

        updateButtonStates()
    }

    /// 广告加载成功回调
    private func handleAdLoaded(_ ad: OpAdxInterstitialAd, index: Int, placementId: String) {
        // 🔑 关键：获取 AdBid 对象
        let adBid = ad.getBid()

        if let bid = adBid {
            let ecpm = bid.getEcpm()
            addLog("✅ 广告 #\(index) 加载成功")
            addLog("   💰 eCPM: $\(String(format: "%.4f", ecpm))")
        } else {
            addLog("⚠️  广告 #\(index) 加载成功，但没有 bid 信息")
        }

        // 保存广告和 bid
        loadedAds.append((ad: ad, bid: adBid, placementId: placementId))
        bidsTableView.reloadData()

        // 检查是否所有广告都加载完成
        if loadedAds.count == testPlacementIds.count {
            addLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            addLog("🎉 所有广告加载完成！")
            addLog("📊 共 \(loadedAds.count) 个广告可参与竞价")
            statusLabel.text = "✅ 已加载 \(loadedAds.count) 个广告，可以开始竞价"
        } else {
            statusLabel.text = "正在加载... (\(loadedAds.count)/\(testPlacementIds.count))"
        }

        updateButtonStates()
    }

    /// 广告加载失败回调
    private func handleAdLoadFailed(_ error: OpAdxAdError, index: Int, placementId: String) {
        addLog("❌ 广告 #\(index) 加载失败")
        addLog("   错误: \(error.message)")

        // 即使失败也要添加一个占位，保持索引一致
        let placeholderAd = OpAdxInterstitialAd(placementId: placementId, auctionType: .clientBidding)
        loadedAds.append((ad: placeholderAd, bid: nil, placementId: placementId))
        bidsTableView.reloadData()

        if loadedAds.count == testPlacementIds.count {
            addLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            let successCount = loadedAds.filter { $0.bid != nil }.count
            addLog("⚠️  加载完成，但有失败项")
            addLog("📊 成功: \(successCount) / 总数: \(loadedAds.count)")
            statusLabel.text = "⚠️  部分广告加载失败 (\(successCount)/\(testPlacementIds.count))"
        }

        updateButtonStates()
    }

    /// 步骤 2: 运行竞价逻辑
    @objc private func runAuction() {
        guard !loadedAds.isEmpty else {
            addLog("❌ 没有可用的广告，请先加载")
            return
        }

        addLog("\n🏁 开始客户端竞价...")
        addLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        // 收集所有有效的出价
        var bidsWithIndex: [(index: Int, ecpm: Double)] = []

        for (index, item) in loadedAds.enumerated() {
            if let bid = item.bid {
                let ecpm = bid.getEcpm()
                bidsWithIndex.append((index: index, ecpm: ecpm))
                addLog("💵 广告 #\(index): eCPM = $\(String(format: "%.4f", ecpm))")
            } else {
                addLog("⏭️  广告 #\(index): 无出价（跳过）")
            }
        }

        guard !bidsWithIndex.isEmpty else {
            addLog("❌ 没有有效的出价")
            statusLabel.text = "❌ 竞价失败：没有有效出价"
            return
        }

        // 按 eCPM 降序排序
        bidsWithIndex.sort { $0.ecpm > $1.ecpm }

        let winnerIdx = bidsWithIndex[0].index
        let winnerEcpm = bidsWithIndex[0].ecpm
        let secondPrice = bidsWithIndex.count > 1 ? bidsWithIndex[1].ecpm : 0.0

        winnerIndex = winnerIdx

        addLog("\n🏆 竞价结果:")
        addLog("   获胜者: 广告 #\(winnerIdx)")
        addLog("   获胜价格: $\(String(format: "%.4f", winnerEcpm))")
        addLog("   第二高价: $\(String(format: "%.4f", secondPrice))")
        addLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        // 🔑 关键：通知所有广告竞价结果
        notifyAuctionResults(winnerIndex: winnerIdx, winnerPrice: winnerEcpm, secondPrice: secondPrice)

        statusLabel.text = "🏆 竞价完成！获胜者: 广告 #\(winnerIdx) ($\(String(format: "%.4f", winnerEcpm)))"
        bidsTableView.reloadData()
        updateButtonStates()
    }

    /// 通知竞价结果
    private func notifyAuctionResults(winnerIndex: Int, winnerPrice: Double, secondPrice: Double) {
        addLog("\n📢 通知竞价结果...")

        for (index, item) in loadedAds.enumerated() {
            guard let bid = item.bid else { continue }

            if index == winnerIndex {
                // 🔑 关键：通知获胜
                bid.notifyWin(
                    secondPrice: secondPrice,
                    bidderName: "OpAdx"
                )
                addLog("✅ 通知广告 #\(index) 获胜 (第二价格: $\(String(format: "%.4f", secondPrice)))")
            } else {
                // 🔑 关键：通知失败
                bid.notifyLose(
                    lossReason: .lowerThanHighestPrice,
                    winnerPrice: winnerPrice,
                    winnerBidder: "OpAdx"
                )
                addLog("📉 通知广告 #\(index) 失败 (原因: 价格低于最高价)")
            }
        }

        addLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    /// 步骤 3: 展示获胜广告
    @objc private func showWinner() {
        guard let winnerIdx = winnerIndex,
              winnerIdx < loadedAds.count else {
            addLog("❌ 请先运行竞价")
            return
        }

        let winnerAd = loadedAds[winnerIdx].ad

        addLog("\n🎬 展示获胜广告 #\(winnerIdx)...")

        winnerAd.show(
            on: self,
            listener: AdInteractionListener(
                onDisplayed: { [weak self] in
                    self?.addLog("👁️  广告已展示（Displayed）")
                },
                onClicked: { [weak self] in
                    self?.addLog("👆 广告被点击")
                },
                onDismissed: { [weak self] in
                    self?.addLog("🚪 广告已关闭")
                }
            )
        )

        updateButtonStates()
    }

    /// 清除所有
    @objc private func clearAll() {
        // 销毁所有广告
        for item in loadedAds {
            item.ad.destroy()
        }

        loadedAds.removeAll()
        winnerIndex = nil

        clearLogs()
        bidsTableView.reloadData()

        statusLabel.text = "准备就绪"
        addLog("🗑️  已清除所有广告")

        updateButtonStates()
    }

    // MARK: - Helpers

    private func addLog(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            let timestamp = dateFormatter.string(from: Date())

            let logMessage = "[\(timestamp)] \(message)\n"

            let oldText = self.logTextView.text ?? ""
            self.logTextView.text = oldText + logMessage

            // 滚动到底部
            let bottom = NSMakeRange(self.logTextView.text.count - 1, 1)
            self.logTextView.scrollRangeToVisible(bottom)
        }
    }

    private func clearLogs() {
        DispatchQueue.main.async { [weak self] in
            self?.logTextView.text = ""
        }
    }

    private func updateButtonStates() {
        let hasLoadedAds = !loadedAds.isEmpty
        let hasValidBids = loadedAds.contains { $0.bid != nil }
        let hasWinner = winnerIndex != nil

        runAuctionButton.isEnabled = hasValidBids && winnerIndex == nil
        runAuctionButton.alpha = runAuctionButton.isEnabled ? 1.0 : 0.5

        showWinnerButton.isEnabled = hasWinner
        showWinnerButton.alpha = showWinnerButton.isEnabled ? 1.0 : 0.5

        clearButton.isEnabled = hasLoadedAds
        clearButton.alpha = clearButton.isEnabled ? 1.0 : 0.5
    }
}

// MARK: - UITableViewDelegate & DataSource

extension ClientBiddingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(loadedAds.count, 1) // 至少显示一行
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BidCell", for: indexPath) as! BidTableViewCell

        if indexPath.row < loadedAds.count {
            let item = loadedAds[indexPath.row]
            let isWinner = winnerIndex == indexPath.row
            cell.configure(
                index: indexPath.row,
                bid: item.bid,
                isWinner: isWinner
            )
        } else {
            cell.configureEmpty()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - Supporting Classes

/// 广告加载监听器
class AdLoadListener: NSObject, OpAdxInterstitialAdLoadListener {
    let index: Int
    let placementId: String
    let onSuccess: (NSObject) -> Void
    let onFailure: (OpAdxAdError) -> Void

    init(index: Int, placementId: String, onSuccess: @escaping (NSObject) -> Void, onFailure: @escaping (OpAdxAdError) -> Void) {
        self.index = index
        self.placementId = placementId
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }

    func onAdLoaded(_ ad: NSObject) {
        onSuccess(ad)
    }

    func onAdFailedToLoad(_ error: OpAdxAdError) {
        onFailure(error)
    }
}

/// 广告交互监听器
class AdInteractionListener: NSObject, OpAdxInterstitialAdInteractionListener {
    let onDisplayed: () -> Void
    let onClicked: () -> Void
    let onDismissed: () -> Void

    init(onDisplayed: @escaping () -> Void, onClicked: @escaping () -> Void, onDismissed: @escaping () -> Void) {
        self.onDisplayed = onDisplayed
        self.onClicked = onClicked
        self.onDismissed = onDismissed
    }

    func onAdDisplayed() {
        onDisplayed()
    }

    func onAdClicked() {
        onClicked()
    }

    func onAdDismissed() {
        onDismissed()
    }

    func onAdFailedToShow(_ error: OpAdxAdError) {
        print("❌ 广告展示失败: \(error.message)")
    }
}

/// Bid 信息表格 Cell
class BidTableViewCell: UITableViewCell {
    private let indexLabel = UILabel()
    private let ecpmLabel = UILabel()
    private let statusLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        indexLabel.font = .boldSystemFont(ofSize: 16)
        ecpmLabel.font = .systemFont(ofSize: 14)
        ecpmLabel.textColor = .systemGreen
        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.textColor = .gray

        let stackView = UIStackView(arrangedSubviews: [indexLabel, ecpmLabel, statusLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(index: Int, bid: AdBid?, isWinner: Bool) {
        indexLabel.text = "广告 #\(index)"

        if let bid = bid {
            let ecpm = bid.getEcpm()
            ecpmLabel.text = "$\(String(format: "%.4f", ecpm))"
            ecpmLabel.textColor = isWinner ? .systemOrange : .systemGreen

            if isWinner {
                statusLabel.text = "🏆 获胜"
                statusLabel.textColor = .systemOrange
                contentView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
            } else {
                statusLabel.text = "已加载"
                statusLabel.textColor = .gray
                contentView.backgroundColor = .white
            }
        } else {
            ecpmLabel.text = "无出价"
            ecpmLabel.textColor = .lightGray
            statusLabel.text = "失败"
            statusLabel.textColor = .systemRed
            contentView.backgroundColor = .white
        }
    }

    func configureEmpty() {
        indexLabel.text = "等待加载..."
        ecpmLabel.text = "-"
        statusLabel.text = "-"
        ecpmLabel.textColor = .lightGray
        contentView.backgroundColor = .white
    }
}
