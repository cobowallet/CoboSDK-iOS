//
//  ViewController.swift
//  Example
//
//  Created by Robin Zhang on 2018/6/21.
//  Copyright © 2018 Example. All rights reserved.
//

import UIKit
import CoboSDK
import BigInt
import web3swift
import enum Result.Result

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        callContract()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func signMessage() {
        let message = "Hello Cobo!"
        CoboSDK.shared.signMessage(message: message) { result in
            switch result {
            case .success(let value):
                guard let address = value.address, let signature = value.signature else { break }
                print(address)
                let match = CoboSDK.shared.verifyMessage(address: address, signature: signature, message: message)
                print("\(match)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func signTransaction() {
        let gasPrice = BigUInt(stringLiteral: "1000000000") // 1 Gwei
        let gasLimit = BigUInt(21000)
        let value = BigUInt(stringLiteral: "1000000000000000000") // 1 ETH
        let from = EthereumAddress("0x43521682ed93df31610d38930082a7d575e1b19e")! // !!! <replace with address in sign message result>
        let to = EthereumAddress("0x43521682ed93df31610d38930082a7d575e1b19e")! // !!! <replace with address to transfer to>
        
        let tx = EthereumTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: Data())
        CoboSDK.shared.sendTransaction(transaction: tx, from: from) { result in
            switch result {
            case .success(let value):
                guard let hash = value.hash else { break }
                print("hash: \(hash)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func callContract() {
        guard let path = Bundle.main.path(forResource: "abi", ofType: "json") else {
            print("failed to load api file")
            return
        }
        let w3 = web3(provider: InfuraProvider(Networks.Ropsten)!)
        let contractAddress = EthereumAddress("0x725DcFdf065d4e41839E0d3B6b15A7725551B93B")!
        let gasPrice = BigUInt(stringLiteral: "1000000000") // 1 Gwei
        let gasLimit = BigUInt(40000)
        let from = EthereumAddress("0x43521682ed93df31610d38930082a7d575e1b19e")! // !!! <replace with address in sign message result>
        
        do {
            let abi = try String(contentsOfFile: path, encoding: .utf8)
            let contract = ContractV2(abi, at:contractAddress)
            
            var options = Web3Options()
            options.from = from
            options.gasPrice = gasPrice
            options.gasLimit = gasLimit
            options.value = BigUInt(0)
            guard var tx = contract?.method("bet", parameters: [true] as [AnyObject], options:options) else {
                print("failed to create contract transaciton")
                return
            }
            
            w3.eth.estimateGas(tx, options: options, callback: { (res: Result<AnyObject, Web3Error>) in
                switch res {
                case .success(let value):
                    guard let value = value as? BigUInt else { break }
                    print("estimated gas limit: \(value)")
                    tx.gasLimit = value
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                }
                CoboSDK.shared.sendTransaction(transaction: tx, from: options.from) { result in
                    switch result {
                    case .success(let value):
                        guard let hash = value.hash else { break }
                        print("hash: \(hash)")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            })
        } catch {
            print("error: \(error)")
        }
    }
}

