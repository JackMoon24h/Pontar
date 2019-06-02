//
//  MyPageViewController.swift
//  Pontar
//
//  Created by Jack Moon on 2019/06/02.
//  Copyright © 2019 Jack Moon. All rights reserved.
//

import UIKit

protocol MyPageDelegate {
    func performCustomSetting(cityName : String)
}

class MyPageViewController: UIViewController
{
    var delegate : MyPageDelegate?
    
    @IBOutlet weak var inputField: UITextField!
    
    @IBAction func AddLocation(_ sender: UIButton)
    {
        delegate?.performCustomSetting(cityName: inputField.text!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func BackBtnOnClick(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
