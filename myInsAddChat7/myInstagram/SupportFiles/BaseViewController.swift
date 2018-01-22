//
//  BaseViewController.swift
//  SwiftDemoJsonParsing
//
//  Created by Lucky  on 5/5/17.
//  Copyright © 2017 Lucky . All rights reserved.
//

/*
 Set up navigation controller.
 */

import UIKit
class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.title = ""
//         self.navigationItem.leftBarButtonItem = nil;
//        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
//         self.navigationItem.backBarButtonItem = backButton;
        setupNavigationWithColor(UIColor.clear)
    
        // Do any additional setup after loading the view.
    }
   
    func setupNavigationWithColor(_ color: UIColor) {
        let font = UIFont.boldSystemFont(ofSize: 20);
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : color, NSAttributedStringKey.font : font as Any]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = color
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension BaseViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func getPicture(){
            //check if camera is available
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else{
                print("camera not avaliable")
                presentPhotoPicker(sourceType: .photoLibrary)
                return
            }
            //choose the source type
            let photoSourcePicker = UIAlertController()
            let takePhoto = UIAlertAction(title: "Take Photo", style: .default){ [unowned self] _ in
                self.presentPhotoPicker(sourceType: .camera)
            }
            
            let openLibrary = UIAlertAction(title: "Open photo Library", style: .default){[unowned self] _ in
                self.presentPhotoPicker(sourceType: .photoLibrary)
            }
            
            photoSourcePicker.addAction(takePhoto)
            photoSourcePicker.addAction(openLibrary)
            photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(photoSourcePicker, animated: true, completion: nil)
        }
        
        //This funciton show the picker view controller
        func presentPhotoPicker(sourceType : UIImagePickerControllerSourceType){
            //initializer
            let picker = UIImagePickerController()
            picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            picker.sourceType = sourceType
            present(picker, animated: true, completion: nil)
        }
    
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func gotoHomePage(){
        //go to main screen
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController{
            //  controller.title = "HomePage of User"
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}
