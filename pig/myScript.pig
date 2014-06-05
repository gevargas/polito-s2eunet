
NeubotTests = LOAD 'csv' using PigStorage(';') as (
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

SpeedTests = FILTER NeubotTests BY (test_name matches '.*speedtest.*');
SpeedTestsInMexico = FILTER SpeedTests BY (client_country matches '.*MX.*');

SpeedsInMexico = FOREACH SpeedTestsInMexico GENERATE
    uuid,
    upload_speed,
    download_speed,
    latency,
    client_provider
;

SpeedsInMexicoGroupedByUser = GROUP SpeedsInMexico BY uuid;
UsersInMexico = FOREACH SpeedsInMexicoGroupedByUser GENERATE group;
C = DISTINCT UsersInMexico;
DUMP C;
