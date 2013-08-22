import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'dart:math';
import 'dart:svg';

import 'chart.dart';

void main() {
  SvgSvgElement chartSvg = query('#averageCallTimeSvg');
  averageAgentTime(chartSvg);
}

double thomasTime = 30.0;
double alphaTime = 30.0;
double betaTime = 30.0;
double deltaTime = 30.0;
double amplitude = 5.0;
Random ran = new Random();
void averageAgentTime(SvgSvgElement container) {
  ScatterSettings settings = new ScatterSettings()
    ..xAxisType = 'datetime'
    ..width = 1700.0
    ..height = 400.0
    ..numberOfHorizontalGridLines = 10
    ..numberOfVerticalGridLines = 20
    ..showLinesBetweenPoints = true;
  var chart = new ScatterChart(settings);

  String thomasKey = 'ThomasPreformance';
  String teamKey = 'TeamPreformance';
  chart.addSerie(thomasKey, null);
  chart.addSerie(teamKey, null);
  
  int chartPoints = 120;
  new Timer.periodic(new Duration(milliseconds: 1000), (t) {
    alphaTime = randomnumber(alphaTime, amplitude*1.5);
    betaTime = randomnumber(betaTime, amplitude*2);
    deltaTime = randomnumber(deltaTime, amplitude*3);
    
    double x = new DateTime.now().millisecondsSinceEpoch.toDouble();
    double y = (thomasTime + alphaTime + betaTime +deltaTime) / 4;;
 
    chart.addDatapointLast(teamKey, x, y);
    
    while (chart.seriesCount(teamKey) > chartPoints) {
      chart.removeDatapointFirst(teamKey);
    }
    chart.refresh();
  });
  
  new Timer.periodic(new Duration(milliseconds: 500), (_) {
    double x = new DateTime.now().millisecondsSinceEpoch.toDouble();
    double y = thomasTime;
    chart.addDatapointLast(thomasKey, x, y);
    thomasTime = randomnumber(thomasTime, amplitude);
    
    while (chart.seriesCount(thomasKey) > chartPoints * 2) {
      chart.removeDatapointFirst(thomasKey);
    }
  });
  
  container.children.add(chart.toSvg());
}

double randomnumber(double base, double amplitude) {
  double value = base + ran.nextDouble() * amplitude - amplitude/2;
  if (value < 0.0) {
    return 0.0;
  }
  return value;
}

/*
 * Gennemsnit kaldtid for alle agenter (evt. for holdet.)
 * Gennemsnit vente for sidste kald taget inde for en time.
 * Antal opkald
 * Pie chart for vente tid: 0-10s, 10-20s, 30s +
 */