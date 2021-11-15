//
//  ContentView.swift
//  caluculaterApp
//
//  Created by 高橋蓮 on 2021/11/15.
//

import SwiftUI

enum caluculateState {
    case initial, addition, substraction, division, multiplication, sum
}
struct ContentView: View {
    
    //電卓を打ったら文字が変わるようにする
    //@Stateはその関数が変化した場合に自動的に値を変換・更新するメゾット
    @State var selectedItem: String = "0"
    @State var caluculateState: caluculateState = .initial
    @State var caluculatedNumber: Double = 0
    private let caluculateItems: [[String]] = [
        ["AC", "+/-", "%", "÷"],
        ["7", "8", "9", "x"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "="],
    ]
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack {
                Spacer()
                
                HStack{
                    Spacer()
                    Text(selectedItem == "0" ? checkDecimal(number:caluculatedNumber) : selectedItem)
                        .font(.system(size: 70, weight: .light))
                        .foregroundColor(Color.white)
                        .padding()
                        .lineLimit(1)
                    //文字が全て画面に収まるように段々小さくするメゾット
                    //今回は最小＝0.4
                        .minimumScaleFactor(0.4)
                }
                
                VStack {
                    ForEach(caluculateItems, id: \.self) { items in
                        NumberView(selectedItem: $selectedItem,
                                   caluculateState: $caluculateState,
                                   caluculatedNumber: $caluculatedNumber,
                                   items: items)
                    }
                }
            }
            .padding(.bottom, 40)
        }
        
        
        
    }
    private func checkDecimal(number: Double) -> String {
        //小数点以下があるか
        if number.truncatingRemainder(dividingBy: 1).isLess(than: .ulpOfOne) {
            return String(Int(number))
        } else {
            return String(number)
        }
    }
    
    
    struct NumberView: View {
        
        //＠BindingはしたのViewに値を渡す
        @Binding var selectedItem: String
        @Binding var caluculateState: caluculateState
        @Binding var caluculatedNumber: Double


        var items: [String]
        //ボタンサイズ・間隔を設定（今回間隔は10 全部で５個のボタン）
        private let buttonWidth: CGFloat = (UIScreen.main.bounds.width - 50) / 4
        private let numbers: [String] = ["1", "2", "3","4", "5", "6","7", "8", "9", "0", "."]
        private let symbols: [String] = ["x", "+", "÷", "-", "="]
        var body: some View {
            HStack {
                ForEach(items, id: \.self) { item in
                    Button {
                        handleButtonInfo(item: item)
                    } label: {
                        Text(item)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .font(.system(size: 33, weight: .regular))
                    }
                    // A ||(or) B ?(だった場合) Aの処理 : Bの処理
                    .foregroundColor(numbers.contains(item) || symbols.contains(item) ? .white : .black)
                    .background(handlebuttoncolor(item: item))
                    .frame(width: item == "0" ? buttonWidth * 2 + 10 : buttonWidth)
                    .cornerRadius(buttonWidth)
                }
            }.frame(height: buttonWidth)
        }
        
        //ボタンの色を設定
        private func handlebuttoncolor(item: String) -> Color {
            if numbers.contains(item){
                return Color(white: 0.2, opacity: 1)
            } else if symbols.contains(item){
                return Color.orange
            } else{
                return Color(white: 0.6, opacity: 1)
            }
        }
        
        //ボタンのタップ時の処理を設定
        private func handleButtonInfo(item: String){
            //数字が入力された時
            if numbers.contains(item) {
                //「.」が入力されて、且つ入力済みの値に「.」が含まれるor「0」の場合には、「.」を追加されない
                if item == "." && (selectedItem.contains(".") || selectedItem.contains("0")) {
                    return
                }
                
                if selectedItem.count >= 10 {
                    return
                }
                
                if selectedItem == "0" {
                    selectedItem = item
                    return
                }
                
                selectedItem += item
                
            } else if item == "AC" {
                selectedItem = "0"
                caluculatedNumber = 0
                caluculateState = .initial
            }
            
            guard let selectedNumber = Double(selectedItem) else {return}
            //   "x", "+", "÷", "-"
            //計算記号が入力された時
            if item == "÷" {
                setcalculate(state: .division, selectedNumber: selectedNumber)
            } else if item == "x" {
                setcalculate(state: .multiplication, selectedNumber: selectedNumber)
            } else if item == "-" {
                setcalculate(state: .substraction, selectedNumber: selectedNumber)
            } else if item == "+" {
                setcalculate(state: .addition, selectedNumber: selectedNumber)
            } else if item == "=" {
                selectedItem = "0"
                calculate(selectedNumber: selectedNumber)
                caluculateState = .sum
            }
            
        }
        private func setcalculate(state: caluculateState, selectedNumber: Double) {
            if selectedItem == "0" {
                caluculateState = .multiplication
                return
            }
            selectedItem = "0"
            caluculateState = state
            calculate(selectedNumber: selectedNumber)
        }
        private func calculate(selectedNumber: Double) {
            
            if caluculatedNumber == 0 {
                caluculatedNumber = selectedNumber
                return
            }
            
            switch caluculateState {
            case .addition:
                caluculatedNumber = caluculatedNumber + selectedNumber
            case .substraction:
                caluculatedNumber = caluculatedNumber - selectedNumber
            case .division:
                caluculatedNumber = caluculatedNumber / selectedNumber
            case .multiplication:
                caluculatedNumber = caluculatedNumber * selectedNumber

            default:
                break
            }
        }
        
        
        
        struct ContentView_Previews: PreviewProvider {
            static var previews: some View {
                ContentView()
            }
        }
        
    }
}
