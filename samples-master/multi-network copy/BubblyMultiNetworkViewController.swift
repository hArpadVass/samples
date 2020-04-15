//
//  BubblyMultiNetworkViewController.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 3/31/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision
import Floaty

class BubblyMultiNetworkViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fab: Floaty!
    
    var asyncManager = MeshNetworkManager.instance
    let picker = UIDocumentPickerViewController(documentTypes: ["public.data", "public.content"]
        , in: .import)
    var dataSet : [BubblySupplimentalNetwork] = []
    var fileHelper : FileUtility = FileUtility()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate      = self
        tableView.dataSource = self
        tableView.delegate   = self
        
        activityIndicator.isHidden         = true
        activityIndicator.hidesWhenStopped = true
        
        tableView.setEmptyView(title: "No other network is not\n associated with any others."
            , message: ""
            , messageImage: UIImage())
        
        if let supNetworks = MeshNetworkManager.instance.meshNetwork?.supplimentalNetworks{
            dataSet = supNetworks
        }
        
        if dataSet.count == 0 {
            tableView.showEmptyView()
        }
        
        fab.buttonColor =  ApplicationColors.color.primary
        fab.hasShadow   =  true
        fab.buttonImage =  UIImage(named: "add_bnt")
        fab.plusColor = .almostWhite
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        fab.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addPressed(_ sender: Any) {
        present(picker, animated: true, completion: nil)
    }
}
extension BubblyMultiNetworkViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSet.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MultiNetworkTableViewCell
        cell?.setlabels(source: dataSet[indexPath.row])
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let source = dataSet[indexPath.row]
        
        switchNetwork(otherNetworkURL: source.url)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            let network = MeshNetworkManager.instance.meshNetwork
            network?.removeSupplimentalNetwork(supNet: dataSet[indexPath.row])
            if MeshNetworkManager.instance.save(){
                fileHelper.removeFileFromDir(fileName: dataSet[indexPath.row].fileName)
                dataSet.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                print("configuration saved")
            }else{
                print("something went wrong")
            }
        }
    }
    
}
extension BubblyMultiNetworkViewController : UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                ///get data for selected network
                let data = try Data(contentsOf: url)
                let secondaryNetwork = try self.asyncManager.meshNetwork?.importStaticNetwork(from: data)
                let fName = url.lastPathComponent
                ///get documents directory
                let docsDir = self.fileHelper.getDocsDirectory()
                guard var directoryURL = docsDir else { return }
                directoryURL.appendPathComponent(fName)
                
                ///check to see if file already exist in the documents
                
                if self.fileHelper.checkFileExist(fileName: fName){
                    print("exist")
                    guard let netToAdd = secondaryNetwork else { return }
                    ///file exist so we'll go ahead and create the obj to store in the json
                    DispatchQueue.main.async {
                        self.addSupNetwork(networkName: netToAdd.meshName
                            , fileName: url.lastPathComponent
                            , url: directoryURL
                            , nodesCount: netToAdd.nodes.count
                            , description: ""
                            , networkID: netToAdd.uuid.uuidString)
                    }
                }else{
                    ///test results - only files showing from previous test manually putting them into the downloads are shownig up.
                    ///need to move from temp files to document location
                    print("doesnt exist")
                    do {
                        ///move file into storage
                        try FileManager.default.moveItem(at: url, to: directoryURL)
                        
                        ///create obj and add to json
                        guard let netToAdd = secondaryNetwork else { return }
                        DispatchQueue.main.async {
                            self.addSupNetwork(networkName: netToAdd.meshName
                                , fileName: url.lastPathComponent
                                , url: directoryURL
                                , nodesCount: netToAdd.nodes.count
                                , description: ""
                                , networkID: netToAdd.uuid.uuidString)
                        }
                    } catch  {
                        print(error.localizedDescription)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.presentAlert(title: "Error", message: "Importing Mesh Network configuration failed.\nCheck if the file is valid.")
                }
            }
        }
    }
    
    
    func switchNetwork(otherNetworkURL url : URL){
        let manager         = MeshNetworkManager.instance
        let pNet = MeshNetworkManager.instance.meshNetwork
        
        guard let previousNetwork = pNet else { return }
        
        guard let previousFileName = MeshNetworkManager.instance.meshNetwork?.meshName else {
            ///todo : handle feedback
            return
        }
        ///we need this url incase the newly imported network does not have the origional networked saved as an associated network.
        ///it is done here so we dont encounter more
        let pURL = fileHelper.getDirectoryFileURL(fileName: "\(previousFileName).json")
        guard let previousURL = pURL else { return }
        
        
        
        
        let targetFileURL = fileHelper.getDirectoryFileURL(fileName: url.lastPathComponent)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: targetFileURL!)
                let _    = try manager.import(from: data)
                
                
                if manager.save() {
                    ///we have to check if the previous network is associated with the network we just switched to. If its not then we have to add it as an assoicated network to the new file. If we ddint do this then the user would have to import / export if they wanted to switch back.
                    
                    /// todo check save function.  -- also have to change the way we save. We need to be aware that saving data could over write json file. so when ever we save we need to explicitly check the file.
                    /// todo - have to save current config before importing new // figure out how to refresh network
                    DispatchQueue.main.async {
                        let importedNetwork = MeshNetworkManager.instance.meshNetwork
                        if !(importedNetwork?.supplimentalNetworks?.contains(where: { $0.networkID == previousNetwork.uuid.uuidString}) ?? false){
                            self.addSupNetwork(networkName: previousNetwork.meshName
                                , fileName: previousFileName
                                , url: previousURL
                                , nodesCount: previousNetwork.nodes.count
                                , description: ""
                                , networkID: previousNetwork.uuid.uuidString)
                            
                            /// save this prvious network in the documents -- if its not there
                            let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                            guard let directoryStr = directory else { return }
                            let directoryURL = URL(fileURLWithPath: directoryStr, isDirectory: true)
                            
                            do {
                                try FileManager.default.moveItem(at: url, to: directoryURL)
                            } catch {
                                print("error")
                            }
                        }
 
                        (UIApplication.shared.delegate as! AppDelegate).meshNetworkDidChange()
                        self.reload()
                        self.presentAlert(title: "Success", message: "Mesh Network configuration imported.")
                    }
                    print("success")
                } else {
                    print("failure")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func reload() {
        
        MeshNetworkManager.instance.selectedConfigGroup  = nil
        MeshNetworkManager.instance.selectedControlGroup = nil
        
        // All tabs should be reset to the root view controller.
        parent?.parent?.children.forEach {
            if let rootViewController = $0 as? UINavigationController {
                rootViewController.popToRootViewController(animated: false)
            }
        }
    }
    
    
    func addSupNetwork(networkName: String, fileName: String, url: URL, nodesCount: Int, description: String, networkID: String){
        let networkToAdd = BubblySupplimentalNetwork(netName: networkName
            , fileName: fileName
            , url: url
            , nodes: nodesCount
            , description: description
            , networkID: networkID)
        
        if self.dataSet.contains(where: {$0.networkID == networkToAdd.networkID}) ||
            self.asyncManager.meshNetwork?.uuid.uuidString == networkToAdd.networkID{
            ///checks for duplicate addresses - if duplicate it returns out of function
            let alert = UIAlertController(title: "Duplicate Detected"
                , message: "This network is already associated with the current network."
                , preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay" , style: .cancel) { (_) in
                self.activityIndicator.stopAnimating()
            }
            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }
        
        ///if it reaches here - saves to json
        MeshNetworkManager.instance.meshNetwork?.addSupplimentalNetwork(network: networkToAdd)
        if MeshNetworkManager.instance.save(){
            
            self.dataSet.append(networkToAdd)
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.tableView.hideEmptyView()
            self.asyncManager = MeshNetworkManager.instance
        }else{
            let alert = UIAlertController(title: "Failure"
                , message: "Networks could not be associated."
                , preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "Close"
                , style: .cancel
                , handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        }
    }
}
