//
//  ProductResult.swift
//  re<ycle
//
//  Created by Robin Leman on 01/02/2020.
//  Copyright © 2020 Lorne & Leman Corp. All rights reserved.
//

import UIKit

class ProductResult: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    struct Product: Decodable {
        let status_verbose: String
        let product: SubProduct
        let code: String
        let status: Int
        
    }
        
    struct SubProduct: Decodable {
        let packaging: String
        
    }
    
        
    let urlProduct = URL(string: "https://world.openfoodfacts.org/api/v0/product/737628064502.json")

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
                var product = try JSONDecoder().decode( Product.self, from:data)
                print(product.product)
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
