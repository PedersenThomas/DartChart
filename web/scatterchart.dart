part of Chart;
/* TODO
 * Idea: Only render the series that is requried to be rendered. This requires that you know how big the chart is, and what changes a changes make to it. 
 *         Series one got a new upper bound, does it affect the other series.
 */

/**
 * Remarks. It can only handle positive numbers.
 */
class ScatterChart {
  ScatterSettings _settings;
  ScatterAxis _axis = new ScatterAxis();
  svg.GElement _container = new svg.GElement();
  Map<String, ScatterSerie> _elements = new Map<String, ScatterSerie>();

  svg.TextElement _xLabel = new svg.TextElement();
  svg.TextElement _yLabel = new svg.TextElement();

  Legend legend;
  
  ScatterChart(this._settings, [Map<String, List<List<double>>> initialData]) {
    double bx = 5.0, by = 5.0; //FIXME Two bx and by. also found in refresh.
    // Step 1 X/Y-Label
    _yLabel
      ..text = _settings.yAxisLabelText
      ..attributes['text-anchor'] = 'middel'
      ..attributes['stroke'] = 'none'
      ..attributes['stroke-width'] = '0'
      ..attributes['fill'] = '#222222';

    _xLabel
      ..text = _settings.xAxisLabelText;

    _container.children.add(_xLabel);
    _container.children.add(_yLabel);
    _container.children.add(_axis.toSvg());

    legend = new Legend(_settings.width - _settings.legendWidth.toDouble(), 10.0, _settings.legendWidth.toDouble(), _settings.legendHeight);
    legend.showData = false;
    _container.children.add(legend.toSvg());
    
    if (initialData != null) {
      initialData.forEach((key, value) {
        addSerie(key, value);
      });
    }
  }

  void addSerie(String key, List<List<double>> data) {
    if(!_elements.containsKey(key)) {
      String color = _settings.colors[_elements.length];
      ScatterSerie serie = new ScatterSerie(data, color);
      _elements[key] = serie;
      _container.children.add(serie.toSvg());
      
      if(legend != null) {
        legend.addDataPoint(key, 0.0, color);
      }
    }
    refresh();
  }
  
  void addDatapointFirst(String serieKey, double x, double y) {
    if (_elements.containsKey(serieKey)) {
      _elements[serieKey].AddDatapointFirst(x, y);
    }
  }
  
  void addDatapointLast(String serieKey, double x, double y) {
    if (_elements.containsKey(serieKey)) {
      _elements[serieKey].AddDatapointLast(x, y);
    }
  }
  
  void addDatapoint(String serieKey, int index, double x, double y) {
    if (_elements.containsKey(serieKey)) {
      _elements[serieKey].AddDatapoint(index, x, y);
    }
  }
  
  void updateDatapoint(String serieKey, int index, double x, double y) {
    if (_elements.containsKey(serieKey)) {
      if (_elements[serieKey].points.length > index && index >= 0) {
        _elements[serieKey].points[index]
          ..xValue = x
          ..yValue = y;
        refresh();
      }
    }
  }
  
  bool removeDatapoint(String serieKey, int index) {
    if (_elements.containsKey(serieKey)) {
      return _elements[serieKey].RemoveDatapoint(index);
    }
    return false;
  }
  
  bool removeDatapointFirst(String serieKey) {
    if (_elements.containsKey(serieKey)) {
      _elements[serieKey].RemoveDatapointFirst();
    }
    return false;
  }
  
  bool removeDatapointLast(String serieKey) {
    if (_elements.containsKey(serieKey)) {
      _elements[serieKey].RemoveDatapointLast();
    }
    return false;
  }
  
  int seriesCount(String serieKey) {
    if (_elements.containsKey(serieKey)) {
      return _elements[serieKey].points.length;
    }
    return 0;
  }

  void refresh() {
    _elements.forEach((_,value) {
      if (_settings.showLinesBetweenPoints) {
        value.showLines();
      } else {
        value.hideLines();
      }
    });

    //Analyze data, Find bounds.
    double highestX, highestY;
    double lowestX, lowestY;
    
    _elements.forEach((_, value) {
      if(highestX == null) {
        for(ScatterPoint point in value.points) {
          lowestX = point.xValue;
          lowestY = point.yValue;
          
          highestX = point.xValue;
          highestY = point.yValue;
          break;
        }
      }
    });
    
    _elements.forEach((_, value) {
      for(ScatterPoint point in value.points) {
        if (point.xValue > highestX) {
          highestX = point.xValue;
        }

        if (point.yValue > highestY) {
          highestY = point.yValue;
        }
      }
    });
    if(highestX == null) {
      lowestX = 0.0;
      lowestY = 0.0;
      
      highestX = 0.0;
      highestY = 0.0;
    }
    
    
    if (_settings.fitXAxis) {
      highestX = fittedAxisTopValue(highestX);
    }
    
    if (_settings.fitYAxis) {
      highestY = fittedAxisTopValue(highestY);
    }

    //Make sure that the right amount of gridLines are there.
    _axis.makeSureThatGridLinesAndMarksCount(_settings.numberOfVerticalGridLines, _settings.numberOfHorizontalGridLines);
    
    //Draw: Axis, Labels, legend
    double topPadding = 10.0;
    double bx = 5.0, by = 5.0;
    _yLabel
      ..attributes['x'] = (bx - _yLabel.getBBox().width/2).toString()
      ..attributes['y'] = (_settings.height/2).toString()
      ..attributes['transform'] = 'rotate(-90 ${bx + _yLabel.getBBox().height/2} ${_settings.height/2})';

    _xLabel
        ..attributes['x'] = (_settings.width / 2 - _xLabel.getBBox().width / 2).toString()
        ..attributes['y'] = (_settings.height - by).toString();

    double widestYGridText = 0.0;
    for(var item in _axis.yAxisGridTexts) {
      if (item.getBBox().width > widestYGridText) {
        widestYGridText = item.getBBox().width;
      }
    }
    
    double xGridTextHeight = 0.0;
    if (_axis.xAxisGridTexts.length > 0) {
      xGridTextHeight = _axis.xAxisGridTexts.first.getBBox().height;
    }
    
    double ex = 5.0, ey = 5.0;
    double HW = 5.0, HH = 5.0;
    double graphHeight = _settings.height - by - topPadding - _xLabel.getBBox().height - ey - xGridTextHeight - HH,
           graphWidth = _settings.width - 2*by - _yLabel.getBBox().height - ex - widestYGridText - HW - _settings.axisLineThickness - _settings.legendWidth;
    double graphX = _settings.width - graphWidth - by - _settings.legendWidth,
           graphY = graphHeight + topPadding; //TODO

    for (int i = 0; i < _axis.verticalGridLines.length; i += 1) {
      _axis.verticalGridLines[i]
        ..attributes['x1'] = ( ((i+1)/_axis.verticalGridLines.length) * graphWidth + graphX ).toString()
        ..attributes['y1'] = (graphY).toString()
        ..attributes['x2'] = ( ((i+1)/_axis.verticalGridLines.length) * graphWidth + graphX).toString()
        ..attributes['y2'] = (graphY - graphHeight).toString();
    }

    for (int i = 0; i < _axis.horizontalGridLines.length; i += 1) {
      _axis.horizontalGridLines[i]
        ..attributes['x1'] = ( graphX ).toString()
        ..attributes['y1'] = ( graphY - ((i+1)/_axis.horizontalGridLines.length) * graphHeight ).toString()
        ..attributes['x2'] = ( graphX + graphWidth).toString()
        ..attributes['y2'] = ( graphY - ((i+1)/_axis.horizontalGridLines.length) * graphHeight ).toString();
    }
    
    double GH = graphHeight / _settings.numberOfHorizontalGridLines;
    double GW = graphWidth / _settings.numberOfVerticalGridLines;
    for(int i = 0; i < _axis.xAxisGridTexts.length; i += 1) {
      _axis.xAxisGridTexts[i]
        ..attributes['x'] = ( graphX + (i) * GW ).toString()
        ..attributes['y'] = (topPadding +  graphHeight + _settings.axisLineThickness + HH ).toString();
      
      if(_settings.xAxisType == 'datetime') {
        
        int epochTime = ((i) / _axis.verticalGridLines.length * (highestX - lowestX) + lowestX).toInt();
        _axis.xAxisGridTexts[i]
        ..text = new DateFormat(DateFormat.HOUR24_MINUTE_SECOND).format( new DateTime.fromMillisecondsSinceEpoch( epochTime ));
      } else {
        _axis.xAxisGridTexts[i]
        ..text = ( (i)/_axis.verticalGridLines.length * (highestX - lowestX) + lowestX).toStringAsFixed(_settings.xAxisDecimals);
      }
    }
    
    for(int i = 0; i < _axis.yAxisGridTexts.length; i += 1) {
      _axis.yAxisGridTexts[i]
      ..text = ( (i+1)/_axis.horizontalGridLines.length * highestY).toStringAsFixed(_settings.yAxisDecimals)
      ..attributes['x'] = (by + _yLabel.getBBox().height + ex + widestYGridText - _axis.yAxisGridTexts[i].getBBox().width).toString()
      ..attributes['y'] = (graphY - ((i+1) * GH)).toString();
    }

    _drawPoints(graphX, graphY, graphWidth, graphHeight,lowestX, lowestY, highestX, highestY);
    
    if(legend != null) {
      legend.refresh();
    }
  }

  double pointPlacement(double value, double low, double high, double width) {
    return (value* width - low * width) / (high-low);
  }
  
  void _drawPoints(double x, double y, double width, double height, double lowestGridPointX, double lowestGridPointY, double HighestGridPointX, double HighestGridPointY) {
    _elements.forEach((_, value) {
      for(ScatterPoint point in value.points) {
        point.point
          //..attributes['cx'] = ((point.xValue / HighestGridPointX) * width + x).toString()
          ..attributes['cy'] = (y-((point.yValue / HighestGridPointY) * height)).toString();
        
        point.point
          ..attributes['cx'] = (pointPlacement(point.xValue, lowestGridPointX, HighestGridPointX, width) + x).toString();
      }

      for(ScatterLine line in value.lines) {
        double x1 = (line.start.xValue / HighestGridPointX * width + x);
        double y1 = (y-(line.start.yValue / HighestGridPointY * height));
        double x2 = (line.end.xValue / HighestGridPointX * width + x);
        double y2 = (y-(line.end.yValue / HighestGridPointY * height));
        
        x1 = pointPlacement(line.start.xValue, lowestGridPointX, HighestGridPointX, width) + x;
        x2 = pointPlacement(line.end.xValue, lowestGridPointX, HighestGridPointX, width) + x;
        
        line.line
          ..attributes['x1'] = x1.toString()
          ..attributes['y1'] = y1.toString()
          ..attributes['x2'] = x2.toString()
          ..attributes['y2'] = y2.toString()
          ..attributes['stroke'] = value.color
          ..attributes['stroke-width'] = (2).toString();
      }
    });

    //Drawing Axis
    _axis.xAxis
      ..attributes['x'] = (x - _settings.axisLineThickness).toString()
      ..attributes['y'] = y.toString()
      ..attributes['width'] = (width + _settings.axisLineThickness).toString()
      ..attributes['height'] = _settings.axisLineThickness.toString();

    _axis.yAxis
      ..attributes['x'] = (x - _settings.axisLineThickness).toString()
      ..attributes['y'] = (y-height).toString()
      ..attributes['width'] = _settings.axisLineThickness.toString()
      ..attributes['height'] = (height + _settings.axisLineThickness).toString();
  }

  svg.SvgElement toSvg() {
    return _container;
  }
}

class ScatterSerie {
  static const double pointRadius = 3.5;
  String color;
  svg.GElement container = new svg.GElement();
  svg.GElement linesContainer = new svg.GElement();

  List<ScatterPoint> points = new List<ScatterPoint>();
  List<ScatterLine> lines = new List<ScatterLine>();

  ScatterSerie(List<List<double>> data, this.color) {
    const int x = 0;
    const int y = 1;

    if (data != null && data.length == 2 && data[x].length == data[y].length) {
      ScatterPoint previusPoint;
      for(int row = 0; row < data[x].length; row += 1) {
        ScatterPoint point = makePoint(data[x][row], data[y][row]);
        points.add(point);
        container.children.add(point.toSvg());

        if(previusPoint != null) {
          ScatterLine line = new ScatterLine(previusPoint, point);
          lines.add(line);
          linesContainer.children.add(line.toSvg());
        }

        previusPoint = point;
      }
    }
  }
  
  bool RemoveDatapoint(int index) {
    if (index == 0) {
      return RemoveDatapointFirst();
      
    } else if (index == points.length -1) {
      return RemoveDatapointLast();
      
    } else if(index >= 0 && index < points.length){
      var firstLineRemoved = linesContainer.children.remove(lines.removeAt(index -1).toSvg());
      var secondLineRemoved = linesContainer.children.remove(lines.removeAt(index -1).toSvg());
      var pointRemoved = container.children.remove(points.removeAt(index).toSvg());
      
      ScatterPoint previusPoint = points[index-1];
      ScatterPoint nextPoint = points[index];
      
      ScatterLine line = new ScatterLine(previusPoint, nextPoint);
      lines.insert(index -1 ,line);
      linesContainer.children.add(line.toSvg());
      
      
      return firstLineRemoved || secondLineRemoved || pointRemoved;
      
    }else {
      return false;
    }
  }
  
  bool RemoveDatapointLast() {
    var pointRemoved = container.children.remove(points.removeAt(points.length -1).toSvg());
    var lineRemoved = linesContainer.children.remove(lines.removeAt(lines.length -1).toSvg());
    return pointRemoved || lineRemoved;
  }
  
  bool RemoveDatapointFirst() {
    var pointRemoved = container.children.remove(points.removeAt(0).toSvg());
    var lineRemoved = linesContainer.children.remove(lines.removeAt(0).toSvg());
    return pointRemoved || lineRemoved;
  }
    
  void AddDatapointFirst(double x, double y) {
    ScatterPoint point = makePoint(x, y);
    
    if(points.length > 1) {
      ScatterLine line = new ScatterLine(point, points.first);
      lines.insert(0, line);
      linesContainer.children.insert(0, line.toSvg());
    }
    
    container.children.add(point.toSvg());
    points.insert(0, point);
  }
  
  void AddDatapointLast(double x, double y) {
    ScatterPoint point = makePoint(x, y);
    
    if(points.length >= 1) {
      ScatterLine line = new ScatterLine(points.last, point);
      lines.add(line);
      linesContainer.children.add(line.toSvg());
    }

    container.children.add(point.toSvg());
    points.add(point);
  }

  ScatterPoint makePoint(double x, double y) {
    ScatterPoint point = new ScatterPoint(x, y)
    //TODO Radius should be a setting
      ..point.attributes['r'] = (pointRadius).toString()
      ..point.attributes['fill'] = color;
    return point;
  }
  
  void AddDatapoint(int index, double x, double y) {
    if (index == 0) {
      AddDatapointFirst(x, y);
      
    } else if (index == points.length -1) {
      AddDatapointLast(x, y);
      
    } else if (points.length-1 > index && index > 0) {
      //Removes line between to points, that no longer should be connected.
      ScatterLine line = lines.removeAt(index-1);
      linesContainer.children.remove(line.toSvg());
      
      ScatterPoint point = makePoint(x, y);
      ScatterPoint previusPoint = points[index-1];
      ScatterPoint nextPoint = points[index];
      

      ScatterLine previusLine = new ScatterLine(previusPoint, point);
      lines.insert(index -1 ,previusLine);
      linesContainer.children.add(previusLine.toSvg());
      
      ScatterLine nextLine = new ScatterLine(point, nextPoint);
      lines.insert(index,nextLine);
      linesContainer.children.add(nextLine.toSvg());

      container.children.add(point.toSvg());
      points.insert(index, point);
    }
  }

  void hideLines() {
    if (container.children.contains(linesContainer)) {
      container.children.remove(linesContainer);
    }
  }

  void showLines() {
    if (!container.children.contains(linesContainer)) {
      container.children.add(linesContainer);
    }
  }

  svg.SvgElement toSvg() {
    return container;
  }
}

class ScatterLine {
  ScatterPoint start, end;
  svg.LineElement line = new svg.LineElement();

  ScatterLine(this.start, this.end);

  svg.SvgElement toSvg() {
    return line;
  }
}

class ScatterPoint {
  double xValue, yValue;
  svg.CircleElement point = new svg.CircleElement();

  ScatterPoint(this.xValue, this.yValue);

  svg.SvgElement toSvg() {
    return point;
  }
}

class ScatterAxis {
  svg.GElement container = new svg.GElement();
  svg.RectElement xAxis = new svg.RectElement();
  svg.RectElement yAxis = new svg.RectElement();
  List<svg.LineElement> verticalGridLines = new List<svg.LineElement>();
  List<svg.LineElement> horizontalGridLines = new List<svg.LineElement>();
  List<svg.TextElement> yAxisGridTexts = new List<svg.TextElement>();
  List<svg.TextElement> xAxisGridTexts = new List<svg.TextElement>();
  
  ScatterAxis() {
    container.children.add(xAxis);
    container.children.add(yAxis);

    xAxis
      ..attributes['fill'] = 'black';

    yAxis
      ..attributes['fill'] = 'black';
  }
  
  void makeSureThatGridLinesAndMarksCount (int verticalCount, int horizontalCount) {
    assert(verticalCount >= 0);
    assert(horizontalCount >= 0);
    
    while(verticalGridLines.length != verticalCount) {
      if (verticalGridLines.length < verticalCount) {
        svg.LineElement line = new svg.LineElement()
          ..attributes['stroke'] = '#cccccc'
          ..attributes['stroke-width'] = '1';
        verticalGridLines.add(line);
        container.children.add(line);
      } else {
        svg.LineElement line = verticalGridLines.removeLast();
        container.children.remove(line);
      }
    }
    
    while(horizontalGridLines.length != horizontalCount) {
      if (horizontalGridLines.length < horizontalCount) {
        svg.LineElement line = new svg.LineElement()
          ..attributes['stroke'] = '#cccccc'
          ..attributes['stroke-width'] = '1';
        horizontalGridLines.add(line);
        container.children.add(line);

      } else {
        svg.LineElement line = horizontalGridLines.removeLast();
        container.children.remove(line);

      }
    }
    
    while(xAxisGridTexts.length != verticalCount +1) {
      if (xAxisGridTexts.length < verticalCount +1) {
        svg.TextElement text = new svg.TextElement()
          ..attributes['style'] = 'dominant-baseline: text-before-edge; text-anchor: middle;';
        xAxisGridTexts.add(text);
        container.children.add(text);
        
      } else {
        svg.TextElement text = xAxisGridTexts.removeLast();
        container.children.remove(text);
      }
    }
    
    while(yAxisGridTexts.length != verticalCount) {
      if (yAxisGridTexts.length < verticalCount) {
        svg.TextElement text = new svg.TextElement()
          ..attributes['dominant-baseline'] = 'middle'
          ..attributes['text-anchor'] = 'start';
        yAxisGridTexts.add(text);
        container.children.add(text);
        
      } else {
        svg.TextElement text = yAxisGridTexts.removeLast();
        container.children.remove(text);
      }
    }
  }

  svg.SvgElement toSvg() {
    return container;
  }
}

class ScatterSettings {
  List<String> colors = ['#3366cc', '#109618', '#dc3912', '#990099', '#0099c6', '#dd4477', '#66aa00', '#b82e2e', '#316395', '#b77322', '#329262', '#651067', '#8b0707', '#e67300', '#6633cc', '#aaaa11', '#22aa99', '#994499'];
  bool showLinesBetweenPoints = false;
  double height = 400.0;
  double width = 600.0;
  String xAxisLabelText = 'X Axis Label';
  String yAxisLabelText = 'Y Axis Label is awesome';
  double axisLineThickness = 3.0;
  int numberOfVerticalGridLines = 5;
  int numberOfHorizontalGridLines = 5;
  int xAxisDecimals = 2;
  int yAxisDecimals = 2;
  bool fitXAxis = false;
  bool fitYAxis = true;
  double legendWidth = 110.0;
  double legendHeight = 200.0;
  String xAxisType = 'numeric'; //'numeric', 'datetime'
}
