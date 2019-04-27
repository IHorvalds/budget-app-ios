//
//  ChooseFileViewController.swift
//  Budget
//
//  Created by Tudor Croitoru on 15/03/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class ChooseFileViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var exportDocuments = [BudgetExportDocument]()

    
    @IBAction func openPanel(_ sender: UIBarButtonItem) {
        panel?.openLeft(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let folderPath  = try FileManager.default.url(for: .documentDirectory,
                                                          in: .userDomainMask,
                                                          appropriateFor: nil,
                                                          create: false)
            
            let enumerator  = FileManager.default.enumerator(atPath: folderPath.path)
            if let paths    = enumerator?.allObjects as? [String] {
                let usefulPaths = paths.filter({$0.contains(".bdg")})
                
                for file in usefulPaths {
                    let url = folderPath.appendingPathComponent(file)
                    
                    exportDocuments.append(BudgetExportDocument(fileURL: url))
                }
            }
            
        } catch {
            print(error)
            //show an alert if necessary
        }
        

    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exportDocuments.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filecell", for: indexPath) as? BudgetDocumentCell
    
        cell?.fileNameLabel.text = String(exportDocuments[indexPath.row].fileURL.lastPathComponent.dropLast(4))
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/2 - 30.0
        
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }

}
