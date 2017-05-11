from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.conf import settings

import os
import pandas as pd
import cPickle as pickle

def index(request):
    return HttpResponse('Hello')

@csrf_exempt
def classifyPotholes(request):
    rawSensorData = request.POST['sensorData']
    rawSensorData = rawSensorData.replace("'", '"')   # Standardize request data
    rawSensorDF = pd.read_json(rawSensorData, orient='records')
    sensorAggregatesDF = getSensorIntervalAggregates(rawSensorDF)
    classifierFilePath = os.path.join(settings.STATIC_ROOT, 'potholeClassifier.p')
    classifier = pickle.load(open(classifierFilePath, 'rb'))
    clf = classifier['classifier']
    threshold = classifier['threshold']
    y_score = clf.decision_function(sensorAggregatesDF)
    y_pred = (y_score >= threshold).astype(int)
    return HttpResponse(y_pred)

@csrf_exempt
def classifyRoadConditions(request):
    rawSensorData = request.POST['sensorData']
    rawSensorData = rawSensorData.replace("'", '"')   # Standardize request data
    rawSensorDF = pd.read_json(rawSensorData, orient='records')
    sensorAggregatesDF = getSensorIntervalAggregates(rawSensorDF)
    classifierFilePath = os.path.join(settings.STATIC_ROOT, 'roadConditionsClassifier.p')
    classifier = pickle.load(open(classifierFilePath, 'rb'))
    clf = classifier['classifier']
    y_pred = clf.predict(sensorAggregatesDF)
    return HttpResponse(y_pred)

def getSensorIntervalAggregates(rawSensorDF):
    meanSpeed, sdSpeed = rawSensorDF['speed'].mean(), rawSensorDF['speed'].std()
    maxAccelX, minAccelX = rawSensorDF['accelerometerX'].max(), rawSensorDF['accelerometerX'].min()
    maxAccelY, minAccelY = rawSensorDF['accelerometerY'].max(), rawSensorDF['accelerometerY'].min()
    maxAccelZ, minAccelZ = rawSensorDF['accelerometerZ'].max(), rawSensorDF['accelerometerZ'].min()
    maxGyroX, minGyroX = rawSensorDF['gyroX'].max(), rawSensorDF['gyroX'].min()
    maxGyroY, minGyroY = rawSensorDF['gyroY'].max(), rawSensorDF['gyroY'].min()
    maxGyroZ, minGyroZ = rawSensorDF['gyroZ'].max(), rawSensorDF['gyroZ'].min()
    meanAccelX, sdAccelX = rawSensorDF['accelerometerX'].mean(), rawSensorDF['accelerometerX'].std()
    meanAccelY, sdAccelY = rawSensorDF['accelerometerY'].mean(), rawSensorDF['accelerometerY'].std()
    meanAccelZ, sdAccelZ = rawSensorDF['accelerometerZ'].mean(), rawSensorDF['accelerometerZ'].std()
    meanGyroX, sdGyroX = rawSensorDF['gyroX'].mean(), rawSensorDF['gyroX'].std()
    meanGyroY, sdGyroY = rawSensorDF['gyroY'].mean(), rawSensorDF['gyroY'].std()
    meanGyroZ, sdGyroZ = rawSensorDF['gyroZ'].mean(), rawSensorDF['gyroZ'].std()
    intervalAggregates = [[meanSpeed, sdSpeed, maxAccelX, maxAccelY, maxAccelZ,
                            maxGyroX, maxGyroY, maxGyroZ, minAccelX, minAccelY, minAccelZ, minGyroX, minGyroY,minGyroZ, meanAccelX, meanAccelY, meanAccelZ, meanGyroX, meanGyroY, meanGyroZ,sdAccelX, sdAccelY, sdAccelZ, sdGyroX, sdGyroY, sdGyroZ]]
    return intervalAggregates
