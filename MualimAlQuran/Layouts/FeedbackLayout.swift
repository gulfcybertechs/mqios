import SwiftUI
import SwiftSoup

struct FeedbackLayout: View {
    
    @EnvironmentObject var mvm: MainViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject var rh = ResponseHandler()
    
    @State var name = ""
    @State var nameValid = true
    @State var nameError = (getLanguage() == "Ar") ? "الرجاء إدخال الإسم" : "Please enter your name"
    
    @State var email = ""
    @State var emailValid = true
    @State var emailError = (getLanguage() == "Ar") ? "الرجاء إدخال البريد الإلكتروني" : "Please enter your email address"
    
    @State var feedback = ""
    @State var feedbackValid  = true
    @State var feedbackError  = (getLanguage() == "Ar") ? "الرجاء إدخال الملاحظات" : "Please enter your feedback"
    
    @FocusState var keyboardFocused: Fields?
    
    func clearFields() {
        name = ""
        email = ""
        feedback = ""        
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            TextBox(type: Fields.name,
                    label: mvm.home.Name,
                    value: $name,
                    valid: $nameValid,
                    errorMessage: $nameError,
                    enabled: $rh.submitEnabled,
                    keyboardFocused: $keyboardFocused)
            
            TextBox(type: Fields.email,
                    label: mvm.home.Email,
                    value: $email,
                    valid: $emailValid,
                    errorMessage: $emailError,
                    enabled: $rh.submitEnabled,
                    keyboardFocused: $keyboardFocused)
            
            Text(mvm.home.Feedback + ":")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(colorResource.lightButtonText)
            TextBox(type: Fields.feedback,
                    label: mvm.home.Feedback,
                    value: $feedback,
                    valid: $feedbackValid,
                    errorMessage: $feedbackError,
                    isMulti: true,
                    enabled: $rh.submitEnabled,
                    keyboardFocused: $keyboardFocused)
            
            HStack(spacing: 0) {
                Button(action: {
                    
                    if (rh.submitEnabled) {
                        
                        nameValid = validateField(button: true, current: nameValid, type: Fields.name, value: name, errorMessage: &nameError)
                        emailValid = validateField(button: true, current: emailValid, type: Fields.email, value: email, errorMessage: &emailError)
                        feedbackValid = validateField(button: true, current: feedbackValid, type: Fields.feedback, value: feedback, errorMessage: &feedbackError)
                        
                        var valid = true
                        
                        if (!nameValid) {
                            valid = false
                        }
                        
                        if (!emailValid) {
                            valid = false
                        }
                        
                        if (!feedbackValid) {
                            valid = false
                        }
                        
                        if (valid) {
                            
                            rh.reset(mvm: mvm)
                            rh.submitEnabled = false
                            
                            keyboardFocused = nil
                            
                            Task.detached { @MainActor in
                                
                                rh.preSubmit()
                                
                                let model = await Apis().feedback(name: name, email: email, feedback: feedback)
                                
                                Apis.validateResponse(mvm: mvm, type: "feedback", model: model, rh: rh) { it in
                                    
                                    clearFields()
                                }
                            }
                        }
                        
                    }
                })
                {
                    HStack {
                        Text(rh.submitText)
                        
                        if (rh.submitLoading) {
                            
                            Spacer().frame(width: 10)
                            
                            ProgressView().tint(.white)
                        }
                    }
                    .padding([.top, .bottom], 12)
                    .padding([.leading, .trailing], 30)
                }
                .scaleEffect(1)
                .foregroundColor(.white)
                .background(colorResource.primary_500)
                .cornerRadius(10)
                
                Spacer()
            }
            
            Spacer().frame(height: 10)
            
            if (rh.error) {
                
                Text(rh.errorMessage)
                    .foregroundStyle(colorResource.danger)
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(colorResource.dangerBG)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            
            if (rh.success) {
                
                Text(rh.successMessage)
                    .foregroundStyle(colorResource.success)
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(colorResource.successBG)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear() {
            
            rh.submitText = mvm.home.Submit
        }
    }
}
