

> # HippoChat iOS SDK

Install HippoChat to see and talk to users of your iPhone app. The HippoChat SDK is distributed via CocoaPods. This method is documented below:
#### Pre Requisites : 
1. Hippo SDK supports iOS 9.0 and above
2. Hippo App_Secret_Key/Reseller_token
3. Xcode

If you have any queries during the integration, please reach out to us at support@fuguchat.com

# Step 1: Install using CocoaPods

HippoChat is available through CocoaPods. To add HippoChat to your project, add the SDK to your Podfile as shown below.

`pod 'Hippo'`

Once you have updated your Podfile run `pod install`(terminal command) to automatically download and install the SDK in your project.

Please note: HippoChat SDK supports apps targeting iOS 10.0+. The SDK itself is compatible with all the above iOS 10.0

#### Upgrading the HippoChat SDK?

Run `pod update Hippo`(terminal command) in your project directory.

Note:  `Hippo dose not support bitcode when using it with Call SDK, to continue with hippo disable bitcode from app target setting .i.e., app_target > build setting > Enable Bitcode > No` 

Note: `Permission required for using Hippo:->> Privacy - Camera Usage Description, Privacy - Microphone Usage Description, Privacy - Photo Library Additions Usage Description, Privacy - Photo Library Usage Description. Add these permissions in info.plist for avoiding crashes.` 



# Step 2: Add HippoChat Credentials
After adding SDK to your project, add HippoChat Credentials before invoking/attempting to use any other feature/method of Hippo SDK.

The HippoChat credential is added either via `APP-SECRET-KEY` or `'RESELLER-TOKEN' and 'REFERENCE-ID'`. Both methods are documented below:

#### Option A - Add Credential via `YOUR-APP-SECRET-KEY`

Commonly used way to add credential listed below.

```sh
HippoConfig.shared.setCredential(withAppSecretKey: YOUR-APP-SECRET-KEY)
```
If you are going to use multiple apps from same APP-SECRET-KEY you must add your apps in Dashboard which will generate an APP-TYPE, which you will use while setting your credentials. APP-TYPE will be different for different apps generated with same APP-SECRET-KEY.
```sh
HippoConfig.shared.setCredential(withAppSecretKey: YOUR-APP-SECRET-KEY, appType: YOUR-APP-TYPE)
```

Note: We highly recommend to add credential only once and from your AppDelegate's application:didFinishLaunchingWithOptions: or when you log in into your app.
Don't forget to replace the `YOUR-APP-SECRET-KEY` in the following code snippet with the actual app secret key. 

```sh
func application(application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
...
HippoConfig.shared.setCredential(withAppSecretKey: YOUR-APP-SECRET-KEY)
...
}
```

Note: If you want to set your app name in custom push notifications than use the following method where you add your Hippo Credentials

```sh
HippoConfig.shared.setAppName(withAppName: YOUR-APPNAME)
```

#### Option B - Add Credential via `'YOUR-RESELLER-TOKEN', 'YOUR-REFERENCE-ID' and 'YOUR-APP-TYPE'`

Add credential via your `reseller_token` and `refernce_id` key before invoking/ attempting to use any other features/methods of Hippo SDK. As documented below:
```sh
HippoConfig.shared.setCredential(withToken: YOUR-RESELLER-TOKEN,
referenceId: YOUR-REFERENCE-ID,
appType: YOUR-APP-TYPE)
```
Note: We highly recommend to add credential only once and from your AppDelegate's application:didFinishLaunchingWithOptions:
Don't forget to replace `YOUR-RESELLER-TOKEN`, `YOUR-REFERENCE-ID` and `YOUR-APP-TYPE` in the following code snippet with the actual reseller_token, reference_id and app_type. 

```sh
func application(application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
...
HippoConfig.shared.setCredential(withToken: YOUR-RESELLER-TOKEN,
referenceId: YOUR-REFERENCE-ID,
appType: YOUR-APP-TYPE)
...
}
```

# Step 3: Updating User Information
Update Identified or logged in user information by passing user data whenever you update/edit user profile on your server like this:
```sh
//Get the user object for the current installation (for customers)
let HippoUserDetail = HippoUserDetail(fullName: "<Full_name_string>",
email: "<Email_string>",
phoneNumber: "<phone_number_string>",
userUniqueKey: "<your_unique_identifier_for_user>",
addressAttribute: <initialize_HippoAttributes>,
customAttributes: <set_custom_attributes>,
selectedlanguage: <selected_language>
)

//Call updateUserDetails so that
//the user information is synced with Hippo servers 
HippoConfig.shared.updateUserDetail(userDetail: HippoUserDetail)

//For initialization of Hippo Manager
  HippoConfig.shared.initManager(authToken: "<User_auth_Token>", 
  app_type: "<App_Type>", 
  selectedLanguage: <selected_language>)

```

Note : If you don't have a unique user identifier to use here, or if you have a userId and an email you can use Email/Phone number on the Registration object as unique key.

# Step 4: Showing conversations inside your application
In response to a specific UI events like a menu selection or button tap event, call the `presentChatsViewController()` method to launch the Conversation Flow. If the app has multiple channels configured, the user will see the channel list. Channel list is ordered as specified in the Dashboard when there are no messages. 

```sh
// Launching Conversation List in your app screen
HippoConfig.shared.presentChatsViewController()
```

# Step 5: Handling Push Notifications

#### Steps to get push notifications working with Hippo

1. Sending the device registration token to Hippo
2. Customizing Notification appearance and passing notification data to Hippo
3. Handle push notification click

#### 1: Send Device Registration Token
HippoChat using the SDK is capable of sending push notifications to your users. To enable this support, when your app delegate receives the application:didRegisterForRemoteNotificationsWithDeviceToken: method, include a call to `registerDeviceToken(deviceToken: Data)` as below:
```sh
func application(_ application: UIApplication,
didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
HippoConfig.shared.registerDeviceToken(deviceToken: deviceToken)
}
```

#### 2: Customizing Notification appearance and passing notification data to Hippo
After receiving remote notification, pass the remoteNotification userInfo into `isHippoNotification(withUserInfo: pushInfo)`  and  `showNotification(userInfo: pushInfo)` method to validate Hippo notification as mentioned below:

```sh
func application(_ application: UIApplication,
didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
let pushInfo = (userInfo as? [String : Any]) ?? [:]
if HippoConfig.shared.isHippoNotification(withUserInfo: pushInfo) {

if HippoConfig.shared.showNotification(userInfo: pushInfo) {
...
//setup banner or any UI you want to show inside your app
//and call `HippoConfig.shared.handleRemoteNotification(userInfo: pushInfo)`
//after tapping on that banner
...
}
return
} 
}
```

# Step 6: Clear User Data on Logout
Clear user data at logout or when deemed appropriate based on user action in the app by invoking the `clearHippoUserData()` function:  
```sh
HippoConfig.shared.clearHippoUserData()
```

# Advanced features

### Other Infomation delegate
Inherit "HippoDelegate" to a class and then set it to HippoConfig.shared.setHippoDelegate(delegate: <-Your class->), This will notifiy that class on any information or any message that you can use. This delegate is also used for getting view for view call and audio call

```
HippoConfig.shared.setHippoDelegate(delegate: <HippoDelegate>)
```
### Open specific chat with channelID
In response to a specific UI events like a menu selection or button tap event, call the `openChatWith(channelId: Int, completion: (_ success: Bool, _ error: Error?) -> Void)` method to launch the specified channel by passing `Channel-ID` as mentioned below:

```sh
// Launching Conversation List from click of a button in your app's screen
HippoConfig.shared.openChatWith(channelId: CHANNEL_ID, completion: { (success, error) in
// handle success or error
})
```

### Open unique chat on specific transaction

If you want to open a unique channel by your specific transaction for example if you want a chat corresponding to your particular Order, you can call `openChatScreen(withTransactionId transactionId: String, tags: [String]? = nil, channelName: String, message: String = "", userUniqueKey: String? = nil, completion: @escaping (_ success: Bool, _ error: Error?) -> Void)` method.

```sh
// Launching Conversation List from click of a button in your iOS app
/**
- parameter withTransactionId: Unique ID to recognize your chat, ex. your OrderID
- parameter tags: Additional Information which will be user to distinguis chats in Dashboard
- parameter channelName: If you want to specify a name for the chat, or you can leave it empty 
- parameter message: Optional parameter, if you want to start a chat with a first message already added
HippoConfig.shared.openChatScreen(withTransactionId: "<transation_id>",
tags: ["<tag_1>, <tag_2>"],
channelName: "<channel_name>", message: "First message after opening the chat")
```
### Open peer to peer chat

Use `HippoConfig.shared.showPeerChatWith(data: PeerToPeerChat, completion: @escaping (_ success: Bool, _ error: Error?) -> Void)` to open chat screen with Peer.

```sh
/**
- parameter uniqueChatId: Unique ID you will use to recognize seprate chats between same peers. Could be set to `nil` if there is no need to create seprate chat between same peers.
- parameter myUniqueId: ID which your systems uses to recognize you uniquely.
- parameter idsOfPeers: Unique IDs of peers with whom you want to start chat.
- parameter channelName: Name you want to give your chat, If you want peers name to show pass empty string.
*/
let peerChatInfo = PeerToPeerChat(uniqueChatId: "YOUR-UNIQUE-CHAT-ID", myUniqueId: "YOUR-UNIQUE-ID", idsOfPeers: ["PEER-UNIQUE-ID"], channelName: "CHANNEL-NAME")

HippoConfig.shared.showPeerChatWith(data: peerChatInfo, completion: { (success, error) in
//handle success or error
})
```

### Switch Enviroment Between Development and Live(Production)

Use `HippoConfig.shared.switchEnvironment(_ envType: HippoEnvironment)` to switch between development and Live enviroments

```sh
HippoConfig.shared.switchEnvironment(.dev)
```
OR
```sh
HippoConfig.shared.switchEnvironment(.live)
```
`live` is selected by Default.

### Changing the colors of Hippo Chat screens to give a look and feel of your application 
Use `HippoConfig.shared.setCustomisedHippoTheme(theme: HippoTheme)` method to easily replicate your application’s look and feel in Hippo Screens, reference code snippet is as follows : 

We highly recommend to add credential only once and from your AppDelegate’s application:didFinishLaunchingWithOptions:

```sh
func application(application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
...
let hippotheme = HippoTheme.defaultTheme()
hippotheme.backgroundColor = .black
hippotheme.headerBackgroundColor = .black
hippotheme.headerTextColor = .black
hippotheme.headerText = "support"
hippotheme.promotionsAnnouncementsHeaderText = "Announcements"

HippoConfig.shared.setCustomisedHippoTheme(theme: hippotheme)
...
}
```
####  Pass fonts with Hippo Theme

Use `HippoTheme.defaultTheme(fontRegular: "", fontBold: "")` to paas your app fonts  in Hippo Theme

```sh
/**
- parameter fontRegular: Pass app regular font here
fontBold: Pass app Bold/Semi-Bold font here
*/
```
### Miltilingual Support
Use `HippoConfig.shared.setLanguage(_ code : String)` to paas  selected language code from your application for using language in particular language

```sh
/**
- parameter code: Pass language code here. For example: "en" for English or "es" For Spanish
*/
```

### Initialize Bot ( Not available for managers)
Use ` HippoConfig.shared.setNewConversationBotGroupId(botGroupId:)` to paas your botgroupid


### Annoucements Section ( Not available for managers)
Use `HippoConfig.shared.presentPromotionalPushController()` for opening Annoucements section from your application



# Setup Video call For Hippo SDK
To enable video call in Hippo SDK, enable it from hippo dashboard setting > add on > video call

> Note:  Please go through Other Infomation delegate paragraph, [Click Here](#other-infomation-delegate) , as you have to send video call/ Audio Call in app View.

#### 1:  Installation Call SDK
Install Call SubPod for video and audio call.

`pod 'Hippo/Call'`

Once you have updated your Podfile run `pod install`(terminal command) to automatically download and install the SDK in your project.

#### 2: Firstly register for VOIP notification in your app delegate
You can take reference from below mentioned link. If already done continue to next step
https://medium.com/ios-expert-series-or-interview-series/voip-push-notifications-using-ios-pushkit-5bc4a8f4d587


#### 3: Send Voip Device Registration Token
HippoChat using the SDK is capable of sending push notifications to your users. To enable this support, when your app delegate receives the _ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType method, include a call to `registerVoipDeviceToken(deviceToken: Data)` as below:
```sh
func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
let token = pushCredentials.token
HippoConfig.shared.registerVoipDeviceToken(deviceData: token)
}
```
#### 4: Passing Voip notification data to Hippo SDK
After receiving Voip notification, pass the remoteNotification userInfo into `isHippoNotification(withUserInfo: pushInfo)`  and  `showNotification(userInfo: pushInfo)` method to validate Hippo notification as mentioned below:

```sh
func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
guard type == PKPushType.voIP else {
return
}
if HippoConfig.shared.isHippoNotification(withUserInfo: pushInfo) {
HippoConfig.shared.handleVoipNotification(payloadDict: payload.dictionaryPayload)
} else {
//Its your voip push to handle
}
}
```
#### 5: Start peer to peer video chat

Use `HippoConfig.shared.startVideoCall(data: PeerToPeerChat, completion: @escaping (_ success: Bool, _ error: Error?) -> Void)` to open chat screen with Peer.

```sh
/**
- parameter uniqueChatId: Unique ID you will use to recognize seprate chats between same peers. Could be set to `nil` if there is no need to create seprate chat between same peers.
- parameter myUniqueId: ID which your systems uses to recognize you uniquely.
- parameter idsOfPeers: Unique IDs of peers with whom you want to start chat.
- parameter channelName: Name you want to give your chat, If you want peers name to show pass empty string.
- parameter peerName: Other peer name to show on screen.
*/
let peerChatInfo = PeerToPeerChat(uniqueChatId: "YOUR-UNIQUE-CHAT-ID", myUniqueId: "YOUR-UNIQUE-ID", idsOfPeers: ["PEER-UNIQUE-ID"], channelName: "CHANNEL-NAME", peerName: "Peer name")

HippoConfig.shared.startVideoCall(data: peerChatInfo, completion: { (success, error) in
//handle success or error
})
```
