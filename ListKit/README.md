# ListKit

`ListKit` is a library for iOS designed to make dynamic lists much faster and easier. It uses the `UICollectionView` as the base technology to create the lists, but it removes the burden to create `dataSource` and `delegate` objects which generally have a lot of boilerplate code and are not very flexible, especially when you want to have dynamic sections.

`ListKit` has the following advantages:

* No need to create `dataSource` and `delegate` objects, which generally have a lot of boilerplate code
* Create list sections and items on the fly, which makes it much easier to use with functional programming
* Plug-in list features like parallax images, sticky/stretchy headers, etc.
* Reuse your custom `UIView`s for items in the list, without having to subclass from `UICollectionViewCell`
* Reuse your lists anywhere in your app, without having to duplicate your `dataSource` and `delegate` objects.
* Easily manage dynamic lists with multiple sections
* Built-in paging support
* Powerful layout and sizing options, including grid layout support out of the box

## Usage

The easiest way to use `ListKit` is using the `ListView` class (a subclass of `UICollectionView`) and creating a `ListSection` object with the required information for each cell as the following:

```swift
let listView = ListView(frame: view.frame)

let colors = ["Blue", "Red", "Yellow", "Brown", "Cyan", "Green", "Black"]
let size = ViewComponentSize(height: 44)

let listSection = ListSection(cellIdentifier: ColorCell.Identifier,
			viewModels: colors,
			size: size)

listView.addSection(listSection)

```

Updating data in the list:

```swift
listSection.viewModels = ["Red", "Green", "Blue"]
```
That's it! The list will be updated immediately. No need to call `reloadData` or `insertItems`!

To use your cells with `ListKit` they need to conform to the `ListViewComponent` protocol in order to get the content, like the following:

```swift
class ColorCell: UICollectionViewCell, ListViewComponent {
	@IBOutlet weak var colorLabel: UILabel!
	
	func update(withViewModel viewModel: Any) {
		guard let color = viewModel as? String else { return }
		colorLabel.text = color
	}
}
```
You can also use your `UIView`s directly, which would make it easier to reuse your views which you don't only use in lists. `ListKit` will wrap your views in a `UICollectionViewCell` so that it can be used in the list. To enable this, you have to pass the identifier of each cell with the parameter name `viewIdentifier` as shown:

```swift
let listSection = ListSection(viewIdentifier: ColorView.Identifier,
						viewModels: colors,
						size: size)
```

**Using Headers and Footers**

To add a header or a footer to the sections, you need to give similar information as with the items.

```swift
let listSection = ListSection(cellIdentifier: ColorCell.Identifier,
            viewModels: colors,
            size: size,
            headerIdentifier: ColorHeaderView.Identifier,
            headerSize: ViewComponentSize(height: 20),
            footerIdentifier: ColorFooterView.Identifier,
            footerSize: ViewComponentSize(height: 20)) { [weak self] indexPath in
            	self?.didSelectColor(at: indexPath.item)
}
```

## Action Handling

**Basic action handling**

To receive callbacks when the user taps any item in the list, you must pass a closure when creating the `ListSection` object like the following:

```swift
let listSection = ListSection(cellIdentifier: ColorCell.Identifier,
			viewModels: colors,
			size: size) { [weak self] indexPath in
			self?.didSelectColor(at: indexPath.item)
}
```

**Advanced action handling**

If you need to handle any other user action in an individual `UIControl` element in your list item, you need to define actions and register callbacks for those actions. 

To define a user action you need an object that conforms to the protocol `UserAction`:

```swift
public protocol UserAction {
    var identifier: String { get }
}
```

An easy way to define your actions is to use an enum:

```swift
enum ColorCellAction: String, UserAction {
    case didTapColorButton
}
```

`ListKit` provides enums of type `String` and that conform to `UserAction` default implementations for the protocol so you don't have to define anything else.


To register a callback for an action in a `ListSection`:

```swift
listSection.register(action: CollorCellAction.didTapColorButton, in: .cell) { [weak self] filterButton in
            self?.handleDidTapColorButton()
        }
```

Note that the callback should be of type `UserActionCallback` which is a `typealias` for `(UIControl) -> ()`

Registering callbacks for actions are supported for every type of component in the list, which are `.cell`, `.header` and `.footer`

`ListKit` will pass this callback to every cell and you have to store it to be called later when the action is triggered:

```swift
extension ColorCell {
    func register(action: UserAction, callback: @escaping (UIControl) -> ()) {
        guard let action = action as? ColorCellAction else { return }
        
        switch action {
        case .didTapColorButton:
            onTapColorButton = callback //onTapColorButton is a closure of type UserActionCallback and is stored in the cell to be called at a later point
        }
    }
}

```


## Sizing

`ListKit` uses the `ViewComponentSize` struct to manage the size of it's components. `ViewComponentSize` stores a `CGSize` and a `ViewComponentSizeType` for each dimension of it's size. `ViewComponentSizeType` states whether a dimension of the size is absolute or relative to the list. This allows to easily size the items or the header/footer of the list. 

**Examples**

Half the width and full height of the list:

```swift
let size = ViewComponentSize(size: CGSize(width: 0.5, height: 1), 
					widthType: .relative, 
					height: .relative)
```

One of the most common cases is to size the list item full width to the list and an absolute height as the following:

```swift
let size = ViewComponentSize(height: 44)
```

Another common case is to have a grid layout. To achive this you can use the `GridViewComponentSize` struct as the following:

```swift
let size = GridViewComponentSize(numberOfItemsPerRow: 4,
                aspectRatio: CGFloat = 1, //Width-to-height aspect ratio
                horizontalPadding: CGFloat = 0, //Padding from left and right
                additionalHeight: CGFloat = 0, //If the item should have an additional absolute height on top of the aspect ratio-determined height
                interitemSpacing:CGFloat = 0) //Spacing between items
``` 

The `GridSizeViewComponentSize` will calculate the correct size of each item dynamically based on size of the list. 

**Advanced Sizing**

In some cases you might need a more advanced sizing logic. If this is the case, you can put your sizing logic into a an object that conforms to the protocol `ViewComponentSizeProtocol`:

```swift
public protocol ViewComponentSizeProtocol {
    var indentLevel: Int { get }
    func calculateActualSize(in frame: CGRect?) -> CGSize //Calculate size in list frame
}
```

`ListKit` will ask your custom sizing object to calculate the size for each item with passing the frame of the list.

`ViewComponentSize` and `GridViewComponentSize` both conform to this protocol.

## Paging

A common use case in lists is paging. `ListKit` supports paging out of the box. If you enable paging for a list section, `ListKit` will show a loader at the end of the list and call your callback to let you know that you have to get the next page, as long as you set `hasNextPage` as `true`.

**Example**

Enabling paging for a section and setting that the section has another page:

```swift
listSection.isPagingEnabled = true
listSection.hasNextPage = true
```

Setting the callback to get next page:

```swift
listSection.getNextPage = { [weak self] in
	self?.getNextPageOfColors()
}
```

## Features

If you want to add features to your list, you must create an object that conforms to the `ListFeature` protocol:

```swift 
public protocol ListFeature {
    func setup(with listViewComponent: ListViewComponent, at index: Int)
    func list(didScrollTo offset: CGPoint)
}
```

`ListKit` passes every list cell to each `ListFeature` once for setting up the feature, so if you need to access any individual cell you should do it in this method.

`ListKit` also passes content offset as it changes, so you can do whatever you want with the offset. 


**Features supported out of the box**

* **Parallax Header**: Adds parallax effects to your list items
* **Sticky Headers**: Adds the sticky header feature, just like `UITableView`