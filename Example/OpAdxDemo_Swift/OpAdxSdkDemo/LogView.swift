//
//  LogView.swift
//  OperaAdxSDK
//
//  Created by Luan Chen on 2025/11/4.
//

// Supporting Types and Protocols
import UIKit

class LogView {
    private var textView: UITextView?
    private var scrollView: UIScrollView?
    
    func setup(in view: UIView) {
        let scrollView = UIScrollView()
        let textView = UITextView()
        
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 12)
        textView.backgroundColor = .systemGray6
        
        scrollView.addSubview(textView)
        view.addSubview(scrollView)
        
        self.textView = textView
        self.scrollView = scrollView
    }
    
    func setupConstraints(in view: UIView, below anchorView: UIView) {
        guard let scrollView = scrollView, let textView = textView else { return }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: anchorView.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            textView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            textView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func print(_ message: String) {
        DispatchQueue.main.async {
            guard let textView = self.textView, let scrollView = self.scrollView else { return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            let timestamp = dateFormatter.string(from: Date())
            
            let logMessage = "[\(timestamp)] \(message)\n"
            
            // 保存当前文本并追加新内容
            let oldText = textView.text ?? ""
            textView.text = oldText + logMessage
            
            // 强制布局更新
            textView.layoutIfNeeded()
            
            // 计算并设置滚动位置
            let textHeight = textView.contentSize.height
            let scrollHeight = scrollView.bounds.height
            
            if textHeight > scrollHeight {
                let bottomOffset = CGPoint(x: 0, y: textHeight - scrollHeight + 20)
                scrollView.setContentOffset(bottomOffset, animated: false)
            }
        }
    }
}
