import SwiftUI
import GoogleSignIn
import AuthenticationServices

class ResponseHandler: ObservableObject {
    @Published var submitText = ""
    @Published var submitLoading = false
    @Published var submitEnabled = true
    @Published var error = false
    @Published var errorMessage = ""
    @Published var success = false
    @Published var successMessage = ""
    @Published var appleShow = true
    @AppStorage("language") var currentLanguage = getLanguage()
    
    func preSubmit() {
        self.error = false
        self.errorMessage = ""
        self.success = false
        self.successMessage = ""
        self.submitText = (currentLanguage == "Ar") ? "الرجاء الإنتظار" : "Please wait"
        self.submitLoading = true
        self.submitEnabled = false
    }
    
    func reset(mvm: MainViewModel) {
        self.error = false
        self.errorMessage = ""
        self.success = false
        self.successMessage = ""
        self.submitText = mvm.home.Login
        self.submitLoading = false
        self.submitEnabled = true
        self.appleShow = true
    }
}

struct LoginLayout: View {
        
    var callback : ((UserResponse) -> Void)? = nil
    @AppStorage("language") var currentLanguage = getLanguage()
    
    @EnvironmentObject var navigation: AppNavigationRouter
    @EnvironmentObject var mvm: MainViewModel
    @StateObject var rh = ResponseHandler()
    
    @State var title = ""
    @State var summary = ""
    
    @State var forgotPassword = false
    @State var createAccount = false
    @State var googleSignin = false
    @State var appleSignin = false
    
    @State var name = ""
    @State var nameValid = true
    @State var nameError = (getLanguage() == "Ar") ? "الرجاء إدخال الإسم" : "Please enter your name"
    
    @State var email = ""
    @State var emailValid = true
    @State var emailError = (getLanguage() == "Ar") ? "الرجاء إدخال البريد الإلكتروني" : "Please enter your email address"
    
    @State var password = ""
    @State var passwordValid  = true
    @State var passwordError  = (getLanguage() == "Ar") ? "الرجاء إدخال كلمة المرور" : "Please enter your password"
    
    @FocusState var keyboardFocused: Fields?
    
    func clearFields() {
        name = ""
        email = ""
        password = ""
    }
    
    var body: some View {
        
        ScrollViewReader { scrollView in
            
            ScrollView {
                
                VStack(spacing: 0) {
                    
                    //region Header
                    Spacer().frame(height: 40)
                    
                    Text(title)
                        .font(currentLanguage == "Ar" ? .system(size: 28, weight: .bold) : .custom("opensans", size: 28))
                        .fontWeight(currentLanguage == "Ar" ? .bold : .medium)
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 5)
                    
                    Text(summary)
                        .font(currentLanguage == "Ar" ? .system(size: 18, weight: .regular) : .custom("opensans", size: 18))
                        .fontWeight(currentLanguage == "Ar" ? .regular : .medium)
                        .foregroundStyle(colorResource.maroon)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 15)
                        .padding(.leading, 15)
                        .padding(.trailing, 15)
                    
                    Spacer().frame(height: 20)
                    //endregion
                    
                    //region Fields
                    if (createAccount) {
                        TextBox(type: Fields.name,
                                label: mvm.home.Name,
                                value: $name,
                                valid: $nameValid,
                                errorMessage: $nameError,
                                isPassword: false,
                                isMulti: false,
                                enabled: $googleSignin,
                                keyboardFocused: $keyboardFocused)
                    }
                    
                    if (!googleSignin && !appleSignin) {
                        
                        TextBox(type: Fields.email,
                                label: mvm.home.Email,
                                value: $email,
                                valid: $emailValid,
                                errorMessage: $emailError,
                                isPassword: false,
                                isMulti: false,
                                enabled: $googleSignin,
                                keyboardFocused: $keyboardFocused)
                        
                        if (!forgotPassword) {
                            TextBox(type: Fields.password,
                                    label: mvm.home.Password,
                                    value: $password,
                                    valid: $passwordValid,
                                    errorMessage: $passwordError,
                                    isPassword: true,
                                    isMulti: false,
                                    enabled: $googleSignin,
                                    keyboardFocused: $keyboardFocused)
                        }
                        
                        //endregion
                        
                        HStack(spacing: 0) {
                            
                            //region Submit Button
                            Button(action: {
                                
                                if (rh.submitEnabled) {
                                    
                                    nameValid = validateField(button: true, current: nameValid, type: Fields.name, value: name, errorMessage: &nameError)
                                    emailValid = validateField(button: true, current: emailValid, type: Fields.email, value: email, errorMessage: &emailError)
                                    passwordValid = validateField(button: true, current: passwordValid, type: Fields.password, value: password, errorMessage: &passwordError)
                                    
                                    var valid = true
                                    
                                    if (createAccount) {
                                        if (!nameValid) {
                                            /*if (valid) {
                                             keyboardFocused = Fields.name
                                             }*/
                                            valid = false
                                        }
                                    }
                                    
                                    if (!emailValid) {
                                        /*if (valid) {
                                         keyboardFocused = Fields.email
                                         }*/
                                        valid = false
                                    }
                                    
                                    if (!forgotPassword) {
                                        if (!passwordValid) {
                                            /*if (valid) {
                                             keyboardFocused = Fields.password
                                             }*/
                                            valid = false
                                        }
                                    }
                                    
                                    if (valid) {
                                        
                                        rh.reset(mvm: mvm)
                                        rh.submitEnabled = false
                                        
                                        keyboardFocused = nil
                                        
                                        Task.detached { @MainActor in
                                            
                                            rh.preSubmit()
                                            
                                            //region Forgot Password
                                            if (forgotPassword) {
                                                
                                                let model = await Apis().forgot(email: email)
                                                
                                                Apis.validateResponse(mvm: mvm, type: "forgot", model: model, rh: rh) { _ in
                                                    
                                                    clearFields()
                                                }
                                            }
                                            //endregion
                                            //region Create Account
                                            else if (createAccount) {
                                                
                                                let model = await Apis().create(name: name, email: email, password: password)
                                                
                                                Apis.validateResponse(mvm: mvm, type: "create", model: model, rh: rh) { it in
                                                    
                                                    clearFields()
                                                    navigation.returnToRoot(in: .account)
                                                    
                                                    callback!(it)
                                                }
                                            }
                                            //endregion
                                            //region Login
                                            else {
                                                
                                                var appleUserID = ""
                                                if (UserDefaults.standard.string(forKey: "AppleIDUser") != nil &&
                                                    UserDefaults.standard.string(forKey: "AppleIDEmail") != nil) {
                                                    if (UserDefaults.standard.string(forKey: "AppleIDEmail")!.trim() == email.trim()) {
                                                        appleUserID = UserDefaults.standard.string(forKey: "AppleIDUser")!
                                                    }
                                                }
                                                
                                                let model = await Apis().login(email: email, password: password, appleUserID: appleUserID)
                                                
                                                Apis.validateResponse(mvm: mvm, type: "login", model: model, rh: rh) { it in
                                                    
                                                    clearFields()
                                                    callback!(it)
                                                }
                                            }
                                            //endregion
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
                            //endregion
                            
                            //region Forgot Password
                            if (!googleSignin && rh.submitEnabled) {
                                
                                Spacer()
                                
                                if (!createAccount && !forgotPassword) {
                                    
                                    Button(
                                        action: {
                                            
                                            rh.reset(mvm: mvm)
                                            nameValid = true
                                            emailValid = true
                                            passwordValid = true
                                            title = mvm.home.ForgotPassword
                                            summary = mvm.home.ForgotPasswordSummary
                                            
                                            if (forgotPassword) {
                                                forgotPassword = false
                                                rh.submitText = mvm.home.Login
                                            } else {
                                                forgotPassword = true
                                                rh.submitText = mvm.home.Submit
                                                navigation.showAccountPage(.forgot)
                                            }
                                        }
                                    )
                                    {
                                        HStack {
                                            Text(mvm.home.ForgotPassword)
                                                .multilineTextAlignment(.center)
                                        }
                                        .padding([.top, .bottom], 12)
                                        .padding([.leading, .trailing], 10)
                                    }
                                    .scaleEffect(1)
                                    .foregroundColor(.gray)
                                    .cornerRadius(10)
                                }
                            }
                            //endregion
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer().frame(height: 10)
                    
                    if (rh.error) {
                        
                        Text(rh.errorMessage.replacingOccurrences(of: "PasswordHash", with: "Password"))
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
                    
                    if (!googleSignin && !appleSignin) {
                        Spacer().frame(height: 50)
                    }
                    else {
                        Spacer().frame(height: 20)
                    }
                    
                    //region Login with Google
                    if (!forgotPassword && !createAccount && !appleSignin) {
                        
                        Button(
                            action: {
                                
                                if (rh.submitEnabled) {
                                    
                                    rh.reset(mvm: mvm)
                                    rh.submitEnabled = false
                                    
                                    googleSignin = true
                                    summary = (currentLanguage == "Ar") ? "تسجيل الدخول مع جوجل" : "Signing in with Google"
                                    navigation.showAccountPage(.google)
                                    
                                    let vc:UIViewController = (UIApplication.shared.firstKeyWindow?.rootViewController)!
                                    
                                    GIDSignIn.sharedInstance.signIn(withPresenting: vc) { signInResult, error in
                                        
                                        var googleValid = true
                                        var googleMessage = ""
                                        
                                        if (error != nil) {
                                            googleValid = false
                                            googleMessage = error!.localizedDescription
                                        }
                                        
                                        else if (signInResult == nil) {
                                            googleValid = false
                                            googleMessage = (currentLanguage == "Ar") ? "لم يتم الحصول على بيانات المستخدم, الرجاء المحاولة مرة أخرى" : "Failed to retrieve user information"
                                        }
                                        
                                        else if (signInResult!.user.profile == nil) {
                                            googleValid = false
                                            googleMessage = (currentLanguage == "Ar") ? "لم يتم الحصول على بيانات المستخدم, الرجاء المحاولة مرة أخرى" : "Failed to retrieve user information"
                                        }
                                        
                                        if (googleValid) {
                                            
                                            Task.detached { @MainActor in
                                                
                                                var appleUserID = ""
                                                if (UserDefaults.standard.string(forKey: "AppleIDUser") != nil &&
                                                    UserDefaults.standard.string(forKey: "AppleIDEmail") != nil) {
                                                    if (UserDefaults.standard.string(forKey: "AppleIDEmail")!.trim() == email.trim()) {
                                                        appleUserID = UserDefaults.standard.string(forKey: "AppleIDUser")!
                                                    }
                                                }
                                                
                                                let model = await Apis().google(name: signInResult!.user.profile!.name, email: signInResult!.user.profile!.email, appleUserID: appleUserID)
                                                
                                                Apis.validateResponse(mvm: mvm, type: "create", model: model, rh: rh) { it in
                                                    
                                                    clearFields()
                                                    navigation.returnToRoot(in: .account)
                                                    
                                                    callback!(it)
                                                }
                                            }
                                        }
                                        else {
                                            
                                            rh.submitEnabled = true
                                            rh.error = true
                                            rh.errorMessage = googleMessage
                                        }
                                    }
                                }
                            }
                        )
                        {
                            HStack {
                                
                                Image("google").resizable().aspectRatio(contentMode: .fit).frame(width:30)
                                
                                Text((currentLanguage == "Ar") ? "تسجيل الدخول باستخدام Google" : "Sign in with Google")
                                
                                if (googleSignin && !rh.submitEnabled) {
                                    
                                    Spacer().frame(width: 10)
                                    
                                    ProgressView().tint(.red)
                                }
                            }
                            .padding([.top, .bottom], 6)
                            .padding(.leading, 10)
                            .padding(.trailing, 15)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                        }
                        .scaleEffect(1)
                        .foregroundColor(colorResource.lightButtonText)
                        .background(Color(hex: "F1F1F1"))
                        .cornerRadius(10)
                    }
                    //endregion
                    
                    Spacer().frame(height: 20)
                    
                    //region Login with Apple
                    if (appleSignin) {
                        
                        ProgressView().tint(.red)
                        
                        Spacer().frame(height: 10)
                    }
                    
                    if (!forgotPassword && !createAccount && !googleSignin && rh.appleShow) {
                        
                        SignInWithAppleButton(.signIn) { request in
                            
                            rh.reset(mvm: mvm)
                            appleSignin = true
                            summary = (currentLanguage == "Ar") ? "تسجيل الدخول مع آبل" : "Signing in with Apple"
                            navigation.showAccountPage(.apple)
                            
                            request.requestedScopes = [.fullName, .email]
                            
                        } onCompletion: { result in
                            
                            switch result {
                                
                            case .success(let auth):
                                
                                rh.appleShow = false
                                
                                if let userCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                                 
                                    var name = ""
                                    var email = ""
                                    var appleUserID = ""
                                    
                                    if (UserDefaults.standard.string(forKey: "AppleIDUser") != nil &&
                                        UserDefaults.standard.string(forKey: "AppleIDName") != nil &&
                                        UserDefaults.standard.string(forKey: "AppleIDEmail") != nil &&
                                        UserDefaults.standard.string(forKey: "AppleIDUser") == userCredential.user) {
                                        
                                        name = UserDefaults.standard.string(forKey: "AppleIDName")!
                                        email = UserDefaults.standard.string(forKey: "AppleIDEmail")!
                                        appleUserID = userCredential.user
                                    }
                                    else {
                                        
                                        appleUserID = userCredential.user
                                        UserDefaults.standard.set(userCredential.user, forKey: "AppleIDUser")
                                        
                                        if (userCredential.identityToken != nil) {
                                            UserDefaults.standard.set(userCredential.identityToken!.description, forKey: "AppleIDToken")
                                        }
                                        if (userCredential.authorizationCode != nil) {
                                            UserDefaults.standard.set(userCredential.authorizationCode!.description, forKey: "AppleIDAuthCode")
                                        }
                                        if (userCredential.state != nil) {
                                            UserDefaults.standard.set(userCredential.state, forKey: "AppleIDState")
                                        }
                                        
                                        if (userCredential.fullName != nil) {
                                            if (userCredential.fullName!.givenName != nil) {
                                                if (userCredential.fullName!.givenName! != "") {
                                                    
                                                    name = userCredential.fullName!.givenName!
                                                    
                                                    if (userCredential.fullName!.familyName != nil) {
                                                        if (userCredential.fullName!.familyName! != "") {
                                                            name += " " + userCredential.fullName!.familyName!
                                                        }
                                                    }
                                                    
                                                    UserDefaults.standard.set(name, forKey: "AppleIDName")
                                                }
                                            }
                                        }
                                                                                
                                        if (userCredential.email != nil) {
                                            if (userCredential.email! != "") {
                                                
                                                email = userCredential.email!
                                                
                                                UserDefaults.standard.set(email, forKey: "AppleIDEmail")
                                            }
                                        }
                                    }
                                    
                                    if (email != "") {
                                        
                                        if (name == "") {
                                            name = email.components(separatedBy: "@")[0].description
                                        }
                                        
                                        Task.detached { @MainActor in
                                            
                                            let model = await Apis().google(name: name, email: email, appleUserID: appleUserID)
                                            
                                            Apis.validateResponse(mvm: mvm, type: "create", model: model, rh: rh) { it in
                                                
                                                DispatchQueue.main.async {
                                                    
                                                    clearFields()
                                                    navigation.returnToRoot(in: .account)
                                                    
                                                    callback!(it)
                                                }
                                            }
                                        }
                                    }
                                    else {
                                        
                                        Task.detached { @MainActor in
                                            
                                            let model = await Apis().apple(appleUserID: appleUserID)
                                            
                                            Apis.validateResponse(mvm: mvm, type: "apple", model: model, rh: rh) { it in
                                                
                                                DispatchQueue.main.async {
                                                    
                                                    clearFields()
                                                    navigation.returnToRoot(in: .account)
                                                    
                                                    callback!(it)
                                                }
                                            }
                                        }
                                        
                                        //rh.error = true
                                        //rh.errorMessage = "Failed to retrieve user information"
                                        //appleSignin = false
                                    }
                                }
                                else {
                                    
                                    rh.error = true
                                    rh.errorMessage = (currentLanguage == "Ar") ? "لم يتم الحصول على بيانات المستخدم, الرجاء المحاولة مرة أخرى" : "Failed to retrieve user information"
                                    appleSignin = false
                                }
                                
                            case .failure(let error):
                                
                                rh.error = true
                                rh.errorMessage = (currentLanguage == "Ar") ? "لم يتم الحصول على بيانات المستخدم: \(error.localizedDescription)" : "Failed to retrieve user information: \(error.localizedDescription)"
                                appleSignin = false
                                
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .signInWithAppleButtonStyle(.black)
                        .modifier(ArabicAppleSignInLabel(isArabic: currentLanguage == "Ar"))
                    }
                    //endregion
                    
                    Spacer().frame(height: 20)
                    
                    if (!forgotPassword && !createAccount && !googleSignin && !appleSignin) {

                        Button(
                            action: {
                                
                                rh.reset(mvm: mvm)
                                nameValid = true
                                emailValid = true
                                passwordValid = true
                                title = mvm.home.Registration
                                summary = mvm.home.RegistrationSummary
                                
                                if (createAccount) {
                                    createAccount = false
                                    rh.submitText = mvm.home.Login
                                } else {
                                    createAccount = true
                                    rh.submitText = mvm.home.Submit
                                    navigation.showAccountPage(.create)
                                }
                            }
                        ) {
                            HStack {
                                Text(mvm.home.LoginFooter)
                                    .font(.system(size: 19))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .padding([.top, .bottom], 12)
                            .padding([.leading, .trailing], 30)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                        }
                        .scaleEffect(1)
                        .foregroundColor(colorResource.lightButtonText)
                        .background(colorResource.lightButton)
                        .cornerRadius(10)
                    }
                }
                .frame(maxWidth: 500)
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .onAppear() {
                    
                    if !navigation.canGoBack(in: .account) {
                        title = mvm.home.Login
                        summary = mvm.home.LoginSummary
                        rh.submitText = mvm.home.Login
                    }
                }
                .onChange(of: navigation.path(for: .account)) { old, next in
                    if !old.isEmpty && next.isEmpty {
                        
                        forgotPassword = false
                        createAccount = false
                        googleSignin = false
                        appleSignin = false
                        
                        rh.reset(mvm: mvm)
                        
                        nameValid = true
                        emailValid = true
                        passwordValid = true
                        title = mvm.home.Login
                        summary = mvm.home.LoginSummary                        
                        
                    }
                }
            }
        }
    }
}

// Keep the native authorization control and callbacks; localize only its Arabic face.
private struct ArabicAppleSignInLabel: ViewModifier {
    let isArabic: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if isArabic {
            content
                .overlay {
                    HStack(spacing: 6) {
                        Image(systemName: "apple.logo")
                        Text("تسجيل الدخول باستخدام Apple")
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .environment(\.layoutDirection, .rightToLeft)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                }
                .accessibilityLabel(Text("تسجيل الدخول باستخدام Apple"))
        } else {
            content
        }
    }
}
