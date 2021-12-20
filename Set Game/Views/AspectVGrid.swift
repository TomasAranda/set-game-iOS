//
//  AspectVGrid.swift
//  Set Game
//
//  Created by Tomás Aranda on 20/12/2021.
//

import SwiftUI

/// Arranges its childrens depending on the quantity of them and aspect ratio desired
struct AspectVGrid<Item, ItemView> : View where Item: Identifiable, ItemView: View {
    var items: [Item]
    var aspectRatio: CGFloat
    var content: (Item) -> ItemView
    
    init(items: [Item], aspectRatio: CGFloat, @ViewBuilder content: @escaping (Item) -> ItemView) {
        self.items = items
        self.aspectRatio = aspectRatio
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                let width: CGFloat = widthThatFits(itemCount: items.count, in: geometry.size, itemAspectRatio: aspectRatio)
                LazyVGrid(columns: [adaptiveGridItem(width: width)], spacing: 0) {
                    ForEach(items) { item in
                        content(item).aspectRatio(aspectRatio, contentMode: .fit)
                    }
                }
//                Spacer(minLength: 0)
            }
        }
    }
    
    private func adaptiveGridItem(width: CGFloat) -> GridItem {
        var gridItem = GridItem(.adaptive(minimum: width))
        gridItem.spacing = 0
        return gridItem
    }
    
    // returns optimal item width that fits any given size
    private func widthThatFits(itemCount: Int, in size: CGSize, itemAspectRatio: CGFloat) -> CGFloat {
        var columnCount = 1
        var rowCount = itemCount
        repeat {
            let itemWidth = size.width / CGFloat(columnCount)
            let itemHeight = itemWidth / itemAspectRatio
            
            if CGFloat(rowCount) * itemHeight < size.height {
                break
            }
            
            columnCount += 1
            rowCount = (itemCount + (columnCount - 1)) / columnCount
        } while columnCount < itemCount
        
        if columnCount > itemCount {
            columnCount = itemCount
        }
        
        return floor(size.width / CGFloat(columnCount))
    }
}



// TODO: Make preview with test data (we don't did this in demo due to time constraints)
struct AspectVGrid_Previews: PreviewProvider {
    static var previews: some View {
        var game = SetGame()
        while game.dealedCards.count < 81 {
            game.dealCards()
        }
        let cards = game.dealedCards
        
        return AspectVGrid(
            items: cards,
            aspectRatio: 2/3
        ) { _ in RoundedRectangle(cornerRadius: 10.0).opacity(1).padding(3) }
    }
}