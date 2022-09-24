//
//  ViewController.swift
//  Project7.3
//
//  Created by Maks Vogtman on 01/09/2022.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    var filterKeyword: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Most Recent Petitions"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(CreditsTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(addFilter))

        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://hackingwithswift.com/samples/petitions-1.json"
            navigationItem.title = "Most Recent Petitions"
        } else {
            urlString = "https://hackingwithswift.com/samples/petitions-2.json"
            navigationItem.title = "Top Rated Petitions"
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self?.parse(json: data)
                    return
                }
            }
            self?.showError()
        }
    }
    
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }
    
    
    @objc func showError() {
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading the feed, please check your connection and try again", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
    }
    
    
    @objc func CreditsTapped() {
        let ac = UIAlertController(title: "Resource", message: "This data comes from the We The People API of the Whitehouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    
    @objc func addFilter() {
        let ac = UIAlertController(title: "Filter", message: "Filter the petitions on the following keyword (leave empty to reset filtering)", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            self?.filterKeyword = ac?.textFields?[0].text ?? ""
            
            DispatchQueue.global().async {
                self?.filterData()
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        })
        
        present(ac, animated: true)
    }
                     
    
    @objc func filterData() {
        if filterKeyword.isEmpty {
            filteredPetitions = petitions
            DispatchQueue.main.async { [weak self] in
                self?.navigationItem.leftBarButtonItem?.title = "Filter"
            }
            return
        }
        
    DispatchQueue.main.async { [weak self] in
        self?.navigationItem.leftBarButtonItem?.title = "Filter (current: \(self?.filterKeyword ?? ""))"
    }

        // keep only petition whose title or body contains keyword
        filteredPetitions = petitions.filter() { petition in
            // use range instead of contains to filter in case insentive manner
            // (see https://www.hackingwithswift.com/example-code/strings/how-to-run-a-case-insensitive-search-for-one-string-inside-another)
            if let _ = petition.title.range(of: filterKeyword, options: .caseInsensitive) {
                return true
            }
            if let _ =  petition.body.range(of: filterKeyword, options: .caseInsensitive) {
                return true
            }
            return false
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredPetitions.isEmpty {
            return petitions.count
        } else {
            return filteredPetitions.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if filteredPetitions.isEmpty {
            let petition = petitions[indexPath.row]
            cell.textLabel?.text = petition.title
            cell.detailTextLabel?.text = petition.body
        } else {
            let petition = filteredPetitions[indexPath.row]
            cell.textLabel?.text = petition.title
            cell.detailTextLabel?.text = petition.body
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

