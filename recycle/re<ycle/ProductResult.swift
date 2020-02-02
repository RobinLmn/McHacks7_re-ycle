//
//  ProductResult.swift
//  re<ycle
//
//  Created by Robin Leman on 01/02/2020.
//  Copyright © 2020 Lorne & Leman Corp. All rights reserved.
//

import UIKit

class ProductResult: UIViewController {
    
    @IBOutlet weak var nameLable: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var explanationMessage: UILabel!
    
    @IBOutlet weak var garbageLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLable.text = GlobalVariables.productName  // Sets label to name of product found
        
    struct Product: Decodable {
        let status_verbose: String
        let product: SubProduct  // product is a dictionnary within the dictionnary
        let code: String
        let status: Int
        
    }
        
    struct SubProduct: Decodable {
        let packaging: String
        let product_name_en: String
        let image_front_url: String
    
    }
        
    struct GlobalVariables {
        static var packagingArray:[String] = [String]()
        static var productName = ""
        static var productImageURL = ""
        
    }
        
    let urlAPI = "https://world.openfoodfacts.org/api/v0/product/"
    let urlAPIextension = ".json"
    let urlProduct = URL(string: urlAPI + BarcodeInput.BarcodeVariables.barcodeFieldText + urlAPIextension)
    
    // Sets the image of found product to imageView
    func setImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }

            // just not to cause a deadlock in UI!
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }

            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
        
    func setLogo(from url: String) {
        guard let imageURL = URL(string: url) else { return }

            // just not to cause a deadlock in UI!
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }

            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
        
    var garbageType = [
        "plastic": "Recycle",
        "canette": "Recycle",
        "Canette": "Recycle",
        "cardboard": "Recycle",
        "plastic bag": "Trash"
        
        ]
    
        // Returns number of materials labeled as being recyclable, trash or compastable as tuple of 3 ints
        func garbageTypeCount(productName: String, garbageTypeDict: [String: String], packagingArray: [String]) -> (String, String) {
            var recyclableMaterials = [String]()
            var trashMaterials = [String]()
            var compostableMaterials = [String]()
            var bestGarbageType = ""
            var explanationResult = ""
            var temp_text = ""

            for packaging in packagingArray {
                print(packaging)
                // guard var data = garbageTypeDict[packaging] else {
                if garbageTypeDict.keys.contains(packaging){
                    if garbageTypeDict[packaging] == "Recycle" {
                        recyclableMaterials += [packaging]
                    } else if garbageTypeDict[packaging] == "Trash" {
                        trashMaterials += [packaging]
                    } else if garbageTypeDict[packaging] == "Compost" {
                        compostableMaterials += [packaging]
                    } else {
                        // If other value than Recycle,Trash,Compost in garbageTypeDict (shouldn't be the case)
                    }
                }
                else {
                       // If no matching key found in garbageTypeDict
                }
        }
            
            if trashMaterials.count >= 1 {
                bestGarbageType = "Trash"
                for trash in trashMaterials {
                    temp_text = temp_text + trash + ", "
                }
                explanationResult = productName + " contains some " + temp_text + "and therefore has to go the Trash can."
            }
                
            
            else {
                bestGarbageType = "Recycle"
                for recycle in recyclableMaterials {
                        temp_text = temp_text + recycle + ", "
                    }
                    explanationResult = productName + " contains some " + temp_text + "and therefore has to be recycled."
            }
        print(bestGarbageType, explanationResult)
        return(bestGarbageType, explanationResult)
    }
        
        
        func findGarbageType(recycleCount: Int, trashCount: Int, compostCount: Int){
            
        }
        
    
        
    let task = URLSession.shared.dataTask(with: urlProduct!) {(data, response, error) in
            
        if let error = error {
            print("error: \(error)")
        }
        else {
            if let response = response as? HTTPURLResponse {
                print("statusCode: \(response.statusCode)")
            }
            guard let data = data else { return }
            do {
                var productToAnalyze = try JSONDecoder().decode( Product.self, from:data)
                var packagings = productToAnalyze.product.packaging
                GlobalVariables.productName = productToAnalyze.product.product_name_en
                DispatchQueue.main.async{
                    self.nameLable.text = GlobalVariables.productName
                }
                GlobalVariables.packagingArray = packagings.components(separatedBy: ",")  // Creates an array with packaging elements
                GlobalVariables.productImageURL = productToAnalyze.product.image_front_url
                setImage(from: GlobalVariables.productImageURL)
                print(GlobalVariables.packagingArray)
                print(GlobalVariables.productName)
                print(GlobalVariables.productImageURL)
                print(BarcodeInput.BarcodeVariables.barcodeFieldText)
                let (bestGarbageType, explanationResult) = garbageTypeCount(productName: GlobalVariables.productName, garbageTypeDict: garbageType, packagingArray: GlobalVariables.packagingArray)
                print(bestGarbageType, explanationResult)
                DispatchQueue.main.async{
                    self.explanationMessage.text = explanationResult
                }
                
                if bestGarbageType == "Recycle" {
                    self.garbageLogo.image = UIImage(named: "recycle_logo")
                } else if bestGarbageType == "Trash" {
                    self.garbageLogo.image = UIImage(named: "trash_logo")
                }
                
                //determineTrashAction(int: recycleCount,int: trashCount,int: compostCount)
                //print(barcodeField)
            }
            catch{
                print("Product error")
            }
        }
    }
    task.resume()
        
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
