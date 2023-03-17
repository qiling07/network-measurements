import pandas as pd
import sys

def update_dict(d, ip, ttl) :
    if ip in d.keys() :
        if ttl < d[ip] :
            d[ip] = ttl
    else :
        d[ip] = ttl

def add_dict(d, ttl, N) :
    if ttl in d.keys() :
        d[ttl] += N
    else :
        d[ttl] = N

def count_response_rate(filename):
    responders = {}
    d_data = pd.read_csv(filename, sep=',')
    d_data = d_data.query("icmp_responder == saddr")
    for i in range(len(d_data)) :
        update_dict(responders, d_data.saddr[i], d_data.origin_ttl[i])
    return responders

def classify_by_ttl(responders) :
    ttls = {}
    for ip, ttl in responders.items() :
        update_dict(ttls, ttl, 1)
    return sorted(ttls.items(), key= lambda item : item[0])

responders = count_response_rate(sys.argv[1])
print("responder count: " + str(len(responders)) + " out of /16")
ttls = classify_by_ttl(responders=responders)
for ttl, cnt in ttls :
    print(ttl, cnt)

