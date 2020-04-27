'''
    Solace monitoring queue.
        script conects tothe solace json website and extract queue informaiton to monitor hightes usages, and plot trends
'''

import requests
import html
import json
import time
import os
from datetime import datetime
import tkinter
from tkinter import messagebox
from collections import OrderedDict
import pylab as pl
import math


#Configuration
#################################################################################
#VPNs URL
#Specify VPN's URL below, one per dictionary entry
urldic = OrderedDict() 
urldic[''] = ''

sleepTimeMinutes = 15 #Minutes to wait between calls
threshold = 0.5 #percentage threashold for queues
#################################################################################

'''
Queue Class: consist of a dictionary object containing queue name and historic queue messages count
    Attributes
        Queue name - String
        Queue usage - Numeric. Holds historic nomber of messages in queue.
        Queue quota - Numeric. Holds maximum quota allow in the queue.
    Methods
        setUsage(Name, Usage) - set the usage that a specific queue has
        getUsage(Name) - returns value of all the usages recorded for a specific queue
        setQuota(Name, Quota) - set the maximum quota a queue is allowed
        getQuota(Name) - returns value of the maximum quota of a specific queue
        lastUsage(Name) - returns value of the last usage recorded for a specific queue
        clearOld() - deletes queues that has not been updated in the las hour
        plotQ() - creates plots for the top 6 queues, displaying last seven records
'''
class Queue(object):
    #Constructor
    def __init__(self): 
        self.queueDic = {}
        
    #Print queues, and usages, basically print the entire dictionary        
    def __str__(self):
        return str(self.queueDic)

    #Set queue usage 
    def setUsage(self, queueName, queueUsage):
        if queueName in self.queueDic:
             self.queueDic[queueName][str(datetime.now().strftime("%Y-%b-%d %H:%M:%S"))] = queueUsage
        else:
            self.queueDic[queueName] = {}
            self.queueDic[queueName][str(datetime.now().strftime("%Y-%b-%d %H:%M:%S"))] = queueUsage

    #Get queue usage
    def getUsage(self, queueName):
        return self.queueDic[queueName]
    
    #Set queue quota
    def setQuota(self, queueName, queueQuota):
        if queueName in self.queueDic:
            self.queueDic[queueName]['quota'] = queueQuota
        else:
            self.queueDic[queueName] = {}
            self.queueDic[queueName]['quota'] = queueQuota

    #Get queue quota
    def getQuota(self, queueName):
            return self.queueDic[queueName].get('quota')


    #Return the last message count registered for a specific queue.
    def lastUsage(self, queueName):
        return list(self.queueDic[queueName].values())[-1]

    #Clear old queues from object
    def clearOld(self):
        delKeys = []
        queues = self.queueDic
        for q in queues:
            if  (datetime.now() - datetime.strptime(str(list(queues[q].keys())[-1]),"%Y-%b-%d %H:%M:%S")).seconds > 3600:
                delKeys.append(q)
        if len(delKeys) != 0:
            pass
        print("\n\n**************************")
        print("Deleted queues due to inactivity" )
        for d in delKeys:
            print(str(d))
            del queues[d]
        print("\n**************************")

    #Plotting Queues
    def plotQ(self, sleepTime):
        queues = self.queueDic
        queueSize = {}
        plottedQueues = []
        plotRow = 2
        #Selecting top plots to display
        if len(queues.keys()) >= 3:
            plotCol = 3
            for q in queues:
                #Selecting the second largest value in the dict. the larges it the quota value
                queueSize[q] = sorted(queues[q].values())[-2] / int(self.getQuota(q))
        else:
            plotCol = math.ceil(len(queues.keys()) / 2)
        pl.ion()
        pl.figure('plots')
        pl.clf()
        i=1
        #Sorting queue by sizes
        queueSize = {k: v for k, v in sorted(queueSize.items(), key=lambda item: item[1], reverse=True)}

        #Plotting queues
        for q in list(queueSize.keys())[:6]:
            x, y = zip(*queues[q].items())
            xplot = [datetime.strptime(t,"%Y-%b-%d %H:%M:%S").time().strftime("%H:%M") for t in x[1:]]
            pl.subplot(plotRow,plotCol,i)
            pl.title(q, fontsize=10)
            #Removing the quota from the list to plot, and creating horizontal line
            if len(y) > 7:
                yplot = y[-7:]
                #pl.hlines(self.getQuota(q), xmin = xplot[-7], xmax = xplot[-1] ,color = 'r')
            else:
                yplot = y[1:]
                #pl.hlines(self.getQuota(q), xmin = xplot[0], xmax = xplot[-1] ,color = 'r')
            pl.plot(xplot[-7:], yplot)
            i += 1
        pl.draw()
        #pl.pause(sleepTime)
        pl.gcf().canvas.draw_idle()
        pl.gcf().canvas.start_event_loop(sleepTime)



#Variables
sleepTime = sleepTimeMinutes * 60
queueName =""
queueUsage = 0

#Creating queue object
queueObj = Queue()

# Creating Tkinter window
# This code is to hide the main tkinter window
root = tkinter.Tk()
root.withdraw()

while True:
    print('\n' + str(datetime.now().strftime("%Y-%b-%d %H:%M:%S")))
    for vpn, url in urldic.items():
        try:
            #Requesting VPN page]
            page = requests.get(url)
        except requests.exceptions.RequestException as e:
            print('Error connecting to ' + vpn + ' VPN')
            print(e)
        else:
            #Converting to JSON
            queues = json.loads(page.text)

            #Printing Results
            print('\n' + vpn.rjust(35) + " VPN")
            print("Queue Name".ljust(55) + "Messages".ljust(10) + "Usage")
            for queue in queues['vpnstats']['queues']['queue']:
                if queue['nummsgsspooled'] != 0:
                    queueName = queue['queuename']
                    queueUsage = queue['nummsgsspooled']
                    queueObj.setQuota(queueName,queueUsage * queue['quota'] / queue['spoolusage'] )
                    queueObj.setUsage(queueName,queueUsage)
                    #Checking spool usage 
                    if queue['spoolusage'] / queue['quota'] > threshold :
                        # Message Box
                        messagebox.showerror(queueName, queueName + " has passed the " + str(threshold * 100) + "% usage")
                    #Checking bind count
                    if queue['bindcount'] == 0 and queue['nummsgsspooled'] > 1000:
                        # Message Box
                        #messagebox.showerror(queueName, queueName + " has 0 binds")
                        print(queueName + " has no binds")
                elif queue['queuename'].find('PTT') != -1 and queue['nummsgsspooled'] != 0:
                    queueUsage = queue['spoolusage']
                    queueName = queue['queuename']
                    if queue['nummsgsspooled'] != 0:
                        # Message Box
                        messagebox.showerror(queueName, queueName + " has messages that might breach SLA")
                else:
                    continue
                    #break
                print(queueName.ljust(55) + str(queueUsage).ljust(10) + str(round(queue['spoolusageinmb'] / queue['quota'] * 100)) + "%")
    #Creating queues plot and waiting some time until next request
    queueObj.plotQ(sleepTime)
    #time.sleep(sleepTime)
    queueObj.clearOld()
    os.system('cls')


    
