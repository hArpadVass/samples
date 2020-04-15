//
//  SchedulerControllerTableViewCell.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 11/26/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

protocol ScheduleAdvancedDelegate {
    func btnPressed(advancedTimeChosenDelegate : AdvancedSettingsChosenDelegate)
    func addSceneBtnPressed(sceneDelegate: AddSceneFromSchedulerDelegate)
}

class SchedulerControllerTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var animatingBottomConstraint  : NSLayoutConstraint!
    @IBOutlet weak var sceneTableViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameTextField:  UITextField!
    @IBOutlet weak var timePicker   : UIDatePicker!
    
    @IBOutlet weak var actionSegment  : UISegmentedControl!
    @IBOutlet var dayButtons: [BubsSchedulerWeekDayButton]!
    
    ///action controlls / elements
    @IBOutlet weak var actionHolderView    : UIView!
    @IBOutlet weak var onOffActionSegment  : UISegmentedControl!
    @IBOutlet weak var sceneRecallTableView: UITableView!
    
    let dateFormatter = DateFormatter()
    let manager    = MeshNetworkManager.instance
    let network    = MeshNetworkManager.instance.meshNetwork
    var dataSource = MeshNetworkManager.instance.meshNetwork?.scenes
    var selectedScene: BubblyScene?
    var groupAddress: MeshAddress?

    var delegate            : NewScheduleDelegate?
    var advancedBtnDelegate : ScheduleAdvancedDelegate?
    
    var scheduleToEdit : Schedule?
    var sTA            : Schedule?
    
    @IBOutlet weak var addSceneBtn: NSLayoutConstraint!
    ///time view constraints
    @IBOutlet weak var timeViewLeftConstraint : NSLayoutConstraint!
    @IBOutlet weak var advancedTimeConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var advancedTimeContainer: UIView!
    @IBOutlet weak var testLabel:             UILabel!
    @IBOutlet weak var timeContainer:         UIView!
    @IBOutlet weak var advanceTimeButton:     UIButton!
    @IBOutlet weak var advancedMinuteLabel:   UILabel!
    @IBOutlet weak var advancedSecondLabel:   UILabel!
    @IBOutlet weak var advancedTransitionTimeLabel: UILabel!
    
    var isAdvancedTimeShowing = false
    var advancedTimeChosenDelegate : AdvancedSettingsChosenDelegate?
    
    var advancedTransitionSecond : Int = 0
    var advancedTransitionMinute : Int = 0
    var advancedTranstionHour    : Int = 0
    var advancedSecond : UInt8 = 0x3C
    var advancedMinute : UInt8 = 0x3C
    var advancedHour   : UInt8 = 0x18
    
    var isAdvancedSelected : Bool = false
    
    private var steps: UInt8 = 0
    private var delay: UInt8 = 0
    private var stepResolution: StepResolution = .hundredsOfMilliseconds
    
    var sceneDelegate : AddSceneFromSchedulerDelegate?
    
    @IBOutlet weak var advancedHourLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        advancedTimeChosenDelegate      = self
        nameTextField.delegate          = self
        sceneRecallTableView.delegate   = self
        sceneRecallTableView.dataSource = self
        sceneDelegate                   = self
        
        sceneRecallTableView.allowsSelection = true
        MeshNetworkManager.instance.delegate = self
        sceneRecallTableView.isHidden        = true
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        advancedTimeContainer.addGestureRecognizer(tap)
        
        dateFormatter.dateFormat = "HHmm"
        sceneRecallTableView.register(UINib(nibName: "SchedulerSceneRecallTableViewCell", bundle: nil), forCellReuseIdentifier: "cell1")
        if #available(iOS 11.0, *) {
            actionHolderView.layer.cornerRadius  = 10
            actionHolderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            sceneRecallTableView.layer.cornerRadius  = 10
            sceneRecallTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        initTableView()
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if isAdvancedTimeShowing{
            //pass ref of delegate to VC which gets assigned in segue to the advanced controls vc
            advancedBtnDelegate?.btnPressed(advancedTimeChosenDelegate: advancedTimeChosenDelegate!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func advancedBtnPressed(_ sender: Any) {
        isAdvancedSelected = !isAdvancedSelected
        adjustConstraints()
    }
    
    
    func initTableView(){
        sceneRecallTableView.setEmptyView(title: "No Scenes", message: "You currently have no scenes set up.", messageImage: UIImage())
        dataSource?.count == 0 ? sceneRecallTableView.showEmptyView() : sceneRecallTableView.hideEmptyView()
        sceneRecallTableView.separatorStyle = dataSource?.count == 0 ? .none : .singleLine
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func selectAction(_ sender: UISegmentedControl) {
        animateActionView(segment: sender.selectedSegmentIndex)
    }
    
    @IBAction func addSceneBtnPressed(_ sender: Any) {
        advancedBtnDelegate?.addSceneBtnPressed(sceneDelegate: self)
    }
    
    
    func animateActionView(segment : Int){
        UIView.animate(withDuration: 0.3, delay: 0.05, options: .curveEaseOut, animations: {
            self.animatingBottomConstraint.constant = -500
            self.layoutIfNeeded()
        }) { (Bool) in
            //show / hide control elements bassed of sender value
            self.onOffActionSegment.isHidden   = segment == 0 ? false : true
            self.sceneRecallTableView.isHidden = !self.onOffActionSegment.isHidden
            self.sceneTableViewTopConstraint.constant = self.sceneRecallTableView.isHidden ? 8 : -30
            
            UIView.animate(withDuration: 0.3) {
                self.addSceneBtn.constant = self.sceneRecallTableView.isHidden ? -660 : 16
                self.layoutIfNeeded()
            }

            //animate view back up
            UIView.animate(withDuration: 0.2, delay: 0.05, options: .curveEaseOut, animations: {
                self.animatingBottomConstraint.constant = 0
                self.layoutIfNeeded()
            }) { (Bool) in }
        }
    }
    func sendMessage(){
        /// filter buttons to see how many are turned off
        let buttonCheck = self.dayButtons.filter({ $0.isOn == false })
        /// if count is 7 then no days were selected
        if buttonCheck.count == 7{ delegate?.alert(title: "Error"
            , message: "No days were selected."
            , shouldDismiss: false) ;return }

        switch actionSegment.selectedSegmentIndex {
        case 0:
            let action : UInt8 = onOffActionSegment.selectedSegmentIndex == 0 ? 0x1 : 0x0
            constructMessage(action: action, sceneId: nil)
        case 1:
            if selectedScene == nil{
                delegate?.alert(title: "Error"
                    , message: "A scene wasnt selected to recall."
                    , shouldDismiss: false)
                return
            }
            constructMessage(action: UInt8(0x2), sceneId: selectedScene?.number)
        default:
            print("something went wrong with the schedule message")
        }
    }
    
    func constructMessage(action: UInt8, sceneId: UInt16?){
        
        if nameTextField.text == ""{
            delegate?.alert(title: "Error", message: "No name was selected.", shouldDismiss: false)
            return
        }
        
        let year      = 0x64
        let month     = 4095
        let day       = 0x00
        var dayBinary = ""
        dayButtons.forEach { (b) in dayBinary.append(b.isOn ? "1" : "0")}
        let dayOfTheWeek   = UInt8(dayBinary, radix: 2)!
        let sID = sceneId  != nil ? sceneId : 0x0000
        
        var index = MeshNetworkManager.instance.getNextScheduleIndex()
        if let sE = scheduleToEdit{
            index = sE.index
        }
        let name = self.nameTextField.text ?? "Name unvailable"
        
        let hour    = isAdvancedTimeShowing ? advancedHour   : UInt8(dateFormatter.string(from: timePicker.date).prefix(2))
        let minute  = isAdvancedTimeShowing ? advancedMinute : UInt8(dateFormatter.string(from: timePicker.date).suffix(2))
        let second  = isAdvancedTimeShowing  ? advancedSecond : 0x00
        
        let transTime = TransitionTime(steps: steps, stepResolution: stepResolution)
        print(transTime.steps)
        print(transTime.stepResolution)
        

        if let sG = MeshNetworkManager.instance.selectedConfigGroup{
            let scheduleToAdd = Schedule(index: index
                , name  : name
                , year  : UInt8(year)
                , month : UInt16(month)
                , day   : UInt8(day)
                , hour  : hour ?? 0
                , minute: minute ?? 0
                , second: UInt8(second)
                , dayOfWeek: dayOfTheWeek
                , action: action
                , transitionSteps: steps
                , transitionResolution: stepResolution.rawValue
                , sceneID: sceneId
                , isActive: true
                , addresses: sG.address)
            
            
            print(transTime)
            ///new message
            let _ = try? manager.send(SchedulerActionSetUnacked(index: index
                , year  : UInt8(year)
                , month : UInt16(month)
                , day   : UInt8(day)
                , hour  : hour!
                , minute: minute!
                , second: second
                , dayOfWeek: dayOfTheWeek
                , action: action
                , transitionTime: transTime
                , sceneID: sID!)
                , to: sG
                , using: (network?.applicationKeys[0])!)
            
            createBubblySchedule(schedule: scheduleToAdd)
            //sTA = scheduleToAdd
        }else{
            //something went wrong
        }
    }
    
    func createBubblySchedule(schedule: Schedule){
        let network = MeshNetworkManager.instance.meshNetwork
        if let sE = scheduleToEdit{
            //"editing"
            network?.insert(scheduleToRemove: sE, scheduleToInsert: schedule)
            if MeshNetworkManager.instance.save(){
                delegate?.alert(title: "Saved"
                    , message: "Edit saved."
                    , shouldDismiss: true)
            }else{
                delegate?.alert(title: "Error"
                    , message: "Schedule was not saved! Please try again."
                    , shouldDismiss: false)
            }
        }else{
            network?.add(schedule: schedule)
            if MeshNetworkManager.instance.save(){
                delegate?.alert(title: "Saved"
                    , message: "Schedule saved."
                    , shouldDismiss: true)
            }else{
                delegate?.alert(title: "Error"
                    , message: "Schedule was not saved! Please try again."
                    , shouldDismiss: false)
            }
        }
    }
}
extension SchedulerControllerTableViewCell : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1") as! SchedulerSceneRecallTableViewCell
        cell.sceneNameLabel.text = dataSource?[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedScene = dataSource?[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func adjustConstraints() {
        self.isAdvancedTimeShowing = !self.isAdvancedTimeShowing
        if timeViewLeftConstraint.constant == -700{
            UIView.animate(withDuration: 0.5) {
                self.advanceTimeButton.transform      = CGAffineTransform.identity
                self.timeViewLeftConstraint.constant  = 32
                self.advancedTimeConstraints.constant = -666
                self.layoutIfNeeded()
            }
        }else{
            ///aniimates arrow
            UIView.animate(withDuration: 0.5, animations: {
                self.advanceTimeButton.transform      = CGAffineTransform(rotationAngle: .pi)
                self.advancedTimeConstraints.constant = 16
                self.timeViewLeftConstraint.constant  = -700
                self.layoutIfNeeded()
            }) { (Bool) in
               ///animates container for visual affordance to let user know its clickable
                UIView.animate(withDuration: 0.3, animations: {
                    self.advancedTimeContainer.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }) { (finished) in
                    UIView.animate(withDuration: 0.3, animations: {
                        self.advancedTimeContainer.transform = CGAffineTransform.identity
                    })
                }
            }
        }
    }
}
extension SchedulerControllerTableViewCell : MeshNetworkDelegate{
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: Address) {
        switch message {
        case let status as SchedulerActionStatus:
            print(status.parameters!)
        case let status as SchedulerStatus:
            print(status.parameters!)
        default:
            print("Default")
        }
    }
}

extension SchedulerControllerTableViewCell : AdvancedSettingsChosenDelegate{
    func AdvancedTimeControls(steps: UInt8, stepsResolution: StepResolution, secondValue: Int, minuteValue: Int, hourValue: Int, strTranstime: String) {
        ///gets settings from the advanced controls ~ set to values in controller
        advancedSecondLabel.text = labelText(value: secondValue)
        advancedMinuteLabel.text = labelText(value: minuteValue)
        advancedHourLabel.text   = labelText(value: hourValue)
        self.advancedSecond      = UInt8(secondValue)
        self.advancedMinute      = UInt8(minuteValue)
        self.advancedHour        = UInt8(hourValue)
        self.steps               = steps
        self.stepResolution      = stepsResolution
        
        self.advancedTransitionTimeLabel.text = "Transition Time: \(strTranstime)"
    }
    
    func labelText(value : Int) -> String{
        var strValue = ""
        switch value{
        case 0x18, 0x3C: strValue = "Any"
        case 0x19, 0x3f: strValue = "Random"
        case 0x3D: strValue = "Every 15"
        case 0x3E: strValue = "Every 20"
        default:
            strValue = "\(value)"
        }
        return strValue
    }
}

extension UITableViewCell {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                         action: #selector(hideKeyboard))
        self.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        self.endEditing(true)
    }
}

extension SchedulerControllerTableViewCell : AddSceneFromSchedulerDelegate{
    func sceneAdded() {
        /// reload table view
        dataSource = MeshNetworkManager.instance.meshNetwork?.scenes
        if dataSource?.count != 0{
            sceneRecallTableView.hideEmptyView()
        }
        sceneRecallTableView.reloadData()
    }
    
    func dismissView() {}
}

protocol NewScheduleDelegate {
    func alert(title: String, message: String, shouldDismiss: Bool)
}
