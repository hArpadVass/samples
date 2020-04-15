//
//  AddSceneController.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 2/19/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

class AddSceneController: UIViewController {
    
    private var name        : String?
    private var ID          : UInt16?
    var selectedGroupAddress: MeshAddress!
    var sceneDelegate       : AddSceneFromSchedulerDelegate?
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ID = MeshNetworkManager.instance.getNextSceneID()
        saveBtn.isEnabled = false
        selectedGroupAddress = MeshNetworkManager.instance.selectedConfigGroup?.address
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func savedPressed(_ sender: Any) {
        sendSceneStore()
        guard sceneDelegate != nil else { return }
        sceneDelegate?.sceneAdded()
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension AddSceneController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CreateSceneTableViewCell
            else {return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)}
        
        cell.selectionStyle = .none
        
        switch indexPath.row {
        case 0:
            cell.sceneName.text = "Scene Name"
            cell.detailLbl.text = "Lobby"
        case 1:
            cell.sceneName.text = "Scene ID"
            cell.detailLbl.textColor = .black
            cell.detailLbl.text = MeshNetworkManager.instance.getNextSceneID().description
        default:
            print("Invalid Row")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Scene Details"
        default:
            return nil
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            presentTextAlert(title: "Scene Name", message: "E.g. Lobby", text: nil, placeHolder: "Lobby", type: .nameRequired, option: nil, cancelHandler: nil) { (name) in
                let cell = tableView.cellForRow(at: indexPath) as? CreateSceneTableViewCell
                self.name                 = name
                cell?.detailLbl.text      = name
                cell?.detailLbl.textColor = UIColor.black
        
                if let _ = self.ID {
                    self.saveBtn.isEnabled = true
                }
            }
        case 1:
            presentTextAlert(title: "Scene ID", message: "E.g. 1", text: nil, placeHolder: MeshNetworkManager.instance.getNextSceneID().description, type: .sceneRequired, option: nil, cancelHandler: nil) { (sceneID) in
                  let cell = tableView.cellForRow(at: indexPath) as? CreateSceneTableViewCell
                // TODO:
                self.ID = UInt16(sceneID) ?? MeshNetworkManager.instance.getNextSceneID()
                cell?.detailLbl.text      = sceneID
                cell?.detailLbl.textColor = UIColor.black
                
                if let _ = self.name {
                      self.saveBtn.isEnabled = true
                }
              }
        default:
            print("Invalid Row")
        }
    }
    
    func sendSceneStore(){
        guard let id = ID, let groupAddress = selectedGroupAddress,let key = MeshNetworkManager.instance.meshNetwork?.applicationKeys[0] else {return}
        let _ = try? MeshNetworkManager.instance.send(SceneStoreUnacknowledged(sceneID: id), to: groupAddress, using: key)
        createBubblyScene()
    }
    
    
    // Function to save new scene
    func createBubblyScene() {
        if let name = name, let id = ID {
             let scene = BubblyScene(name: name, number: id, addresses: selectedGroupAddress)
                let network = MeshNetworkManager.instance.meshNetwork
                network?.add(scene: scene)
            if MeshNetworkManager.instance.save() {
                print("saved")
            } else {
                presentAlert(title: "Error", message: "Mesh configuration could not be saved.")
            }
            //dismiss(animated: true, completion: nil)
        }
    }
}
