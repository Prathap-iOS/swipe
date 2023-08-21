//
//  ViewController.swift
//  swipe
//
//  Created by Prathap Reddy on 17/08/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var products = [ProductList]()
    var isSearching = false
    var searchProducts = [ProductList]()
    
    var productTypeList: [String] = []
    
    private var floatingButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.backgroundColor = .white
        let image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        
        //Corner Radius
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(floatingButton)
        floatingButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchingAPIData(URL: "https://app.getswipe.in/api/public/get") { result in
            self.products = result
            DispatchQueue.main.async { [self] in
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NotificationCenter.default.addObserver(self, selector: #selector(didGetNotification(_:)), name: Notification.Name("message"), object: nil)
        floatingButton.frame = CGRect(
            x: view.frame.size.width - 80,
            y: view.frame.size.height - 120,
            width: 60,
            height: 60)
    }
    
    @objc func didGetNotification(_ notification: Notification) {
        let message = notification.object as! String?
        self.view.showToast(toastMessage: message!, duration: 5.0)
    }
    
    @objc private func didTapButton() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddProductViewController") as! AddProductViewController
        vc.modalPresentationStyle = .fullScreen
        vc.productTypeList = self.productTypeList
        present(vc, animated: true)
    }
    
    func fetchingAPIData(URL url: String, completion: @escaping ([ProductList]) -> Void) {
        let url = URL(string: url)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) { data, response, error in
            if data != nil && error == nil {
                do {
                    let parsingData = try JSONDecoder().decode([ProductList].self, from: data!)
                    completion(parsingData)
                } catch {
                    print("Parsing error")
                }
            }
        }
        dataTask.resume()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching {
            return self.searchProducts.count
        } else {
            return self.products.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductListViewCell
        if isSearching {
            cell.productNameLabel.text = self.searchProducts[indexPath.section].product_name
            cell.productTypeLabel.text = self.searchProducts[indexPath.section].product_type
            cell.priceLabel.text = "₹\(self.searchProducts[indexPath.section].price)"
            cell.taxesLabel.text = "Applicable \(self.searchProducts[indexPath.section].tax) % extra taxes"
            let image = self.searchProducts[indexPath.section].image
            if image == "" {
                cell.productImageView.image = UIImage(named: "Swipe_logo")
            } else {
                cell.productImageView.load(url: URL(string: image)!)
            }
        } else {
            cell.productNameLabel.text = self.products[indexPath.section].product_name
            cell.productTypeLabel.text = self.products[indexPath.section].product_type
            cell.priceLabel.text = "₹\(self.products[indexPath.section].price)"
            cell.taxesLabel.text = "Price excludes \(self.products[indexPath.section].tax)% taxes "
            let image = self.products[indexPath.section].image
            if image == "" {
                cell.productImageView.image = UIImage(named: "Swipe_logo")
            } else {
                cell.productImageView.load(url: URL(string: image)!)
            }
        }
        productTypeList.append(self.products[indexPath.section].product_type)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = self.tableView.backgroundColor
        return view
    }
    
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchProducts = self.products.filter({$0.product_name.lowercased().prefix(searchText.count) == searchText.lowercased()})
//        self.searchProducts = self.products.filter({$0.product_type.lowercased().prefix(searchText.count) == searchText.lowercased()})
        isSearching = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        tableView.reloadData()
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

