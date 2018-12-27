//
//  ViewController.swift
//  Microphone
//
//  Created by Charles Catta on 2018-11-14.
//  Copyright © 2018 Charles Catta. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit

enum RoutingState {
    case stopped
    case started
}

class ViewController: UIViewController {
    @IBOutlet var inputTableView: UITableView!
    @IBOutlet var outputTableView: UITableView!
    
    @IBOutlet var routeBtn: UIButton!
    var selectedInputDevice: AKDevice? {
        didSet(newDevice) {
            updateBtnState()
        }
    }
    var selectedOutputDevice: AKDevice? {
        didSet(newDevice) {
            updateBtnState()
        }
    }
    var state: RoutingState = .stopped {
        didSet(newState) {
            updateBtnState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTableView.delegate = self
        inputTableView.dataSource = self
        
        outputTableView.delegate = self
        outputTableView.dataSource = self
        updateBtnState()
    }
    
    func updateBtnState() {
        switch self.state {
        case .stopped:
            routeBtn.backgroundColor = #colorLiteral(red: 0.2782555953, green: 0.5267801961, blue: 1, alpha: 1)
            routeBtn.setTitle("Route", for: .normal)
        case .started:
            routeBtn.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            routeBtn.setTitle("Stop Routing", for: .normal)
        }
        if (selectedOutputDevice != nil && selectedInputDevice != nil) {
            routeBtn.isEnabled = true
        } else {
            routeBtn.isEnabled = false
        }
    }
    
    @IBAction func didTapRoute(_ sender: UIButton) {
        if (selectedInputDevice != nil) && (selectedOutputDevice != nil) && state == .stopped {
            do {
                try AudioKit.setInputDevice(selectedInputDevice!)
                try AudioKit.setOutputDevice(selectedOutputDevice!)
                let mic = AKMicrophone()
                try mic.setDevice(selectedInputDevice!)
                AudioKit.output = mic
                try AudioKit.start()
                state = .started
            } catch let error {
                let alert = UIAlertController(title: "An error occured when trying to start routing", message: error.localizedDescription, preferredStyle: .alert)
                self.present(alert, animated: true)
                state = .stopped
            }
        } else if state == .started {
            do {
                try AudioKit.stop()
                state = .stopped
            } catch let error {
                let alert = UIAlertController(title: "An error occured while stopping the routing", message: error.localizedDescription, preferredStyle: .alert)
                self.present(alert, animated: true)
            }
        }
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let emptyCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        if tableView == inputTableView {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = AudioKit.inputDevices?[indexPath.item].description
            return cell
        } else if tableView == outputTableView {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = AudioKit.outputDevices?[indexPath.item].description
            return cell
        }
        return emptyCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == inputTableView {
            return AudioKit.inputDevices?.count ?? 0
        } else if tableView == outputTableView {
            return AudioKit.outputDevices?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == inputTableView {
            guard let device = AudioKit.inputDevices?[indexPath.item] else { return }
            self.selectedInputDevice = device
        } else if tableView == outputTableView {
            guard let device = AudioKit.outputDevices?[indexPath.item] else { return }
            self.selectedOutputDevice = device
        }
    }
    
}
