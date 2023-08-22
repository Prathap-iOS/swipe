//
//  AddProductViewController.swift
//  swipe
//
//  Created by Prathap Reddy on 18/08/23.
//

import UIKit
typealias Parameters = [String: String]

class AddProductViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var addProductImageView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameTF: UITextField!
    @IBOutlet weak var productTypeTF: UITextField!
    @IBOutlet weak var sellingPriceTF: UITextField!
    @IBOutlet weak var taxRateTF: UITextField!
    
    @IBOutlet weak var productTypeTableView: UITableView!
    @IBOutlet weak var photoSelectionView: UIView!
    @IBOutlet weak var placeHolderImageView: UIImageView!
    @IBOutlet weak var addProductImageLabel: UILabel!
    
    let child = SpinnerViewController()
    
    var isSource: String?
    var productName: String?
    var productType: String?
    var price: Float = 0.0
    var tax: Float = 0.0
    var imageString = ""
    
    let url = URL(string: "https://app.getswipe.in/api/public/add")
    
    let boundary: String = "Boundary-\(UUID().uuidString)"
    var productImage = UIImage()
    
    var productTypeList: [String] = []
    
    var filePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.productTypeList.removeDuplicates()
        self.addDoneButtonOnKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isSource == "pcell" {
            self.productImageView.isHidden = false
            self.photoSelectionView.isHidden = true
            self.productTypeTableView.isHidden = true
            self.addProductImageLabel.isHidden = true
            self.placeHolderImageView.isHidden = true
            if self.imageString == "" {
                self.productImageView.image = UIImage(named: "Swipe_logo")
            } else {
                self.productImageView.load(url: URL(string: self.imageString)!)
            }
            self.productNameTF.text = self.productName
            self.productTypeTF.text = self.productType
            self.sellingPriceTF.text = "\(self.price)"
            self.taxRateTF.text = "\(self.tax)"
        } else {
            self.productImageView.isHidden = true
            self.photoSelectionView.isHidden = true
            self.productTypeTableView.isHidden = true
            self.addProductImageLabel.isHidden = false
            self.placeHolderImageView.isHidden = false
        }
        
    }
    
    @IBAction func addProductImageViewTap(_ sender: Any) {
        self.photoSelectionView.isHidden = false
    }
    
    @IBAction func saveProductDetailsTap(_ sender: Any) {
        Task { @MainActor in
            await self.valicationsTF()
        }
    }
    
    func showSpinnerView() {
        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func hideSpinnerView() {
        // then remove the spinner view controller
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    func uploadProduct() async {
        showSpinnerView()
        let urlString = "https://app.getswipe.in/api/public/add"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Adding files
        let filePath = self.filePath ?? ""
        if let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
           let fileName = filePath.components(separatedBy: "/").last {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"files[]\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Adding other form data
        let formData = [
            "product_name": self.productNameTF.text,
            "product_type": self.productTypeTF.text,
            "price": "\(self.sellingPriceTF.text ?? "")",
            "tax": "\(self.taxRateTF.text ?? "")"
        ]
        for (key, value) in formData {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value ?? "")\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data,
               let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
                DispatchQueue.main.async {
                    self.hideSpinnerView()
                    self.dismiss(animated: true) {
                        self.view.showToast(toastMessage: "Product added Successfully!", duration: 2.0)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func saveImageToFile(image: UIImage) -> String? {
        // Get the document directory URL
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // Create a unique file name
        let fileName = "\(UUID().uuidString).png"
        
        // Append the file name to the documents directory URL to create the full file URL
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Convert the image to PNG data
        guard let imageData = image.pngData() else {
            return nil
        }
        
        // Write the image data to the file
        do {
            try imageData.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Error saving image to file: \(error)")
            return nil
        }
    }
    
    @IBAction func onCancelButtonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func valicationsTF() async {
        if productNameTF.text == "" {
            showAlert(message: "Product name shouldn't be empty")
        } else if productTypeTF.text == "" {
            showAlert(message: "Product type shouldn't be empty")
        } else if sellingPriceTF.text == "" {
            showAlert(message: "Selling price shouldn't be empty")
        } else if taxRateTF.text == "" {
            showAlert(message: "Tax rate shouldn't be empty")
        } else {
            await self.uploadProduct()
        }
    }
    
    func showAlert(message: String?) {
        let alert = UIAlertController(title: "Warning",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func onCameraButtonTap(_ sender: Any) {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .camera
        imagePickerVC.delegate = self
        present(imagePickerVC, animated: true)
    }
    
    @IBAction func onPhotosButtonTap(_ sender: Any) {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.delegate = self
        present(imagePickerVC, animated: true)
    }
    
    @IBAction func onDismissButtonTap(_ sender: Any) {
        self.photoSelectionView.isHidden = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            self.placeHolderImageView.isHidden = true
            self.addProductImageLabel.isHidden = true
            self.photoSelectionView.isHidden = true
            self.productImageView.isHidden = false
            self.productImageView.image = image
            self.productImage = image
            self.filePath = self.saveImageToFile(image: image)
        }
    }
    
    @IBAction func onProductTypeButtonTap(_ sender: Any) {
        if self.productTypeTableView.isHidden == true {
            self.productTypeTableView.isHidden = false
        } else {
            self.productTypeTableView.isHidden = true
        }
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        productNameTF.inputAccessoryView = doneToolbar
        sellingPriceTF.inputAccessoryView = doneToolbar
        taxRateTF.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        productNameTF.resignFirstResponder()
        sellingPriceTF.resignFirstResponder()
        taxRateTF.resignFirstResponder()
    }
}

extension AddProductViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productTypeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTypeCell", for: indexPath)
        cell.textLabel?.text = self.productTypeList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.productTypeTF.text = self.productTypeList[indexPath.row]
        self.productTypeTableView.isHidden = true
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

//MARK:- Image Resizer
extension UIImage {

    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func resizedToMB(_ inMb: Double) -> UIImage? {
        let requiredSize = inMb*1024
        guard let imageData = self.jpegData(compressionQuality: 1.0) else {return nil}
    //    guard let imageData = UIImagePNGRepresentation(self) else { return nil }

        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / requiredSize

        while imageSizeKB > requiredSize {
            guard let resizedImage = resizingImage.resized(withPercentage: 0.9),
                  let imageData = resizedImage.jpegData(compressionQuality: 1.0)
                else { return nil }

            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / requiredSize
        }

        return resizingImage
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

