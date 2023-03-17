import pandas as pd
import sys
from functools import partial

def updateLink(row, basicLinks, extendedLinks):
    key = (row['near_addr'], row['far_addr'])
    if row['probe_src_port'] == "24000" :
        basicLinks.add(key)
    else :
        extendedLinks.add(key)

def read_dminer_data(filename):
    basicLinks = set()
    extendedLinks = set()
    d_data = pd.read_csv(filename, sep='\t')
    d_data['probe_dst_addr'] = [i[7:] if len(i) > 7 else '' for i in d_data['probe_dst_addr']]
    d_data['near_addr'] = [i[7:] if len(i) > 7 else '' for i in d_data['near_addr']]
    d_data['far_addr'] = [i[7:] if len(i) > 7 else '' for i in d_data['far_addr']]
    # discard empty link
    d_data = d_data[d_data.near_addr.str.contains('.') & d_data.far_addr.str.contains('.')].reset_index()
    d_data.apply(partial(updateLink, basicLinks, extendedLinks), axis=1)
    return basicLinks, extendedLinks

f1 = sys.argv[1]
basic_links, extended_links = read_dminer_data(f1)
all_links = basic_links + extended_links

a = len(basic_links)
b = len(all_links)
print( a, b, int(100*a/b))
