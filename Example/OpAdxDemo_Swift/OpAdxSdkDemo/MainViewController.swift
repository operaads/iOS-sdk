//
//  MainViewController.swift
//  OperaAdxSDK
//
//  Created by Luan Chen on 2025/11/4.
//

import UIKit
import OpAdxSdk

class MainViewController: UIViewController {
    
    private let tableView = UITableView()
    private let sdkVersionLabel = UILabel()
    
    private let items: [MainItem] = [
        MainItem(format: "Native", placementId: AdConfig.getPlacementId(adFormat: .native, forceVideo: false)),
        MainItem(format: "Banner", placementId: AdConfig.getPlacementId(adFormat: .banner, forceVideo: false)),
        MainItem(format: "Interstitial", placementId: AdConfig.getPlacementId(adFormat: .interstitial, forceVideo: false)),
        MainItem(format: "Rewarded", placementId: AdConfig.getPlacementId(adFormat: .rewarded, forceVideo: false)),
        MainItem(format: "Bid Response Debugging", placementId: "Debug custom bid responses")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let initConfig =  OpAdxSdkInitConfig.create(applicationId: AdConfig.applicationId, iOSAppId: AdConfig.iOSAppId)
        initConfig.useTestAd = AdConfig.useTestAd // only use for test
        OpAdxSdkCore.shared.initialize(initConfig: initConfig)
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Opera Ads Demo"
        
        sdkVersionLabel.text = "SDK Version: \(OpAdxSdkCore.getVersion()).\(OpAdxSdkCore.getBuildNum())"
        sdkVersionLabel.textAlignment = .center
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainCell")
        tableView.isScrollEnabled = false
        
        view.addSubview(sdkVersionLabel)
        view.addSubview(tableView)
        
        sdkVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            sdkVersionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            sdkVersionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sdkVersionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: sdkVersionLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainTableViewCell
        let item = items[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = items[indexPath.row]
        var viewController: UIViewController?
        
        switch item.format {
        case "Native":
            viewController = NativeViewController()
        case "Banner":
            viewController = BannerViewController()
        case "Interstitial":
            viewController = InterstitialViewController()
        case "Rewarded":
            viewController = RewardedViewController()
        case "Bid Response Debugging":
            viewController = BidRespDebugViewController()
        default:
            break
        }
        
        if let vc = viewController {
            if vc is BaseViewController {
                let baseVC:BaseViewController = vc as! BaseViewController
                baseVC.placementId = item.placementId
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// Supporting types
struct MainItem {
    let format: String
    let placementId: String
}

class MainTableViewCell: UITableViewCell {
    private let formatLabel = UILabel()
    private let placementLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        formatLabel.font = .boldSystemFont(ofSize: 16)
        placementLabel.font = .systemFont(ofSize: 12)
        placementLabel.textColor = .gray
        placementLabel.numberOfLines = 2
        
        let stackView = UIStackView(arrangedSubviews: [formatLabel, placementLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with item: MainItem) {
        formatLabel.text = item.format
        placementLabel.text = item.placementId
    }
}

