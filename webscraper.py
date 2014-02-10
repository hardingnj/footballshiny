#! /usr/bin/python

from bs4 import BeautifulSoup
from cookielib import CookieJar
import re
import time
import urllib2
import codecs

# This page is used to get the web addresses for each league table
stattopage = urllib2.urlopen('http://www.statto.com/football/stats/england/premier-league/2011-2012').read()
# This is the root that is appended to to get full web address
root = 'http://www.statto.com/football/stats/'

# regexes of optgroup
patFinderTables = re.compile('<optgroup label=\"English Premier League\">(.*)</optgroup></select></div>')
patFinderLeagues = re.compile('option value=\"(.*?)\"')
patFinderRows = re.compile('<td .*?<\\tr>');

tables = re.findall(patFinderTables,stattopage)
leagues = re.findall(patFinderLeagues,tables[0])

# how many leagues have we found?
print "found ", len(leagues), " attempting to read..."

# hash for league data
league_data = {}

# loop thru each league
cj = CookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
for i in leagues:

    # Paste together the URL
    url = root + i + '/table'
    print url
    # Create an opener with the correct cookies set (OBSOLETED BY USE OF COOKIE JAR)
    # COOOKIIIEEE JARRRR COOOKIIEEEE JARRR
    #opener = urllib2.build_opener();
    #opener.addheaders.append(('Cookie', 'options=DD0505030'));
    #opener.addheaders.append(('Cookie', 'uid=3be22f9e2012-10-29CA44760b17058fd4e5c393d03ad7798146'));
    #opener.addheaders.append(('Cookie', '__utma=144434807.1069062572.1351552161.1351552161.1351552161.1'));
    #opener.addheaders.append(('Cookie', '__utmb=144434807.8.10.1351552161'));
    #opener.addheaders.append(('Cookie', '__utmc=144434807'));
    #opener.addheaders.append(('Cookie', '__utmz=144434807.1351552161.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)'));
    tabpage = opener.open(url).read()

    # # Print out the gotten webpage (Test code, feel free to mung until no good
    # pageout = open('./'+ str(j) + '.html','w');
    # pageout.write(tabpage);

    # Parse it with BeautifulSoup
    mysoup = BeautifulSoup(tabpage)
    rows = mysoup.findAll("tr", {'class': ['c0', 'c1']})
    dat = []
    # loop through each row, and append to dat array
    for row in rows:
        line = []
        cols = row.find_all('td',text=True)
        for td in cols:
            text=str(td.find(text=True))
            line.append(text)
        dat.append(line)
    print "Champions were: ", dat[0]
    league_data[i] = dat
    # sleep- otherwise we get in trouble with web servers.
    time.sleep( 2 )
