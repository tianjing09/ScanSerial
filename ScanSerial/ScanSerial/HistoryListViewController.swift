//
//  HistoryListViewController.swift
//  ScanSerial
//
//  Created by jing 田 on 2018/3/11.
//  Copyright © 2018年 jing 田. All rights reserved.
//

import UIKit

class HistoryListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView:UITableView?
    lazy var historyList: NSArray? = {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        if let cachePath = paths.first {
            let filePathName = cachePath.appending("/scanSerialHistoryList.plist")
            if let historyList = NSArray.init(contentsOfFile: filePathName) {
                return historyList
            }
        }
        return  nil
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Do any additional setup after loading the view.
        self.refreshView()
    }
    
    private func refreshView() {
        self.view.backgroundColor = .white
        self.title = "扫描记录"
        self.tableView = UITableView(frame:self.view.frame, style:.plain)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.register(UITableViewCell.self,
                                 forCellReuseIdentifier: "HistoryCell")
        self.view.addSubview(self.tableView!)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let history = historyList {
            return history.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let identify:String = "HistoryCell"
            let cell = tableView.dequeueReusableCell(
                withIdentifier: identify, for: indexPath)
            if let history = historyList {
                if let item = history[indexPath.row] as? Dictionary<String, String> {
                    cell.textLabel?.text = item["time"]! + "扫描过: " + item["serialNO"]!
                }
            }
            return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
