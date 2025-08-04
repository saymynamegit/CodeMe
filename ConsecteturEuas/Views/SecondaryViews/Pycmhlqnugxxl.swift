import SwiftUI
import CoreData

struct Mpfi: View {
   
    @Binding var isPresented: Bool
    let nywdcsziuc = UIImpactFeedbackGenerator(style: .medium)
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var clearAllImageIsPressed: Bool
   
    var body: some View {
        ZStack {
  
            VStack(spacing: 16) {
                
                VStack(spacing: 8) {
                Text("Are you sure you want to\nclear your history?")
                    .xmjsmo(.rmlcgfpiqbli(color: Color.trznvuo))
                    .multilineTextAlignment(.center)

                Text("This will permanently delete all saved\ndata and cannot be undone.")
                        .xmjsmo(.ioibd(color: Color.seyoqnymjbswa))
                    .multilineTextAlignment(.center)
                }
                VStack(spacing: 12) {
                    Button(action: {
                        PersistentController.shared.deleteAll()
                        _ = ImageFileManager.shared.deleteAllImages()
                        nywdcsziuc.impactOccurred()
                        
                        do {
                            try viewContext.save()
                        } catch {
                            // Handle the error properly, e.g. log or show alert
                            print("Failed to save viewContext: \(error)")
                        }
            
                        clearAllImageIsPressed = true
                        isPresented = false
                    }) {
                        Text("Clear")
                            .xmjsmo(.qimvxhrkcaz(color: Color.trznvuo))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                Color.ojeehc
                            )
                            .cornerRadius(12)
                            .gkdw(color: Color.bjfbafoi, radius: 4, x: 0, y: 2)
                    }


                    Button(action: {
                        nywdcsziuc.impactOccurred()
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .xmjsmo(.qimvxhrkcaz(color: Color.trznvuo))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.itlbv)
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
            .background(Color.zwtjfhoowdynuq)
            .cornerRadius(20)
            .frame(width: 342)
        }
        .onAppear {
            nywdcsziuc.prepare()
        }
        .animation(.easeInOut, value: isPresented)
    }
}
