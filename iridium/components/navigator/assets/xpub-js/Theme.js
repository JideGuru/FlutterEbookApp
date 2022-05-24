//
// Controller to override the book's style with our own theme.
//
// When a spine item is loaded, a <style> tag is inserted in the DOM to contain
// our theme.
// You can override the theme by calling MantanoReader.theme.set("body { ... }")
//
function ThemeController() {
    var self = this;
    this.verticalMargin = 0;
}
ThemeController.prototype.setVerticalMargin = function(verticalMargin) {
    this.verticalMargin = verticalMargin;
};
ThemeController.prototype.updateProperty = function(propertyName, propertyValue) {
    document.documentElement.style.setProperty(propertyName, propertyValue);
};
