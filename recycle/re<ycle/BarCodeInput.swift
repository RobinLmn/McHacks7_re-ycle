//
//  BarcodeInput.swift
//  re<ycle
//
//  Created by Robin Leman on 01/02/2020.
//  Copyright © 2020 Lorne & Leman Corp. All rights reserved.
//

import UIKit

class BarcodeInput: UIViewController {
    
    struct BarcodeVariables{
        static var barcodeFieldText = ""
    }

    @IBOutlet weak var barcodeField: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBAction func onEnterTapped(_ sender: Any) {
        print("test")
        BarcodeVariables.barcodeFieldText = barcodeField.text!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        barcodeField.resignFirstResponder()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        barcodeField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIViewController: UITextFieldDelegate {
    
}
