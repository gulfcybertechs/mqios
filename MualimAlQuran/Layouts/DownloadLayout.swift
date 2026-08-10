import SwiftUI
import SwiftSoup

struct DownloadLayout: View {
    
    @EnvironmentObject var mvm: MainViewModel
    @Environment(\.dismiss) private var dismiss
    @State var clearAllAlert = false
    
    var audioHelper: AudioHelper = AudioHelper(player: .constant(Player()))
    @State var safeArea = UIApplication.shared.firstKeyWindow?.safeAreaInsets
    @AppStorage("language") var currentLanguage = getLanguage()
    
    var body: some View {
        
        ZStack {
            
            AppBG()
            
            ScrollViewReader { scrollView in
                
                ScrollView {
                    
                    VStack(spacing: 0) {
                        
                        //region Header
                        Spacer().frame(height: 40)
                        
                        Text(mvm.pageSelected.Title)
                            .font(.custom("opensans", size: 26))
                            .fontWeight(.medium)
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 5)
                        
                        Rectangle()
                            .fill(colorResource.maroon)
                            .frame(height: 1)
                            .padding(.bottom, 5)
                        
                        Spacer().frame(height: 10)
                        //endregion
                           
                        HStack(spacing: 0) {
                            
                            Button(action: {
                                
                                for it in recitersList(download: true, mvm: mvm) {
                                    
                                    if (!mvm.downloadingItems.contains(where: { $0.id == it.0 })) {
                                        
                                        mvm.downloadingItems.insert(DownloadModel(id: it.0, Name: it.1), at: 0)
                                        
                                        Task(priority: .background) {
                                            do {
                                                try await startDownload(reciter: DownloadModel(id: it.0, Name: it.1))
                                            } catch {
                                                print(error)
                                            }
                                        }
                                    }
                                }
                            }
                            ) {
                                Text((currentLanguage == "Ar") ? "تنزيل الكل" : "Download All")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(colorResource.primary_500)
                            
                            if (mvm.downloadingItems.count > 0) {
                                
                                Spacer()
                                
                                Button(action: { mvm.downloadingItems.removeAll() }) {
                                    
                                    Text((currentLanguage == "Ar") ? "إيقاف الكل" : "Stop All")
                                        .foregroundStyle(.black)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(colorResource.ee)
                                
                            } 
                            else {
                                
                                Spacer()
                                
                                Button(action: { clearAllAlert = true }) {
                                    
                                    Text((currentLanguage == "Ar") ? "حذف الكل" : "Clear All")
                                        .foregroundStyle(.white)
                                }                                
                                .buttonStyle(.borderedProminent)
                                .tint(colorResource.maroon)
                                .alert((currentLanguage == "Ar") ? "هل أنت متأكد من أنك تريد حذف جميع البيانات التي تم تنزيلها؟" : "Are you sure you want to clear all the downloaded files?", isPresented: $clearAllAlert) {
                                    Button((currentLanguage == "Ar") ? "حذف" : "Delete", role: .destructive) {
                                        
                                        for it in recitersList(download: true, mvm: mvm) {
                                            
                                            mvm.deleteFiles(reciter: it.0)
                                        }
                                    }
                                    Button((currentLanguage == "Ar") ? "إلغاء" : "Cancel", role: .cancel) { }
                                }
                            }
                        }
                        
                        if (mvm.downloadItems.isEmpty) {
                            
                            ProgressView()
                        }
                        else {
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 2000), spacing: 0, alignment: .leading)], spacing: 0) {
                                                                                                
                                ForEach($mvm.downloadItems) { item in
                                    
                                    DownloadItem(item: item, vm: .constant(self))
                                }
                            }
                        }
                    }
                }
                .padding(.top, (safeArea?.top ?? 0) + 1)
                .padding(.leading, safeArea?.left)
                .padding(.trailing, safeArea?.right)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.leading, 15)
        .padding(.trailing, 15)
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity)
        .clipped()
        .ignoresSafeArea(.all, edges: [.top, .leading, .trailing])
        .onAppear {
            
            if (mvm.downloadItems.isEmpty) {
                
                Task {
                    try! await Task.sleep(nanoseconds:300_000_000)
                    mvm.loadDownloadItems()
                }
            }
            
            audioHelper.prepareRecitationDir()
            
            mvm.viewLevel = "download"
            mvm.back = false
        }
        .task(id: mvm.back) {
            //mvm.downloadItems.removeAll()
            if (mvm.back) { mvm.back = false; dismiss(); }
        }
        .onRotate { newOrientation in
            
            Task {
                
                for _ in 1...5 {
                    
                    try await Task.sleep(nanoseconds: 100_000_000)
                    safeArea = UIApplication.shared.firstKeyWindow?.safeAreaInsets
                }
            }
        }
    }
    
    func startDownload(reciter: DownloadModel) async throws {
        
        let documentsURL = try FileManager.default.url(for: .documentDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: false)
                        
        for it in mvm.verseByVerse {
            
            if (mvm.downloadingItems.isEmpty) {
                break
            }
            
            if (mvm.downloadingItems.contains(where: { it in it.id == reciter.id })) {
                
                var selectedVerseAudioFileName = audioHelper.audioName(name: it.Surah) + "" + audioHelper.audioName(name: it.Ayah) + ".mp3"
                var root = "recitation"
                var reciterID = reciter.id
                
                if (reciter.id == "WordByWord") {
                    
                    reciterID = "w"
                    
                    for wordItem in it.Words {
                        
                        selectedVerseAudioFileName = audioHelper.audioName(name: it.Page) + "" + audioHelper.audioName(name: wordItem.Word) + ".mp3"
                        
                        let fileName = "/\(root)/\(reciterID)/\(selectedVerseAudioFileName)"
                        let url = URL(string: "https://mualim-alquran.com/\(root)/\(reciterID)/\(selectedVerseAudioFileName)")!
                        
                        if (!audioHelper.fileExist(name: fileName)) {
                            let (source, _) = try await URLSession.shared.download(from: url)
                            let destination = documentsURL.appendingPathComponent(fileName)
                            try FileManager.default.moveItem(at: source, to: destination)
                        }
                    }
                }
                else {
                    
                    if (reciter.id == "English" || reciter.id == "Swahili" || reciter.id == "French" || reciter.id == "Portuguese" || reciter.id == "Spanish" || reciter.id == "Russian" || reciter.id == "German" || reciter.id == "Hindi" || reciter.id == "Chinese" || reciter.id == "Urdu" || reciter.id == "Bahasa" || reciter.id == "Bangla" || reciter.id == "Hausa" || reciter.id == "Turkish") {
                        root = "translation"
                    }
                    
                    let fileName = "/\(root)/\(reciterID)/\(selectedVerseAudioFileName)"
                    let url = URL(string: "https://mualim-alquran.com/\(root)/\(reciterID)/\(selectedVerseAudioFileName)")!
                    
                    if (!audioHelper.fileExist(name: fileName)) {
                        let (source, _) = try await URLSession.shared.download(from: url)
                        let destination = documentsURL.appendingPathComponent(fileName)
                        try FileManager.default.moveItem(at: source, to: destination)
                    }
                }
            }
        }
    }
}
