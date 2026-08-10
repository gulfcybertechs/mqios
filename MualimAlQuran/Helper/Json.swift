import SwiftUI

class Json {
    
    func load<T: Decodable>(_ filename: String) -> T {
        var data: String
        
        guard let file = Bundle.main.url(forResource: getLanguage() + "_" + filename + ".json", withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        //let currentLanguage = getLanguage()
        
        do {
            
            data = try String(contentsOf: file)
            
            /*if (currentLanguage != "" && currentLanguage != "En") {
                
                let keys = ["Title", "Summary", "Link1", "Link2", "LoginSummary", "Email", "Password", "Login", "Registration", "RegistrationSummary", "Name", "Submit", "LoginFooter", "RegisterFooter", "Feedback", "AboutUs", "Lesson", "ForgotPassword", "ForgotPasswordSummary", "ResetPassword", "ResetPasswordSummary", "NewPassword", "ConfirmPassword", "Share", "Instructions", "Page", "OneWord", "TwoWords", "_3Times", "_5Times", "_7Times", "Completed", "Incomplete", "Progress", "Bookmark", "ShareSummary", "InfoSettings", "Downloads", "Language", "RestartApp", "RestartAppSummary", "Letters", "Harakat", "Vowels", "Sukoon", "Muqatta", "Noon", "Meem", "Laam", "Qalqalah", "Madd", "Signs", "Title1", "Summary1", "Trans", "TransH1", "TransH2", "TransH3", "TransT1", "TransT2", "TransT3", "Arti", "SurahName", "Verse_", "Description", "Intro", "IntroText", "Letters", "LettersText", "Method", "MethodText", "Sign", "SignText", "Examples", "Col1", "Col2", "Col3", "Col4", "Vocabularies", "VocabulariesText", "ExamplesText", "Meaning", "ColorsMeaning", "Madd6", "Madd4", "Madd2", "Gunnah", "Idgam", "Tafkheem", "Qalqalah"]
                
                keys.forEach { key in
                    data = data.replacingOccurrences(of: "\"" + key + "\":", with: "\"" + key + "En\":")
                }
                
                keys.forEach { key in
                    data = data.replacingOccurrences(of: "\"" + key + "\(currentLanguage)\":", with: "\"" + key + "\":")
                }
            }*/
            
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            //data = data.replacingOccurrences(of: "\"", with: "")
            return try decoder.decode(T.self, from: data.data(using: .utf8)!)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
}
