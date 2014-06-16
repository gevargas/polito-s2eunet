
NeubotTests = LOAD 'csv1' using PigStorage(';') as (
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


/* Get only asymmetric connections where download_speed is higher than upload_speed */
SpeedTestsAsym = FILTER NeubotTests BY ( download_speed > upload_speed );


/* Group tests by MLAB server locations
   mlabservername is a string as "mlab03-trn02", where location is "trn"
*/
SpeedTestAsym_By_ClientAddress = GROUP SpeedTestsAsym BY (client_address, SUBSTRING(mlabservername,7,10));

/* Get only the client_address that made the tests ALWAYS with maybe different servers, but all in the same location */
ClientsGood = FOREACH SpeedTestAsym_By_ClientAddress GENERATE group, COUNT(SpeedTestsAsym) as tests_per_client_per_mlablocation;
ClientsGood = FILTER ClientsGood BY (tests_per_client_per_mlablocation == 1);
--DESCRIBE ClientsGood;

/* TODO: Now I would like to get only the SpeedTestsAsym where the client_address is in the ClientsGood ?!?
         IDEA: use FLATTEN ?
*/
C = FOREACH ClientsGood GENERATE group.client_address as client_address;
R = JOIN C BY client_address, SpeedTestsAsym BY client_address;

SpeedTestsAsymGoodClients = FOREACH R GENERATE C::client_address as a, SpeedTestsAsym::client_address as b, SpeedTestsAsym::uuid;
DUMP SpeedTestsAsymGoodClients;


