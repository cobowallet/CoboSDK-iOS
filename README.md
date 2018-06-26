# CoboSDK-iOS
CoboSDK帮助开发者通过[Cobo钱包](https://cobo.com/)进行ethereum交易的签名和发送。
DApp开发者可以使用CoboSDK获取用户的ethereum账户地址，完成消息的签名和校验，发起交易、调用智能合约以及广播签名后的交易数据。从而省去了开发者自行实现用户私钥管理和钱包功能的工作。

## 接入CoboSDK
接入CoboSDK需要如下几个步骤：

### 添加依赖

- Cocoapods

在你的`Podfile`中添加：
```ruby
pod 'CoboSDK'
```
然后在终端中执行`$ pod install`

- Carthage
```
TODO
```

### 注册URL Scheme
在Xcode中，选择工程设置项，选中`TARGETS`，打开`Info`标签页，点击`URL Types`中的`+`按钮添加新的URL Type。在`URL Schemes` 中填入应用的URL Scheme。URL Scheme应当尽可能唯一，建议使用`<Bundle ID>.cobo`。

![URL Types](Docs/url-types.png)

注册URL Scheme到CoboSDK中，这里的URL Scheme应当与`URL Type`中添加的URL Scheme相同。
```swift
CoboSDK.shared.setup(callbackScheme: <replace with your url scheme>)
```

### 添加```LSApplicationQueriesSchemes```
在应用的```Info.plist```文件中，添加如下内容：
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>cobo-wallet</string>
</array>
```

![Info.plist](Docs/queries-schemes.png)

### 接收返回结果
实现`AppDelegate`中的`func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool`方法来接收返回的结果数据：
```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    return CoboSDK.shared.application(app, open: url, options: options)
}
```

## 使用SDK

### 签名消息
```swift
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
```

### 发送交易
```swift
let gasPrice = BigUInt(stringLiteral: "1000000000") // 1 Gwei
let gasLimit = BigUInt(21000)
let value = BigUInt(stringLiteral: "1000000000000000000") // 1 ETH
let from = <replace with address in sign message result>
let to = <replace with address to transfer to>

let tx = EthereumTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: Data())
CoboSDK.shared.sendTransaction(transaction: tx, from: from) { result in
    switch result {
    case .success(let value):
        guard let hash = value.hash, let tx = value.rawTransaction else { break }
        print("hash: \(hash)")
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

更多功能使用请参考```Example```工程。