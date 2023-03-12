//
//  ProductDetailsViewController.swift
//  Shopify
//
//  Created by Mahmoud on 21/02/2023.
//

import UIKit
import Cosmos
import CoreData
class ProductDetailsViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource{
    var userdef = UserDefaults.standard

    
    var managedContext : NSManagedObjectContext!
    var resultOfSearch : [NSManagedObject] = []
    
    var currencyConverter : Float = 0.0
    var currency : String?
    var productID : Int?
    var productTitle : String?
    var productPrice : String?
    var isFavourite : Bool? = false
    let order : DraftOrder? = nil
    var optionss : Options?
    var product : Product = Product()
    var arrImgs = [UIImage(named: "product")!, UIImage(named: "tmp")!, UIImage(named: "tmpBrand")]
    var arrReviews : [Reviews] = [Reviews(img: UIImage(named: "review1")!, name: "Anedrew", reviewTxt: "Very Good"), Reviews(img: UIImage(named: "review2")!, name: "Sandra", reviewTxt: "Good"), Reviews(img: UIImage(named: "review3")!, name: "John", reviewTxt: "Nice"), Reviews(img: UIImage(named: "review4")!, name: "Leli", reviewTxt: "Very Good")]
    var timer :  Timer?
    var currentCellIndex  = 0
    var productState : Bool = false
    var dataViewModel : CoreDataViewModel?
    var networkViewModel : ShoppingCartProductsViewModel?
    var cartItemsList : [LineItem] = []
    var arrayOfDec : [[String : Any]] = []
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDiscription: UITextView!
    @IBOutlet weak var favbtn: UIButton!
    @IBOutlet weak var reviewCV: UICollectionView!
    @IBOutlet weak var myscroll: UIScrollView!
    @IBOutlet weak var colorSegmented: UISegmentedControl!
    @IBOutlet weak var sizeSeg: UISegmentedControl!
    @IBOutlet weak var imgsCV: UICollectionView!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var productV: UIView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var cartBtn: UIButton!
    
    @IBOutlet weak var sizeTable: UITableView!
    @IBOutlet weak var tableLbl: UILabel!
    
    
    @IBOutlet weak var colorTable: UITableView!
    
    
    
    @IBAction func addProductToCart(_ sender: Any) {
        
        
            let deleteAlert : UIAlertController  = UIAlertController(title:"Add product to shopping cart", message:"Are you sure you want to add this product to shopping cart?", preferredStyle: .actionSheet)
            deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{ action in
                for item in self.cartItemsList
                {
                    var temp : [String : Any] = ["title": item.title, "price":item.price, "quantity": item.quantity,"product_id": item.product_id, "variant_id": item.variant_id]
                    self.arrayOfDec.append(temp)
                }
                let myLine : [String : Any] = ["title": self.product.title, "price": self.product.variants?[0].price, "quantity": 1, "product_id": self.product.id, "variant_id":self.product.variants?[0].id]
                self.arrayOfDec.append(myLine)
                print(self.arrayOfDec)
                    guard let url = URL(string: "https://48c475a06d64f3aec1289f7559115a55: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@ios-q2-new-capital-admin2-2022-2023.myshopify.com/admin/api/2023-01/draft_orders/1113759416624.json") else{
                        return
                    }
                    var request = URLRequest(url :url)
                    request.httpMethod = "PUT"
                    request.httpShouldHandleCookies = false
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    let body : [String : Any] = [
                        "draft_order": [
                            "line_items": self.arrayOfDec
                        ],
                        "applied_discount": [
                            "description": "Custom discount",
                            "value_type": "fixed_amount",
                            "value": "10.0",
                            "amount": "10.00",
                            "title": "Custom"
                        ],
                        "customer": [
                            "id": 6817112686896
                        ],
                        "use_customer_default_address": true

                    ]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: body,options: .fragmentsAllowed)
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data else{
                            return
                        }
                        do{
                            print("success\(response)")
                        }
                        catch let error{
                            print(error.localizedDescription)
                        }
                    }
                    task.resume()
            }))
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(deleteAlert, animated:true, completion:nil )
        
    }
    @IBAction func favvBtn(_ sender: Any) {
        if  productState == false
        {
            favbtn.setImage(UIImage(systemName:  "heart.fill"), for: .normal)
            productState = true
            dataViewModel?.saveProductToCoreData(productTypt: 2, draftproduct: product)
        }
        else if productState == true
        {
            favbtn.setImage(UIImage(systemName: "heart"), for: .normal)
            productState = false
             dataViewModel?.deleteProductFromCoreData(deletedProductType: 2, productId: product.id ?? 0)
        }
    }
  /*      print("pressed on heart button")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
       // let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Fav")
      //  print("League Name is: \(leagueName!)")
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ShoppingCartProduct")
       // let pred = NSPredicate(format: "product_id == %i", productType as CVarArg )
       // fetchRequest.predicate = pred
        var fetchedProductsList : [NSManagedObject] = []
        do
        {
            resultOfSearch = try managedContext.fetch(fetchRequest)
        }catch let error
        {
            print(error.localizedDescription)
        }
        
        if resultOfSearch.count == 0 // not saved to the core data
        {
            favbtn.imageView?.image = UIImage(named: "heart.fill")
           favbtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            isFavourite = true
            let entity = NSEntityDescription.entity(forEntityName: "WishList", in: managedContext)
            let favProduct = NSManagedObject(entity: entity!, insertInto: managedContext)
            favProduct.setValue(productTitle, forKey: "product_title")
            favProduct.setValue(productID, forKey: "prduct_id")
            favProduct.setValue(productPrice, forKey: "product_price")
            favProduct.setValue(isFavourite, forKey: "league_fav")
            
            do
            {
                try managedContext.save()
            }catch let error
            {
                print(error.localizedDescription)
            }
        }
        else if resultOfSearch.count != 0 // saved to the device
        {
            favbtn.imageView?.image = UIImage(named: "heart")
            favbtn.setImage(UIImage(systemName: "heart"), for: .normal)
            let target = resultOfSearch[0]
            managedContext.delete(target)
            do
            {
                try managedContext.save()
            } catch let error
            {
                print(error.localizedDescription)
            }
        }
        */
        
    // var optionsValue:[String] = []
   // var selctedItem = sizeSeg.selectedSegmentIndex
    
    override func viewWillAppear(_ animated: Bool)
    {
        
        if productState == true
        {
            favbtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataViewModel = CoreDataViewModel()
        productState =  isAddedToWishList(productId: product.id ?? 0)
        networkViewModel = ShoppingCartProductsViewModel()
        networkViewModel?.getCartProducts(url: "https://48c475a06d64f3aec1289f7559115a55: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@ios-q2-new-capital-admin2-2022-2023.myshopify.com/admin/api/2023-01/draft_orders/1113759416624.json")

        networkViewModel?.bindingCartProducts = {
            DispatchQueue.main.async { [self] in
                self.cartItemsList = self.networkViewModel?.ShoppingCartProductsResult ?? []
            }
         //   self.postProductFav()
        }
      //  currencyConverter = userdef.value(forKey: "currency") as! Float
       /* if userdef.value(forKey: "currency") as! Double == 1.0
        {
            currency = "$"
        }
        else
        {
            currency = "£"
        }
        print("FA\(currencyConverter)")
        */
      //  let indexpath = IndexPath(row: optionss?.values?.count - 1  , section: 1)
       
     //   cosmos.inputViewController?.isBeingDismissed = false
        productName.adjustsFontSizeToFitWidth = true
       // priceLbl.text = "  \(product.variants?.first?.price ?? "") EGP"
        priceLbl.text = String((Float(product.variants?.first?.price ?? "") ?? 0.0) * currencyConverter).appending(" ").appending(currency ?? "")
        productName.text = product.title
       // var countt = [product.options?[0].values?.count]
      /*  for i in countt
        {
            sizeSeg.setTitle(product.options?[0].values?[i ?? 1] ?? "", forSegmentAt: i ?? 1)
        }*/
        productDiscription.text = product.body_html
      //  sizeSeg.setTitle(product.options?[0].values?[0] ?? "", forSegmentAt: 0)
       // sizeSeg.setTitle("\(product?.options?[0].values?[1] ?? "")", forSegmentAt: 1)
        //sizeSeg.setTitle("\(product?.options?[0].values?[2] ?? "")", forSegmentAt: 2)
        //sizeSeg.setTitle("\(product?.options?[0].values?[3] ?? "")", forSegmentAt: 3)
      //  colorSegmented.setTitle("\(product.options?[1].values?[0] ?? "")", forSegmentAt: 0)
        
        myscroll.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 210)
        imgsCV.delegate = self
        imgsCV.dataSource = self
       colorTable.delegate = self
         colorTable.dataSource = self
       sizeTable.delegate = self
        sizeTable.dataSource = self
        reviewCV.dataSource = self
        reviewCV.delegate = self
        pageController.numberOfPages = arrImgs.count
        startTimer()
      //  txtView.layer.cornerRadius = txtView.frame.size.height / 2
      // txtView.clipsToBounds = true
        txtView.isEditable = false
        myscroll.layer.cornerRadius = myscroll.frame.size.height / 9
       myscroll.clipsToBounds = true
        
        cartBtn.layer.cornerRadius = cartBtn.frame.size.height / 2
        cartBtn.clipsToBounds = true
        
    sizeTable.layer.cornerRadius = cartBtn.frame.size.height / 2
            sizeTable.clipsToBounds = true
        
        colorTable.layer.cornerRadius = cartBtn.frame.size.height / 2
               colorTable.clipsToBounds = true
        
        priceLbl.layer.cornerRadius = priceLbl.frame.size.height / 2
       priceLbl.clipsToBounds = true
        
      //  addcartLbl.layer.cornerRadius = addcartLbl.frame.size.height / 2
     //  addcartLbl.clipsToBounds = true
    }
        
    @IBAction func sizeee(_ sender: Any) {
        print("index = \(sizeSeg.selectedSegmentIndex)")
        
        print("value = \(sizeSeg.titleForSegment(at: sizeSeg.selectedSegmentIndex))")
        //makeSize_ColorPostRequest()
        
    }
    
    @IBAction func colorChanged(_ sender: Any) {
        print("index = \(colorSegmented.selectedSegmentIndex)")
        
        print("value = \(colorSegmented.titleForSegment(at: colorSegmented.selectedSegmentIndex))")
       // makeSize_ColorPostRequest()
        
    }
    
    
    
    private func makeSize_ColorPostRequest()
    {
        guard let url = URL(string: "https://48c475a06d64f3aec1289f7559115a55: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@ios-q2-new-capital-admin2-2022-2023.myshopify.com/admin/api/2023-01/draft_orders.json") else{
            return
        }
        print("Making api call")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpShouldHandleCookies = false
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Authorization")
       // request.addValue("application/json",forHTTPHeaderField: "Accept")
                
     //   request.setValue("application/json", forHTTPHeaderField: "Authorization -token")
        print("\(sizeSeg.titleForSegment(at: sizeSeg.selectedSegmentIndex)!)")
   
        let body : [String : Any] = [
                    "draft_order": [
                            "line_items": [
                                [
                                    "title": "Custom Tee",
                                    "price": "20.00",
                                    "quantity": 2,
                                    "sku":"\(sizeSeg.titleForSegment(at: sizeSeg.selectedSegmentIndex)!)",
                                    //"variant_id":"\(colorSegmented.titleForSegment(at: colorSegmented.selectedSegmentIndex)!)"
                                    
                                ]
                            ],
                            "applied_discount": [
                                "description": "Custom discount",
                                "value_type": "fixed_amount",
                                "value": "10.0",
                                "amount": "10.00",
                                "title": "Custom"
                            ],
                            "shipping_address": [
                                "address2": "\(colorSegmented.titleForSegment(at: colorSegmented.selectedSegmentIndex)!)"
                                
                            ],
                            "customer": [
                                "id": 6817112686896
                            ],
                            "use_customer_default_address": true
                        ]
                ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error ==  nil else{
                return
            }
            
            do{
                let response =  try JSONSerialization.jsonObject(with: data , options:  .allowFragments)
                print("SUCCSESS\(response)")
            }catch{
                print(error)
            }
        }
        task.resume()
    }

    
    
    private func postProductFav()
    {
        guard let url = URL(string: "https://48c475a06d64f3aec1289f7559115a55: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@ios-q2-new-capital-admin2-2022-2023.myshopify.com/admin/api/2023-01/draft_orders.json") else{
            return
        }
        print("Making api call FAV")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpShouldHandleCookies = false
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Authorization")

        
        let body : [String : Any] = [
            "draft_order": [
                "line_items": [
                        [
                            "title": "\(product.title ?? "")",
                            "price":  "\(product.variants?.first?.price ?? "" )",
                            "quantity": 1
                    
                       // "properties" : //cartProduct.ggg
                    ]
            ]
        ]
    ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error ==  nil else{
                return
            }
            
            do{
                let response =  try JSONSerialization.jsonObject(with: data , options:  .allowFragments)
                print("SUCCSESS\(response)")
            }catch{
                print(error)
            }
        }
        task.resume()
    }
    
    func startTimer()
    {
        timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(moveToNextIndex), userInfo: nil, repeats: true)
    }
    
  @objc  func moveToNextIndex()
    {
        if currentCellIndex < arrImgs.count - 1
        {
            currentCellIndex += 1
        }
        else
        {
            currentCellIndex  = 0
        }
       // currentCellIndex += 1
        imgsCV.scrollToItem(at: IndexPath(item: currentCellIndex, section: 0), at: .centeredHorizontally, animated: true)
        pageController.currentPage = currentCellIndex
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == imgsCV
        {
            return product.images?.count ?? 0
        }
        return  arrReviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == imgsCV
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productDetailsCell", for: indexPath) as! ProductDetailsCollectionViewCell
           // cell.productDetailsImg(name: URL(string: (arrProducts[indexPath.row])))
            cell.productDetailsImg.kf.setImage(with: URL(string: ((product.images?[indexPath.row])?.src!)!))
            return cell
            
           // cell.productDetailsImg(name:URL(string : (arrProducts[indexPath.row].images!)))
           // return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewCell", for: indexPath) as! ReviewCollectionViewCell
        let rev = arrReviews[indexPath.row]
        cell.setReview(img: rev.img, name: rev.name, txt: rev.reviewTxt)
        return cell
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

struct Reviews
{
    let img : UIImage
    let name : String
    let reviewTxt : String
    
}
extension ProductDetailsViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
            
        return CGSize(width: self.view.frame.width - 50, height: self.view.frame.height * 0.17)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        
        
            return UIEdgeInsets(top: 0 , left: 25, bottom: 0, right: 25)
       
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return CGFloat(15)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return CGFloat(25)
    }
}
extension UISegmentedControl {

    func updateTitle(array titles: [[String]]) {

        removeAllSegments()
        for t in titles {
            let title = t.joined(separator: ", ")
            insertSegment(withTitle: title, at: numberOfSegments, animated: true)
        }

    }
}
/*
extension ProductDetailsViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return product.options?[0].values?.count ?? 1
    }
    /*
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sizeTable.dequeueReusableCell(withIdentifier: "sizeCell", for: indexPath)
        cell.textLabel?.text = product.options?[0].values
        return cell
    }
    */
    
    
}
*/
extension ProductDetailsViewController : UITableViewDelegate
{
    
}
extension ProductDetailsViewController : UITableViewDataSource
{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == sizeTable
        {
            return product.options?[0].values?.count ?? 4
        }
        
        return product.options?[1].values?.count ?? 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == sizeTable
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "sizeCell", for: indexPath)
            cell.textLabel?.text = product.options?[0].values?[indexPath.row]
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "colorCell", for: indexPath)
        cell.textLabel?.text = product.options?[1].values?[indexPath.row]
        //roduct.options?[1].values?[0] ??
        return cell
    }
    
  
    func isAddedToWishList (productId: Int) -> Bool
   {
       var state : Bool = false
       let appDelegate = UIApplication.shared.delegate as! AppDelegate
       let managedContext = appDelegate.persistentContainer.viewContext
       let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ShoppingCartProduct")
      // let fpred = NSPredicate(format: "product_type == %i", 2)
       let pred = NSPredicate(format: "product_id == %i", productId)
       var count : Int?
       fetchRequest.predicate = pred
       do{
            count = try managedContext.fetch(fetchRequest).count
       }catch let error{
           print(error.localizedDescription)
       }
       if count == 0
       {
           state = false
       }
       else
       {
           state = true
       }
      return state
   }

}
