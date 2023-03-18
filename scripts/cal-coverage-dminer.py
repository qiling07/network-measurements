import pandas as pd
import sys
from functools import partial

def updateLink(row, basicLinks, extendedLinks):
    key = (row['near_addr'], row['far_addr'])
    if int(row['probe_src_port']) == 24000 :
        basicLinks.add(key)
    else :
        extendedLinks.add(key)

def read_dminer_data(filename, basicLinks, extendedLinks):
    d_data = pd.read_csv(filename, sep='\t')
    d_data['probe_dst_addr'] = [i[7:] if len(i) > 7 else '' for i in d_data['probe_dst_addr']]
    d_data['near_addr'] = [i[7:] if len(i) > 7 else '' for i in d_data['near_addr']]
    d_data['far_addr'] = [i[7:] if len(i) > 7 else '' for i in d_data['far_addr']]

    if d_data.shape[0] == 0 :
        return basicLinks, extendedLinks

    # discard empty link
    d_data = d_data[d_data.near_addr.str.contains('.') & d_data.far_addr.str.contains('.')].reset_index()
    d_data.apply(partial(updateLink, basicLinks=basicLinks, extendedLinks=extendedLinks), axis=1)
    return basicLinks, extendedLinks

def write_links(basicLinks, allLinks, filename) :
    f = open(filename, 'w')
    f.write("basicLinks ")
    for a, b in basicLinks :
        f.write(a + "_" + b + " ")
    f.write("\n")

    f.write("allLinks ")
    for a, b in allLinks :
        f.write(a + "_" + b + " ")
    f.write("\n")
    f.close()


basicLinks1 = set()
extendedLinks1 = set()
f1 = sys.argv[1]
read_dminer_data(f1, basicLinks1, extendedLinks1)

basicLinks2 = set()
extendedLinks2 = set()
f2 = sys.argv[2]
read_dminer_data(f2, basicLinks2, extendedLinks2)

allLinks1 = basicLinks1.union(extendedLinks1)
allLinks2 = basicLinks2.union(extendedLinks2)
allLinks = allLinks1.union(allLinks2)

if not (len(allLinks1) < 0.7 * len(allLinks) or len(allLinks2) < 0.7 * len(allLinks)) :
    basicLinks = basicLinks1.union(basicLinks2)

    f3 = sys.argv[3]
    write_links(basicLinks=basicLinks1, allLinks=allLinks1, filename=f3)
