import pandas as pd
import sys


def read_dminer_data(filename):
    d_data = pd.read_csv(filename, sep='\t')
    d_data['probe_dst_addr'] = [i[7:] if len(i) > 7 else '' for i in d_data['probe_dst_addr']]
    d_data['near_addr'] = [i[7:] if len(i) > 7 else '' for i in d_data['near_addr']]
    d_data['far_addr'] = [i[7:] if len(i) > 7 else '' for i in d_data['far_addr']]
    # discard empty link
    d_data = d_data[d_data.near_addr.str.contains('.') & d_data.far_addr.str.contains('.')].reset_index()
    links_dminer = {'\''+d_data.near_addr[i]+'\', \'' + d_data.far_addr[i]+'\', \'' + d_data.near_ttl[i]+'\'' for i in range(len(d_data))}
    return links_dminer

f1 = sys.argv[1]
links_dminer = read_dminer_data(f1)
print(len(links_dminer))
