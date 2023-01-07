//
//  ContactUsView.swift
//  Parked
//
//  Created by Natanael Jop on 22/09/2022.
//

import SwiftUI
import MessageUI

struct ContactUsView: View {
    @State var text = ""
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    var body: some View {
        VStack{
            ZStack(alignment: .topLeading){
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Gradient(colors: [Color.green, Color.blue, Color.purple]), style: StrokeStyle(lineWidth: 10))
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.revLabel)
                TextField("Provide feedback or ask a question...", text: $text, axis: .vertical)
                    .lineLimit(.max)
                    .padding(20)
            }.padding(30)
            Button {
                self.isShowingMailView.toggle()
            } label: {
                HStack{
                    Spacer()
                    Text("Send")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(20)
                        .foregroundColor(.white)
                    Spacer()
                }.background(Color.accentColor)
                    .cornerRadius(20)
                    .padding([.bottom, .horizontal], 20)
            }

        }.background(Color(UIColor.systemGray6))
            .navigationTitle("Contact Us")
            .disabled(!MFMailComposeViewController.canSendMail())
                    .sheet(isPresented: $isShowingMailView) {
                        MailView(result: self.$result, emailData: EmailData(subject: "Feedback", recipients: ["natanael.jop.app@gmail.com"], body: text))
                    }
    }
}

struct ContactUsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactUsView()
    }
}
