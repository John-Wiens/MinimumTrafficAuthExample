//
//  ContentView.swift
//  TrafficAuthSDKTest
//
//  Created by john on 7/6/26.
//

import SwiftUI
import TrafficAuthSDK

struct ContentView: View {
    
    let token = ""
    let deviceId = ""
    let testMessageHex = "0381004003803200142F414DAB7F03E094E6E25EA5165C627D80007FFFFFFFFFFFF080FDFA1FA1007FFF8000000001040D0000002034001400600120000286274A12968000028632EB255340810101000301801631AFB5FC255D0F5080800257A35CBF8468396F188100000000A35CBF8468396F18815E6F5B00012A5022958400A9830101800348010300012000012600017F81821B84637FB2B24EB0F6AA3C284C91694C6BE4EAEED96E008C0C44213CD3B5A1A380805B11138F9D0178047569DA59EA3EEAF2CE0DD090D5B49C9A986E0F6499C5CA52A8E0E16E4CD05E3D345CE58F54A1E64E833470F3711613CFFD2C31067B71CC96"
    
    @State private var validationTime: Double?
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            if let validationTime {
                Text("Validation Time: \(validationTime) ms")
            } else {
                ProgressView()
            }
        }
        .padding()
        .task {
            validationTime = await getValidationTime()
        }
    }
    
    
    public func getValidationTime() async -> Double{
        let localSigning = LocalSigning.init(scmsEnv: ScmsEnvironment.PREPRODUCTION)
        let tokenType = TokenType.DM_DASHBOARD;
        
        do{
            
            if(localSigning.getState() == SigningAPIState.NEED_CERTS){
                try await localSigning.getDeviceCerts(token: token, type: tokenType, deviceId: deviceId)
            }
            
        }
        catch{
            NSLog("Unable to Retrive Certificates \(error)")
        }
        
        let state = localSigning.getState()
        NSLog("Signing API Status: \(state.rawValue)")
        
        
        let data = convertHexToData(hexString: testMessageHex)
        
        if(data != nil){
            
            do{
                let start = CACurrentMediaTime()
                let (valid, _) = try localSigning.validate(message:data!, shouldValidate:true)
                NSLog("Validity: \(valid)")
                
                let end = CACurrentMediaTime()
                let elapsedSeconds = end - start
                NSLog("Validate Execution time: \(elapsedSeconds) seconds")
                
                let milliseconds = round(elapsedSeconds * 1000000) / 1000
                
                return milliseconds
                
            }catch{
                NSLog("Error in Signature Verification \(error)")
            }
        }
        return -1
        
    }
    
    public func convertHexToData(hexString:String) -> Data?{
        let hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)

        guard hex.count % 2 == 0 else {
            return nil
        }

        var data = Data()
        var index = hex.startIndex

        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            let byteString = hex[index..<nextIndex]

            guard let byte = UInt8(byteString, radix: 16) else {
                return nil
            }

            data.append(byte)
            index = nextIndex
        }

        return data
    }
}


#Preview {
    ContentView()
}
