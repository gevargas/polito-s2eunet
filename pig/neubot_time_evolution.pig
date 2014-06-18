REGISTER piggybank-0.3-amzn.jar;

DEFINE FORMAT_DT org.apache.pig.piggybank.evaluation.datetime.FORMAT_DT();
DEFINE DATE_TIME    org.apache.pig.piggybank.evaluation.datetime.DATE_TIME();



--NeubotTests = LOAD 'data_csv4_to_20140528.speedtest.csv' using PigStorage(';') as (
A = LOAD 'data_csv4_20140528.speedtest.csv' using PigStorage(';') as (
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

grp_Asnum_YMD = GROUP A BY (asnum, FORMAT_DT('yyyyMMdd', DATE_TIME(timestamp*1000)));
grp_Asnum_YMD_AvgDownloadSpeed = FOREACH @ GENERATE 
	group.asnum as asnum, 
	ToUnixTime(ToDate(group.$1,'yyyyMMdd')) as date,
	AVG(A.download_speed) as avg,
	COUNT(A.download_speed) as cnt;
grp_Asnum_YMD_AvgDownloadSpeed = ORDER @ BY cnt DESC;

rmf grp_Asnum_YMD_AvgDownloadSpeed
STORE grp_Asnum_YMD_AvgDownloadSpeed INTO 'grp_Asnum_YMD_AvgDownloadSpeed' using PigStorage(';');

grp_Asnum_YMD_AvgDownloadSpeed = LIMIT grp_Asnum_YMD_AvgDownloadSpeed 10;
DUMP @;
DUMP @;
