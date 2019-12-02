import csv
import os
import numbers
from collections import Counter
import plotly
import time
import cpuinfo
from shutil import copyfile
#import plotly.offline as offline
import plotly.graph_objs as go

dirname = os.path.dirname(__file__)
resultsDir = os.path.join(dirname, '../Results')
graphsDir = os.path.join(dirname, '../Graphs')

def calculateAverages(data):
    averagesList = []
    for technology in data:
        averages = Counter()
        for iteration in technology:
            for k, v in iteration.items():
                averages[k] += int(v)
        for i in averages:
            averages[i] /= len(technology)
        averagesList.append(averages)
    return averagesList

def buildTable(dataAverages, files, outputDir):
    headerValues = []
    tests = []
    values = []
    qtyOfTech = len(files)
    headerValues.append(['<b>Test</b>'])
    for file in files:
        text = '<b>' + os.path.splitext(file)[0] + '</b>'
        headerValues.append([text])
    for i in range(qtyOfTech -1 ):
        text = '<b>' + os.path.splitext(files[i])[0] + '/' + os.path.splitext(files[qtyOfTech-1])[0] + '</b>'
        headerValues.append([text])

    #Get tests names
    for idx, tech in enumerate(dataAverages):
        for test in tech:
            if test not in tests:
                tests.append(test)
    values.append(tests)

    #Populate value array
    for i in range((len(dataAverages)*2)-1):
        l = ["N/A"] * len(tests)
        values.append(l)
    for idx, tech in enumerate(dataAverages):
        for test in tech:
            i = tests.index(test)
            values[idx+1][i] = tech[test]
    for i in range(qtyOfTech -1 ):
        for j in range(len(values[0])):
            if(isinstance(values[i + 1][j], numbers.Number) and  isinstance(values[qtyOfTech][j], numbers.Number)):
                values[qtyOfTech + i + 1][j] = "{:.4f}".format(float(values[i + 1][j]) / values[qtyOfTech][j])
    #format with comas
    for idx, tech in enumerate(dataAverages):
        for test in tech:
            i = tests.index(test)
            values[idx+1][i] = "{:,}".format(values[idx+1][i])

    headerColor = 'grey'
    rowEvenColor = 'lightgrey'
    rowOddColor = 'white'
    trace = go.Table(
        header = dict(
            values = headerValues,
            line = dict(color = '#506784'),
            fill = dict(color = headerColor),
            align = ['left','center'],
            font = dict(color = 'white', size = 12)
        ),
        cells = dict(
            values = values,
            line = dict(color = '#506784'),align = ['left', 'center'],
            font = dict(color = '#506784', size = 11)
        )
    )
    filename = os.path.join(outputDir , "comparison-table.html")
    plotly.offline.plot([trace], filename=filename)

def buildBarChart(dataAverages, files, outputDir):
    traces = []
    for idx, tech in enumerate(dataAverages):
        if(os.path.splitext(files[idx])[0] != "Set"):
            tests = []
            values = []
            for test in tech:
                tests.append(test)
                values.append(tech[test])
            traces.append(go.Bar(
                x=tests,
                y=values,
                name=os.path.splitext(files[idx])[0]
            ))
    layout = go.Layout(
        barmode='group',
        title="Speed comparison in nanoseconds of the different bitmap features. (smaller = better)",
        yaxis={'title': 'Execution time (nanoseconds)', 'type':"log"},
        )
    filename = os.path.join(outputDir , "bar-chart.html")
    fig = go.Figure(data=traces, layout=layout)
    plotly.offline.plot(fig, filename=filename)

def buildGraphs(files, datasetName, root):
    data = []
    
    for file in files:
        with open( os.path.join(root, file), 'r' ) as theFile:
            reader = csv.DictReader(theFile)
            d = []
            for line in reader:
                d.append(line)
            data.append(d)

    dataAverages = calculateAverages(data)
    outputDir = os.path.join(graphsDir, cpuinfo.get_cpu_info()['brand'], datasetName) 
    if not os.path.exists(outputDir):
        os.makedirs(outputDir)
    buildTable(dataAverages, files, outputDir)
    buildBarChart(dataAverages, files, outputDir)

for subdir, dirs, files in os.walk(resultsDir):
    for d in dirs:
        for s, di, f in os.walk(os.path.join(subdir, d)):
            if("SwiftRoaring.csv" in f):
                f.remove("SwiftRoaring.csv")
                f.append("SwiftRoaring.csv")
            buildGraphs(f, d, os.path.join(subdir, d))





