part of Chart;

/**
 * Remarks. It can only handle positive numbers.
 */
class ScatterChart {
  bool showLinesBetweenPoints = false;
  svg.GElement container = new svg.GElement();
  Map<String, ScatterSerie> elements = new Map<String, ScatterSerie>();

  ScatterChart([Map<String, List<List<double>>> initialData]) {
    initialData.forEach((key, value) {
      addSerie(key, value);
    });
  }

  void addSerie(String key, List<List<double>> data) {
    if(!elements.containsKey(key)) {
      String color = randomColor();
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


    double x = 100.0, y = 650.0;
    double height = 600.0, width = 800.0;
    //Analyse data, Find bounds.
    double highestX = 0.0, highestY = 0.0;
    elements.forEach((_, value) {
      for(ScatterPoint point in value.points) {
        if (point.x > highestX) {
          highestX = point.x;
        }

        if (point.y > highestY) {
          highestY = point.y;
        }
      }
    });

    drawPoints(x, y, width, height, highestX, highestY);
  }

  void drawPoints(double x, double y, double width, double height, double HighestGridPointX, double HighestGridPointY) {
    elements.forEach((_, value) {
      for(ScatterPoint point in value.points) {
        point.point
          ..attributes['cx'] = (point.x / HighestGridPointX * width + x).toString()
          ..attributes['cy'] = (y-(point.y / HighestGridPointY * height)).toString()
          //TODO MOVE, don't set this each time.
          ..attributes['r'] = '3.5'
          ..attributes['fill'] = value.color;
      }

      for(ScatterLine line in value.lines) {
        double x1 = (line.start.x / HighestGridPointX * width + x);
        double y1 = (y-(line.start.y / HighestGridPointY * height));
        double x2 = (line.end.x / HighestGridPointX * width + x);
        double y2 = (y-(line.end.y / HighestGridPointY * height));
        line.line
          ..attributes['x1'] = x1.toString()
          ..attributes['y1'] = y1.toString()
          ..attributes['x2'] = x2.toString()
          ..attributes['y2'] = y2.toString()
          ..attributes['stroke'] = value.color
          ..attributes['stroke-width'] = (1).toString();
      }
    });
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
  double x, y;
  svg.CircleElement point = new svg.CircleElement();

  ScatterPoint(this.x, this.y);

  svg.SvgElement toSvg(){
    return point;
  }
}
