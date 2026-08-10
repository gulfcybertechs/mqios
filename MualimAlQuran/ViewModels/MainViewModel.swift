import SwiftUI

class MainViewModel: ObservableObject
{
    //@Published var langList: [String] = ["Title", "Summary", "Link1", "Link2", "LoginSummary", "Email", "Password", "Login", "Registration", "RegistrationSummary", "Name", "Submit", "LoginFooter", "RegisterFooter", "Feedback", "AboutUs", "Lesson", "ForgotPassword", "ForgotPasswordSummary", "ResetPassword", "ResetPasswordSummary", "NewPassword", "ConfirmPassword", "Share", "Instructions", "Page", "OneWord", "TwoWords", "_3Times", "_5Times", "_7Times", "Completed", "Incomplete", "Progress", "Bookmark", "ShareSummary", "InfoSettings", "Downloads", "Language", "RestartApp", "RestartAppSummary", "Letters", "Harakat", "Vowels", "Sukoon", "Muqatta", "Noon", "Meem", "Laam", "Qalqalah", "Madd", "Signs", "Title1", "Summary1", "Trans", "TransH1", "TransH2", "TransH3", "TransT1", "TransT2", "TransT3", "Arti", "SurahName", "Verse_", "Description", "Intro", "IntroText", "Letters", "LettersText", "Method", "MethodText", "Sign", "SignText", "Examples", "Col1", "Col2", "Col3", "Col4", "Vocabularies", "VocabulariesText", "ExamplesText", "Meaning"]
    
    //@Published var selectedTab = 0
    @Published var selectedTab = Tab.home
    @Published var homeScroll: Int? = nil
    @Published var viewLevel = "home"
    @Published var back = false
    @Published var backLevels = ["stage", "stage1", "lesson", "tajweed", "tajweedEx", "ql", "qlVoc", "qlEx"]
    @Published var backForce = false
    @Published var navigateToMemorizing = false
    @Published var homeNavSelection: Int? = nil
    @Published var stageNavSelection: Int? = nil
    @Published var stage1NavSelection: Int? = nil
    
    @Published var accountScroll: Int? = nil
    @Published var accountViewLevel = "account"
    @Published var accountBack = false
    @Published var accountBackLevels = ["forgot", "google", "create", "apple"]
    
    @Published var menuScroll: Int? = nil
    @Published var menuBackLevels = ["page", "feedback", "language", "download"]
    
    @Published var qlScrollTarget = -1
    
    var initiated = false
    var splashLoading = true
    @Published var loading = true
    @Published var language = "En"
    
    var listType = "home"
    var listSelected = ListModel()
    var listSelected1 = ListModel()
    
    var home: HomeModel = HomeModel()
    var stages: [ListModel] = []
    var lessons: [ListModel] = []
    var stageTabs: [ListTabModel] = []
    @Published var stageTab = ListModel(isTab: true, TabIndex: "101")
    @Published var stageLessons: [ListModel] = []
    var stageLessonsTajweed: [ListModel] = []
    var lessonSelected = ListModel()
    var lessonItems: [LessonModel] = []
    
    var lesson1data: [LessonModel] = []
    var lesson3data: [LessonModel] = []
    var lesson5data: [LessonModel] = []
    var lesson6data: [LessonModel] = []
    var lesson8data: [LessonModel] = []
    var lesson9data: [LessonModel] = []
    var lesson10data: [LessonModel] = []
    var lesson11data: [LessonModel] = []
    var lesson12data: [LessonModel] = []
    var lesson13data: [LessonModel] = []
    var lesson15data: [LessonModel] = []
    var lesson16data: [LessonModel] = []
    
    var surahNames: [String] = []
    var surahNamesAr: [String] = []
    @Published var recitationItems: [RecitationModel] = []
    var verse1: [RecitationModel] = []
    var verseByVerse: [RecitationModel] = []
    var recitationInitialLoad = false
    
    var tajweed: [TajweedModel] = []
    var tajweedSetup: [TajweedExSetupModel] = []
    var tajweedItems: [TajweedModel] = []
    var tajweedExItems: [TajweedExModel] = []
    var tajweedSelectedSetup = TajweedExSetupModel()
    
    var tajweed1data: [TajweedExModel] = []
    var tajweed2data: [TajweedExModel] = []
    var tajweed3data: [TajweedExModel] = []
    var tajweed4data: [TajweedExModel] = []
    var tajweed5data: [TajweedExModel] = []
    var tajweed6data: [TajweedExModel] = []
    var tajweed7data: [TajweedExModel] = []
    var tajweed8data: [TajweedExModel] = []
    var tajweed9data: [TajweedExModel] = []
    var tajweed10data: [TajweedExModel] = []
    var tajweed11data: [TajweedExModel] = []
    var tajweed12data: [TajweedExModel] = []
    var tajweed13data: [TajweedExModel] = []
    var tajweed14data: [TajweedExModel] = []
    var tajweed15data: [TajweedExModel] = []
    var tajweed16data: [TajweedExModel] = []
    var tajweed17data: [TajweedExModel] = []
    var tajweed18data: [TajweedExModel] = []
    var tajweed19data: [TajweedExModel] = []
    var tajweed20data: [TajweedExModel] = []
    var tajweed21data: [TajweedExModel] = []
    var tajweed22data: [TajweedExModel] = []
    var tajweed23data: [TajweedExModel] = []
    var tajweed24data: [TajweedExModel] = []
    var tajweed25data: [TajweedExModel] = []
    
    var ql: [QLModel] = []
    var qlHeaders: [QLHeaderModel] = []
    var qlSections: [QLSectionModel] = []
    var qlWords: [QLWordModel] = []
    var ql15: [QL15] = []
    var ql30: [QL15] = []
    var ql33: [QL15] = []
    var qlVoc: [QLVocModel] = []
    var qlEx: [QLExModel] = []
    var qlItems: [QLModel] = []
    var qlVocItems: [QLVocModel] = []
    var qlExItems: [QLExModel] = []
    
    var memorizingItems: [Memorizing] = []
    
    var pages: [PageModel] = []
    var pageSelected = PageModel()
    var languageItems: [PageModel] = []
    var downloadItems: [DownloadModel] = []
    @Published var downloadingItems: [DownloadModel] = []
    
    func initiate() {
        
        if (!initiated) {
            
            self.initiated = true
            
            self.home = (Json().load("Home") as [HomeModel])[0]
            self.stages = Json().load("Stages")
            self.stages = self.stages.sorted { item1, item2 in item1.Sort < item2.Sort }
            
            self.splashLoading = false
            
            Task {                                
                
                //try await Task.sleep(nanoseconds: 5000_000_000)
                
                lessons = Json().load("Lessons")
                stageTabs = Json().load("StageTabs")
                                
                lesson1data = Json().load("Lesson1")
                lesson3data = Json().load("Lesson3")
                lesson5data = Json().load("Lesson5")
                lesson6data = Json().load("Lesson6")
                lesson8data = Json().load("Lesson8")
                lesson9data = Json().load("Lesson9")
                lesson10data = Json().load("Lesson10")
                lesson11data = Json().load("Lesson11")
                lesson12data = Json().load("Lesson12")
                lesson13data = Json().load("Lesson13")
                lesson15data = Json().load("Lesson15")
                lesson16data = Json().load("Lesson16")
                
                pages.removeAll()
                pages = Json().load("Pages")
                pages.append(PageModel(id: "feedback", Title: home.Feedback))
                pages.append(PageModel(id: "download", Title: home.Downloads))
                pages.append(PageModel(id: "language", Title: home.Language))
                
                languageItems.removeAll()
                languageItems.append(PageModel(id: "En", Title: "English"))
                languageItems.append(PageModel(id: "Ar", Title: "Arabic"))
                languageItems.append(PageModel(id: "Swa", Title: "Swahili"))
                languageItems.append(PageModel(id: "Fr", Title: "French"))
                languageItems.append(PageModel(id: "Pt", Title: "Portuguese"))
                languageItems.append(PageModel(id: "Es", Title: "Spanish"))
                languageItems.append(PageModel(id: "Ru", Title: "Russian"))
                languageItems.append(PageModel(id: "De", Title: "German"))
                languageItems.append(PageModel(id: "Hi", Title: "Hindi"))
                languageItems.append(PageModel(id: "Zh", Title: "Chinese"))
                languageItems.append(PageModel(id: "Ur", Title: "Urdu"))
                languageItems.append(PageModel(id: "Ind", Title: "Bahasa"))
                //languageItems.append(PageModel(id: "Bn", Title: "Bangla"))
                //languageItems.append(PageModel(id: "Ha", Title: "Hausa"))
                //languageItems.append(PageModel(id: "Tr", Title: "Turkish"))
                
                surahNames = Json().load("SurahNames")
                surahNamesAr = Json().load("SurahNamesAr")
                verse1 = Json().load("Verses1")
                verseByVerse = Json().load("Verses")
                
                stageLessonsTajweed = stage3(listData: lessons
                    .filter { $0.StageID == 3 && $0.id != 51 && $0.id != 52 && $0.id != 97 }
                    .sorted { item1, item2 in item1.Sort < item2.Sort })
                
                tajweed = Json().load("Tajweed")
                tajweedSetup = Json().load("TajweedExSetup")
                tajweed1data = Json().load("TajweedEx1")
                tajweed2data = Json().load("TajweedEx2")
                tajweed3data = Json().load("TajweedEx3")
                tajweed4data = Json().load("TajweedEx4")
                tajweed5data = Json().load("TajweedEx5")
                tajweed6data = Json().load("TajweedEx6")
                tajweed7data = Json().load("TajweedEx7")
                tajweed8data = Json().load("TajweedEx8")
                tajweed9data = Json().load("TajweedEx9")
                tajweed10data = Json().load("TajweedEx10")
                tajweed11data = Json().load("TajweedEx11")
                tajweed12data = Json().load("TajweedEx12")
                tajweed13data = Json().load("TajweedEx13")
                tajweed14data = Json().load("TajweedEx14")
                tajweed15data = Json().load("TajweedEx15")
                tajweed16data = Json().load("TajweedEx16")
                tajweed17data = Json().load("TajweedEx17")
                tajweed18data = Json().load("TajweedEx18")
                tajweed19data = Json().load("TajweedEx19")
                tajweed20data = Json().load("TajweedEx20")
                tajweed21data = Json().load("TajweedEx21")
                tajweed22data = Json().load("TajweedEx22")
                tajweed23data = Json().load("TajweedEx23")
                tajweed24data = Json().load("TajweedEx24")
                tajweed25data = Json().load("TajweedEx25")
                
                ql = Json().load("QL")
                qlHeaders = Json().load("QLHeaders")
                qlSections = Json().load("QLSections")
                qlWords = Json().load("QLSectionWords")
                ql15 = Json().load("QL15")
                ql30 = Json().load("QL30")
                ql33 = Json().load("QL33")
                qlVoc = Json().load("QLVoc")
                
                let qlExData: [QLExModel] = Json().load("QLEx")
                qlExData.forEach { it in
                    
                    if (it.Verse.trim().replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").split(separator: ":").count > 1) {
                        let Surah = it.Verse.trim().replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").split(separator: ":")[0]
                        let Ayah = it.Verse.trim().replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").split(separator: ":")[1]
                        
                        it.VerseText = verseByVerse.first (where: { $0.Surah == Surah && $0.Ayah == Ayah } )!.Verse
                        it.VerseTranslation = verseByVerse.first ( where: { $0.Surah == Surah && $0.Ayah == Ayah })!.Verse_
                    }
                    qlEx.append(it)
                }
                
                await MainActor.run {
                    self.loading = false
                }
            }
        }
    }
    
    func loadStageLessons(item: ListModel) {
        
        if (!lessons.isEmpty) {
            stageLessons.removeAll()
            let data = lessons
                .filter { $0.StageID == item.id && $0.id != 14 && $0.id != 17 && $0.id != 19 }
                .sorted { item1, item2 in item1.Sort < item2.Sort }
            
            switch (item.id) {
            case 1: stageLessons = data
            default:
                stageLessons = data
            }
            
            switch (item.id) {
            case 1: stageLessons = stage1(listData: data)
            case 3: stageLessons = lessons.filter { $0.id == 51 || $0.id == 52 || $0.id == 97 }
            case 4: stageLessons = stage4(listData: data)
            default: stageLessons = data
            }
        }
    }
    
    func loadLessonItems() {
        
        if (!lessonItems.isEmpty) {
            
            for i in (0...lessonItems.count - 1) {
                
                lessonItems[i] = LessonModel()
            }
            
            lessonItems.removeAll()
        }
        
        lessonItems = []
        
        switch (lessonSelected.Number) {
        case 1: lessonItems = lesson1data
        case 2: lessonItems = lesson2(listData: lesson1data.filter { $0.id != 30 })
        case 3: lessonItems = lesson3data
        case 4, 17: lessonItems = lesson4(listData: lesson1data.filter { $0.id != 30 }, lessonNumber: lessonSelected.Number)
        case 5: lessonItems = lesson5data
        case 6: lessonItems = lesson6(listData: lesson6data)
        case 7: lessonItems = lesson1data.filter { $0.id != 30 }
        case 8: lessonItems = lesson8(listData: lesson8data, lesson: lessonSelected)
        case 9: lessonItems = lesson9(listData: lesson9data)
        case 10: lessonItems = lesson10(listData: lesson10data, lesson: lessonSelected)
        case 11: lessonItems = lesson11data
        case 12: lessonItems = lesson12(listData: lesson12data)
        case 13: lessonItems = lesson13(listData: lesson13data)
        case 15: lessonItems = lesson15(listData: lesson15data)
        case 16: lessonItems = lesson16(listData: lesson16data)
        default: lessonItems = lesson1data
        }                
    }
    
    func loadTajweedItems() {
        
        tajweedItems.removeAll()
        
        let data = tajweed.filter { $0.id == lessonSelected.Number }
        
        var newData: [TajweedModel] = []
        newData.append(data[0].copy(id: data[0].id + 101, type: "Intro"))
        newData.append(data[0].copy(id: data[0].id + 102, type: "Letters"))
        newData.append(data[0].copy(id: data[0].id + 103, type: "Method"))
        newData.append(data[0].copy(id: data[0].id + 104, type: "Sign"))
        newData.append(data[0].copy(id: data[0].id + 105, type: "Examples"))
        
        tajweedItems = newData
    }
    
    func loadTajweedExItems() {

        tajweedExItems.removeAll()
        
        switch (lessonSelected.Number) {
        case 1: tajweedExItems = tajweed1data
        case 2: tajweedExItems = tajweed2data
        case 3: tajweedExItems = tajweed3data
        case 4: tajweedExItems = tajweed4data
        case 5: tajweedExItems = tajweed5data
        case 6: tajweedExItems = tajweed6data
        case 7: tajweedExItems = tajweed7data
        case 8: tajweedExItems = tajweed8data
        case 9: tajweedExItems = tajweed9data
        case 10: tajweedExItems = tajweed10data
        case 11: tajweedExItems = tajweed11data
        case 12: tajweedExItems = tajweed12data
        case 13: tajweedExItems = tajweed13data
        case 14: tajweedExItems = tajweed14data
        case 15: tajweedExItems = tajweed15data
        case 16: tajweedExItems = tajweed16data
        case 17: tajweedExItems = tajweed17data
        case 18: tajweedExItems = tajweed18data
        case 19: tajweedExItems = tajweed19data
        case 20: tajweedExItems = tajweed20data
        case 21: tajweedExItems = tajweed21data
        case 22: tajweedExItems = tajweed22data
        case 23: tajweedExItems = tajweed23data
        case 24: tajweedExItems = tajweed24data
        case 25: tajweedExItems = tajweed25data
        default: break
        }
    }
    
    func loadQLItems(mvm: MainViewModel) {

        qlItems.removeAll()
        
        let data = ql.filter { $0.id == lessonSelected.Number }
        
        var newData: [QLModel] = []
        newData.append(
            QLModel(
                id: data[0].id + 100000,
                Intro: data[0].Intro,
                IntroText: data[0].IntroText,
                Vocabularies: data[0].Vocabularies,
                VocabulariesText: data[0].VocabulariesText,
                Examples: data[0].Examples,
                ExamplesText: data[0].ExamplesText,
                Type: "Intro"
            )
        )
        
        var wordsIndex = 1
        var headerTitleIndex = 1
        var sectionIndex = 0
        var index = 1000
        
        for header in qlHeaders.filter({ $0.QLID == lessonSelected.Number }) {
            
            var emptyHeader = false
            if (header.Title.trim() == "") {
                emptyHeader = true
            }
            
            if (header.StartOver) {
                headerTitleIndex = 1
            }
            
            newData.append(
                QLModel(
                    id: index,
                    headerID: index,
                    headerTitleIndex: headerTitleIndex,
                    IntroText: header.Title,
                    Type: "Header",
                    EmptyHeader: emptyHeader,
                    StartOver: header.StartOver,
                    StartOverTitle: header.IntroText
                )
            )
            
            
            if (header.Title.trim() != "") {
                headerTitleIndex+=1
            }
               
            for section in (qlSections.filter { section in section.HeaderID == header.id }) {
                
                newData.append(
                    QLModel(
                        id: section.id,
                        headerID: index,
                        IntroText: section.Title,
                        Type: "Section",
                        EmptyHeader: emptyHeader,
                        sectionIndex: sectionIndex
                    )
                )
                
                let words = qlWords.filter { word in word.SectionID == section.id }
                var wordsHeader = false
                var wordIndex = 0
                words.forEach { word in
                    
                    if (!wordsHeader) {
                        
                        newData.append(
                            QLModel(
                                id: word.id + 20000,
                                headerID: index,
                                sectionID: section.id,
                                Type: "WordHeader",
                                EmptyHeader: emptyHeader,
                                sectionIndex: sectionIndex
                            )
                        )
                        
                        wordsHeader = true
                    }
                    
                    let wordModel = QLModel(
                        id: word.id + 2001,
                        headerID: index,
                        sectionID: section.id,
                        IntroText: word.Word,
                        Type: "Word",
                        lastWord: (wordIndex == words.count - 1),
                        WordIndex: wordsIndex,
                        Word2: word.Word2,
                        Meaning: word.Meaning,
                        Meaning2: word.Meaning2,
                        EmptyHeader: emptyHeader,
                        sectionIndex: sectionIndex
                    )
                    wordsIndex+=1
                    
                    if (bodyCondition2(item: QLModel(sectionID: section.id))) {
                        wordModel.Meaning2Index = wordsIndex
                        wordsIndex+=1
                    }
                    
                    if (bodyCondition3(item: QLModel(sectionID: section.id), mvm: mvm)) {
                        wordModel.Word2Index = wordsIndex
                        wordsIndex+=1
                    }
                    
                    newData.append(wordModel)
                    
                    wordIndex+=1
                }
                
                if (lessonSelected.Number == 15 || lessonSelected.Number == 30 || lessonSelected.Number == 33) {
                    
                    var words15 = ql15.filter { $0.id == -1 }
                    if (section.id == 162) {
                        words15 = ql15.filter { $0.id <= 8 }
                    } else if (section.id == 166) {
                        words15 = ql15.filter { (9...10) ~= $0.id }
                    } else if (section.id == 168) {
                        words15 = ql15.filter { (11...12) ~= $0.id }
                    } else if (section.id == 172) {
                        words15 = ql15.filter { $0.id == 13 }
                    } else if (section.id == 358) {
                        words15 = ql30
                    } else if (section.id == 372) {
                        words15 = ql33.filter { $0.id <= 9 }
                    } else if (section.id == 376) {
                        words15 = ql33.filter { (10...11) ~= $0.id }
                    } else if (section.id == 378) {
                        words15 = ql33.filter { (12...15) ~= $0.id }
                    }
                    
                    wordsHeader = false
                    wordIndex = 0
                    words15.forEach { word in
                        
                        if (!wordsHeader) {
                            
                            newData.append(
                                QLModel(
                                    id: word.id + 30000,
                                    headerID: index,
                                    sectionID: section.id,
                                    Type: "WordHeader",
                                    EmptyHeader: emptyHeader,
                                    sectionIndex: sectionIndex
                                )
                            )
                            
                            wordsHeader = true
                        }
                        
                        let wordModel = QLModel(
                            id: word.id + 3001,
                            headerID: index,
                            sectionID: section.id,
                            Type: "Word",
                            lastWord: (wordIndex == words15.count - 1),                            
                            Word1: word.Word1,
                            Word2: word.Word2,
                            Word3: word.Word3,
                            Word4: word.Word4,
                            Word5: word.Word5,
                            Word6: word.Word6,
                            EmptyHeader: emptyHeader,
                            sectionIndex: sectionIndex
                        )
                        
                        if (word.Word1.trim() != "" && word15Check(word: word.Word1)) {
                            wordModel.WordIndex = wordsIndex
                            wordsIndex+=1
                        }
                        if (word.Word2.trim() != "" && word15Check(word: word.Word2)) {
                            wordModel.Word2Index = wordsIndex
                            wordsIndex+=1
                        }
                        if (word.Word3.trim() != "" && word15Check(word: word.Word3)) {
                            wordModel.Word3Index = wordsIndex
                            wordsIndex+=1
                        }
                        if (word.Word4.trim() != "" && word15Check(word: word.Word4)) {
                            wordModel.Word4Index = wordsIndex
                            wordsIndex+=1
                        }
                        if (word.Word5.trim() != "" && word15Check(word: word.Word5)) {
                            wordModel.Word5Index = wordsIndex
                            wordsIndex+=1
                        }
                        if (word.Word6.trim() != "" && word15Check(word: word.Word6)) {
                            wordModel.Word6Index = wordsIndex
                            wordsIndex+=1
                        }
                        
                        newData.append(wordModel)
                        
                        wordIndex+=1
                    }
                }
                
                sectionIndex+=1
            }
            
            index+=1
        }
        
        newData.append(
            QLModel(
                id: 10000,
                Intro: data[0].Vocabularies,
                IntroText: data[0].VocabulariesText,
                Type: "Voc"
            )
        )
        
        newData.append(
            QLModel(
                id: 10001,
                Intro: data[0].Examples,
                IntroText: data[0].ExamplesText,
                Type: "Examples"
            )
        )
        
        qlItems = newData
    }
    
    func loadQLVocItems(mvm: MainViewModel) {
        
        qlVocItems.removeAll()
        
        qlVocItems = qlVoc.filter { $0.QLID == mvm.lessonSelected.Number.description }
        
        var wordsIndex = 1
        var section2 = false
        qlVocItems.forEach { it in
            
            if (qlVocCondition(item: it) && !section2) {
                wordsIndex = 1
                section2 = true
            }
            
            if (it.Singular.trim() != "") {
                it.WordIndex1 = wordsIndex
                wordsIndex+=1
            }
            
            if (it.Plural.trim() != "") {
                it.WordIndex2 = wordsIndex
                wordsIndex+=1
            }
            
            if (it.Meaning2.trim() != "") {
                it.WordIndex3 = wordsIndex
                wordsIndex+=1
            }
            
            
        }
    }
    
    func loadQLExItems(mvm: MainViewModel) {
        
        qlExItems.removeAll()
        
        qlExItems = qlEx.filter { $0.QLID == mvm.lessonSelected.Number.description }
    }
    
    func loadDownloadItems() {
        
        downloadItems.removeAll()
        
        recitersList(download: true, mvm: self).forEach { it in
            
            downloadItems.append(DownloadModel(id: it.0, Name: it.1))
        }
    }
    
    func deleteFiles(reciter: String) {

        Task {
            
            var reciterID = reciter
            if (reciter == "WordByWord") {
                reciterID = "w"
            }
            
            var root = "recitation"
            if (reciter == "English" || reciter == "Swahili" || reciter == "French" || reciter == "Portuguese" || reciter == "Spanish" || reciter == "Russian" || reciter == "German" || reciter == "Hindi" || reciter == "Chinese" || reciter == "Urdu" || reciter == "Bahasa" || reciter == "Bangla" || reciter == "Hausa" || reciter == "Turkish") {
                root = "translation"
            }
            
            let documentsURL = try FileManager
                .default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("/\(root)/\(reciterID)")
            
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL,
                                                                           includingPropertiesForKeys: nil,
                                                                           options: .skipsHiddenFiles)
                for fileURL in fileURLs where fileURL.pathExtension == "mp3" {
                    try FileManager.default.removeItem(at: fileURL)
                }
            } catch  { print(error) }
        }
    }
    
    func stage1(listData: [ListModel]) -> [ListModel] {
        
        let stageTabsData = stageTabs
        
        var newListData: [ListModel] = []
        
        var tabIndex = 100
        for i in 0...(listData.count - 1) {
            
            let row = listData[i]
            
            if (row.Sort == 1 || row.Sort == 5 || row.Sort == 8 || row.Sort == 11 || row.Sort == 15) {
                
                tabIndex += 1
                
                let tab = row.copy()
                
                tab.id = tabIndex
                tab.isTab = true
                tab.TabIndex = tabIndex.description
                tab.TabVisible = false
                if (row.Sort == 1) {
                    tab.TabVisible = true
                }
                tab.Title = stageTabsData[0].Letters
                if (row.Sort == 5) {
                    tab.Title = stageTabsData[0].Harakat
                }
                if (row.Sort == 8) {
                    tab.Title = stageTabsData[0].Vowels
                }
                if (row.Sort == 11) {
                    tab.Title = stageTabsData[0].Sukoon
                }
                if (row.Sort == 15) {
                    tab.Title = stageTabsData[0].Muqatta
                }
                
                newListData.append(tab)
            }
            
            if (tabIndex > 101) {
                row.TabVisible = false
            }
            
            row.TabIndex = tabIndex.description
            newListData.append(row)
        }
        
        return newListData
    }
    
    func stage3(listData: [ListModel]) -> [ListModel] {
        
        let stageTabsData = stageTabs
        
        var newListData: [ListModel] = []
        
        var tabIndex = 100;
        
        for i in 0...(listData.count - 1) {
            
            let row = listData[i]
            
            if (row.Sort == 1 || row.Sort == 7 || row.Sort == 10 || row.Sort == 12 || row.Sort == 16 || row.Sort == 26) {
                
                tabIndex += 1
                let tab = row.copy()
                tab.id = tabIndex
                tab.isTab = true
                tab.TabIndex = tabIndex.description
                tab.TabVisible = false
                if (row.Sort == 1) {
                    tab.TabVisible = true
                }
                
                tab.Title = stageTabsData[0].Noon
                if (row.Sort == 7) {
                    tab.Title = stageTabsData[0].Meem
                }
                if (row.Sort == 10) {
                    tab.Title = stageTabsData[0].Laam
                }
                if (row.Sort == 12) {
                    tab.Title = stageTabsData[0].Qalqalah
                }
                if (row.Sort == 16) {
                    tab.Title = stageTabsData[0].Madd
                }
                if (row.Sort == 26) {
                    tab.Title = stageTabsData[0].Signs
                }
                
                newListData.append(tab)
            }
            
            if (tabIndex > 101) {
                row.TabVisible = false
            }
            
            row.TabIndex = tabIndex.description
            newListData.append(row)
        }
        
        return newListData
    }
    
    func stage4(listData: [ListModel]) -> [ListModel] {
        
        var newListData: [ListModel] = []
        
        var tabIndex = 100;
        
        for i in 0...(listData.count - 1) {
            
            let row = listData[i]
            
            if (row.Sort == 1 || row.Sort == 6 || row.Sort == 11 || row.Sort == 16 || row.Sort == 21 || row.Sort == 26 || row.Sort == 31 || row.Sort == 36) {
                
                tabIndex += 1
                let tab = row.copy()
                tab.id = tabIndex
                tab.isTab = true
                tab.TabIndex = tabIndex.description
                tab.TabVisible = false
                if (row.Sort == 1) {
                    tab.TabVisible = true
                }
                
                tab.Title = "Stage \((tabIndex - 100).description)"
                
                newListData.append(tab)
            }
            
            if (tabIndex > 101) {
                row.TabVisible = false
            }
            
            row.TabIndex = tabIndex.description
            newListData.append(row)
        }
        
        return newListData
    }
    
    func lesson2(listData: [LessonModel]) -> [LessonModel] {

        var newListData: [LessonModel] = []

        var newIDs = 100
        
        listData.forEach { row in

            row.section = true
            row.sectionID = row.id.description
            row.letterPosition = 1
            newListData.append(row)

            // letter 1
            let letter1: LessonModel = row.copy()

            if (row.id != 1 && row.id != 8 && row.id != 9 && row.id != 10 && row.id != 11 && row.id != 26 && row.id != 28) {
                letter1.Letter = letter1.Letter + "ـ"
            }

            if (row.id == 28) {

                letter1.LetterFragment1 = "أ"
                letter1._TopFr1 = "15"
                letter1.LetterFragment2 = "إ"
                letter1._TopFr2 = "-5"

                letter1.LetterFragments = true
            }

            if (row.id == 29) {
                letter1.Letter = "يـ"
            }

            newIDs += 1
            letter1.id = newIDs
            letter1.section = false
            letter1.sectionID = row.id.description
            letter1.letterPosition = 2
            
            if (getLanguage() == "Ar") {
                letter1.Trans = "البداية"
            }
            else if (getLanguage() == "Swa") {
                letter1.Trans = "Mwanzo";
            }
            else if (getLanguage() == "Fr") {
                letter1.Trans = "Début";
            }
            else if (getLanguage() == "Pt") {
                letter1.Trans = "Início";
            }
            else if (getLanguage() == "Es") {
                letter1.Trans = "Comienzo";
            }
            else if (getLanguage() == "Ru") {
                letter1.Trans = "начало";
            }
            else if (getLanguage() == "De") {
                letter1.Trans = "Anfang";
            }
            else if (getLanguage() == "Hi") {
                letter1.Trans = "शुरुआत";
            }
            else if (getLanguage() == "Zh") {
                letter1.Trans = "开始";
            }
            else if (getLanguage() == "Ur") {
                letter1.Trans = "آغاز";
            }
            else if (getLanguage() == "Ind") {
                letter1.Trans = "Awal";
            }
            else if (getLanguage() == "Bn") {
                letter1.Trans = "শুরু";
            }
            else if (getLanguage() == "Ha") {
                letter1.Trans = "Farko";
            }
            else if (getLanguage() == "Tr") {
                letter1.Trans = "Başlangıç";
            }
            else {
                letter1.Trans = "Beginning"
            }
            
            newListData.append(letter1)

            // letter 2
            let letter2: LessonModel = letter1.copy()

            letter2.Letter = "ـ" + letter2.Letter

            if (row.id == 28) {

                letter2.LetterFragment1 = "ـأ"
                letter2._TopFr1 = "15"
                letter2.LetterFragment2 = "ؤ"
                letter2._TopFr2 = "-15"
              letter2.LetterFragment3 = "ـئـ"
                letter2._TopFr3 = "-15"

                letter2.LetterFragments = true
            }

            newIDs += 1
            letter2.id = newIDs
            letter2.section = false
            letter2.sectionID = row.id.description
            letter2.letterPosition = 3
            
            if (getLanguage() == "Ar") {
                letter2.Trans = "الوسط";
            }
            else if (getLanguage() == "Swa") {
                letter2.Trans = "Katikati";
            }
            else if (getLanguage() == "Fr") {
                letter2.Trans = "Milieu";
            }
            else if (getLanguage() == "Pt") {
                letter2.Trans = "Meio";
            }
            else if (getLanguage() == "Es") {
                letter2.Trans = "Medio";
            }
            else if (getLanguage() == "Ru") {
                letter2.Trans = "Середина";
            }
            else if (getLanguage() == "De") {
                letter2.Trans = "Mitte";
            }
            else if (getLanguage() == "Hi") {
                letter2.Trans = "मध्य";
            }
            else if (getLanguage() == "Zh") {
                letter2.Trans = "中间";
            }
            else if (getLanguage() == "Ur") {
                letter2.Trans = "درمیانی";
            }
            else if (getLanguage() == "Ind") {
                letter2.Trans = "Tengah";
            }
            else if (getLanguage() == "Bn") {
                letter2.Trans = "মাঝখানে";
            }
            else if (getLanguage() == "Ha") {
                letter2.Trans = "Tsakiya";
            }
            else if (getLanguage() == "Tr") {
                letter2.Trans = "Orta";
            }
            else {
                letter2.Trans = "Middle"
            }
            
            newListData.append(letter2)

            // letter 3
            let letter3: LessonModel = row.copy()

            letter3.Letter = "ـ" + letter3.Letter

            if (row.id == 3) {

                letter3.LetterFragment1 = "ـت"
                letter3._TopFr1 = "-10"
                letter3.LetterFragment2 = "ة"
                letter3._TopFr2 = "-10"
                letter3.LetterFragment3 = "ـة"
                letter3._TopFr3 = "-5"

                letter3.LetterFragments = true
            }

            if (row.id == 28) {

                letter3.LetterFragment1 = "أ"
                letter3._TopFr1 = "15"
                letter3.LetterFragment2 = "ء"
                letter3._TopFr2 = "-15"
                letter3.LetterFragment3 = "ئ"
                letter3._TopFr3 = "-15"

                letter3.LetterFragments = true
            }

            newIDs += 1
            letter3.id = newIDs
            letter3.section = false
            letter3.sectionID = row.id.description
            letter3.letterPosition = 4
            
            if (getLanguage() == "Ar") {
                letter3.Trans = "النهاية";
            }
            else if (getLanguage() == "Swa") {
                letter3.Trans = "Mwisho";
            }
            else if (getLanguage() == "Fr") {
                letter3.Trans = "Fin";
            }
            else if (getLanguage() == "Pt") {
                letter3.Trans = "Final";
            }
            else if (getLanguage() == "Es") {
                letter3.Trans = "Final";
            }
            else if (getLanguage() == "Ru") {
                letter3.Trans = "Конец";
            }
            else if (getLanguage() == "De") {
                letter3.Trans = "Ende";
            }
            else if (getLanguage() == "Hi") {
                letter3.Trans = "अंत";
            }
            else if (getLanguage() == "Zh") {
                letter3.Trans = "结尾";
            }
            else if (getLanguage() == "Ur") {
                letter3.Trans = "ختم";
            }
            else if (getLanguage() == "Ind") {
                letter3.Trans = "Akhir";
            }
            else if (getLanguage() == "Bn") {
                letter3.Trans = "শেষ";
            }
            else if (getLanguage() == "Ha") {
                letter3.Trans = "Ƙarshe";
            }
            else if (getLanguage() == "Tr") {
                letter3.Trans = "Son";
            }
            else {
                letter3.Trans = "End"
            }
            
            newListData.append(letter3)

            // letter separator
            /*let letterSep: LessonModel = row.copy()
            newIDs += 1
            letterSep.id = newIDs
            letterSep.separator = true
            newListData.append(letterSep)*/
        }

        return newListData
    }
    
    func lesson4(listData: [LessonModel], lessonNumber: Int) -> [LessonModel] {

        var newListData: [LessonModel] = []

        var audioID = 1;
        if (lessonNumber == 17) {
            audioID = 88;
        }

        var newIDs = 100

        listData.forEach { row in

            row.section = true
            row.sectionID = row.id.description
            row.letterPosition = 1
            row.audioLesson = "1"
            row.audioFile = row.id
            newListData.append(row)

            // letter 1
            let letter1: LessonModel = row.copy()

            newIDs += 1
            letter1.id = newIDs
            if (letter1._Top == "") {
                letter1._Top = "0"
            }
            letter1._Top = (Int(letter1._Top)! + 6).description
            letter1.section = false
            letter1.sectionID = row.id.description
            letter1.letterPosition = 2
            letter1.audioFile = firstLetter(audioID: audioID)
            audioID += 1

            if (lessonNumber == 17) {
                letter1.Letter = letter1.Letter + "ً"
                letter1.audioLesson = "4_"
                letter1.Trans = letter1.TransT1.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            else {
                letter1.Letter = letter1.Letter + "َ"
                letter1.audioLesson = "4"
                letter1.Trans = letter1.TransH1.trimmingCharacters(in: .whitespacesAndNewlines)
            }


            newListData.append(letter1)

            // letter 2
            let letter2: LessonModel = row.copy()

            newIDs += 1
            letter2.id = newIDs
            letter2.section = false
            letter2.sectionID = row.id.description
            letter2.letterPosition = 3
            letter2.audioFile = secondLetter(audioID: audioID)
            audioID += 1

            if (lessonNumber == 17) {
                letter2.Letter = letter2.Letter + "ٍ"
                letter2.audioLesson = "4_"
                letter2.Trans = letter2.TransT2.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            else {
                letter2.Letter = letter2.Letter + "ِ"
                letter2.audioLesson = "4"
                letter2.Trans = letter2.TransH2.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            newListData.append(letter2)

            // letter 3
            let letter3: LessonModel = row.copy()

            newIDs += 1
            letter3.id = newIDs
            if (letter1._Top == "") {
                letter3._Top = "0"
            }
            letter3._Top = (Int(letter3._Top)! + 10).description
            letter3.section = false
            letter3.sectionID = row.id.description
            letter3.letterPosition = 4
            letter3.audioFile = thirdLetter(audioID: audioID)
            audioID += 1

            if (lessonNumber == 17) {
                letter3.Letter = letter3.Letter + "ٌ"
                letter3.audioLesson = "4_"
                letter3.Trans = letter3.TransT3.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            else {
                letter3.Letter = letter3.Letter + "ُ"
                letter3.audioLesson = "4"
                letter3.Trans = letter3.TransH3.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            newListData.append(letter3)

            // letter separator
            //let letterSep: LessonModel = row.copy()
            //letterSep.separator = true
            //newListData.append(letterSep)
        }

        return newListData
    }
    
    func lesson6(listData: [LessonModel]) -> [LessonModel] {

        var newListData: [LessonModel] = []

        var i = 1
        listData.forEach { row in

            if (i == 1) {
                row.vowel1 = true
                row.vowel1Left = 30
                row.vowel1Top = 20
            }
            else if (i == 2) {
                row.vowel1 = true
                row.vowel1Left = 40
                row.vowel1Top = 10
            }
            else if (i == 3) {
                row._Top = "-30"
                row.vowel1 = true
                row.vowel1Left = 30
                row.vowel1Top = 20
            }
            else if (i == 4) {
                row.vowel1 = true
                row.vowel1Left = 50
                row.vowel1Top = 20
            }
            else if (i == 5) {
                row._Top = "0"
                row.vowel1 = true
                row.vowel1Left = 30
                row.vowel1Top = 20
            }
            else if (i == 6) {
                row._Top = "-20"
                row.vowel1 = true
                row.vowel1Left = 20
                row.vowel1Top = 20
            }
            else if (i == 7) {
                row.vowel1 = true
                row.vowel1Left = 30
                row.vowel1Top = 20
            }
            else if (i == 8) {
                row.vowel1 = true
                row.vowel1Left = 40
                row.vowel1Top = 20
            }
            else if (i == 9) {
                row.vowel1 = true
                row.vowel1Left = 70
                row.vowel1Top = 20
            }
            else if (i == 10) {
                row._Top = "-20"
                row.vowel1 = true
                row.vowel1Left = 50
                row.vowel1Top = 0
            }
            else if (i == 11) {
                row._Top = "-30"
                row.vowel1 = true
                row.vowel1Left = 40
                row.vowel1Top = 10
            }
            else if (i == 12) {
                row._Top = "-20"
                row.vowel1 = true
                row.vowel1Left = 50
                row.vowel1Top = 0
            }
            else if (i == 13) {
                row._Top = "-20"
                row.vowel1 = true
                row.vowel1Left = 40
                row.vowel1Top = 10
            }
            else if (i == 14) {
                row._Top = "0"
                row.vowel1 = true
                row.vowel1Left = 35
                row.vowel1Top = 10
            }
            else if (i == 15) {
                row._Top = "0"
                row.vowel1 = true
                row.vowel1Left = 35
                row.vowel1Top = 10
            }
            else if (i == 16) {
                row._Top = "-30"
                row.vowel1 = true
                row.vowel1Left = 40
                row.vowel1Top = 10
            }
            else if (i == 17) {
                row._Top = "0"
                row.vowel1 = true
                row.vowel1Left = 30
                row.vowel1Top = 20
            }
            else if (i == 18) {
                row._Top = "0"
                row.vowel1 = true
                row.vowel1Left = 30
                row.vowel1Top = 20
            }
            else if (i == 19) {
                row._Top = "-10"
                row.vowel1 = true
                row.vowel1Left = 20
                row.vowel1Top = 20
            }
            else if (i == 20) {
                row._Top = "-20"
                row.vowel1 = true
                row.vowel1Left = 50
                row.vowel1Top = 30
            }
            else if (i == 21) {
                row._Top = "-20"
                row.vowel1 = true
                row.vowel1Left = 50
                row.vowel1Top = 10
            }
            else if (i == 22) {
                row._Top = "-20"
                row.vowel1 = true
                row.vowel1Left = 60
                row.vowel1Top = 40
            }
            else if (i == 23) {
                row._Top = "-20"
                row.vowel1 = true
                row.vowel1Left = 60
                row.vowel1Top = 40
            }
            else if (i == 24) {
                row._Top = "10"
                row.vowel1 = true
                row.vowel1Left = 40
                row.vowel1Top = 20
            }
            else if (i == 25) {
                row._Top = "10"
                row.vowel1 = true
                row.vowel1Left = 40
                row.vowel1Top = 20
            }
            else if (i == 26) {
                row._Top = "10"
                row.vowel1 = true
                row.vowel1Left = 40
                row.vowel1Top = 20
            }
            else if (i == 27) {
                row._Top = "10"
                row.vowel1 = true
                row.vowel1Left = 25
                row.vowel1Top = 10
            }
            else if (i == 28) {
                row._Top = "10"
                row.vowel1 = true
                row.vowel1Left = 40
                row.vowel1Top = 20
            }
            else if (i == 29) {
                row._Top = "-30"
                row.vowel2 = true
                row.vowel2Left = 50
                row.vowel2Top = 90
            }
            else if (i == 30) {
                row._Top = "-30"
                row.vowel2 = true
                row.vowel2Left = 60
                row.vowel2Top = 90
            }
            else if (i == 31) {
                row._Top = "0"
                row.vowel3 = true
                row.vowel3Left = 60
                row.vowel3Top = 120
            }
            else if (i == 32) {
                row.vowel3 = true
                row.vowel3Left = 40
                row.vowel3Top = 90
            }
            else if (i == 33) {
                row.vowel3 = true
                row.vowel3Left = 50
                row.vowel3Top = 90
            }

            newListData.append(row)
            i += 1
        }

        return newListData
    }
    
    func lesson8(listData: [LessonModel], lesson: ListModel) -> [LessonModel] {

        var newListData: [LessonModel] = []

        var i = 1
        listData.forEach { row in

            if (i == 85) {

                // letter separator
                let letterSep: LessonModel = row.copy()
                
                letterSep.section = true
                letterSep.sectionID = "2"
                letterSep.id = letterSep.id + 400
                letterSep.separator = true
                letterSep.title1 = lesson.Title1.description
                newListData.append(letterSep)
            }
                
            if (i == 1) {
                row.section = true
                row.sectionID = "1"
            }
            if (i > 1 && i <= 84) {
                row.section = false
                row.sectionID = "1"
            }
            if (i == 85) {
                row.section = true
                row.sectionID = "3"
            }
            if (i > 85) {
                row.section = false
                row.sectionID = "3"
            }
                
            newListData.append(row)
            
            i += 1
        }

        return newListData
    }
    
    func lesson9(listData: [LessonModel]) -> [LessonModel] {

        var newListData: [LessonModel] = []

        var id = 1
        listData.forEach { row in

            if (id == 2) {
                row.Letter = "ءَاوَىٰ"
            }

            if (id == 4) {
                row.Letter = " إِۦلَـٰفِ"
            }

            if (id == 6) {
                row.Letter = "بِهِۦ"
            }

            if (id == 8) {
                row.Letter = "جِا۟ىٓءَ"
            }

            if (id == 12) {
                row.Letter = "دَاوُۥدُ"
            }

            if (id == 13) {
                row.Letter = "ذَٰلِكَ"
            }

            if (id == 16) {
                row.Letter = "مَـٰلِكِ"
            }

            if (id == 18) {
                row.Letter = "طَغَىٰ"
            }

            if (id == 22) {
                row.Letter = "عَلَىٰ"
            }

            if (id == 37) {
                row.Letter = "يَرَهُۥٓ"
            }

            if (id == 52) {
                row.Letter = "تُرَٰبًا"
            }

            if (id == 56) {
                row.Letter = "سَلَـٰمٌ"
            }

            if (id == 64) {
                row.Letter = "كِتَـٰبًا"
            }

            if (id == 68) {
                row.Letter = "مَـَٔابًا"
            }

            if (id == 69) {
                row.Letter = "مَّتَـٰعًا"
            }

            if (id == 73) {
                row.Letter = "مِهَـٰدًا"
            }

            if (id == 98) {
                row.Letter = "الْمَوْءُۥدَةُ"
            }

            if (id == 100) {
                row.Letter = "مَوَٰزِينُهُۥ"
            }

            newListData.append(row)
            id += 1
        }

        return newListData
    }
            
    func lesson10(listData: [LessonModel], lesson: ListModel) -> [LessonModel] {

        var newListData: [LessonModel] = []

        var i = 1
        listData.forEach { row in

            if (i == 49) {

                // letter separator
                let letterSep: LessonModel = row.copy()
                
                letterSep.section = true
                letterSep.sectionID = "2"
                letterSep.id = letterSep.id + 400
                letterSep.separator = true
                letterSep.title1 = lesson.Title1.description
                newListData.append(letterSep)
            }
            
            if (i == 1) {
                row.section = true
                row.sectionID = "1"
            }
            if (i > 1 && i <= 48) {
                row.section = false
                row.sectionID = "1"
            }
            if (i == 49) {
                row.section = true
                row.sectionID = "3"
            }
            if (i > 49) {
                row.section = false
                row.sectionID = "3"
            }

            newListData.append(row)
            i += 1
        }

        return newListData
    }

    func lesson12(listData: [LessonModel]) -> [LessonModel] {

        var newListData: [LessonModel] = []

        var i = 1
        listData.forEach { row in

            if (i == 1) {

                row.Letter = "يَزَّكَّىٰ"
            }

            if (i == 9) {

                row.Letter = "مِن شَرِّ النَّفَّـٰثَـٰتِ"
            }

            newListData.append(row)
            i += 1
        }

        return newListData
    }
    
    func lesson13(listData: [LessonModel]) -> [LessonModel] {

        var newListData: [LessonModel] = []

        var i = 1
        listData.forEach { row in

            if (i == 2) {
                row.Letter = "دَآبـَّةٍ"
            }

            if (i == 7) {

                row.Letter = "أَتُحَـٰٓجُّوٓنِّى"
            }

            if (i == 8) {

                row.Letter = "وَلَا تَحَـٰٓضُّونَ"
            }

            if (i == 9) {

                row.Letter = "وَالصَّـٰٓفَّـٰتِ"
            }

            if (i == 11) {

                row.Letter = row.Letter.replacingOccurrences(of: "ى", with: "ىٰ")
            }

            row.Letter = row.Letter
                .replacingOccurrences(of: "<span class=\"letter-1 madda\">~</span>", with: "")
                .replacingOccurrences(of: "<span class=\"letter-1\">ـو</span>", with: "ـو")
                .replacingOccurrences(of: "<span class=\"letter-1 madda\">آ</span>", with: "")
                .replacingOccurrences(of: "<span class=\"letter-1\">ـآ</span>", with: "ـآ")

            newListData.append(row)
            i += 1
        }

        return newListData
    }
    
    func lesson15(listData: [LessonModel]) -> [LessonModel] {

        var newListData: [LessonModel] = []

        var i = 1
        listData.forEach { row in

            if (i == 1) {

                row.vowel2 = true
                row.vowel2Left = 30
                row.vowel2Top = 30

                row.vowel3 = true
                row.vowel3Left = -10
                row.vowel3Top = 40
            }

            if (i == 2) {

                row.vowel4 = true
                row.vowel4Left = 50
                row.vowel4Top = 70

                row.vowel2 = true
                row.vowel2Left = -20
                row.vowel2Top = 20

                row.vowel3 = true
                row.vowel3Left = -40
                row.vowel3Top = 40
            }

            if (i == 3) {

                row.vowel2 = true
                row.vowel2Left = 0
                row.vowel2Top = -10
            }

            if (i == 4) {

                row.vowel3 = true
                row.vowel3Left = 16
                row.vowel3Top = 70

                row.vowel2 = true
                row.vowel2Left = -10
                row.vowel2Top = -10
            }

            if (i == 5) {

                row.vowel4 = true
                row.vowel4Left = 80
                row.vowel4Top = 70

                row.vowel2 = true
                row.vowel2Left = 20
                row.vowel2Top = 20

                row.vowel3 = true
                row.vowel3Left = -65
                row.vowel3Top = 40
            }

            if (i == 7) {

                row.vowel2 = true
                row.vowel2Left = 5
                row.vowel2Top = 20

                row.vowel3 = true
                row.vowel3Left = 55
                row.vowel3Top = 70
            }

            if (i == 8) {

                row.vowel2 = true
                row.vowel2Left = 20
                row.vowel2Top = 20
            }

            if (i == 9) {

                row.vowel2 = true
                row.vowel2Left = 10
                row.vowel2Top = 20
            }

            if (i == 10) {

                row.vowel2 = true
                row.vowel2Left = 10
                row.vowel2Top = 20
            }

            if (i == 11) {

                row.vowel2 = true
                row.vowel2Left = 40
                row.vowel2Top = 20
            }

            if (i == 12) {

                row.vowel5 = true
                row.vowel5Left = -40
                row.vowel5Top = 70

                row.vowel2 = true
                row.vowel2Left = 20
                row.vowel2Top = 5

                row.vowel3 = true
                row.vowel3Left = 60
                row.vowel3Top = 55

                row.vowel4 = true
                row.vowel4Left = 100
                row.vowel4Top = 55
            }

            if (i == 13) {

                row.vowel2 = true
                row.vowel2Left = 10
                row.vowel2Top = 0
            }

            if (i == 14) {

                row.vowel2 = true
                row.vowel2Left = 10
                row.vowel2Top = 10
            }

            newListData.append(row)
            i += 1
        }

        return newListData
    }
    
    func lesson16(listData: [LessonModel]) -> [LessonModel] {

        var newListData: [LessonModel] = []

        var i = 1
        listData.forEach { row in

            if (i == 2) {

                row.Letter = "ٱلْمَلَـٰٓئِكَةُ"
            }

            if (i == 3) {

                row.Letter = " إِنَّـآ أَعْطَيْنَـٰكَ"
            }

            if (i == 5) {

                row.Letter = "خَيْرًا يَرَهُۥ"
            }

            if (i == 6) {

                row.Letter = "شَرًّا يَرَهُۥ"
            }

            if (i == 7) {

                row.Letter = "مِيقَـٰتًا  يَوْمَ"
            }

            if (i == 14) {

                row.Letter = row.Letter.replacingOccurrences(of: "أَبْصَرُهَا", with: "أَبْصَـٰرُهَا")
            }

            newListData.append(row)
            i += 1
        }

        return newListData
    }
}

func word15Check(word: String) -> Bool {

    return word.trim() != "1" &&
            word.trim() != "2" &&
            word.trim() != "3" &&
            word.trim() != "4" &&
            word.trim() != "5" &&
            word.trim() != "6" &&
            word.trim() != "7" &&
            word.trim() != "8" &&
            word.trim() != "9" &&
            word.trim() != "10"
}
