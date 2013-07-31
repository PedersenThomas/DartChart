part of Chart;

/**
 * Remarks. It can only handle positive numbers.
 */
class ScatterChart {
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
    });
  }

  svg.SvgElement toSvg() {
    return container;
  }
}

class ScatterSerie {
  String color;
  svg.GElement container = new svg.GElement();
  List<ScatterPoint> points = new List<ScatterPoint>();

  ScatterSerie(List<List<double>> data, this.color) {
    const int x = 0;
    const int y = 1;

    if (data != null || data.length == 2 && data[x].length == data[y].length) {
      for(int row = 0; row < data[x].length; row += 1) {
        ScatterPoint point = new ScatterPoint(data[x][row], data[y][row]);
        points.add(point);
        container.children.add(point.toSvg());
      }
    }
  }

  svg.SvgElement toSvg() {
    return container;
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
