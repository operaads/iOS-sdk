//
//  BaseViewController.swift
//  OperaAdxSDK
//
//  Created by Luan Chen on 2025/11/4.
//

import UIKit
import OpAdxSdk

class BaseViewController: UIViewController {
    
    var placementId: String?
    let logView = LogView()
    let adContainer = UIView()
    
    private var adFormatLabel = UILabel()
    private var placementIdLabel = UILabel()
    private var loadAdButton = UIButton()
    private var showAdButton = UIButton()
    private var destroyAdButton = UIButton()
    private var videoToggle: UISwitch?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        loadAdButton.addTarget(self, action: #selector(loadAdTapped), for: .touchUpInside)
        showAdButton.addTarget(self, action: #selector(showAdTapped), for: .touchUpInside)
        destroyAdButton.addTarget(self, action: #selector(destroyAdTapped), for: .touchUpInside)
        
        disableShowAd()
        disableDestroyAd()
        
        if hasVideo {
            setupVideoToggle()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        adFormatLabel.text = adFormatString
        placementIdLabel.text = placementId
        placementIdLabel.numberOfLines = 0
        
        loadAdButton.setTitle("Load Ad", for: .normal)
        loadAdButton.backgroundColor = .systemBlue
        
        showAdButton.setTitle("Show Ad", for: .normal)
        showAdButton.backgroundColor = .systemGreen
        
        destroyAdButton.setTitle("Destroy Ad", for: .normal)
        destroyAdButton.backgroundColor = .systemRed
        
        [adFormatLabel, placementIdLabel, loadAdButton, showAdButton,
         destroyAdButton, adContainer].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        logView.setup(in: view)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            adFormatLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            adFormatLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            placementIdLabel.topAnchor.constraint(equalTo: adFormatLabel.bottomAnchor, constant: 10),
            placementIdLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            placementIdLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            loadAdButton.topAnchor.constraint(equalTo: placementIdLabel.bottomAnchor, constant: 20),
            loadAdButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loadAdButton.widthAnchor.constraint(equalToConstant: 100),
            loadAdButton.heightAnchor.constraint(equalToConstant: 44),
            
            showAdButton.topAnchor.constraint(equalTo: loadAdButton.topAnchor),
            showAdButton.leadingAnchor.constraint(equalTo: loadAdButton.trailingAnchor, constant: 10),
            showAdButton.widthAnchor.constraint(equalToConstant: 100),
            showAdButton.heightAnchor.constraint(equalToConstant: 44),
            
            destroyAdButton.topAnchor.constraint(equalTo: loadAdButton.topAnchor),
            destroyAdButton.leadingAnchor.constraint(equalTo: showAdButton.trailingAnchor, constant: 10),
            destroyAdButton.widthAnchor.constraint(equalToConstant: 100),
            destroyAdButton.heightAnchor.constraint(equalToConstant: 44),
            
            adContainer.topAnchor.constraint(equalTo: loadAdButton.bottomAnchor, constant: 20),
            adContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            adContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            adContainer.heightAnchor.constraint(equalToConstant: 340)
        ])
        
        logView.setupConstraints(in: view, below: adContainer)
    }
    
    private func setupVideoToggle() {
        let videoLabel = UILabel()
        videoLabel.text = "isVideo"
        
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(videoToggleChanged(_:)), for: .valueChanged)
        self.videoToggle = toggle
        
        let stackView = UIStackView(arrangedSubviews: [videoLabel, toggle])
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: placementIdLabel.centerYAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: placementIdLabel.centerXAnchor, constant: 20)
        ])
    }
    
    @objc private func videoToggleChanged(_ sender: UISwitch) {
        placementId = AdConfig.getPlacementId(adFormat: adFormat, forceVideo: sender.isOn)
        placementIdLabel.text = placementId
    }
    
    @objc private func loadAdTapped() {
        loadAd()
    }
    
    @objc private func showAdTapped() {
        showAd()
    }
    
    @objc private func destroyAdTapped() {
        destroyAd()
    }
    
    // MARK: - Properties to override
    var hasVideo: Bool {
        return false
    }
    
    var adFormat: AdFormat {
        return .banner
    }
    
    var adFormatString: String {
        return ""
    }
    
    // MARK: - Methods to override
    func loadAd() {}
    
    func showAd() {}
    
    func destroyAd() {
        adContainer.subviews.forEach { $0.removeFromSuperview() }
    }
    
    // MARK: - Button state management
    func enableShowAd() {
        showAdButton.isEnabled = true
        showAdButton.alpha = 1.0
    }
    
    func disableShowAd() {
        showAdButton.isEnabled = false
        showAdButton.alpha = 0.5
    }
    
    func enableDestroyAd() {
        destroyAdButton.isEnabled = true
        destroyAdButton.alpha = 1.0
    }
    
    func disableDestroyAd() {
        destroyAdButton.isEnabled = false
        destroyAdButton.alpha = 0.5
    }
    
    func isVideoItem() -> Bool {
        return self.videoToggle?.isOn ?? false
    }
}
