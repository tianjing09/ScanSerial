//
//  ViewController.swift
//  ScanSerial
//
//  Created by jing 田 on 2018/2/9.
//  Copyright © 2018年 jing 田. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, ScanViewControllerDelegate {
    var viewWidth: CGFloat = 0.0
    lazy var resultLabel: UILabel = {
        let label =  UILabel.init(frame: CGRect(x: 20, y: 180, width: self.viewWidth - 40, height: 50))
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .orange
        label.text = ""
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewWidth = self.view.bounds.size.width
        // Do any additional setup after loading the view, typically from a nib.
        self.refreshView()
    }

    private func refreshView() {
        self.view.backgroundColor = .white
        self.title = "扫描"
        let rightButton = UIButton(type: .system)
        rightButton.setTitle("历史", for: .normal)
        rightButton.addTarget(self, action:#selector(seeList), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        
        let scanButton = UIButton(type: .system)
        scanButton.setTitle("扫描条形码", for: .normal)
        scanButton.frame = CGRect(x: (self.viewWidth - 100) / 2, y: 20, width: 100, height: 100)
        scanButton.addTarget(self, action:#selector(scan), for: .touchUpInside)
        scanButton.backgroundColor = .orange
        scanButton.layer.cornerRadius = 50.0;
        self.view.addSubview(scanButton)
        
        let resultTitleLabel = UILabel.init(frame: CGRect(x: 20, y: 150, width: 100, height: 30))
        resultTitleLabel.font = UIFont.systemFont(ofSize: 18)
        resultTitleLabel.textColor = .orange
        resultTitleLabel.text = "扫描结果:"
        self.view.addSubview(resultTitleLabel)
      
        self.view.addSubview(resultLabel)
    }
    
    @objc private func seeList() {
      self.navigationController?.pushViewController(HistoryListViewController(), animated: true)
    }
    
    @objc private func scan() {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if granted {
                DispatchQueue.main.async {
                    let viewController = ScanViewController()
                    viewController.delegate = self
                    self.present(viewController, animated: true, completion: nil)
                }
            } else {
                let alertController = UIAlertController(title: "提示", message: "你的相机不允许访问，请通过设置打开", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "好的", style: .default, handler:nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func didScan(_ valueString: String) {
        resultLabel.text = "设备序列号：" + valueString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

