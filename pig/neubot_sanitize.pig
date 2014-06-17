
--NeubotTests = LOAD 'data.csv' using PigStorage(';') as (
NeubotTests = LOAD 'data_csv4_to_20140528.speedtest.csv' using PigStorage(';') as (
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


/* 
   Group tests by MLAB server locations
   mlabservername is a string as "mlab03-trn02", where location is "trn"
*/
SpeedTestAsym_By_ClientAddress = GROUP SpeedTestsAsym BY (client_address, SUBSTRING(mlabservername,7,10));
SpeedTestAsym_By_Mlablocation = GROUP SpeedTestAsym_By_ClientAddress BY group.client_address;

/* Count how many MLAB server locations a given client_address run tests with */
CountMlabLocations = FOREACH SpeedTestAsym_By_Mlablocation GENERATE group, COUNT($1) as tests_per_client_per_mlablocation, $1;


/* Filter only whose that performed tests with one and only one location */
ClientsGood = FILTER CountMlabLocations BY (tests_per_client_per_mlablocation == 1);

/* Flatten: go back to the original tuples */
ClientsGood = FOREACH ClientsGood GENERATE FLATTEN($2);
ClientsGood = FOREACH ClientsGood GENERATE FLATTEN($1);

/* Now you only have tubles from tests by the good clients !! */
STORE ClientsGood INTO 'clientsgood' USING PigStorage (';');

-- DUMP ClientsGood;

/* TODO: Now I would like to get only the SpeedTestsAsym where the client_address is in the ClientsGood ?!?  
         IDEA: use FLATTEN ?
*/
/*
C = FOREACH ClientsGood GENERATE group.client_address;
SpeedTestsAsymGoodClients = FILTER SpeedTestsAsym BY ( client_address IS IN C);
DUMP SpeedTestsAsymGoodClients;
*/

