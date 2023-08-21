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
    
    let url = URL(string: "https://app.getswipe.in/api/public/add")
    
    let boundary: String = "Boundary-\(UUID().uuidString)"
    var productImage = UIImage()
    
    var productTypeList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.productImageView.isHidden = true
        self.photoSelectionView.isHidden = true
        self.productTypeTableView.isHidden = true
        self.productTypeList.removeDuplicates()
    }
    
    @IBAction func addProductImageViewTap(_ sender: Any) {
        self.photoSelectionView.isHidden = false
    }
    
    @IBAction func saveProductDetailsTap(_ sender: Any) {
        Task { @MainActor in
            await self.valicationsTF()
        }
    }
    
    func postRequest() async {
        let parameters = ["product_name" : self.productNameTF.text!,
                          "product_type" : self.productTypeTF.text!,
                          "price" : "\(self.sellingPriceTF.text!)",
                          "tax" : "\(self.taxRateTF.text!)"]
        
        guard let mediaImage = Media(withImage: self.productImage, forKey: "files[]") else { return }
        
        guard let url = URL(string: "https://app.getswipe.in/api/public/add") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = generateBoundary()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
        request.httpBody = dataBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("message"), object: "Product added Successfully!")
                        self.dismiss(animated: true, completion: nil)
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    func createDataBody(withParameters params: Parameters?, media: [Media]?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for(key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
            
            if let media = media {
                for photo in media {
                    body.append("--\(boundary + lineBreak)")
                    body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; fileName=\"\(photo.fileName)\"\(lineBreak)")
                    body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                    body.append(photo.data)
                    body.append(lineBreak)
                }
            }
            
            body.append("--\(boundary)--\(lineBreak)")
        }
        return body
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(UUID().uuidString)"
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
            await self.postRequest()
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
        }
    }
    
    @IBAction func onProductTypeButtonTap(_ sender: Any) {
        if self.productTypeTableView.isHidden == true {
            self.productTypeTableView.isHidden = false
        } else {
            self.productTypeTableView.isHidden = true
        }
    }
    
//    func multiPartRequest(fileName: String, fileData: Data) async {
//        var multipart = MultipartRequest()
//        for field in [
//            "product_name": self.productNameTF.text,
//            "product_type": self.productTypeTF.text,
//            "price" : self.sellingPriceTF.text,
//            "tax" : self.taxRateTF.text,
//        ] {
//            multipart.add(key: field.key, value: field.value!)
//        }
//
//        multipart.add(
//            key: "file",
//            file: fileName,
//            fileMimeType: "image/png",
//            fileData: fileData
//        )
//
//        /// Create a regular HTTP URL request & use multipart components
//        var request = URLRequest(url: self.url!)
//        request.httpMethod = "POST"
//        request.setValue(multipart.httpContentTypeHeadeValue, forHTTPHeaderField: "Content-Type")
//        request.httpBody = multipart.httpBody
//
//        /// Fire the request using URL sesson or anything else...
//        let (data, response) = try! await URLSession.shared.data(for: request)
//        print((response as! HTTPURLResponse).statusCode)
//        print(String(data: data, encoding: .utf8)!)
//        valicationsTF(statusCode: (response as! HTTPURLResponse).statusCode)
//    }
}

//public struct MultipartRequest {
//
//    public let boundary: String
//
//    private let separator: String = "\r\n"
//    private var data: Data
//
//    public init(boundary: String = UUID().uuidString) {
//        self.boundary = boundary
//        self.data = .init()
//    }
//
//    private mutating func appendBoundarySeparator() {
//        data.append("--\(boundary)\(separator)")
//    }
//
//    private mutating func appendSeparator() {
//        data.append(separator)
//    }
//
//    private func disposition(_ key: String) -> String {
//        "Content-Disposition: form-data; name=\"\(key)\""
//    }
//
//    public mutating func add(
//        key: String,
//        value: String
//    ) {
//        appendBoundarySeparator()
//        data.append(disposition(key) + separator)
//        appendSeparator()
//        data.append(value + separator)
//    }
//
//    public mutating func add(
//        key: String,
//        file: String,
//        fileMimeType: String,
//        fileData: Data
//    ) {
//        appendBoundarySeparator()
//        data.append(disposition(key) + "; file=\"\(file)\"" + separator)
//        data.append("Content-Type: \(fileMimeType)" + separator + separator)
//        data.append(fileData)
//        appendSeparator()
//    }
//
//    public var httpContentTypeHeadeValue: String {
//        "multipart/form-data; boundary=\(boundary)"
//    }
//
//    public var httpBody: Data {
//        var bodyData = data
//        bodyData.append("--\(boundary)--")
//        return bodyData
//    }
//}

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

