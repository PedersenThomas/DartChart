/* == TODO ==
 * LegendSettings.
 */

/* == KNOWN BUGS ==
 * There is only saved a reference to settings, so the user can change the settings, just by editing what looks like there settings object.
 */

part of Chart;

class BarChart {
  BarchartSettings settings;
  Legend legend;
  svg.GElement container = new svg.GElement();

  LinkedHashMap<String, barItem> elements = new LinkedHashMap<String, barItem>();
  barAxis axis;

  BarChart(this.settings, [Map<String, double> initialData]) {
    gradientTest();
    axis = new barAxis();
    legend = new Legend(settings.width - settings.legendWidth.toDouble(), 10.0, settings.legendWidth.toDouble(), settings.height - 10.0);

    container.children.add(axis.toSvg());
    container.children.add(legend.toSvg());

    initialData.forEach((key, value) {
        addDatapoint(key, value);
      });

    refresh();
    //XXX Did somebody say hack?
    _refreshShortly;
  }
  
  void gradientTest() {
    svg.DefsElement defsContainer = new svg.DefsElement();
    container.children.add(defsContainer);

    svg.LinearGradientElement LG = new svg.LinearGradientElement();
    svg.StopElement firstStop = new svg.StopElement()
      ..attributes['offset'] = '0%'
      ..attributes['stop-color'] = 'lightGreen';
    svg.StopElement secondStop = new svg.StopElement()
    ..attributes['offset'] = '100%'
    ..attributes['stop-color'] = 'green';

    LG.children.add(firstStop);
    LG.children.add(secondStop);
    
    /*
     * id="grad1" x1="0%" y1="0%" x2="100%" y2="0%"
     */
    String id = 'grad1';
    LG
      ..attributes['id'] = id
      ..attributes['x1'] = '0%'
      ..attributes['y1'] = '0%'
      ..attributes['x2'] = '0%'
      ..attributes['y2'] = '100%';
    defsContainer.children.add(LG);
    
    settings.colors.insert(0, 'url(#$id)');
  }

  //My family didn't die, angles didn't lose their wings, the world didn't explode. There is something wrong here.
  void get _refreshShortly {
    new Timer(new Duration(milliseconds: 0), refresh);
  }

  void _checkText(svg.TextElement item, double maxWidth) {
    if (item.getBBox().width > maxWidth) {
      String before = item.text;
      String after = item.text.substring(0, item.text.length - 1);
      item.text = after;
      //TODO XXX ??? WARNING ERROR BAD CODE INCOMMING.
      new Timer(new Duration(milliseconds: 0), () => _checkText(item, maxWidth));
    }
  }

  void refresh() {
    _MakeSureWeHaveTheRightAmountOfGridLinesAndTextMarks();
    updateAxisText();
    legend.refresh();
    legend.sorted = settings.legendSorted;

    double bx = 5.0, by = 5.0;
    // Step 1 X/Y-Label
    axis.y_axis_label
      ..text = settings.yAxisLabelText
      ..attributes['text-anchor'] = 'middel'
      ..attributes['stroke'] = 'none'
      ..attributes['stroke-width'] = '0'
      ..attributes['fill'] = '#222222'
      ..attributes['x'] = (bx - axis.y_axis_label.getBBox().width/2).toString()
      ..attributes['y'] = (settings.height/2).toString()
      ..attributes['transform'] = 'rotate(-90 ${bx + axis.y_axis_label.getBBox().height/2} ${settings.height/2})';

    axis.x_axis_label
      ..text = settings.xAxisLabelText
      ..attributes['x'] = (settings.width / 2 - axis.x_axis_label.getBBox().width / 2).toString()
      ..attributes['y'] = (settings.height - by).toString();

    double YLH = axis.y_axis_label.getBBox().height;
    double XLH = axis.x_axis_label.getBBox().height;

    //Step 2 analyze data for gridlines and grid labels.
    //analyzes data
    double lowerGridValue = 0.0;
    double upperGridValue = yAxisTopValue();
    //TODO XXX Do something here.
    if (upperGridValue == 0) {
      return;
    }

    //step 3 inserts gridline and text.
    double ex = 5.0, ey = 5.0;
    double cx = 50.0, cy = 0.0;
    //Finds the text that is widest in the y axis.
    for (svg.TextElement item in axis._y_axis_textmark) {
      if (item.getBBox().width > cx){
        cx = item.getBBox().width;
      }
    }

    //Finds the text that is tallest in the x axis.
    for (svg.TextElement item in axis._x_axis_textmark) {
      if (item.getBBox().height > cy){
        cy = item.getBBox().height;
      }
    }

    double ax = 3.0 + 2 * settings.barStrokeWidth;
    double hw = 5.0, hh = 10.0;
    double dx = ex + cx + hw, dy = ey + cy + hh;
    double plw = 5.0;
    double legend = plw + settings.legendWidth;
    double graphWidth = settings.width - bx - YLH - dx - settings.axisLineThickness - legend;
    double graphHeight = settings.height - by - XLH - dy - settings.axisLineThickness;
    double barWidth = ( (graphWidth - ax) / elements.length ) - ax;

    double GH = graphHeight / settings.gridlinesCount;

    double graphX = bx + YLH + dx + settings.axisLineThickness;
    double graphY = by + graphHeight;

    for (int i = 0; i < axis._y_axis_textmark.length; i += 1) {
      svg.TextElement item = axis._y_axis_textmark[i];
      item
        ..attributes['x'] = (by + YLH + ex + cx - item.getBBox().width).toString()
        ..attributes['y'] = (by + graphHeight - (i * GH)).toString();
    }
//    axis._y_axis_textmark.forEach((TextElement item) {
//      item
//        ..text = (index * (endGridValue / settings.gridlinesCount)).toStringAsFixed(1)
//        ..attributes['x'] = (by + YLH + ex + cx - item.getBBox().width).toString()
//        ..attributes['y'] = (by + graphHeight - (index * GH)).toString();
//      index += 1;
//    });

    List<String> keys = elements.keys.toList(growable: false);

    for (int i = 0; i < axis._x_axis_textmark.length; i += 1) {
      svg.TextElement item = axis._x_axis_textmark[i];
      String text = keys[i];
      double textCenterX = graphX + (i +1) * (ax + barWidth) - barWidth / 2;
      item
        ..attributes['x'] = (textCenterX).toString()
        ..attributes['y'] = (graphY + hh).toString();

      _checkText(item, barWidth);
    }

    for(int i = 0; i < axis._guidelines.length; i += 1) {
      axis._guidelines[i]
        ..attributes['x'] = (graphX).toString()
        ..attributes['y'] = (graphY - ((i+1) * GH)).toString()
        ..attributes['width'] = (graphWidth).toString()
        ..attributes['height'] = 1.toString();
    }

    //Step 4 - draw axis.
    axis.x_axis
      ..attributes['width'] = graphWidth.toString()
      ..attributes['height'] = settings.axisLineThickness.toString()
      ..attributes['x'] = graphX.toString()
      ..attributes['y'] = graphY.toString();

    axis.y_axis
      ..attributes['width'] = settings.axisLineThickness.toString()
      ..attributes['height'] = (graphHeight + settings.axisLineThickness).toString()
      ..attributes['x'] = (graphX-settings.axisLineThickness).toString()
      ..attributes['y'] = (graphY-graphHeight).toString();

    //Step 5 - draw Bars.
    //TODO Make it here, so it draws the bars, in the right order, if they need to be sorted.
    //        Takes the sortedlist from SortedElements(). Should be easy
    //        Maybe should it always request the list, and make it a paramter to sort it  or not.
    // That way we can probably also easily cache some work there.

    if(settings.sorted) {
      int index = 0;
      List<KeyValuePair<String, barItem>> list = sortedElements();
      for(KeyValuePair<String, barItem> item in list) {
        double barHeight = item.value.data / (upperGridValue - lowerGridValue) * graphHeight;
        item.value.barRect
          ..attributes['width'] = barWidth.toString()
          ..attributes['height'] = barHeight.toString()
          ..attributes['y'] = (graphY - barHeight).toString()
          ..attributes['x'] = (index * (barWidth + ax) + ax + graphX).toString();
        index += 1;
      }
    } else {
      int index = 0;
      elements.forEach((_, item) {
        double barHeight = item.data / (upperGridValue - lowerGridValue) * graphHeight;
        item.barRect
          ..attributes['width'] = barWidth.toString()
          ..attributes['height'] = barHeight.toString()
          ..attributes['y'] = (graphY - barHeight).toString()
          ..attributes['x'] = (index * (barWidth + ax) + ax + graphX).toString();

        item.updateText();
        index += 1;
    });
    }
  }

  void _MakeSureWeHaveTheRightAmountOfGridLinesAndTextMarks() {
    //Grid lines.
    while(axis._guidelines.length < settings.gridlinesCount) {
      svg.RectElement item = new svg.RectElement()
      ..attributes['fill'] = '#cccccc';
      axis._guidelines.add(item);
      axis.container.children.add(item);
    }

    while(axis._guidelines.length > settings.gridlinesCount) {
      svg.RectElement item = axis._guidelines.removeLast();
      axis.container.children.remove(item);
    }

    //YAxis
    while(axis._y_axis_textmark.length < settings.gridlinesCount +1) {
      svg.TextElement item = new svg.TextElement()
        ..attributes['font-size'] = settings.fontSize.toString()
        ..attributes['fill'] = 'black'
        ..attributes['style'] = 'dominant-baseline: text-before-edge; text-anchor: start;';
      axis._y_axis_textmark.add(item);
      axis.container.children.add(item);
    }

    while(axis._y_axis_textmark.length > settings.gridlinesCount +1) {
      svg.TextElement item = axis._y_axis_textmark.removeLast();
      axis.container.children.remove(item);
    }

    //X Axis
    while(axis._x_axis_textmark.length < elements.length) {
      svg.TextElement item = new svg.TextElement()
        ..attributes['font-size'] = settings.fontSize.toString()
        ..attributes['fill'] = 'black'
        ..attributes['style'] = 'dominant-baseline: text-before-edge; text-anchor: middle;';
      axis._x_axis_textmark.add(item);
      axis.container.children.add(item);
    }

    while(axis._x_axis_textmark.length > elements.length) {
      svg.TextElement item = axis._x_axis_textmark.removeLast();
      axis.container.children.remove(item);
    }
  }

  /**
   * When you click on a bar.
   */
  void _barClick(String key) {
    barItem item = elements[key];
    double value = item.data;
    updateDatapoint(key, value + 13.3);
    refresh();
  }

  /**
   * Updates a data point.
   */
  void updateDatapoint(String key, double value) {
    if (elements.containsKey(key)) {
      elements[key].data = value;
      legend.updateDataPoint(key, value);
      refresh();
    } else {
      print('$key was not found in the barchart.');
    }
  }

  /**
   * Makes a new bar for the chart.
   */
  barItem _makeBarItem(String key, double value){
    barItem bar = new barItem(value, settings);
    if (settings.colors != null && settings.colors.length > 0) {
      bar.color = settings.colors[elements.length % settings.colors.length];
    } else {
      bar.color = randomColor();
    }
    bar.container.onClick.listen((_) => _barClick(key));

//    bar.container.onMouseOver.listen((e) {
//      bar.text.attributes['font-size'] = '30';
//      bar.text.attributes['fill'] = 'Red';
//      _refreshShortly;
//    });
//
//    bar.container.onMouseOut.listen((e) {
//      bar.text.attributes['font-size'] = settings.fontSize.toString();
//      bar.text.attributes['fill'] = 'white';
//      _refreshShortly;
//    });

    return bar;
  }

  /**
   * Adds a new data point.
   */
  void addDatapoint(String key, double startValue) {
    if(!elements.containsKey(key)) {
      var bar = _makeBarItem(key, startValue);
      elements[key] = bar;
      container.children.add(bar.toSvg());
      svg.TextElement item = new svg.TextElement()
        ..attributes['font-size'] = settings.fontSize.toString()
        ..attributes['fill'] = 'black'
        ..attributes['style'] = 'dominant-baseline: text-before-edge; text-anchor: middle;';
      axis._x_axis_textmark.add(item);
      axis.container.children.add(item);
      legend.addDataPoint(key, startValue, bar.color);
      refresh();
    }
  }

  List<KeyValuePair<String, barItem>> sortedElements() {
    List<KeyValuePair<String, barItem>> result = new List<KeyValuePair<String, barItem>>();
    elements.forEach((key, value){
      result.add(new KeyValuePair(key, value));
    });

    result.sort((KeyValuePair<String, barItem> a, KeyValuePair<String, barItem>b) {
      return -a.value.data.compareTo(b.value.data);
    });

    return result;
  }

  void updateAxisText() {
    List<String> xTexts = new List<String>();
    if (settings.sorted){
      //TODO
      List<KeyValuePair<String, barItem>> sortedList = sortedElements();
      for(final KeyValuePair<String, barItem> item in sortedList) {
        xTexts.add(item.key);
      }
    } else {
      elements.forEach((key, _){
        xTexts.add(key);
      });
    }

    axis.updateXAxisText(xTexts);

    List<String> yTexts = new List<String>();
    double maxValue = yAxisTopValue();
    for(int i = 0; i <= settings.gridlinesCount; i += 1) {
        yTexts.add((i * (maxValue / settings.gridlinesCount)).toStringAsFixed(settings.numberOfDecimalsOnAxis));
    }

    axis.updateYAxisText(yTexts);
  }

  svg.SvgElement toSvg() {
    return container;
  }

  double yAxisTopValue() {
    if (elements.length == 0) {
      return 0.0;
    }
    //XXX This will fail if the elements if empty.
    //double minValue = elements[elements.keys.first].data;
    double maxValue = elements[elements.keys.first].data;

    elements.forEach((key, value) {
//      if (value.data < minValue) {
//        minValue = value.data;
//      }
        if (value.data > maxValue) {
        maxValue = value.data;
      }
    });

    int digits = (log(maxValue) / LN10).floor();
    if(digits <= 1){
      digits = 2;
    }
    int modulus = pow(10, digits-1).toInt();
    if (maxValue % modulus != 0){
      maxValue += modulus - maxValue % modulus;
    }

    return maxValue;
  }
}

class barItem {
  String _color;
  BarchartSettings settings;
  double _data;
  svg.GElement container = new svg.GElement();
  svg.RectElement barRect = new svg.RectElement();
  svg.TextElement insideBarText = new svg.TextElement();

  double get data => _data;
         set data(double value) {
    _data = value;
    updateText();
  }

  String get color => _color;
         set color(value) {
           _color = value;
           barRect.attributes['fill'] = value;
         }

  void updateText() {
    //setupObserver();
    insideBarText.text = _data.toStringAsFixed(1);
  }

  barItem(this._data, this.settings) {
    updateText();
    container.children.add(barRect);
    //container.chrildren.add(text);
    barRect
      ..attributes['stroke'] = 'black'
      ..attributes['stroke-width'] = settings.barStrokeWidth.toString();

    insideBarText
      ..attributes['fill'] = 'white'
      ..attributes['font-size'] = settings.fontSize.toString()
      ..attributes['style'] = 'dominant-baseline: text-before-edge; text-anchor: start;';
  }

  /**
   * XXX ???? TODO FIXME OR DELETEME
   * Used for text inside a bar. NOT USED!
   */
  void setupObserver() {
    var mo = new html.MutationObserver((List<html.MutationRecord> changes, html.MutationObserver observer) {
      observer.disconnect();

      for (html.MutationRecord change in changes) {
        //print('${change.target} ${change.target.text} oldVal: ${change.oldValue} ${change.addedNodes.first.nodeName}');  // lots of data in MutationRecord, check it out in the API
      }

      if (insideBarText.getBBox().width  > barRect.getBBox().width ||
          insideBarText.getBBox().height > barRect.getBBox().height) {
        insideBarText.attributes['visibility'] = 'hidden';
      } else {
        double padding = 5.0;
        insideBarText
          ..attributes['visibility'] = 'visible'
          ..attributes['x'] = (barRect.getBBox().x + barRect.getBBox().width/2 - insideBarText.getBBox().width/2).toString()
          ..attributes['y'] = (barRect.getBBox().y + barRect.getBBox().height - insideBarText.getBBox().height - padding).toString();
      }
    });

    mo.observe(insideBarText, childList: true, characterData: true, subtree: true);
  }

  svg.SvgElement toSvg() {
    return container;
  }
}

class barAxis {
  svg.GElement container = new svg.GElement();
  svg.RectElement y_axis = new svg.RectElement();
  svg.RectElement x_axis = new svg.RectElement();
  svg.TextElement y_axis_label = new svg.TextElement();
  svg.TextElement x_axis_label = new svg.TextElement();
  List<svg.RectElement> _guidelines = new List<svg.RectElement>();
  List<svg.TextElement> _y_axis_textmark = new List<svg.TextElement>();
  List<svg.TextElement> _x_axis_textmark = new List<svg.TextElement>();

  barAxis() {
    container.children.addAll([y_axis, x_axis, y_axis_label, x_axis_label]);
  }

  void updateXAxisText(List<String> data) {
    if (data.length == _x_axis_textmark.length) {
      for(int i = 0; i < data.length; i += 1) {
        _x_axis_textmark[i].text = data[i];
      }
    }
  }

  void updateYAxisText(List<String> data) {
    if (data.length == _y_axis_textmark.length) {
      for(int i = 0; i < data.length; i += 1) {
        _y_axis_textmark[i].text = data[i];
      }
    }
  }

  svg.SvgElement toSvg() {
    return container;
  }
}

/**
 * Settings for the barchart.
 */
class BarchartSettings {
  int    axisLineThickness = 2;
  double barSpacing = 10.0;
  int    barStrokeWidth = 1;
  /**
   * Set it to an empty list, or null to get random colors.
   */
  List<String> colors = ['#3366cc', '#dc3912', '#109618', '#990099', '#0099c6', '#dd4477', '#66aa00', '#b82e2e', '#316395', '#b77322', '#329262', '#651067', '#8b0707', '#e67300', '#6633cc', '#aaaa11', '#22aa99', '#994499'];
  double fontSize = 13.0;
  int    gridlinesCount = 10;
  int    height = 700;
  int    legendWidth = 100;
  bool   legendSorted = false;
  int    numberOfDecimalsOnAxis = 0;
  bool   sorted = false;
  bool   vertial = true;
  String yAxisLabelText = 'value';
  int    width = 600;
  String xAxisLabelText = 'key';
}
