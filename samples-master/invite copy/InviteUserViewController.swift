//
//  InviteUserViewController.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 1/7/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision
import Foundation
import Firebase
import FirebaseStorage
import FirebaseDynamicLinks

class InviteUserViewController: UIViewController {
    
    var alert : UIAlertController = UIAlertController()
    var networks : [Group] = []
    var selectedNetworks : [Group] = []
    
    @IBOutlet weak var userLevelSegmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        networks = MeshNetworkManager.instance.getGroups()
        tableView.allowsMultipleSelection = true
        
        
    }
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendBtnTapped(_ sender: Any) {
        if userLevelSegmentControl.selectedSegmentIndex == 2 {
            ///check if user level  has ben set to something that can be potentially damaging
            ///make them confirm decision
            alert.message = "You are giving this user more control than normal. Are you sure?"
            let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
                self.createLink()
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(confirm)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        }else{
            createLink()
        }
    }
    
    func createLink(){
        ///create URL componets
        var componets = URLComponents()
        componets.scheme = "https"
        componets.host = "bubblynet.com"
        componets.path = "/networks"
        
        ///add query items to be added to URL
        componets.queryItems = createQueryItems()
        guard let linkParameter = componets.url else { return }
        ///create dynamic link
        guard let shareLink  = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: "https://bubblynet.page.link") else {
            return
        }
        //
        if let bundleId = Bundle.main.bundleIdentifier{
            shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleId)
        }
        shareLink.iOSParameters?.appStoreID = "1468558018"
        ///impliment Android package name
        //shareLink.androidParameters = DynamicLinkAndroidParameters(packageName: "packageName")
        shareLink.shorten { (url, warning, error) in
            ///check error
            if let error = error{
                print(error.localizedDescription)
                return
            }
            ///print warnings
            if let warnings = warning{
                warnings.forEach { (warning) in
                    print(warning)
                }
            }
            ///show link
            guard url != nil else { return }
            self.showShareSheet(shareLink.url ?? URL(fileURLWithPath: "www.bubblynet.com"))
        }
    }
    
    func createQueryItems() -> [URLQueryItem]{
        var queryItems = [URLQueryItem]()
        selectedNetworks.forEach { (network) in
            queryItems.append(URLQueryItem(name: network.name, value: network.address.address.description))
        }
        return queryItems
    }
    
    func showShareSheet(_ url: URL){
        let text = "Check out this network..."
        let activityVc = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        present(activityVc, animated: true)
        
    }
    
}
extension InviteUserViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SubnetTableViewCell
        cell.networkName.text = networks[indexPath.row].name
        cell.idLabel.text = "\(networks[indexPath.row].address)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNetworks.append(networks[indexPath.row])
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedNetwork = networks[indexPath.row]
        selectedNetworks = selectedNetworks.filter({ $0 != deselectedNetwork})
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        
    }
}
