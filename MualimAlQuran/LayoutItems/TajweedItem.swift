import SwiftUI

struct TajweedItem: View {
    
    @EnvironmentObject var navigation: AppNavigationRouter
    @EnvironmentObject var mvm: MainViewModel
    @Binding var item: TajweedModel
    @Binding var activeLetter: Int
    @Binding var player: Player
    @State var title: String = ""
    @State var text: String = ""   
    @AppStorage("language") var currentLanguage = getLanguage()
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            //region Title
            if (item.Type == "Examples") {
                
                Button(action: {
                    
                    AppHaptics.tap()
                    mvm.loadTajweedExItems()
                    navigation.push(.tajweedExamples, in: .home)
                    
                }) {
                    
                    HStack()
                    {
                        
                        Text(title)
                            .foregroundStyle(colorResource.maroon)
                            .font(.system(size: 20))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: (currentLanguage == "Ar") ? "chevron.left" : "chevron.right")
                            .foregroundColor(colorResource.maroon)
                            .font(.system(size: 20))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(15)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .scaleEffect(1)
                .background(colorResource.lightButton)
                .cornerRadius(10)
                .padding(12)
                
            } else {
                
                if (title != "")
                {
                    Text(title)
                        .foregroundStyle(colorResource.maroon)
                        .font(.system(size: 20))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(colorResource.lightButton)
                }
            }
            //endregion
            
            //region Summary
            if (text != "") {
                
                if (item.Type == "Sign") {
                    
                    //region Sign
                    ScrollView(.horizontal) {
                        
                        HStack(spacing: 0)
                        {
                            VStack(spacing: 0)
                            {
                                Text("Noon Saakin")
                                    .foregroundStyle(colorResource.primary_500)
                                    .padding(.top, 5)
                                    .padding(.bottom, 5)
                                    .frame(alignment: .center)
                                
                                let _text1 = item.SignText
                                    .replacingOccurrences(of: "نـ<span style=\"left: 160px; top: -70px;\">ْ</span>&nbsp;&nbsp;&nbsp;ـنـ<span style=\"left: 85px; top: -70px;\">ْ</span>&nbsp;&nbsp;&nbsp;ن<span style=\"left: 15px; top: -70px;\">ْ</span>", with: "نْـ&nbsp;&nbsp;&nbsp;ـنْـ&nbsp;&nbsp;&nbsp;نْ")
                                    .replacingOccurrences(of: "نـ<span style=\"left: 160px; top: -70px;\">ۢ</span>&nbsp;&nbsp;&nbsp;ـنـ<span style=\"left: 85px; top: -70px;\">ۢ</span>&nbsp;&nbsp;&nbsp;ن<span style=\"left: 15px; top: -70px;\">ۢ</span>", with: "نۢـ&nbsp;&nbsp;&nbsp;ـنۢـ&nbsp;&nbsp;&nbsp;نۢ")
                                    .replacingOccurrences(of: "&nbsp;", with: " ")
                                
                                Text(_text1)
                                    .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 40))
                                    .frame(height: 80)
                                    .padding(.leading, 12)
                                    .padding(.trailing, 12)
                                    .padding(.top, 5)
                                    .border(Color(hex: "E4E4E4"), width: 1)
                            }
                            .border(Color(hex: "E4E4E4"), width: 1)
                            .padding(.top, 15)
                            .padding(.trailing, 15)
                            
                            VStack(spacing: 0)
                            {
                                Text("Tanween")
                                    .foregroundStyle(colorResource.primary_500)
                                    .padding(.top, 5)
                                    .padding(.bottom, 5)
                                    .frame(alignment: .center)
                                
                                let _text2 = (item.SignText2 + " " + item.SignText3 + " " + item.SignText4)
                                    .replacingOccurrences(of: "_<span style=\"left: 4px; top: -60px;\">ٌ</span>", with: "ٌ &nbsp;&nbsp;&nbsp;")
                                    .replacingOccurrences(of: "_<span style=\"left: 4px; top: -15px;\">ٍ</span>", with: "ٍ &nbsp;&nbsp;&nbsp;")
                                    .replacingOccurrences(of: "_<span style=\"left: 4px; top: -60px;\">ً</span>", with: "ً")
                                    .replacingOccurrences(of: "_<span style=\"left: 8px; top: -60px;\">ُۢ</span>", with: "   ُۢ")
                                    .replacingOccurrences(of: "_<span style=\"left: 8px; top: -5px;\">َۢ</span>", with: "   َۢ")
                                    .replacingOccurrences(of: "_<span style=\"left: 8px; top: -60px;\">َۢ</span>", with: "   َۢ")
                                    .replacingOccurrences(of: "&nbsp;", with: " ")
                                
                                Text(_text2)
                                    .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 55))
                                    .frame(height: 80)
                                    .padding(.leading, 12)
                                    .padding(.trailing, 24)
                                    .padding(.top, 5)
                                    .offset(y: (-15))
                                    .border(Color(hex: "E4E4E4"), width: 1)
                                    
                            }
                            .border(Color(hex: "E4E4E4"), width: 1)
                            .padding(.top, 15)
                            .padding(.trailing, 15)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 12)
                        .padding(.trailing, 12)
                        .padding(.bottom, 12)
                        .background(.white)
                    }
                    //endregion
                    
                } else {
                    
                    Text(text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(.white)
                }
            }
            //endregion
            
            //region Letters
            if (item.Type == "Letters" && item._Letters != "") {
                
                // FlowRow
                ScrollView(.horizontal) {
                    
                    HStack(spacing: 0)
                    {
                        
                        ForEach(item._Letters.split(separator: ",").indices, id: \.self) { index in
                            
                            let it = item._Letters.split(separator: ",")[index]
                            
                            ZStack
                            {
                                
                                Text(it)
                                    .foregroundStyle(colorResource.orange)
                                    .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 40))
                                    .frame(width: 80, height: 80)
                                    .padding(.leading, 12)
                                    .padding(.trailing, 12)
                                    .padding(.bottom, 12)
                                    .background(.white)
                                
                                HStack(spacing: 0) {
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 0) {
                                        
                                        Spacer()
                                        
                                        if (activeLetter == index) {
                                            
                                            ProgressView()
                                                .tint(colorResource.maroon)
                                                //.frame(width: 18, height: 18)
                                                .padding(2)
                                            
                                        } else {
                                            
                                            Image(systemName: "play.circle.fill")
                                                .foregroundStyle(colorResource.primary_500)
                                                .frame(width: 18, height: 18)
                                                .padding(2)
                                        }
                                    }
                                }
                            }
                            .padding(2)
                            .border(Color(hex: "E4E4E4"), width: 1)
                            .padding(.trailing, 5)
                            .onTapGesture {
                                
                                activeLetter = index
                                                                                                          
                                letterPlayByName(name: String(item._LettersAudio.split(separator: ",")[index]), player: player)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(12)
                    .background(.white)
                }
            }
            //endregion
            
            Spacer()
        }
        .frame(maxWidth:.infinity)
        .onAppear() {
            
            switch (item.Type) {
                
            case "Intro":
                title = item.Intro
                text = item.IntroText.replacingOccurrences(of: "<span>", with: "").replacingOccurrences(of: "</span>", with: "").replacingOccurrences(of: "<br />", with: "\n").replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
                break
                
            case "Letters":
                title = item.Letters
                text = item.LettersText
                break
                
            case "Method":
                title = item.Method
                text = item.MethodText.replacingOccurrences(of: "<span>", with: "").replacingOccurrences(of: "</span>", with: "").replacingOccurrences(of: "<br />", with: "\n").replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
                break
                
            case "Sign":
                title = item.Sign
                text = item.SignText
                break
                
            case "Examples":
                title = item.Examples
                break
                
            default: break
                
            }
            //endregion
        }        
    }
}
