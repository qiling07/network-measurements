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


basicLinks = set()
extendedLinks = set()

f1 = sys.argv[1]
read_dminer_data(f1, basicLinks, extendedLinks)

f2 = sys.argv[2]
read_dminer_data(f2, basicLinks, extendedLinks)

allLinks = basicLinks.union(extendedLinks)
a = len(basicLinks)
b = len(allLinks)
if b == 0 :
    print("N/A " + f1 + " " + f2)
else :
    print( a, b, int(100*a/b))

f3 = sys.argv[3]
write_links(basicLinks=basicLinks, allLinks=allLinks, filename=f3)
