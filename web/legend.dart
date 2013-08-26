part of Chart;
/* == TODO ==
 * What is the key is too bug to show. Should we just cut it, and make room for the data, or is the key text more importen?
 */
class Legend {
  double X, Y;
  double width = 100.0, height = 500.0;
  bool sorted = false;
  double fontSize = 13.0;
  int decimals = 0;
  bool showData = true;

  LinkedHashMap<String, LegendItem> elements = new LinkedHashMap<String, LegendItem>();
  svg.GElement container = new svg.GElement();
  svg.RectElement background = new svg.RectElement();

  Legend(this.X, this.Y, this.width, this.height) {
    container.children.add(background);

    //All of this should be possible to configure from outside.
    background
      ..attributes['fill'] = 'white'
      ..attributes['stroke'] = '#cccccc'
      ..attributes['stroke-width'] = 1.toString()
      ..attributes['width'] = width.toString()
      ..attributes['height'] = height.toString()
      ..attributes['x'] = X.toString()
      ..attributes['y'] = Y.toString();
  }

  /**
   * Inserts a new data point.
   */
  void addDataPoint(String key, double data, String color) {
    if(!elements.containsKey(key)) {
      LegendItem item = _makeItem(key, data, color);
      elements[key] = item;
      container.children.add(item.toSvg());
    }
  }

  /**
   * Updates a data pont.
   */
  void updateDataPoint(String key, double data) {
    if (elements.containsKey(key)) {
      elements[key].data = data;
    }
  }

  /**
   * Makes a new item.
   */
  LegendItem _makeItem(String key, double data, String color) {
    LegendItem item = new LegendItem(data, color)
      ..key = key
      ..text.attributes['font-size'] = fontSize.toString();
    return item;
  }

  void _checkText(svg.TextElement item, String key, String data, double maxWidth) {
    if (item.getBBox().width > maxWidth) {
      String newKey = key.substring(0, key.length-1);

      if (data != null && data != '') {
        item.text = '$newKey: $data';
      } else {
        item.text = '$newKey';
      }

      new Timer(new Duration(milliseconds: 0), () => _checkText(item, newKey, data, maxWidth));
    }
  }

  /**
   * Redraws the svg elements.
   */
  void refresh() {
    double borderMargin = 5.0;
    double spaceBetweenColorbowAndText = 2.0;
    double itemX = X + borderMargin;
    double itemY = Y + borderMargin;
    double padding = 5.0;
    double textHeight = 0.0;

    List<KeyValuePair<String, LegendItem>> list = elementsToList(sorted);

    for(KeyValuePair<String, LegendItem> item in list) {
      textHeight = item.value.text.getBBox().height;
      item.value.colorBox
        ..attributes['height'] = textHeight.toString()
        ..attributes['width'] = textHeight.toString()
        ..attributes['x'] = itemX.toString()
        ..attributes['y'] = itemY.toString();

      item.value.text
        ..attributes['x'] = (itemX + textHeight + spaceBetweenColorbowAndText).toString()
        ..attributes['y'] = itemY.toString();

      double maxWidth = width - 2 * borderMargin - textHeight - spaceBetweenColorbowAndText;
      if (showData) {
        String dataText = item.value.data.toStringAsFixed(decimals);
        item.value.text.text = '${item.key}: ${dataText}';
        _checkText(item.value.text, item.key, dataText, maxWidth);
      } else {
        item.value.text.text = item.key;
        _checkText(item.value.text, item.key, '', maxWidth);
      }

      itemY += textHeight + padding;
    }
    double backgroundHeight = (itemY - Y);
    background.attributes['height'] = backgroundHeight.toString();
  }

  List<KeyValuePair<String, LegendItem>> elementsToList(bool sorted) {
    List<KeyValuePair<String, LegendItem>> result = new List<KeyValuePair<String, LegendItem>>();
    elements.forEach((key, value){
      result.add(new KeyValuePair(key, value));
    });

    if(sorted) {
      result.sort((KeyValuePair<String, LegendItem> a, KeyValuePair<String, LegendItem> b) {
        return -a.value.data.compareTo(b.value.data);
      });
    }
    return result;
  }

  /**
   * Returns the legends top svgElement.
   */
  svg.SvgElement toSvg() {
    return container;
  }
}

/**
 * A class that describes a data point.
 */
class LegendItem {
  svg.GElement container = new svg.GElement();
  svg.RectElement colorBox = new svg.RectElement();
  svg.TextElement text = new svg.TextElement();
  String _color;
  double data;
  String key = '';

  LegendItem(double data, this._color) {
    this.data = data;

    colorBox
      ..attributes['width'] = '12'
      ..attributes['height'] = '12'
      ..attributes['fill'] = _color;

    text
      ..attributes['dominant-baseline'] = 'text-before-edge'
      ..attributes['text-anchor'] = 'start';
//      ..attributes['style'] = 'dominant-baseline: text-before-edge; text-anchor: start;';

    container.children.add(colorBox);
    container.children.add(text);
  }

  svg.SvgElement toSvg() {
    return container;
  }
}
