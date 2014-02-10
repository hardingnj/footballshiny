#! /usr/bin/python

from bs4 import BeautifulSoup
from cookielib import CookieJar
import re
import time
import urllib2
import codecs
import yaml

# This page is used to get the web addresses for each league table
#stattopage = urllib2.urlopen('http://www.statto.com/football/stats/england/premier-league/2011-2012').read()
stattopage = urllib2.urlopen('http://www.statto.com/football/stats/france/ligue-1/2011-2012').read()
outfile = 'france_data.yaml'

# This is the root that is appended to to get full web address
root = 'http://www.statto.com/football/stats/'

# regexes of optgroup
#patFinderTables = re.compile('<optgroup label=\"English Premier League\">(.*)</optgroup></select></div>')
patFinderTables = re.compile('<optgroup label=\"French Ligue 1\">(.*)</optgroup></select></div>')
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
	
    year = re.search( r'-(\d+)$', i).group(1)
    print i, year
    # Paste together the URL
    url = root + i + '/table'
    print url
    tabpage = opener.open(url).read()

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
    league_data[year] = dat
    # sleep- otherwise we get in trouble with web servers.
    time.sleep( 2 )
 
stream = file(outfile, 'w')
yaml.dump(league_data, stream)

