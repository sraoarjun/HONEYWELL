CREATE FUNCTION udf_GetHoursAndMinutes (
    @purge_job_start_time datetime,@purge_duration varchar(50)
)
RETURNS Datetime
AS
begin
declare @num_hours int  
declare @num_minutes int
declare @dt datetime 

SET @num_hours =  REVERSE(PARSENAME(REPLACE(REVERSE(@purge_duration), ':', '.'), 1)) 
SET @num_minutes = REVERSE(PARSENAME(REPLACE(REVERSE(@purge_duration), ':', '.'), 2)) 

SET @dt = dateadd(MINUTE,@num_minutes, dateadd(HOUR, @num_hours, @purge_job_start_time)) 
RETURN @dt
END