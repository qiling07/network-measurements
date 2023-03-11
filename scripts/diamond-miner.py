import sys
import logging
from pathlib import Path
from uuid import uuid4

from pycaracal import prober
from pych_client import ClickHouseClient

from diamond_miner.generators import probe_generator_parallel
from diamond_miner.insert import insert_mda_probe_counts, insert_probe_counts
from diamond_miner.queries import (
    CreateTables,
    GetLinks,
    InsertLinks,
    InsertPrefixes,
    InsertResults,
)

# Configuration
credentials = {
    "base_url": "http://localhost:8123",
    "database": "default",
    "username": "default",
    "password": "",
}
measurement_id = str(uuid4())
probes_filepath = Path("probes.csv.zst")
results_filepath = Path("results.csv")

target_prefix = sys.argv[1]
rate = int(sys.argv[2])
outFileName = sys.argv[3]

# ICMP traceroute towards every /24 in 1.0.0.0/22 starting with 6 flows per prefix between TTLs 2-32
prefixes = [(target_prefix, "udp", range(1, 33), 6)]
def save_file(file_name,content):
    with open(file_name,'w', encoding='utf-8') as f:
        f.write('probe_dst_addr\tprobe_src_port\tnear_ttl\tfar_ttl\tnear_addr\tfar_addr\n')
        f.write(content)

if __name__ == "__main__":
    logging.basicConfig(level=logging.WARNING)
    with ClickHouseClient(**credentials) as client:
        CreateTables().execute(client, measurement_id)
        for round_ in range(1, 10):
            logging.info("round=%s", round_)
            if round_ == 1:
                # Compute the initial probes
                insert_probe_counts(
                    client=client,
                    measurement_id=measurement_id,
                    round_=1,
                    prefixes=prefixes,
                )
            else:
                # Insert results from the previous round
                InsertResults().execute(
                    client, measurement_id, data=results_filepath.read_bytes()
                )
                InsertPrefixes().execute(client, measurement_id)
                InsertLinks().execute(client, measurement_id)
                # Compute subsequent probes
                insert_mda_probe_counts(
                    client=client,
                    measurement_id=measurement_id,
                    previous_round=round_ - 1,
                )

            # Write the probes to a file
            n_probes = probe_generator_parallel(
                filepath=probes_filepath,
                client=client,
                measurement_id=measurement_id,
                round_=round_,
            )
            logging.info("n_probes=%s", n_probes)
            if n_probes == 0:
                break

            # Send the probes
            config = prober.Config()
            config.set_output_file_csv(str(results_filepath))
            config.set_probing_rate(rate)
            config.set_sniffer_wait_time(1)
            prober.probe(config, str(probes_filepath))

        links = GetLinks().execute(client, measurement_id)
        links_client = client.text('select distinct probe_dst_addr,probe_src_port,near_ttl,far_ttl, \
                                    near_addr,far_addr from links__{} order by probe_dst_addr'.format(measurement_id).replace("-", "_"))
        save_file(outFileName,links_client)
        print(f"{len(links)} links discovered")
