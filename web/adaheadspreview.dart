import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'dart:math';
import 'dart:svg';

import 'chart.dart';

void main() {
  SvgSvgElement callTimeSvg = query('#averageCallTimeSvg');
  averageAgentTime(callTimeSvg);
  
  SvgSvgElement waitingSvg = query('#waitingTimeSvg');
  waitingTime(waitingSvg);
}

double zero = 0.0, ten = 0.0, twenty = 0.0, thirty = 0.0;
String zeroKey = '0-10';
String tenKey = '10-20';
String twentyKey = '20-30';
String thirtyKey = '30+';
void waitingTime(SvgSvgElement container) {
  double height = 600.0;
  container.attributes['height'] = height.toString();
  pieChart chart = new pieChart();
  container.children.add(chart.toSvg());
  
  chart
    ..addDataPoint(zeroKey, zero)
    ..addDataPoint(tenKey, ten)
    ..addDataPoint(twentyKey, twenty)
    ..addDataPoint(thirtyKey, thirty);
  
  new Timer.periodic(new Duration(milliseconds: 1000), (_) {
    int choice = ran.nextInt(10);
    switch(choice){
      case 0:
      case 4:
      case 5:
        zero += 1.0;
        chart.updateValue(zeroKey, zero);
        break;
        
      case 1:
      case 6:
      case 8:
      case 9:
        ten += 1.0;
        chart.updateValue(tenKey, ten);
        break;
        
      case 2:
      case 7:
        twenty += 1.0;
        chart.updateValue(twentyKey, twenty);
        break;
        
      case 3:
        thirty += 1.0;
        chart.updateValue(thirtyKey, thirty);
        break;
    }
  });
}


double thomasTime = 30.0;
double alphaTime = 30.0;
double betaTime = 30.0;
double deltaTime = 30.0;
double amplitude = 5.0;
Random ran = new Random();
void averageAgentTime(SvgSvgElement container) {
  double height = 400.0;
  container.attributes['height'] = height.toString();
  
  ScatterSettings settings = new ScatterSettings()
    ..xAxisLabelText = 'Tidspunkt'
    ..yAxisLabelText = 'Gennemsnit antal sekunder for samtaletiden.'
    ..xAxisType = 'datetime'
    ..width = 1700.0
    ..height = height
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