import pandas as pd
from matplotlib import pyplot as plt
import sys
# data = pd.read_csv('./result_us_222.csv')
# df_chunk = pd.read_csv('./result_us_{}_2.csv'.format(date), chunksize=1000000, iterator = True)
DATA_PATH = sys.argv[3]
# DATA_PATH = 'lq/'
# CON = 'SA/'
# ip_prefix = '177.'
CON = sys.argv[1]
ip_prefix = sys.argv[2]
prefix_len = len(ip_prefix)
for i in range(0, 256, 16):
    prefix_12 = ip_prefix + str(i) + '.0.0_12'
    for j in range(0, 16):
        prefix_16 = ip_prefix + str(i+j)+'.0.0_16'
        zmap_file = [DATA_PATH+CON+prefix_12+'/'+prefix_16+'.zmap',
                     DATA_PATH+CON+prefix_12+'/'+prefix_16+'.zcomplement']
        out_file = [DATA_PATH+CON+prefix_12+'/'+prefix_16+'.zmap.link',
                    DATA_PATH+CON+prefix_12+'/'+prefix_16+'.zcomplement.link']
        for _ in range(2):
            data = pd.read_csv(zmap_file[_])
            l = len(data['saddr'].unique())
            twohop = set()
            links = []
            lens_link = []
            ip_link_map = {}
            ip_ttl_map = {}
            data = data.sort_values(["saddr", 'origin_ttl']).reset_index()
            for k in range(len(data)-1):
                near_dst, far_dst = data.at[k, 'saddr'], data.at[k+1, 'saddr']
                if near_dst[:prefix_len] != ip_prefix or near_dst != far_dst:
                    continue
                near_addr, far_addr = data.at[k,
                                              'icmp_responder'], data.at[k+1, 'icmp_responder']
                near_ttl, far_ttl = data.at[k,
                                            'origin_ttl'], data.at[k+1, 'origin_ttl']
                ip = near_dst
                if (far_ttl-near_ttl <= 1 and far_ttl-near_ttl > 0):
                    if (far_addr != ip and near_addr != far_addr):
                        # if(far_ttl-near_ttl==2):
                        #     twohop.add((near_addr,far_addr))
                        if ip_link_map.get(ip) is None:
                            ip_link_map[ip] = [(near_addr, far_addr)]
                        else:
                            if (near_addr, far_addr) not in ip_link_map[ip]:
                                ip_link_map[ip].append((near_addr, far_addr))
                        if (near_addr, far_addr) not in links:
                            links.append((near_addr, far_addr))
                            if ip_ttl_map.get(ip) is None:
                                ip_ttl_map[ip] = [(near_ttl, far_ttl)]
                            else:
                                ip_ttl_map[ip].append((near_ttl, far_ttl))
                        # print(ip,near_ttl,len(links))
                        # print(ip,near_ttl,len(links))
            lens_link.append(len(links))
            file = open(out_file[_], 'w')
            for k, v in ip_link_map.items():
                file.write(str(k)+' '+str(v)+'\n')
            file.close()
