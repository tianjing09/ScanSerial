//
//  ScanViewController.swift
//  ScanSerial
//
//  Created by jing 田 on 2018/3/10.
//  Copyright © 2018年 jing 田. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    lazy var session = AVCaptureSession.init()
    
    lazy var tipLabel: UILabel = {
        let label =  UILabel.init(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        label.center = self.view.center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.text = ""
        label.backgroundColor = .orange
        label.isHidden = true
        return label
    }()
    
    lazy var filePath: String? = {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        if let cachePath = paths.first {
            let filePathName = cachePath.appending("/scanSerialHistoryList.plist")// "scanSerialHistoryList.plist")
            return filePathName
        }
        return  nil
    }()
    
    var delegate: ScanViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadScanView()
        self.refreshView()
    }
    
    private func refreshView() {
        self.view.backgroundColor = .white
        
        let height = self.view.bounds.size.height
        let width = self.view.bounds.size.width
        
        let topView = UIView.init(frame: CGRect(x: 0, y: 0, width: width, height: height/2 - 40))
        topView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.view.addSubview(topView)
        
        let bottomView = UIView.init(frame: CGRect(x: 0, y: height/2 + 40 , width: width, height: height/2 - 40))
        bottomView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.view.addSubview(bottomView)
        
        let backButton = UIButton(type: .system)
        backButton.setTitle("返回", for: .normal)
        backButton.frame = CGRect(x: 20, y: 25, width: 100, height: 50)
        backButton.addTarget(self, action:#selector(back), for: .touchUpInside)
        backButton.backgroundColor = .orange
        backButton.layer.cornerRadius = 10.0;
        self.view.addSubview(backButton)
        
        self.view.addSubview(tipLabel)
    }

    @objc private func back() {
       self.dismiss(animated: true, completion: nil)
     }
    
    private func loadScanView() {
        if let device = AVCaptureDevice.default(for: .video), let input = try? AVCaptureDeviceInput.init(device: device) {
            let output = AVCaptureMetadataOutput.init()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            session.canSetSessionPreset(.high)
            session.addInput(input)
            session.addOutput(output)
            let height = self.view.bounds.size.height
            output.rectOfInterest = CGRect(x: (height/2 - 40.0) / height, y: 0, width: 80.0 / height, height: 1)
            output.metadataObjectTypes = [.ean8, .ean13, .upce, .code39, .code39Mod43, .code93, .code128, .pdf417]
            let layer = AVCaptureVideoPreviewLayer.init(session: session)
            layer.videoGravity = .resizeAspectFill
            layer.frame = self.view.layer.bounds
            self.view.layer.insertSublayer(layer, at: 0)
            session.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if !metadataObjects.isEmpty {
            if let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let value = readableObject.stringValue {
                if vertifyScanString(value) {
                    session.stopRunning()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func vertifyScanString(_ scanString: String) -> Bool {
        if scanString.count == 12 || scanString.count == 13 {
            var processString = scanString
            if scanString.count == 13, scanString.first == "S" {
               processString.remove(at: processString.startIndex)
            } else {
                showTip("扫描的不是设备序列号，请重新扫描其他")
            }
            if let path = filePath {
                var isHave = false
                var historyArray = [Any]()
                if let historyList = NSArray.init(contentsOfFile: path) {
                    historyArray = historyList as! [Any]
                    for item in historyList {
                        if let history = item as? Dictionary<String, String>  {
                            if (history["serialNO"] == processString) {
                               isHave = true
                               break
                            }
                        }
                    }
                }
                if (isHave) {
                  showTip("已经扫描过此设备序列号，请重新扫描其他")
                } else {
                    let dformatter = DateFormatter()
                    dformatter.dateFormat = "yyyy年MM月dd日"
                    let dic = ["time":dformatter.string(from:Date()), "serialNO":processString]
                    let list = NSMutableArray.init(array: historyArray)
                    list.add(dic)
                    list.write(toFile: path, atomically: true)
                    delegate?.didScan(processString)
                    return true
                }
            }
            return false
        }
        showTip("扫描的不是设备序列号，请重新扫描其他")
        return false
    }
    
    private func showTip(_ tip: String) {
        tipLabel.text = tip
        if tipLabel.isHidden {
            tipLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                self.tipLabel.isHidden = true
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

protocol ScanViewControllerDelegate : NSObjectProtocol {
    func didScan(_ valueString: String)
}
