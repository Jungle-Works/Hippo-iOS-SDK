//
//  Fugu+Properties.swift
//  Fugu
//
//  Created by Gagandeep Arora on 13/10/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation

let HippoSDKSource = 1
let Device_Type_iOS = 2
var userDetailData = [String: Any]()

let fuguAppVersion = "2.1.52"
var versionCode = 250

/*
 201 = Bot messages
 202 = Video Call
 203 = Audio Call
 204 = Hippo Pay
 
 206 = Document sending
 207 = manager Document sharing
 
 208 = changes for thirdParty agent login
 209 = consent Bot
 
 210 = newUser form and github repo
 211 = Calling issue fixed
 212 = can create payment request
 
 214 *** 1.7.29 = o2o chat
 215 *** 1.7.30 = ride status
 
 216 *** 1.7.31 = Swift conversation to 5.0
 218 *** 1.7.34 = customer to agent video call, lead form fixes
 219 *** 1.7.35 = Vidoe call changes, handled audio call connecting state
 220 *** 1.7.36 = handled lowercase CallType
 221 *** 1.7.37 = userImage changes
 222 *** 1.7.38 = hot fix for HippoUser
 223 *** 1.7.39 = navigation changes
 224 *** 1.7.40 = fetchUnreadCount for P2P
 225 *** 1.7.41 = handled HTML entities and removed agent data on updateUserDetail
 226 *** 1.7.42 = updated UI of SDK
 227 *** 1.7.43 = UI Changes
 228 *** 1.7.44 = Time issue fixes and UI improvement
 229 *** 1.7.45 = Added bot_group_id
 230 *** 1.7.46 = createConversation chnages for bot and iPad issue fixed
 231 *** 1.7.47 = removed logs
 232 *** 1.7.48 = corner radius issue fixed
 233 *** 1.7.49 = handled isMyChat key
 234 *** 1.7.50 = renamed borderWidth and color
 235 *** 1.7.51 = added @objcMembers to HippoConfig
 
 240 *** 1.8.0 = handled device token generation, merchant chat changes
 241 *** 1.8.1 = borderWithIssue fixed
 242 *** 1.8.2 = Payment messge ui fixes and skip bot functionality
 243 *** 1.8.3 = Payment handled at agentSDK
 
 245 *** 1.8.5 = Test changes
 
 244 *** 1.8.4 = voip changes
 
 300 *** 2.1.0 = voip changes
 
 301 *** 2.1.1 = ticket attributes
 
 302 *** 2.1.2 = failed pod upload
 
 303 *** 2.1.3 = promotional push
 
 304 *** 2.1.4 = new conversation button added
 
 305 *** 2.1.5 = suggestions for normal messages
 
 306 *** 2.1.6 = show back button on promotional push screen
 
 307 *** 2.1.7 = show back button on promotional push screen and hotfix url
 
 308 *** 2.1.8 = Show Title On Promotion Push Contoller & Hide Image On Down Swipe
 
 309 *** 2.1.9 = Set Theme Color Of Navigation Bar In Promotional Push Controller
 
 310 *** 2.1.10 = Public Method For Get App Name, Faye Error Handling, Remove Forced Name Capitalization
 
 311 *** 2.1.12 = Merged code with buddy branch & old calling
 
 312 *** 2.1.13 = Broadcast issue, chat cache issues fixed and change new conversation button
 
 313 *** 2.1.14 = Promotions issue fixed and deep linking handled
 
 314 *** 2.1.15 = Update agent sdk with feedback and filter functionality, with develop_latest branch code
 
 315 *** 2.1.16 = Functionlity for payment gateways like paytm and redirection from web view on success and error in paytm payment.
 
 316 *** 2.1.17 = Calling issues fixed and pending status added in agent chat.
 
 317 *** 2.1.18 = Cp sdk feedback done and present full screen done and Merge branch 'FatafatCpSdkIssues'
 
 318 *** 2.1.19 = Function added to get current channel id.
 
 319 *** 2.1.20 = UI changes and unread count in agent sdk
 
 320 *** 2.1.21 = p2p chat count in parent app and chat autoclose in refresh channel
 
 321 *** 2.1.22 = p2p chat count in parent app and chat autoclose in refresh channel
 
 322 *** 2.1.23 = payment method fixes and calling fixes done
 
 323 *** 2.1.24 = curreny handled in payment, method exposed for registering new channel id in p2p chat, resolved bot group id must be a number issue
 
 324 *** 2.1.25 = Enhanced ui in cp and agent sdk
 
 325 *** 2.1.26 = Rating and review ui changes, generic calling functions and fixes
 
 326 *** 2.1.27 = Fallback for btn color
 
 327 *** 2.1.28 = Variable added for new calling and issues fixed
 
 328 *** 2.1.29 = Color coding changed for conversation
 
 329 *** 2.1.31 = Agent sdk issues fixed and api optimisations done for extra hits
 
 330 *** 2.1.32 = Agent sdk issues fixed , show slow internet bar made configurable from parent app
 
 331 *** 2.1.33 = Bugs fixes, UI changes and localization
 
 332 *** 2.1.33 = Bugs fixes
 
 334 *** 2.1.35 = Bug fixes

 334 *** 2.1.41 = Search user unique key issues
 
 334 *** 2.1.42 = Edit and delete messages functionality
 
 335 *** 2.1.43 = Payment cell ui fixes
 
 336 *** 2.1.44 = O2O chat and razor pay sdk functionality added
 
 337 *** 2.1.45 = Bug Fixes
 
 338 *** 2.1.46 = Support Chat (O2o new flow)
 
 339 *** 2.1.47 = Sockets and E-prescription
 
 340 *** 2.1.48 = Support Chat (O2o new flow)
 
 341 *** 2.1.49 = eprescription, mimetype restriction and socket issues fixed
 
 342 *** 2.1.50 = Socket user id issue fixed
 
 342 *** 2.1.51 = Unread api optimisation
 
 343 *** 2.1.53 = P2P optimisation and razor pay sdk remove
 
 */
