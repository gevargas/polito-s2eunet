
--A = LOAD 'data_csv4_20140528.speedtest.csv' using PigStorage(';') as (
A = LOAD 'data_csv4_to_20140528.speedtest.csv' using PigStorage(';') as (
	client_address: chararray, 
	client_country: chararray,
	lon: float,
	lat: float,
	client_provider: chararray,
	mlabservername:  chararray,
	connect_time:    float,
	download_speed:  float,
	neubot_version:  float,
	platform:        chararray,
	remote_address:  chararray,
	test_name:       chararray,
	timestamp:       long,
	upload_speed:    float,
	latency:  float,
	uuid:     chararray,
	asnum:    chararray,
	region:   chararray,
	city:     chararray,
	hour:     int,
	month:    int,
	year:     int,
	weekday:  int,
	day:      int,
	filedate: chararray
);

Connections = FOREACH A GENERATE timestamp, client_address, mlabservername;

/* Count the number of tests (tests_cnt) for each couple (client_address, mlabserver_location) */
/* mlabserver_location is just the location in the mlabservername (e.g., mlab01-trn02 => trn */
Connections_grp = GROUP Connections BY (client_address, SUBSTRING(mlabservername,7,10));
Connections_grp_cnt = FOREACH Connections_grp GENERATE group, COUNT(Connections) as tests_cnt;


/* For each client_address, get the couple (client_address, mlabserver_location) with the maximum number of tests */
Connections_grp_cnt_grp = GROUP Connections_grp_cnt BY group.client_address;
GoodConnections_max = FOREACH Connections_grp_cnt_grp {
	SA = ORDER Connections_grp_cnt BY tests_cnt DESC;
	SB = LIMIT SA 1;
	GENERATE FLATTEN(SB.group);
}

/* Use JOIN to filter from the original set (A), only one "connection" per client_address */
GoodConnections = JOIN GoodConnections_max BY (group.$0, group.$1), A BY (client_address, SUBSTRING(mlabservername,7,10));
GoodConnections = FOREACH GoodConnections GENERATE $1 ..;

rmf good_connections
STORE GoodConnections INTO 'good_connections' using PigStorage(';');
