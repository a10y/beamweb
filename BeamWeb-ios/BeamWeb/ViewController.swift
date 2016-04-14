//
//  ViewController.swift
//  BeamWeb
//
//  Created by Andrew Duffy on 4/8/16.
//  Copyright © 2016 Andrew Duffy. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate {
    
    var responds: Bool = false
    
    func backPressed(send: UIButton!) {
        print("back pressed")
        webview.goBack()
    }
    
    func forwardPressed(sender: UIButton!) {
        print("Forward pressed")
        webview.goForward()
    }
    
    override func viewDidLoad() {
        NSLog("Adding URL bar...")
        // Add the location bar.
        let fullScreen = UIScreen.mainScreen().bounds
        let topCenter = CGRectMake(fullScreen.width / 4.0, 20.0, fullScreen.width / 2.0, 30.0)
        locationBar = UITextField.init(frame: topCenter)
        locationBar.borderStyle = UITextBorderStyle.Line
//        locationBar.keyboardType = UIKeyboardType.
        locationBar.autocapitalizationType = UITextAutocapitalizationType.None
        locationBar.autocorrectionType = UITextAutocorrectionType.No
        locationBar.delegate = self
        view.addSubview(locationBar)
        print("URL bar added")
        
        
        // Add the forward/back buttons
        let topLeft = CGRectMake(0, 20.0, fullScreen.width / 4.0, 30.0)
        let topRight = CGRectMake(fullScreen.width * 0.75, 20.0, fullScreen.width / 4.0, 30.0)
        let backButton = UIButton.init(frame: topLeft)
        let forwardButton = UIButton.init(frame: topRight)
        backButton.backgroundColor = UIColor.blackColor()
        forwardButton.backgroundColor = UIColor.blackColor()
        backButton.addTarget(self, action: #selector(ViewController.backPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        forwardButton.addTarget(self, action: #selector(ViewController.forwardPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        backButton.setTitle("<", forState: UIControlState.Normal)
        forwardButton.setTitle(">", forState: UIControlState.Normal)

        view.addSubview(backButton)
        view.addSubview(forwardButton)

        // Setup and create the webview
        let prefs = WKPreferences()
        prefs.javaScriptEnabled = true // make sure JS is enabled
        
        let config = WKWebViewConfiguration()
        config.preferences = prefs
        
        // make room for url above
        let bounds = CGRectMake(0.0, 50.0, fullScreen.width, fullScreen.height - 50.0)
        webview = WKWebView.init(frame: bounds, configuration: config)
        
        if let theWebView = webview {
            let url = NSURL(string: "https://aduffy.org")
            let req = NSURLRequest.init(URL: url!)
            theWebView.loadRequest(req)
            theWebView.navigationDelegate = self
            view.addSubview(theWebView)
            responds = true
            print("Success!")
        } else{
            print("Failure")
        }
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        switch motion {
        case .MotionShake:
            if responds {
                flickToDesktop(); // magic happens here
                print("fuck yeah")
            }
        default:
            // some other event we don't care about
            break
        }
    }
    
    func flickToDesktop() {
        // send to the server.
        // tcp fun ensues
        let url = locationBar.text!.cStringUsingEncoding(NSUTF8StringEncoding)
        let host = "10.31.37.169".cStringUsingEncoding(NSUTF8StringEncoding)
        let retcode = send_ping(url!, host!, 6000) // send the ping and stuff
        print("Retcode of " + String(retcode))
    }
    
    
    
    /**
     * Update on navigation.
     */
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        let text = webView.URL!.absoluteString
        locationBar.text = text
        //flickToDesktop()

    }
    
    /**
     * When enter pressed in url, goes to the URL in the locationBar field.
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("TextField should return method called")
        // Open the page
        var url: NSURL?

        if let testing = NSURL.init(string: locationBar.text!) {
            if (UIApplication.sharedApplication().canOpenURL(testing)) {
                url = testing
            } else {
                url = googleQueryUrl()
            }
        } else {
            url = googleQueryUrl()
        }

        let req = NSURLRequest.init(URL: url!)
        webview.loadRequest(req)
        print("Navigating to " + (url?.absoluteString)!)
        
        // This just was autofiled, idk what it does
        textField.resignFirstResponder();
        return true;
    }
    
    /**
     * Buils a Google search query
     */
    func googleQueryUrl() -> NSURL {
        // build a google query
        let text = locationBar.text!
        print("bad url, building a google query instead")
        let query = "https://www.google.com/#q=" + text.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        return NSURL.init(string: query)!
    }

    
    var webview: WKWebView!
    var locationBar: UITextField!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
        // Current stance on this is "fuck it"
    }
    
    override func viewWillDisappear(animated: Bool) {
        responds = false // don't beam after disappearing
    }
    
    override func viewWillAppear(animated: Bool) {
        responds = true
    }

}

