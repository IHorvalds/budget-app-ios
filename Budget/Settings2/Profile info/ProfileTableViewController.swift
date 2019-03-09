//
//  ProfileTableViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 22/02/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import AVKit
import Photos

class ProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    var settings: Settings?
    
    @IBAction func changeProfilePicture(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(.init(title: "Take a picture", style: .default, handler: { (_) in
            
            if UIImagePickerController.isCameraDeviceAvailable(.front) {
                switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
                case .authorized: // The user has previously granted access to the camera.
                    self.imagePicker.sourceType = .camera
                    self.present(self.imagePicker, animated: true, completion: nil)
                    
                case .notDetermined: // The user has not yet been asked for camera access.
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        if granted {
                            self.imagePicker.sourceType = .camera
                            self.present(self.imagePicker, animated: true, completion: nil)
                        } else {
                            let errorAlert = UIAlertController(title: "Camera access denied", message: "Please allow camera access in order to take a picture.", preferredStyle: .alert)
                            errorAlert.addAction(.init(title: "OK", style: .default, handler: nil))
                            self.present(errorAlert, animated: true, completion: nil)
                        }
                    }
                    
                case .restricted: // The user can't grant access due to restrictions.
                    return
                    
                case .denied: // The user has previously denied access.
                    let errorAlert = UIAlertController(title: "Camera access denied", message: "Please allow camera access in order to take a picture.", preferredStyle: .alert)
                    errorAlert.addAction(.init(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                
                @unknown default:
                    return
                }
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "An error occured while opening the camera. Please try again.", preferredStyle: .alert)
                errorAlert.addAction(.init(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        
        alert.addAction(.init(title: "Import from library", style: .default, handler: { (_) in
            
            let photos = PHPhotoLibrary.authorizationStatus()
            
            switch photos {
            case .authorized:
                
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
                
            case .notDetermined:
                
                PHPhotoLibrary.requestAuthorization({ status in
                    if status == .authorized {
                        self.imagePicker.sourceType = .photoLibrary
                        self.present(self.imagePicker, animated: true, completion: nil)
                    } else {
                        let errorAlert = UIAlertController(title: "Error", message: "Please allow access to your photo library to select a profile picture.", preferredStyle: .alert)
                        errorAlert.addAction(.init(title: "OK", style: .default, handler: nil))
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                })
                
            case .restricted:
                return
            case .denied:
                
                let errorAlert = UIAlertController(title: "Library access denied", message: "Please allow access to your photo library to select a profile picture.", preferredStyle: .alert)
                errorAlert.addAction(.init(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
                
            @unknown default:
                return
            }
            
        }))
        
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.permittedArrowDirections = [.down]
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        navigationItem.backBarButtonItem?.title = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        settings?.saveSettingsToDefaults()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            if indexPath.row == 0 {
                performSegue(withIdentifier: "editprofilesegue", sender: tableView.cellForRow(at: indexPath))
            } else {
                performSegue(withIdentifier: "editprofilesegue", sender: tableView.cellForRow(at: indexPath))
            }
        default:
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0, indexPath.row == 0 {
            return 280.0
        }
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "profileoptioncell") as! ProfileTableViewCell
                (cell as! ProfileTableViewCell).userPicture.image = Settings.decodeImageFromBase64(strBase64: settings?.userImage ?? "")
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                cell.layer.masksToBounds = true
                (cell as! ProfileTableViewCell).userPicture.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                
                (cell as! ProfileTableViewCell).userName.text = settings?.userName
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "cameraoptionscell") as! RoundedTableViewCell
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        default:
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "nameoptioncell") as! RoundedTableViewCell
                cell.layer.maskedCorners    = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                cell.detailTextLabel?.text  = settings?.userName
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "preferredcurrencycell") as! RoundedTableViewCell
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.detailTextLabel?.text = settings?.preferredCurrency
            }
        }
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "editprofilesegue",
            let destVC = segue.destination as? FieldEditingTableViewController {
            destVC.navigationItem.title = (sender as? UITableViewCell)?.textLabel?.text
            destVC.settings = settings
            if tableView.indexPathForSelectedRow?.row == 0 {
                destVC.attributeToEdit = [.UserName]
            } else {
                destVC.attributeToEdit = [.PreferredCurrency]
            }
        }
    }
}

extension ProfileTableViewController {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            settings?.userImage = Settings.encodeImageToBase64(image: editedImage)
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
        if  picker.sourceType == .camera,
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
