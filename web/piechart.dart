/* == TODO ==
 Popup information
 Color based on data

 * == KNOWN BUGS ==
 Does not work in FF, because getBBox, doesn't work on an invisible element.
 Legend doesn't show up right, until the second refresh/redraw.
 */

part of Chart;

class pieChart {
  //TODO most of these should be in a settings object,
  double centerY = 300.0;
  double centerX = 450.0;
  svg.GElement container = new svg.GElement();
  LinkedHashMap<String, _PieItem> elements = new LinkedHashMap<String, _PieItem>();
  Legend legend;
  double radius = 250.0;

  //Color table
  List<String> color = ['#3366cc', '#dc3912', '#109618', '#990099', '#0099c6',
                        '#dd4477', '#66aa00', '#b82e2e', '#316395', '#b77322',
                        '#329262', '#651067', '#8b0707', '#e67300', '#6633cc',
                        '#aaaa11', '#22aa99', '#994499'];

  //??? Not sure if we should expose this without the data.
  int get count => elements.length;

  /**
   * Constructor making a new piechart.
   */
  pieChart(Map<String, double> data) {
    //??? Shouldn't we go the other way around this, and tell how much space we have, and based on that, we find the radius, and centerpoint.
    radius = 250.0;
    centerX = radius*1.15;
    centerY = radius*1.15;

    //TODO There should be a setting if you don't want a Legend.
    legend = new Legend(centerX + radius * 1.12, centerY-radius, 100.0, 400.0);
    container.children.add(legend.toSvg());

    //Transforming the initial data into PieItems.
    data.forEach((key, value) {
      _PieItem item = _makeItem(value);
      container.children.add(item.toSvg());
      elements[key] = item;

      legend.addDataPoint(key, value, item.color);
    });

    refresh();
  }

  /**
   * addes a new data point to the chart.
   */
  void addDataPoint(String key, double value) {
    if (!elements.containsKey(key)) {
      //If the key is not already used, make a new item, and append to the collection.
      _PieItem item = _makeItem(value);
      elements[key] = item;
      //Inserts the svg element, to the DOM.
      container.children.add(item.toSvg());

      legend.addDataPoint(key, value, item.color);

      refresh();
    }
  }

  /**
   * Controls there is enough space for the text.
   */
  void checkTextPlacement (List<_LineSegment> lineSegments) {
    elements.forEach((_, _PieItem item) {
      //Exstract the boundaries for the text.
      double left   = item.inlineText.getBBox().x;
      double top    = item.inlineText.getBBox().y;
      double width  = item.inlineText.clientWidth.toDouble();
      double height = item.inlineText.clientHeight.toDouble();

      //Makes a list of the lines alone the boundary.
      List<_LineSegment> textBoundaries = new List<_LineSegment>();
      //Top Line
      textBoundaries.add(new _LineSegment(x1: left,
                                          y1: top,
                                          x2: left + width,
                                          y2: top));
      //Left Line
      textBoundaries.add(new _LineSegment(x1: left,
                                          y1: top,
                                          x2: left,
                                          y2: top  + height));

      //Bottom Line
      textBoundaries.add(new _LineSegment(x1: left,
                                          y1: top  + height,
                                          x2: left + width,
                                          y2: top  + height));

      //Right Line
      textBoundaries.add(new _LineSegment(x1: left + width,
                                          y1: top,
                                          x2: left + width,
                                          y2: top  + height));

      bool showText = true;
      textBoundaries.forEach((_LineSegment textLine) {
        //To make sure we don't check more lines than necessary.
        if(showText) {
          bool intersecting = lineSegments.any((_LineSegment line) {
            return textLine.intersect(line);
          });

          if (intersecting) {
            showText = false;
          }
        }
      });

      item.inlineText.attributes['visibility'] = showText ? 'visible' : 'hidden';
    });
  }

  /**
   * Makes a new item to the [piechart].
   */
  _PieItem _makeItem(double data) {
    String itemColor = color[elements.length % color.length];
    _PieItem item = new _PieItem(data, itemColor);

    //Sets up event handlers.
//    item.container.onMouseOver.listen((e) {
//      item.highLight = true;
//      refresh();
//    });
//    item.container.onMouseOut.listen((e) {
//      item.highLight = false;
//      refresh();
//    });

    item.container.onClick.listen((e) {
      item.highLight = !item.highLight;
      refresh();
    });

    return item;
  }

  svg.SvgElement toSvg() {
    return container;
  }

  /**
   * Places the text within the circle segment.
   */
  void _placeText(List<_LineSegment> lineSegments) {
    elements.forEach((_, _PieItem item) {
      double medianAngle = item.angle + item.deltaAngle/2;

      //Finds the outer bounds of the text.
      double left = item.inlineText.getBBox().x;
      double top = item.inlineText.getBBox().y;
      double width = item.inlineText.clientWidth.toDouble();
      double height = item.inlineText.clientHeight.toDouble();
      double innerRadius = sqrt(pow(width, 2) + pow(height, 2)) / 2;

      //The text comes too close to the bounder on the sides.
      double paddingConstant = this.radius / 20;
      double padding = (cos(medianAngle) *  paddingConstant);
      //Calculating where the venter of the text should be.
      double textCenterx = item.cx + (this.radius - innerRadius - padding.abs()) * cos(medianAngle);
      double textCentery = item.cy + (this.radius - innerRadius - padding.abs()) * sin(medianAngle);

      //Placing the text.
      item.inlineText.attributes['x'] = (textCenterx - (width / 2)).toString();
      item.inlineText.attributes['y'] = (textCentery - (height / 2)).toString();
    });

    //To get back in the message queue, after the dom is updated/re-rendered.
    //TODO find a better way.
    new Timer(new Duration(milliseconds: 0), () => checkTextPlacement(lineSegments));
  }

  /**
   * Redraws the svg.
   */
  void refresh() {
    print('Piechart Refresh');
    //Analyzses data. Finds the total.
    double sum = 0.0;
    elements.forEach((key, value){
      sum += value.data;
    });

    //The starting angle in radians.
    double angle = 0.0;
    List<_LineSegment> linesegments = new List<_LineSegment>();

    elements.forEach((String key, _PieItem value) {
      double procetages = (value.data / sum) * 100;
      value.inlineText.text = procetages.toStringAsFixed(2) + '%';
      double cx = centerX, cy = centerY;
      double deltaAngle = (value.data / sum) * (2*PI);
      double medianAngle = angle + deltaAngle / 2 ;

      //If a slice should be highlighted, move the cener for the slice.
      if (value.highLight) {
        double highlightMoveDistance = radius * 0.1;
        cx += highlightMoveDistance * cos(medianAngle);
        cy += highlightMoveDistance * sin(medianAngle);
      }

      value.angle = angle;
      value.deltaAngle = deltaAngle;
      value.cx = cx;
      value.cy = cy;

      //The point where the arc start
      double startX, starty;
      startX = cx + radius * cos(angle);
      starty = cy + radius * sin(angle);

      angle += deltaAngle;

      //The point where the arc ends.
      double endX, endy;
      endX = cx + radius * cos(angle);
      endy = cy + radius * sin(angle);

      //Intersection check list
      linesegments.add(new _LineSegment(x1: centerX, y1: centerY, x2: startX, y2: starty));
      linesegments.add(new _LineSegment(x1: centerX, y1: centerY, x2: endX,   y2: endy));

      String bigArc = deltaAngle >= PI ? '1' : '0';

      String d;
      //If one element covers 100%
      if (value.data == sum) {
        d = 'M ${cx+radius} $cy A $radius $radius 0 0 0 ${cx-radius} ${cy} A $radius $radius 0 0 0 ${cx+radius} ${cy} z';
      } else {
        d = 'M $cx $cy L $startX $starty A $radius $radius 0 $bigArc 1 $endX $endy z';
      }
      value.element.attributes['d'] = d;
    });

    //TODO find a better way to get back into the message queue.
    new Timer(new Duration(milliseconds: 0), () => _placeText(linesegments));

    legend.refresh();
  }

  /**
   * Updates one of the data points.
   */
  void updateValue(String key, double value) {
    if (elements.containsKey(key)) {
      elements[key].data = value;
      legend.updateDataPoint(key, value);
      refresh();
    }
  }
}

/**
 * A class for a slice of the chart.
 */
class _PieItem {
  String _color;
  double data;
  bool highLight = false;

  double angle;
  double deltaAngle;
  double cx, cy;

  svg.GElement container = new svg.GElement();
  svg.PathElement element = new svg.PathElement();
  svg.TextElement inlineText = new svg.TextElement();

  String get color => _color;
         set color(value) {
    _color = value;
    element.attributes['fill'] = value;
  }

  _PieItem(this.data, String color) {
    container
      ..children.add(element)
      ..children.add(inlineText);

    //TODO All these things down from here, should be a setting. Except Style and visibility.
    element
      ..attributes['stroke'] = 'white'
      ..attributes['stroke-width'] = '2';

    inlineText
      ..attributes['fill'] = 'white'
      ..attributes['font-family'] = 'Arial'
      ..attributes['font-size'] = 22.toString()
      ..attributes['visibility'] = 'hidden'
      ..attributes['style'] = 'dominant-baseline: text-before-edge; text-anchor: start;';
    this.color = color;
  }

  svg.SvgElement toSvg() {
    return container;
  }
}

/**
 * Represents a line segment with two points.
 */
class _LineSegment {
  double x1, y1, x2, y2;

  /**
   * Checks if two lines segments cross.
   */
  bool intersect(_LineSegment other) {
    //Source: http://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
    double s02_x, s02_y, s10_x, s10_y, s32_x, s32_y, s_numer, t_numer, denom, t;
    s10_x = x2 - x1;
    s10_y = y2 - y1;
    s32_x = other.x2 - other.x1;
    s32_y = other.y2 - other.y1;

    denom = s10_x * s32_y - s32_x * s10_y;
    if (denom == 0)
        return false; // Collinear
    bool denomPositive = denom > 0;

    s02_x = x1 - other.x1;
    s02_y = y1 - other.y1;
    s_numer = s10_x * s02_y - s10_y * s02_x;
    if ((s_numer < 0) == denomPositive)
        return false; // No collision

    t_numer = s32_x * s02_y - s32_y * s02_x;
    if ((t_numer < 0) == denomPositive)
        return false; // No collision

    if (((s_numer > denom) == denomPositive) || ((t_numer > denom) == denomPositive))
        return false; // No collision
    // Collision detected
    return true;
  }

  _LineSegment({this.x1, this.y1, this.x2, this.y2});
}
