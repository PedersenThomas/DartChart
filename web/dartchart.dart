import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'dart:svg';

import 'chart.dart';

BarChart bar;
pieChart pie;
int pieIndex = 1, barIndex = 1;
Random ran = new Random();

Map<String, double> sampleData =
{'0': 5.0, '1':8.0, '2': 7.0, '3': 3.0, '4': 8.0, '5': 6.0, '6': 6.0};

Map<String, double> sampleData2 =
{'Alice': 5.0, 'Bob':8.0, 'Chloe': 7.0, 'Dwain': 10.0, 'Elise': 8.0, 'Frederik': 6.0,
 'Grete': 6.0, 'Hans': 12.0, 'Irene': 3333.0, 'Jacob': 1.0, 'Kathrine': 110.0, 'Lars': 490.0,
 'MortensHansome': 5199.0};

void main() {
  setupClickEvents();

  int chartPicker = 3;
  switch(chartPicker){
    case 1:
      drawBarChart();
      break;
    case 2:
      drawPieChart();
      break;
    case 3:
      drawScatterPlot();
      break;
    default:
  }


  //Seth();
}

void setupClickEvents() {
  query('#addElement')
  .onClick.listen((e) {
    if (bar != null) {
      bar.addDatapoint(barIndex.toString(), ran.nextDouble() * 10.0 + 10);
      barIndex += 1;
    } else if(pie != null) {
      pie.addDataPoint(pieIndex.toString(), ran.nextDouble() * 10.0 + 10);
      pieIndex += 1;
    }
  });
  query('#refreshButton')
    .onClick.listen((_){
      print('RefreshButton');
      if (pie != null) {pie.refresh();}
      if (bar != null) {bar.refresh();}
    });
}

void Seth() {
  SvgSvgElement parent = query('#chartSvg');
  var element = new TextElement();
  element.text = 'Dart';
  element.attributes['x'] = '50';
  element.attributes['y'] = '50';
  parent.children.add(element);


  var mo = new MutationObserver((List<MutationRecord> changes, MutationObserver observer) {
    print('Mutation incomming');
    for (MutationRecord change in changes) {
      print(change.target.text);  // lots of data in MutationRecord, check it out in the API
    }
  });

  mo.observe(parent, childList: true, characterData: true, subtree: true);

  new Timer(new Duration(seconds: 1), () {
    print('changing stuff');
    element.text = 'is awesome';
  });
}

void randomUpdate() {
  new Timer.periodic(new Duration(milliseconds: 1000),(_) {
    InputElement item =  query('#switchRandomChange');
    if (item.checked) {
      if (pie != null && pie.count>0){
        pie.updateValue(ran.nextInt(pie.count).toString(), ran.nextDouble() * (30) + 1);
      }
      if(bar != null) {
        bar.updateDatapoint(ran.nextInt(barIndex).toString(), ran.nextDouble() * (30) + 1);
      }
    }
  });
}

void drawBarChart() {
  barIndex = sampleData.length;
  SvgSvgElement e = query('#chartSvg');
  BarchartSettings settings = new BarchartSettings()
    ..width = 800
    ..xAxisLabelText = 'navne, som har ingen betydning for hvorfor denne tekst skulle være så lang'
    ..yAxisLabelText = 'Antal ubesvaredeopkald'
    ..sorted = true
    ..legendSorted = true
    ..legendWidth = 150;

  bar = new BarChart(settings, sampleData);
  e.children.add(bar.toSvg());
  randomUpdate();
  //test(e);
}

void test(SvgSvgElement svg) {
  RectElement rect = new RectElement()
    ..attributes['x'] = '100'
    ..attributes['y'] = '100'
    ..attributes['width'] = '100'
    ..attributes['height'] = '100'
    ..attributes['rx'] = '20'
    ..attributes['ry'] = '20'
    ..attributes['fill'] = 'red';
//svg.children.add(rect);
  int x = 800;
  int y = 100;
  int r = 50;
  PathElement path = new PathElement()
    ..id = 'awesomePath'
    ..attributes['fill'] = 'red'
    ..attributes['d'] = 'M $x $y L ${x+r} ${y} A $r $r 0 1 0 ${x-r} ${y} z';

  svg.children.add(path);
  new Timer(new Duration(milliseconds: 500), () {
    path.attributes['fill'] = 'blue';
    int duration = 5000;
    String newD = 'M $x $y L ${x+r} ${y} A $r $r 0 1 0 ${x} ${y+r} z';
    AnimateElement ATE = new AnimateElement()
      ..attributes['attributeType'] = 'XML'
      ..attributes['attributeName'] = 'd'
      ..attributes['to'] = newD
      ..attributes['dur'] = '${duration}ms'
      ..attributes['fill'] = 'freeze'
      ..attributes['begin'] = 'indefinite';
    path.children.add(ATE);

    String eventName = 'end';

    ATE.beginElement();

    new Timer(new Duration(milliseconds: duration), (){
      path.attributes['d'] = newD;
      path.attributes['fill'] = 'green';
      path.children.remove(ATE);
    });
  });
}

void drawPieChart() {
  pieIndex = sampleData.length;
  SvgSvgElement e = query('#chartSvg');
  pie = new pieChart(sampleData);
  e.children.add(pie.toSvg());
  randomUpdate();
}

void drawScatterPlot() {
  List<List<double>> series1 = new List<List<double>>()
      ..add(new List<double>())
      ..add(new List<double>());
  for (var i = 0; i < 315; i++) {
    double xOffSet = 1.0, yOffset = 1.0;
    double x = (sin(i / 25) +xOffSet);
    double y = (cos(i / 10) * 0.5 +yOffset);
    series1[0].add(x);
    series1[1].add(y);
  }

  List<List<double>> series2 = new List<List<double>>()
      ..add(new List<double>())
      ..add(new List<double>());
  for (var i = 0; i < 158; i++) {
    double xOffSet = 1.0, yOffset = 1.0;
    double x = (sin(i / 5) * 0.5 + xOffSet);
    double y = (cos(i / 25) + yOffset);
    series2[0].add(x);
    series2[1].add(y);
  }

  List<List<double>> series3 = new List<List<double>>()
      ..add(new List<double>())
      ..add(new List<double>());
  int limit = 8;
  for (int i = 1; i < limit; i++) {
    double x = i.toDouble();
    double y = log(i);
    series3[0].add(x/limit * 2);
    series3[1].add(y);
  }

  Map<String, List<List<double>>> data = new Map<String, List<List<double>>>();
  data['SampleData1'] = series1;
  data['SampleData2'] = series2;
  data['SampleData3'] = series3;
  ScatterChart scatter = new ScatterChart(data)
    ..showLinesBetweenPoints = true;
  SvgSvgElement e = query('#chartSvg')
      ..children.add(scatter.toSvg());

  scatter.refresh();

}
