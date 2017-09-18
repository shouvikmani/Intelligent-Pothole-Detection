import pandas as pd
import time
import requests

# url = 'http://localhost:8000/'
url = 'https://ipd-classification-server.herokuapp.com/'


### Pothole Classification Tests

potholeTrip1Data = pd.read_csv('data/trip1_sensors.csv')
potholeTrip2Data = pd.read_csv('data/trip2_sensors.csv')
potholeTrip3Data = pd.read_csv('data/trip3_sensors.csv')

potholeWindow = 10
potholeEndpoint = url + 'classifyPotholes'

def testPotholeClassifier(tripData):
    predictions = []
    times = []
    for i in xrange(0, len(tripData), potholeWindow):
        intervalData = tripData[i:i+potholeWindow]
        intervalDataJSON = intervalData.to_json(orient='records')
        startTime = time.time()
        r = requests.post(potholeEndpoint, data={'sensorData': intervalDataJSON})
        endTime = time.time()
        predictions.append(int(r.text))
        times.append(endTime - startTime)
    print 'Predictions:', predictions
    print 'Number of intervals classified with potholes:', sum(predictions)
    print 'Number of total intervals:', len(predictions)
    print 'Average request length:', (sum(times) / float(len(times)))

print '---Pothole Trip 1---'
testPotholeClassifier(potholeTrip1Data)
print

print '---Pothole Trip 2---'
testPotholeClassifier(potholeTrip2Data)
print

print '---Pothole Trip 3---'
testPotholeClassifier(potholeTrip3Data)
print


### Road Conditions Classification Tests

roadConditionsBadRoad1Data = pd.read_csv('data/bad1_sensors.csv')
roadConditionsBadRoad2Data = pd.read_csv('data/bad2_sensors.csv')
roadConditionsGoodRoad1Data = pd.read_csv('data/good1_sensors.csv')
roadConditionsGoodRoad2Data = pd.read_csv('data/good2_sensors.csv')

roadConditionsWindow = 25
roadConditionsEndpoint = url + 'classifyRoadConditions'

def testRoadConditionsClassifier(tripData):
    predictions = []
    times = []
    for i in xrange(0, len(tripData), roadConditionsWindow):
        intervalData = tripData[i:i+roadConditionsWindow]
        intervalDataJSON = intervalData.to_json(orient='records')
        startTime = time.time()
        r = requests.post(roadConditionsEndpoint, data={'sensorData': intervalDataJSON})
        endTime = time.time()
        predictions.append(float(r.text))
        times.append(endTime - startTime)
    print 'Predictions:', predictions
    print 'Fraction of intervals classified as bad road:', (sum(predictions) / float(len(predictions)))
    print 'Average request length:', (sum(times) / float(len(times)))

print '---Bad Road 1---'
testRoadConditionsClassifier(roadConditionsBadRoad1Data)
print

print '---Bad Road 2---'
testRoadConditionsClassifier(roadConditionsBadRoad2Data)
print

print '---Good Road 1---'
testRoadConditionsClassifier(roadConditionsGoodRoad1Data)
print

print '---Good Road 2---'
testRoadConditionsClassifier(roadConditionsGoodRoad2Data)
print
