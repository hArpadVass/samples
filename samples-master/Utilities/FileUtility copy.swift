//
//  FileUtility.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 4/14/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import nRFMeshProvision

class FileUtility{
    
    
    init() { }
    
    func checkFileExist(fileName : String) -> Bool{
        let fm = FileManager.default
        ///files in the document directory
        let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        do {
            let items = try fm.contentsOfDirectory(atPath: documentsPathString!)
            print(items)
            return items.contains(fileName)
        } catch {
            print(error)
            return false
        }
    }
    
    func getDocsDirectory() -> URL?{
        let directory          = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        guard let directoryStr = directory else { return nil}
        let url                = URL(fileURLWithPath: directoryStr, isDirectory: true)
        return url
    }
  
    
    
    func getDirectoryFileURL(fileName : String) -> URL?{
        let docsDir = getDocsDirectory()
        guard let url = docsDir else {return nil}
        return url.appendingPathComponent(fileName)
    }
    
    
    func removeFileFromDir(fileName : String){
        print("looking for file \(fileName)")
        let fm      = FileManager.default
        let docsDir = getDocsDirectory()
        
        guard let directory = docsDir else {
            print("directory not found")
            return
        }
                
        do {
            let fileURLs = try fm.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            try fileURLs.forEach { (url) in
                if url.lastPathComponent == fileName{
                    print("match found -- attempting to delete file.")
                    ///we have to assign an empty variable because attempting to remove the file throws. So we cant do two throws in the same block D:
                    try fm.removeItem(at: url)
                }
            }
        }catch  {
            print(error)
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
        let pURL = getDirectoryFileURL(fileName: "\(previousFileName).json")
        guard let previousURL = pURL else { return }
        
        
        
        
        let targetFileURL = getDirectoryFileURL(fileName: url.lastPathComponent)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: targetFileURL!)
                let _    = try manager.import(from: data)
                
                
                if manager.save() {
                    ///we have to check if the previous network is associated with the network we just switched to. If its not then we have to add it as an assoicated network to the new file. If we ddint do this then the user would have to import / export if they wanted to switch back.
                    
                    /// todo check save function.  -- also have to change the way we save. We need to be aware that saving data could over write json file. so when ever we save we need to explicitly check the file.
                    /// todo - have to save current config before importing new // figure out how to refresh network
                    
                    /// add delegate back to main
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
//                        self.presentAlert(title: "Success", message: "Mesh Network configuration imported.")
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
//        parent?.parent?.children.forEach {
//            if let rootViewController = $0 as? UINavigationController {
//                rootViewController.popToRootViewController(animated: false)
//            }
//        }
    }
    
    func addSupNetwork(networkName: String, fileName: String, url: URL, nodesCount: Int, description: String, networkID: String){
        let networkToAdd = BubblySupplimentalNetwork(netName: networkName
            , fileName: fileName
            , url: url
            , nodes: nodesCount
            , description: description
            , networkID: networkID)
    }

}
