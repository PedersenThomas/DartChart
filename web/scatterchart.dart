part of Chart;

/**
 * Remarks. It can only handle positive numbers.
 */
class ScatterChart {
  ScatterSettings settings;
  ScatterAxis axis = new ScatterAxis();
  List<String> colors = ['#3366cc', '#dc3912', '#109618', '#990099', '#0099c6', '#dd4477', '#66aa00', '#b82e2e', '#316395', '#b77322', '#329262', '#651067', '#8b0707', '#e67300', '#6633cc', '#aaaa11', '#22aa99', '#994499'];
  bool showLinesBetweenPoints = false;
  svg.GElement container = new svg.GElement();
  Map<String, ScatterSerie> elements = new Map<String, ScatterSerie>();

  svg.TextElement xLabel = new svg.TextElement();
  svg.TextElement yLabel = new svg.TextElement();

  ScatterChart(this.settings, [Map<String, List<List<double>>> initialData]) {
    double bx = 5.0, by = 5.0; //FIXME Two bx and by. also found in refresh.
    // Step 1 X/Y-Label
    yLabel
      ..text = settings.yAxisLabelText
      ..attributes['text-anchor'] = 'middel'
      ..attributes['stroke'] = 'none'
      ..attributes['stroke-width'] = '0'
      ..attributes['fill'] = '#222222';

    xLabel
      ..text = settings.xAxisLabelText;

    container.children.add(xLabel);
    container.children.add(yLabel);
    container.children.add(axis.toSvg());

    initialData.forEach((key, value) {
      addSerie(key, value);
    });

  }

  void addSerie(String key, List<List<double>> data) {
    if(!elements.containsKey(key)) {
      String color = colors[elements.length];
      ScatterSerie serie = new ScatterSerie(data, color);
      elements[key] = serie;
      container.children.add(serie.toSvg());
    }
    refresh();
  }

  void refresh() {
    elements.forEach((_,value) {
      if (showLinesBetweenPoints) {
        value.showLines();
      } else {
        value.hideLines();
      }
    });

    //Analyze data, Find bounds.
    double highestX = 0.0, highestY = 0.0;
    elements.forEach((_, value) {
      for(ScatterPoint point in value.points) {
        if (point.xValue > highestX) {
          highestX = point.xValue;
        }

        if (point.yValue > highestY) {
          highestY = point.yValue;
        }
      }
    });

    //Make sure that the right amount of gridLines are there.
    axis.makeSureThatGridLinesAndMarksCount(settings.numberOfVerticalGridLines, settings.numberOfHorizontalGridLines);
    
    //Draw: Axis, Labels, legend
    double topPadding = 10.0;
    double bx = 5.0, by = 5.0;
    yLabel
      ..attributes['x'] = (bx - yLabel.getBBox().width/2).toString()
      ..attributes['y'] = (settings.height/2).toString()
      ..attributes['transform'] = 'rotate(-90 ${bx + yLabel.getBBox().height/2} ${settings.height/2})';

    xLabel
        ..attributes['x'] = (settings.width / 2 - xLabel.getBBox().width / 2).toString()
        ..attributes['y'] = (settings.height - by).toString();

    double widestYGridText = 0.0;
    for(var item in axis.yAxisGridTexts) {
      if (item.getBBox().width > widestYGridText) {
        widestYGridText = item.getBBox().width;
      }
    }
    
    double xGridTextHeight = 0.0;
    if (axis.xAxisGridTexts.length > 0) {
      xGridTextHeight = axis.xAxisGridTexts.first.getBBox().height;
    }
    
    double ex = 5.0, ey = 5.0;
    double graphHeight = settings.height - by - topPadding - xLabel.getBBox().height - ey - xGridTextHeight,
           graphWidth = settings.width - 2*by - yLabel.getBBox().height - ex - widestYGridText - settings.axisLineThickness;
    double graphX = settings.width - graphWidth - by,
           graphY = graphHeight + topPadding; //TODO

    for (int i = 0; i < axis.verticalGridLines.length; i += 1) {
      axis.verticalGridLines[i]
        ..attributes['x1'] = ( ((i+1)/axis.verticalGridLines.length) * graphWidth + graphX ).toString()
        ..attributes['y1'] = (graphY).toString()
        ..attributes['x2'] = ( ((i+1)/axis.verticalGridLines.length) * graphWidth + graphX).toString()
        ..attributes['y2'] = (graphY - graphHeight).toString();
    }

    for (int i = 0; i < axis.horizontalGridLines.length; i += 1) {
      axis.horizontalGridLines[i]
        ..attributes['x1'] = ( graphX ).toString()
        ..attributes['y1'] = ( graphY - ((i+1)/axis.horizontalGridLines.length) * graphHeight ).toString()
        ..attributes['x2'] = ( graphX + graphWidth).toString()
        ..attributes['y2'] = ( graphY - ((i+1)/axis.horizontalGridLines.length) * graphHeight ).toString();
    }
    
    
    double GH = graphHeight / settings.numberOfHorizontalGridLines;
    double GW = graphWidth / settings.numberOfVerticalGridLines;
    for(int i = 0; i < axis.xAxisGridTexts.length; i += 1) {
      axis.xAxisGridTexts[i]
        ..text = ( (i+1)/axis.verticalGridLines.length * highestX).toStringAsFixed(2)
        ..attributes['x'] = ( graphX + (i+1) * GW  ).toString()
        ..attributes['y'] = (topPadding +  graphHeight + settings.axisLineThickness ).toString();
    }
    
    for(int i = 0; i < axis.yAxisGridTexts.length; i += 1) {
      axis.yAxisGridTexts[i]
      ..text = ( (i+1)/axis.horizontalGridLines.length * highestY).toString()
      ..attributes['x'] = (by + yLabel.getBBox().height + ex + widestYGridText - axis.yAxisGridTexts[i].getBBox().width).toString()
      ..attributes['y'] = (graphY - ((i+1) * GH)).toString();
    }

    drawPoints(graphX, graphY, graphWidth, graphHeight, highestX, highestY);
  }

  void drawPoints(double x, double y, double width, double height, double HighestGridPointX, double HighestGridPointY) {
    elements.forEach((_, value) {
      for(ScatterPoint point in value.points) {
        point.point
          ..attributes['cx'] = ((point.xValue / HighestGridPointX) * width + x).toString()
          ..attributes['cy'] = (y-((point.yValue / HighestGridPointY) * height)).toString()
          //TODO MOVE, don't set this each time.
          ..attributes['r'] = '3.5'
          ..attributes['fill'] = value.color;
      }

      for(ScatterLine line in value.lines) {
        double x1 = (line.start.xValue / HighestGridPointX * width + x);
        double y1 = (y-(line.start.yValue / HighestGridPointY * height));
        double x2 = (line.end.xValue / HighestGridPointX * width + x);
        double y2 = (y-(line.end.yValue / HighestGridPointY * height));
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
    axis.xAxis
      ..attributes['x'] = (x - settings.axisLineThickness).toString()
      ..attributes['y'] = y.toString()
      ..attributes['width'] = (width + settings.axisLineThickness).toString()
      ..attributes['height'] = settings.axisLineThickness.toString();

    axis.yAxis
      ..attributes['x'] = (x - settings.axisLineThickness).toString()
      ..attributes['y'] = (y-height).toString()
      ..attributes['width'] = settings.axisLineThickness.toString()
      ..attributes['height'] = (height + settings.axisLineThickness).toString();
  }

  svg.SvgElement toSvg() {
    return container;
  }
}

class ScatterSerie {
  String color;
  svg.GElement container = new svg.GElement();
  svg.GElement linesContainer = new svg.GElement();

  List<ScatterPoint> points = new List<ScatterPoint>();
  List<ScatterLine> lines = new List<ScatterLine>();

  ScatterSerie(List<List<double>> data, this.color) {
    const int x = 0;
    const int y = 1;

    if (data != null || data.length == 2 && data[x].length == data[y].length) {
      ScatterPoint previusPoint;
      for(int row = 0; row < data[x].length; row += 1) {
        ScatterPoint point = new ScatterPoint(data[x][row], data[y][row]);
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

  svg.SvgElement toSvg(){
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
    
    while(xAxisGridTexts.length != verticalCount) {
      if (xAxisGridTexts.length < verticalCount) {
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
          ..attributes['style'] = 'dominant-baseline: text-before-edge; text-anchor: start;';
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
  double height = 400.0;
  double width = 600.0;
  String xAxisLabelText = 'X Axis Label';
  String yAxisLabelText = 'Y Axis Label is awesome';
  double axisLineThickness = 3.0;
  int numberOfVerticalGridLines = 5;
  int numberOfHorizontalGridLines = 5;
}
