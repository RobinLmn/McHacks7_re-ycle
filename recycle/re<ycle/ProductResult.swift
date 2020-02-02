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
        "plastic bag": "Trash",
        "metal": "Recycle",
        "Metal": "Recycle",
        "Aluminium": "Recycle",
        "aluminium": "Recycle",
        "Glass": "Recyle",
        "verre": "Recycle",
        "glass": "Recycle",
        "Verre": "Recycle",
        "Plastique": "Recycle",
        "Organic": "Compost"
        
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
                    bestGarbageType = "Unknown"
                    explanationResult = "Unfortunently we don't have information about this product's packaging yet. Feel free to add it yourself at https://world.openfoodfacts.org"
                       
                }
        }
            
            if trashMaterials.count >= 1 {
                bestGarbageType = "Trash"
                for trash in trashMaterials {
                    temp_text = temp_text + trash + " "
                }
                explanationResult = "It contains some " + temp_text + ": Throw it to the Trash can :("
            }
                
            
            else if recyclableMaterials.count >= 1 {
                bestGarbageType = "Recycle"
                for recycle in recyclableMaterials {
                        temp_text = temp_text + recycle + " "
                    }
                    explanationResult = "It contains some " + temp_text + ": Recycle it!"
            }
            
            else if compostableMaterials.count >= 1 {
                bestGarbageType = "Compost"
                for compost in compostableMaterials {
                        temp_text = temp_text + compost + " "
                    }
                    explanationResult = "It contains some " + temp_text + ": Compost it!"
            }
            
            else {
                bestGarbageType = "Unknown"
                explanationResult = "Unfortunently we don't have information about this product's packaging yet. Feel free to add it yourself at https://world.openfoodfacts.org"
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
                
                print("--------")
                print(productToAnalyze.status)
                print("--------")
                print("--------")
                
                if (productToAnalyze.status == 1) {
                    
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
                        
                    DispatchQueue.main.async{
                        self.garbageLogo.image = UIImage(named: "recycle_logo")
                        }
                    }
                    else if bestGarbageType == "Trash" {
                        DispatchQueue.main.async{
                        self.garbageLogo.image = UIImage(named: "trash_logo")
                        }
                    }
                    else if bestGarbageType == "Compost" {
                        DispatchQueue.main.async{
                        self.garbageLogo.image = UIImage(named: "compost_logo")
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                        self.garbageLogo.image = UIImage(named: "unknown_logo")
                        }
                    }
                }
                
                else if (productToAnalyze.status == 0) {
                    DispatchQueue.main.async{
                        self.nameLable.text = "Unknown product"
                    }
                    
                    DispatchQueue.main.async{
                    self.garbageLogo.image = UIImage(named: "mistery_box")
                    }
                    
                    DispatchQueue.main.async{
                        self.explanationMessage.text = "Unfortunently we don't have information about this product. Feel free to add it yourself at https://world.openfoodfacts.org"
                    }
                    
                    DispatchQueue.main.async{
                    self.garbageLogo.image = UIImage(named: "unknown_logo")
                    }
                }
                
                
                
            }
            catch{
                
                DispatchQueue.main.async{
                    self.nameLable.text = "Invalid Bar Code"
                }
                
                DispatchQueue.main.async{
                self.imageView.image = UIImage(named: "mistery_box")
                }
                
                DispatchQueue.main.async{
                    self.explanationMessage.text = "No Information on this product. Add it yourself at https://world.openfoodfacts.org"
                }
                
                DispatchQueue.main.async{
                self.garbageLogo.image = UIImage(named: "unknown_logo")
                }
                
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
